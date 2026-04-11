---
name: deep-review
description: 現在のブランチ(または指定ブランチ / PR)の変更を、high-signal チェックリスト駆動で多角的にコードレビューする。利用可能な AI エンジン(codex / gemini / grok CLI)とサブエージェントに並列ディスパッチし、各 finding を敵対的に再検証してから報告する。実装後・PR 作成前、または「レビューして」「品質を確認して」と指示されたときに使う。検出した Critical/High は最小 diff の fix を提示する(適用は呼び出し側)。
allowed-tools: Bash, Read, Grep, Glob, Agent
---

# コードレビュースキル(deep-review)

`$ARGUMENTS`(指定ブランチ / PR 番号。無ければ現在のブランチ)の変更を、inline レビュアーの鋭さでレビューする。

> **深さ優先**: このスキルはトークン消費より検出漏れゼロを優先する。サブエージェントは出し惜しみせず並列起動し、finding が出なくなるまでラウンドを重ねる。省略・サンプリングをする場合は必ず報告に明記する(silent truncation 禁止)。

> **位置づけ**: このスキルは**検出**(バグ・脆弱性・仕様不一致を見つけ、Critical/High に最小 diff の修正案を提示する。書き換え自体は呼び出し側)。書き換えによる品質磨きは `/simplify` などの領分。レビューで「もっと綺麗に」は出さない。

## すべての finding が超える基準(最初に読む)

報告する finding は全て [refs/finding-bar.md](refs/finding-bar.md) の 4 ゲート(**located** `file:line` / **fixable** 最小 diff / **confident** high・medium のみ / **material** 正しさ・セキュリティ・データ・仕様・明示規約)を超えること。**少数精鋭** — 行に紐付いた 10 件は一般論 40 件に勝る。

## レビューの背骨

このレビューの**背骨**は [refs/high-signal-checklist.md](refs/high-signal-checklist.md)。自動 PR レビュアー(Copilot 等)が頻繁に指摘し、汎用プロンプトが取りこぼす具体カテゴリ(仕様↔コード不一致・enum ハードコード・移行の残置物・nil・時刻境界・get-or-insert race・index 欠落・XSS・弱いアサーション・メッセージ↔ロジックドリフト・自動生成ファイル手編集)。diff を全カテゴリに当てるのが**主**の仕事(Phase 3.b)。

下表の観点は**二次レンズ**(取りこぼし防止の網)。レンズ由来の finding も finding-bar を超えること。

| 観点 | 詳細 |
|------|------|
| Architecture | パターン適切性・SOLID・既存アーキテクチャとの整合 |
| Quality | 可読性・保守性・重複・複雑度 |
| Security | OWASP Top 10・入力検証・認証・認可 |
| Testing | カバレッジ欠落・正常/異常/edge/boundary の十分性 |
| Performance | 非効率なデータ取得・N+1・無駄な計算・計算量 |
| Conventions | CLAUDE.md / AGENTS.md / `.claude/rules/` 準拠 |
| Consistency | PR 概要 / コミット / Issue ↔ 実 diff(主張スコープ・定義・DB 影響・振る舞いが全部コードと一致するか) |

## Phase 1: 変更収集

### base ブランチ検出

origin の祖先ブランチを自動検出する。検出不能なら `origin/main` → `origin/master` → ローカル `main` / `master` の順にフォールバック。

```bash
CUR="$(git branch --show-current)"
BASE_REF="$(
  git for-each-ref --format='%(refname:short)' refs/remotes/origin/ \
    | grep -v '^origin/HEAD$' \
    | grep -v "^origin/${CUR}$" \
    | while read -r b; do
        git merge-base --is-ancestor "$b" HEAD 2>/dev/null || continue
        n="$(git rev-list --count "$b..HEAD")"
        [ "$n" -gt 0 ] && echo "$n $b"
      done \
    | sort -n | head -1 | awk '{print $2}'
)"
if [ -z "$BASE_REF" ]; then
  for c in origin/main origin/master main master; do
    git rev-parse --verify "$c" >/dev/null 2>&1 && { BASE_REF="$c"; break; }
  done
fi
echo "BASE_REF=${BASE_REF:-(検出不能 — ユーザーに base を確認すること)}"
```

