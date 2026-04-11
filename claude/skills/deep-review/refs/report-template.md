# コードレビュー報告テンプレート

finding を先頭に、行に紐付けて出す。散文は最小限。すべての finding は located・fixable・material であること([finding-bar.md](finding-bar.md))。「一般的な所見」セクションは作らない。

## サマリ

- **Branch**: {branch_name}
- **変更ファイル数**: {file_count}
- **使った AI エンジン**: {engines_used}(例: codex / gemini / Claude のみ)
- **Verdict**: APPROVE / REQUEST_CHANGES
- **Findings**: {critical} Critical · {high} High · {medium} Medium

## 仕様 ↔ 実装

intent(PR 概要 / コミットメッセージ / 紐づく Issue)の事実主張 1 つにつき 1 行。誤った振る舞いを出荷する MISMATCH が 1 つでもあれば Critical。

| 主張 (Claim) | 根拠 (file:line) | VERIFIED / MISMATCH |
|-------------|------------------|---------------------|
| {claim} | {path}:{line} | {result} |

## Findings

Critical → High → Medium、その中はファイル順。1 finding = 1 ブロック。Medium 未満は報告しない。

### [Critical] {path}:{line} — {一行で問題} · {category} · confidence: {high|medium}

**なぜ間違いか:** {具体的に 1〜2 文 — 何が、どの入力 / タイミングで壊れるか}。

```diff
- {問題の行}
+ {最小の fix}
```

> 各 finding についてこのブロックを繰り返す。安全な一行 fix が無い設計レベルの問題は、diff の代わりに **最小の次の一手:** {具体的アクション} を書き、なぜ patch を出さないかを述べる。

## 対象外とした指摘(False Positive 分析)

検討したが報告しないと判断した候補を表で出す(推敲・敵対的 verify で落としたもの)。「指摘漏れ」ではなく「精査の結果」であることを示し、レビューの信頼性を上げる。無ければ「なし」。

| 検討した指摘 | 対象外とした理由 |
|-------------|----------------|
| {candidate} | {reason(反証内容 / ゲート不通過の種別)} |

## 品質ゲート

プロジェクトで特定できたコマンドのみ。特定できなければ「未実行(コマンド不明)」と書く。

- **test**: PASS / FAIL / 未実行 — {実行したコマンド}(変更に関連する範囲のみ)
- **lint / type check**: PASS / FAIL / 未実行 — {実行したコマンド}

## アクションアイテム

- [ ] {Critical / High の各項目。上の finding にリンク}
