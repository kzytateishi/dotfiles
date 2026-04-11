# 公式情報の当て先（地図）

**このファイルは URL しか持たない。** モデル名・価格・コンテキスト長・制限値は一切書かない。値は毎回 WebFetch して、その場で読む。

## 使い方

1. 知りたいことに対応する行を下表から選ぶ
2. **WebFetch する**（複数社を比べるなら並列で）
3. 回答には **URL と取得日**を必ず添える

> **検証日の意味**: 「その日にこの URL を WebFetch して中身が取れた」という記録でしかない。**中身が今も同じである保証はない。** 検証日が古いほど、リンク切れとページ改編の両方を疑う。
>
> **URL 自体が引っ越す領域である。** 下の「移転の実績」に、実際に踏んだリダイレクトを記録してある。同じことがまた起きる前提で扱う。

---

## Anthropic（Claude）

| 知りたいこと | URL | 検証日 |
|---|---|---|
| モデル一覧・スペック比較（起点） | https://platform.claude.com/docs/en/about-claude/models/overview | 2026-07-27 |
| どのモデルを選ぶかの公式ガイド | https://platform.claude.com/docs/en/about-claude/models/choosing-a-model | 2026-07-27 |
| 料金（キャッシュ・バッチ・ツール込み） | https://platform.claude.com/docs/en/about-claude/pricing | 2026-07-27 |
| 非推奨・廃止予定と移行先 | https://platform.claude.com/docs/en/about-claude/model-deprecations | 2026-07-27 |
| レート制限 | https://platform.claude.com/docs/en/api/rate-limits | 2026-07-27 |
| API のリリースノート | https://platform.claude.com/docs/en/release-notes/overview | 2026-07-27 |
| 新モデル発表の一次情報 | https://www.anthropic.com/news | 2026-07-27 |
| プロダクト側のブログ | https://claude.com/blog | 2026-07-27 |
| 実装寄りの技術記事 | https://www.anthropic.com/engineering | 2026-07-27 |
| Claude アプリ側の更新履歴 | https://support.claude.com/en/articles/12138966-release-notes | 2026-07-27 |

### Claude Code

| 知りたいこと | URL | 検証日 |
|---|---|---|
| ドキュメント起点 | https://code.claude.com/docs/en/overview | 2026-07-27 |
| どのモデル・エイリアスを指定できるか | https://code.claude.com/docs/en/model-config | 2026-07-27 |
| **全ドキュメントページの索引** | https://code.claude.com/docs/llms.txt | 2026-07-27 |
| CLI 本体の changelog | https://github.com/anthropics/claude-code/blob/main/CHANGELOG.md | 2026-07-27 |

> **`llms.txt` が最短経路。** Claude Code のドキュメントで個別ページの場所が分からないときは、URL を推測するより `llms.txt` を 1 回 WebFetch して目的のページを引く方が速く、外れない。

---

## OpenAI（GPT / Codex）

| 知りたいこと | URL | 検証日 |
|---|---|---|
| モデル一覧（起点） | https://developers.openai.com/api/docs/models | 2026-07-27 |
| モデルを横並びで比較 | https://developers.openai.com/api/docs/models/compare | 2026-07-27 |
| 料金（処理方式別に分かれている） | https://developers.openai.com/api/docs/pricing | 2026-07-27 |
| API の changelog | https://developers.openai.com/api/docs/changelog | 2026-07-27 |
| 廃止予定と代替 | https://developers.openai.com/api/docs/deprecations | 2026-07-27 |

### Codex CLI

| 知りたいこと | URL | 検証日 |
|---|---|---|
| Codex ドキュメント起点 | https://learn.chatgpt.com/docs | 2026-07-27 |
| CLI の使い方・オプション | https://learn.chatgpt.com/docs/codex/cli | 2026-07-27 |
| Codex 全体の changelog（デスクトップ / CLI / モバイル） | https://learn.chatgpt.com/docs/changelog | 2026-07-27 |
| 実装・issue | https://github.com/openai/codex | 2026-07-27 |