> **自己ブランチを除外する理由**: 現在のブランチが push 済みだと `origin/<current>..HEAD` の commit 数が 0 になり、最小値として必ず選ばれてしまう。その結果 diff が空になり「変更なし = 問題なし」と誤って報告する。`grep -v "^origin/${CUR}$"` と `[ "$n" -gt 0 ]` の 2 段でこれを防いでいる。
>
> **`$BASE_REF` は次の Bash 呼び出しに引き継がれない**。Claude Code は呼び出しごとに新しいシェルを起動するため、シェル変数は消える。**上の出力で得た実際の値(例 `origin/main`)を、以降のコマンドに文字列として直接埋め込むこと。** 以下の例中の `$BASE_REF` はプレースホルダであり、そのまま実行してはいけない。

### 変更情報の取得

```bash
git branch --show-current
git diff "$BASE_REF...HEAD" --stat
git diff "$BASE_REF...HEAD"
git status --porcelain
git log --oneline "$BASE_REF..HEAD"
```

**intent(Consistency 観点に必須)**: 主張をコードと突き合わせるため intent を取得する。

```bash
gh pr view --json title,body 2>/dev/null   # PR があれば
```

PR が無ければ commit log を intent 源にする。ブランチ名 / commit にイシュートラッカーの ID があり、取得手段(`gh issue view`、MCP ツール等)が利用可能なら本文・完了条件も取得する。

**diff スコープ**: 基本は base ブランチとの diff(`$BASE_REF...HEAD`)。広すぎると分析が浅くなり、狭すぎるとクロスファイルの問題を見逃す。`--stat` が 1000 行超 / 30 ファイル超なら、全部見るか特定ディレクトリに絞るかをユーザーに確認する。

**PR レビュー時の worktree 分離(任意)**: 作業中のブランチを汚さず他人の PR をレビューする場合は worktree を切る。

```bash
git worktree add ./.review-<PR番号> origin/<ブランチ>   # 終了後: git worktree remove ./.review-<PR番号>
```

### 影響範囲の事前調査(必須)

**変更ファイルだけを見てレビューを始めない。** diff の外側に波及先がないかを先に調査する:

- 変更したクラス / 関数 / 定数の**呼び出し元**(grep で全参照を洗う)
- 変更した DB カラム / スキーマを参照する**他のクエリ・scope**
- 変更した API エンドポイント / 型を利用する**フロントエンド・他サービス**
- 変更によって**壊れる可能性のある既存テスト**

ここで見つかった「diff 外の壊れる箇所」は最優先の finding 候補(呼び出し元の未修正は High 以上)。

### レビュー文脈の準備

レビュー前にプロジェクトの規約を読む: リポジトリの `CLAUDE.md`・`AGENTS.md`・`.claude/rules/`(存在するもののみ)。**変更パスに応じて動的に選択する** — 変更に関係しないルールを混ぜるとノイズになる(例: Rails 変更なら rails 系ルールのみ、frontend 変更なら frontend 系のみ)。AI エンジンに渡す文脈を用意: diff / file_list / commit_log / intent / conventions。

## Phase 2: 並列レビュー(補助エンジン)

利用可能な補助エンジンを**並列**でディスパッチする。各エンジンに finding-bar の 4 ゲートを prompt に埋め込み、`file:line` + 最小 fix + confidence を要求する。位置の無い散文しか返さないエンジンの出力は破棄する(noise)。