> **料金ページは「同じモデルに複数の単価」が並ぶ構造。** 処理方式（標準 / バッチ / それ以外の優先度クラス）で単価が違うので、**どの行を読んだかまで書く。** 1 モデル = 1 価格だと思って読むと間違える。

---

## Google（Gemini）

| 知りたいこと | URL | 検証日 |
|---|---|---|
| モデル一覧（起点。テキスト以外も同居） | https://ai.google.dev/gemini-api/docs/models | 2026-07-27 |
| 料金（無料枠と有料枠が別建て） | https://ai.google.dev/gemini-api/docs/pricing | 2026-07-27 |
| リリースノート | https://ai.google.dev/gemini-api/docs/changelog | 2026-07-27 |
| レート制限 | https://ai.google.dev/gemini-api/docs/rate-limits | 2026-07-27 |
| 新モデル発表の一次情報 | https://blog.google/technology/google-deepmind/ | 2026-07-27 |
| 開発者向けの発表 | https://developers.googleblog.com/ | 2026-07-27 |

### Gemini CLI

| 知りたいこと | URL | 検証日 |
|---|---|---|
| ドキュメント起点 | https://google-gemini.github.io/gemini-cli/docs/ | 2026-07-27 |
| CLI のコマンド・設定 | https://google-gemini.github.io/gemini-cli/docs/cli/ | 2026-07-27 |
| 実装・issue・リリース | https://github.com/google-gemini/gemini-cli | 2026-07-27 |

> **Gemini CLI は「公式ドキュメント」を名乗るサードパーティのミラーが検索上位に多い。** 上表の 2 ドメイン（`google-gemini.github.io` と `github.com/google-gemini`）以外は一次情報として扱わない。
>
> **`ai.google.dev` の料金は API 直接利用のもの。** クラウド経由は別料金なので、Google Cloud 経由なら下の「クラウド経由の料金」を見る。

---

## xAI（Grok）

| 知りたいこと | URL | 検証日 |
|---|---|---|
| ドキュメント起点 | https://docs.x.ai/docs/overview | 2026-07-27 |
| モデル一覧 | https://docs.x.ai/developers/models | 2026-07-27 |
| 料金 | https://docs.x.ai/developers/pricing | 2026-07-27 |
| リリースノート | https://docs.x.ai/developers/release-notes | 2026-07-27 |

> **`docs.x.ai` は旧 `/docs/...` から新 `/developers/...` へ移行済み。並存ではない。** `/docs/models` は **308 で `/developers/models` へリダイレクト**する（「どちらも中身が返る」ように見えるのはリダイレクト追跡の結果）。**`/developers/...` を正とする。**
> `/docs/changelog` は **308 → `/developers/changelog` → そこが 404**。正解は `/developers/release-notes`。**リダイレクト先が 404 のこともあるので、着地点まで確認する。**

---

## その他（必要になったときだけ）

| 提供元 | 知りたいこと | URL | 検証日 |
|---|---|---|---|
| **Mistral** | モデル一覧 | https://docs.mistral.ai/getting-started/models/models_overview/ | 2026-07-27 |
| **Mistral** | changelog | https://docs.mistral.ai/getting-started/changelog/ | 2026-07-27 |
| **Mistral** | 料金 | https://mistral.ai/pricing | 2026-07-27 |
| **Mistral** | 発表 | https://mistral.ai/news | 2026-07-27 |
| **Meta** | AI 開発者向け起点 | https://developer.meta.com/ai/ | 2026-07-27 |

> **Meta（Llama）は当て先が不安定。** `llama.com/models/` は `developer.meta.com/ai/models/` へ 301 するが、**その先が 400**（2026-07-27 実測）。起点の `developer.meta.com/ai/` も **curl には 400 を返すが WebFetch では読める**ため、取得手段によって結果が変わる。**片方で落ちてももう片方を試す。**

## クラウド経由の料金（一次提供元とは別に課金される）

| 経路 | URL | 検証日 |
|---|---|---|
| Amazon Bedrock | https://aws.amazon.com/bedrock/pricing/ | 2026-07-27 |
| Google Cloud | https://cloud.google.com/vertex-ai/generative-ai/pricing | 2026-07-27 |