- **サブエージェント panel**(`Agent` ツール、常に全員を並列起動): 観点ごとに 1 体ずつ、**最低でも以下の 6 レンズ**を起動する — ① correctness(ロジック・境界・nil)/ ② security(OWASP・入力検証・認可)/ ③ テスト網羅・アサーション厳密性 / ④ エラーハンドリング・並行性・冪等性 / ⑤ パフォーマンス(N+1・index・計算量)/ ⑥ 規約・仕様↔実装整合。各エージェントには diff・intent・規約・finding-bar・チェックリストの該当カテゴリを丸ごと渡す。変更が大きい場合はさらに**ファイル群ごと**に担当を分割してよい(観点 × 領域のマトリクス)。
- **codex CLI**(あれば): 第二の視点として実装レビュー。

  ```bash
  codex exec --skip-git-repo-check --sandbox read-only "以下の diff をレビュー。file:line + 最小 fix + confidence(high/medium)必須。style 指摘禁止。<diff / intent / conventions>"
  ```

- **gemini CLI**(あれば): quality & security 観点。

  ```bash
  git diff "$BASE_REF...HEAD" | gemini --skip-trust -p "この diff をレビュー。file:line + 最小 fix + confidence 必須。style 指摘禁止。"
  ```

- **grok CLI**(あれば): 第三の視点として実装レビュー。公式 Grok Build CLI(`xai-org/grok-build`)を read-only で起動し、リポジトリを自分で探索させる(公式 Claude Code プラグイン `grok-build-plugin-cc` の review と同じ起動形)。認証は `grok login` 済みセッションか `XAI_API_KEY`(zshrc の load-api-keys が Keychain から読み込む)。未認証・未導入なら warning を残して skip。

  ```bash
  grok -p "この作業ディレクトリの $BASE_REF...HEAD の diff をレビュー。file:line + 最小 fix + confidence(high/medium)必須。style 指摘禁止。<intent / conventions>" \
    --agent explore --permission-mode plan --sandbox review --output-format plain --no-auto-update
  ```

  `review` は ~/.grok/sandbox.toml のカスタムプロファイル(read-only 相当。組み込み read-only は macOS + Docker Desktop で docker.sock の symlink により起動拒否になるため、no-op の restrict_network だけ外したもの)。プロファイルが無い環境では `--sandbox read-only`、それも起動拒否なら `--sandbox workspace` にフォールバックする(--permission-mode plan は維持)。api.x.ai / auth.x.ai がサンドボックスの許可ホストに無い環境では接続に失敗する — その場合はサンドボックス外実行の承認を求めるか、skip して報告に明記する。

**出力フォーマット(共通)**: File(path:line)/ Severity(Critical/High/Medium)/ Category / Finding(何が間違いか)/ Fix(最小 diff)/ Confidence。

**一部のエンジンが失敗 / 未導入の場合**: 該当エンジンだけ warning を残して skip し、残りエンジン + Phase 3 で続行する(1 個の失敗で Phase 2 全体を中断しない)。全て無い / 全滅した場合は Phase 2 を飛ばし、Phase 3 で Claude が全観点をカバーする。

## Phase 3: Claude 統合レビュー

### a. Phase 2 結果の統合

finding-bar を超えるものだけ取り込む。複数エンジンが指摘 → 優先度を上げる。食い違い → Claude 自身の判断を理由付きで示す。Phase 2 が触れていない観点は直接レビューする。

### b. Claude 自身のレビュー — チェックリスト駆動(中核パス)

これが主パス。Phase 2 の有無に関わらず行う。

1. **仕様 ↔ 実装テーブル(カテゴリ A)**: intent の各事実主張を、それを証明 / 反証する行に紐付ける。report-template の `Claim | file:line | VERIFIED / MISMATCH` テーブルを**最初に**出す。誤った振る舞いを出荷する MISMATCH は Critical。
2. **全カテゴリ走査**: [refs/high-signal-checklist.md](refs/high-signal-checklist.md) のカテゴリ B〜I を順に diff へ当てる。流し読みしない。各カテゴリは located な finding を出すか「clear」と書く。
3. **二次レンズ**: 上表の観点でチェックリストが拾わなかったもの(architecture fit・統合リスク・規約準拠)を sweep。同じ基準。
4. **loop-until-dry**: Phase 2 + 3 で見つかった finding を既知リストに積み、**新規 finding が 2 ラウンド連続でゼロになるまで**追加の finder ラウンドを回す(前ラウンドの既知リストを渡し「これ以外を探せ」と指示)。1 回で打ち切らない — 検出漏れの尾は 2 巡目以降に出る。

### b'. 二段階サイクル(列挙 → 推敲)

AI は「言いたいことを全部言う」傾向がある。Phase 2〜3.b は**第 1 段(列挙)** — 重要度を問わずすべて集める。報告前に必ず**第 2 段(推敲)**を独立に行う: 集めた候補を 1 件ずつ finding-bar の 4 ゲートに当て直し、本当に必要なものだけ残して重要度を付け直す。落とした候補は捨てずに「対象外とした指摘」として記録する(report-template 参照)。

### c. 敵対的 verify(報告前の検証規律)

**報告前に、各 Critical / High finding を独立に反証させる。** エンジン / Claude の finding を鵜呑みにしない。finding ごとに **skeptic を 3 体**、それぞれ別レンズ(correctness / security / 再現可能性)で並列起動する(`Agent` ツール、`general-purpose`)。prompt は「これを**反証**せよ。誤検知なら理由を、本物なら再現条件を述べよ。確信が持てなければ refuted=true に倒せ」。

- **過半数(2/3 以上)が反証した finding は落とす**(report に出さない)。Medium は skeptic 1 体でよい。
- 残った finding だけを Critical → High → Medium で報告する。

これにより「もっともらしいが誤り」の finding が PR コメントに残るのを防ぐ。

### d. 品質ゲート(プロジェクトのコマンド)

プロジェクトの既存コマンドを特定して実行する。優先順: ① CLAUDE.md / AGENTS.md に記載のコマンド → ② `Taskfile.yml` / `Makefile` / `package.json scripts` の lint・test タスク → ③ 特定できなければ skip して報告に「未実行」と書く。

- テストは変更に関連する範囲に絞って実行する(フル実行はユーザーに確認)。
- lint / type check の FAIL は該当行を finding として位置特定する。

## 出力

[refs/report-template.md](refs/report-template.md) に従って報告する。会話に直接出力し、ユーザー指示が無い限りファイルは作らない。仕様↔実装テーブルを finding の前に必ず出す。「一般的な提案」「留意点」セクションは作らない(行が無いものは finding ではない)。

### Severity

- **Critical**: マージ前に必ず修正(セキュリティ・データ損失・破壊的変更・誤った振る舞いを出荷する仕様 mismatch)
- **High**: マージ前に修正すべき(バグ・規約違反・filter/sort カラムの index 欠落・壊れていても pass する弱いテスト)
- **Medium**: 直す価値あり + 具体 fix あり(保守性・非ブロッキングなチェックリストヒット)。Medium 未満は downgrade でなく **drop**。

## レビュー後アクション

このスキルは**検出・提示まで**(コードは書き換えない)。Critical / High が存在する場合、各 finding に最小 diff の fix を提示し、呼び出し側が適用する:

1. 全 Critical → 全 High の順に fix を適用 → 2. 品質ゲート再実行で検証 → 3. `/deep-review` を再実行して解消を確認。

**Critical / High が 0 になるまで「レビュー通過」としない。**

## 自己改善ループ

レビュー完了時に以下に該当するものがあれば、報告の末尾で**チェックリスト / 規約への還元を提案**する(勝手に書き換えない):

- 同種の指摘が 2 回以上出た → [refs/high-signal-checklist.md](refs/high-signal-checklist.md) への新カテゴリ / 項目追加を提案
- プロジェクト固有の暗黙ルールを発見した → そのリポジトリの `CLAUDE.md` / `.claude/rules/` への明文化を提案
- 誤検知が多かった観点 → チェックリスト項目の絞り込みを提案