> **クラウド経由は単価もモデルの提供終了時期も別。** 「API 直で使うのか、クラウド経由か」を先に確定させないと、答えた価格が相手の請求書と合わない。

---

## 移転の実績（同じことがまた起きる）

実際に踏んだリダイレクト。**WebFetch は別ホストへのリダイレクトを自動で追わず「REDIRECT DETECTED」を返す** ので、必ず手で追い直す。

| 旧 URL | 新 URL | 種別 | 確認日 |
|---|---|---|---|
| `docs.claude.com/en/docs/claude-code/...` | `code.claude.com/docs/en/...` | 301 | 2026-07-27 |
| `docs.claude.com/...`（API 側） | `platform.claude.com/docs/en/...` | 恒久移転 | 2026-07-27 |
| `platform.openai.com/docs/...` | `developers.openai.com/api/docs/...` | 恒久移転 | 2026-07-27 |
| `developers.openai.com/codex/...` | `learn.chatgpt.com/docs/codex/...` | 308 | 2026-07-27 |
| `developers.openai.com/codex/changelog` | `learn.chatgpt.com/docs/changelog` | 308 | 2026-07-27 |
| `www.llama.com/models/` | `developer.meta.com/ai/models/`（**移転先が 404**） | 301 | 2026-07-27 |

**リダイレクトを追ったら、この表と上の当て先表の両方を書き換える。** 追っただけで直さないと、次回また同じ 1 往復を払う。

## WebFetch が通らない当て先（403）

以下は **2026-07-27 に WebFetch が 403 を返した**。ページが消えたのではなく、自動取得を拒否されている。

- `openai.com/news`（および `openai.com/news/`）
- `x.ai/news` / `x.ai/blog`

> **403 の当て先は一次情報として引かない。** 代わりに、
> ① ドキュメント側の changelog / リリースノート（上表）で同じ事実を取る
> ② `WebSearch` で発表内容を拾い、**ドキュメント側の記載で裏を取ってから**答える
> ③ 裏が取れなければ「一次情報に到達できなかった」と書く。**推測で埋めない。**

---

## 当て先が 404 だったときの探し方

**URL を推測して 2 回目・3 回目を撃たない。** 1 回外したら探索に切り替える。

1. **同じドメインの起点に戻る** — `/docs/en/...` が死んでいても `/docs/` は生きていることが多い。起点から辿り直す
2. **索引ファイルを探す** — `llms.txt` が公開されているサイト（Claude Code など）は、これを 1 回引くのが最短
3. **パス系統の並存を疑う** — xAI の `/docs/...` と `/developers/...` のように、旧新 2 系統が並んでいることがある
4. **`WebSearch` で探す** — クエリ例:

   | 探すもの | クエリ例 |
   |---|---|
   | モデル一覧 | `<提供元> API models documentation` |
   | 料金 | `<提供元> API pricing per million tokens official` |
   | 更新履歴 | `<提供元> API changelog release notes` |
   | 廃止情報 | `<提供元> model deprecations retirement date` |
   | CLI ドキュメント | `<CLI 名> CLI official docs site:<公式ドメイン>` |

   > **`site:` で公式ドメインに絞る。** この領域は「公式ドキュメント」を名乗る非公式のミラー・要約サイトが検索上位を占める。ドメインを見ずに引用しない。

5. **見つけたら必ず WebFetch して中身を確認する。** 検索結果のタイトルだけで当て先表に書かない
6. **書き換えて、検証日を今日の日付に更新する**

---

## メンテナンス

- **1 行直したら、その行の検証日も直す。** 日付を触らない更新は、次に読む人を騙す
- 404 / 403 / リダイレクトを踏んだら、**その場で**この表と「移転の実績」に反映する。「あとで直す」は直らない
- **値は絶対に書き足さない。** 調べる過程で価格やコンテキスト長を目にしても、ここには転記しない。転記した瞬間、このファイルは「地図」から「腐る情報源」に落ちる
