# High-Signal レビューチェックリスト

自動 PR レビュアー(GitHub Copilot 等)が最も高頻度で指摘するカテゴリの、具体的なチェック項目。汎用の「品質/セキュリティをレビューして」というプロンプトが取りこぼすのは、これらが**操作可能な手順に落ちていない**から。**下記の各カテゴリを diff に適用し、ヒットを finding として報告する**(file・line・severity・具体的な fix 付き。基準は [finding-bar.md](finding-bar.md))。

例は Ruby/Rails・TypeScript だが、意図は言語非依存。コード識別子・技術用語は原文のまま扱う。

---

## A. 仕様 ↔ 実装の一致(最頻出の取りこぼし)

**PR 概要 / コミットメッセージ / 紐づく Issue** を**実際の diff** と突き合わせる。intent の各事実主張に対し、対応するコードを見つけて真かどうかを確認する。

- [ ] **「DB / migration 変更なし」と書いてあるのに migration がある**(逆も)。diff から migration / schema ファイルを探し、intent と突き合わせる。
- [ ] **定義の食い違い。** 例: Issue が「コンバージョン = `activated_at` のあるユーザー」と書くのに、コードは別カラム / フラグで絞っている。両方を引用して mismatch を指摘し、どちらを直すか示す。
- [ ] **スコープの食い違い。** intent が 1 アプリ / 1 layer と言うのに、diff がそれより広い(or 狭い)。スコープドリフトを指摘。
- [ ] **振る舞いの食い違い。**「X にフォールバック」「Y のときブロック」— 実際の制御フローを追って確認する。
- [ ] **影響 / デプロイ注記が古い。** 新 index・新 env var・新 NOT NULL カラム・データ backfill は PR 概要の影響範囲 / デプロイ前作業に反映されているべき。

## B. enum / 定数のハードコード・規約ドリフト

typed accessor があるのに literal を使っている箇所を指摘する。diff を grep する。

- [ ] **enum 値の literal 直書き**(enum の value object / predicate を使うべき)。
  - Ruby/Enumerize: `status.to_sym == :guest` → `status.guest?`、比較値 `"guest"` → 定義済み value 参照。
  - TS: `Role` enum/const があるのに `role === "admin"` → enum member を使う。
- [ ] **マジックナンバー / 文字列**(ドメイン概念)→ 名前付き定数。
- [ ] **既存の helper / scope / predicate の再実装**(既存クエリ scope、ファイル内に既にある `escapeHtml` 等)→ 再利用する。
- [ ] **隣のファイルとのパターン乖離。** 5 行隣の sibling と同じ概念を別実装している(factory・scope・エラーハンドリング)。ローカルの idiom に合わせる(プロジェクト固有パターン > 一般論)。

## B'. 移行の残置物・意図しないフォールバック

リネーム / 移行を謳う diff に旧経路が残っていないか。プロジェクトが後方互換を明示的に禁止している場合は **High 以上**で報告する。

- [ ] **旧カラム / 旧メソッドへのフォールバック**: `new_column || old_column`、`params[:new_key] || params[:old_key]`、`data?.newField ?? data?.oldField`。意図的な移行措置なら intent に明記されているはず(A と突き合わせる)。
- [ ] **旧インターフェースの残置**: `alias_method :old, :new`、`delegate :old_method`、`export { newFunc as oldFunc }` の re-export。
- [ ] **痕跡の残置**: `_old_variable`(アンダースコア残し)、`# removed: ...` コメント、`# TODO: 後で消す` 等の時間依存コメント。
- [ ] **暗黙フォールバック**: `risky_call rescue default_value`。「壊れたデータが来るかも」を理由にした防御分岐はバリデーション層で保証すべき。

## C. nil / nullable / blank と入力正規化

- [ ] **nullable カラムを正規化せず使用。** NOT NULL も default も無いカラムが `.map`/`.size`/`.each` に届く → `nil` で `NoMethodError`。`Array(x)` / default で正規化する。
- [ ] **present? だが不正。** present でも blank / 不正(空白・大文字小文字・危険文字)のまま URL / host / SQL / filename に補間される。正規化・検証する。
- [ ] **境界の無いユーザー入力**を配列サイズ / range / limit / regex に使用。

## D. 時刻・範囲の境界

- [ ] **日付境界が必要な所で `Time.current` / `now()`。**「from 日付 .. to 日付」仕様には `beginning_of_day` / `end_of_day` 相当を使い、同ファイル内の既存の境界スタイルに合わせる。
- [ ] **半開区間 vs 閉区間のバグ。** `>= from` だけで `to` の上限を無視(未来日 / backfill 行が漏れ込む)。両端を必ず bound する。
- [ ] **タイムゾーン / UTC vs ローカル**の比較・永続値の不一致。
- [ ] **off-by-one**(`<` vs `<=`、`length` vs `length - 1`)。

## E. 並行性・冪等性

- [ ] **`find_or_create_by!` / get-or-insert の race。** 同時到達 → unique violation → 500。rescue して再 fetch、または DB unique 制約 + upsert。
- [ ] **成功前に冪等レコードを書く。** marker を先に作って handler が raise すると、retry がスキップされ event が失われる。「処理済み」は handler 成功**後**に確定する。
- [ ] **thread / 非同期処理でのコネクション / リソースリーク。** 例外でワーカーを黙って殺さない。

## F. DB index・クエリ効率

- [ ] **filter / sort / count に使う新カラムに index が無い。** 新カラム(or 新しい複合述語)への `WHERE` / `ORDER BY` / `COUNT` → migration に対応する(複合)index を追加するか、無い理由を述べる。
- [ ] **アプリ側で load してから filter**(DB でできるのに)。必要な行 / 型にクエリを絞る。
- [ ] **冗長 / 重複クエリ**(同じ値を 2 回解決、呼び出し側が既に実行したクエリを再実行)。一度計算して渡す。
- [ ] **N+1**(変更した association をまたいで)。

## G. Web / フロントのセキュリティ・アクセシビリティ

- [ ] **文字列補間 HTML → XSS。** HTML 文字列に値を直接入れると markup が壊れる / script 注入。`createElement`/`textContent` で組む、既存の escape helper を使う、URL は厳密に検証・エンコード。
- [ ] **`rel="noopener noreferrer"` の無い `target="_blank"`。**
- [ ] **キーボードフォーカス表示の欠落。** 新しい interactive / link スタイルが `:hover` だけ定義して `:focus-visible` / `:focus` が無い。
- [ ] **出力エンコード / SSRF / open-redirect**(ユーザー入力由来の値)。

## H. テストの厳密さ

- [ ] **アサーションが結果を証明していない。**「エラーが出ない」だけ(or 緩い `be >= 1`)のテストは、機能が壊れていても pass する。具体的な期待値を assert し、再実行 / 冪等テストでは **2 回目**の呼び出し結果も assert する。
- [ ] **再現が本番フローと乖離。** テストがショートカット(`record.update!(version: 2)`)で状態を作るが、実コードはそれを生成しない。実 service / flow を通す。
- [ ] **factory / fixture データが対象ロジックを満たさない。** service が属性 X で行を識別するなら factory も X を設定する。さもないとテストは何もテストしていない。
- [ ] **正常系の隣に error / edge / boundary が無い。**

## I. メッセージ / i18n・自動生成ファイル

- [ ] **ユーザー向けメッセージがコードと矛盾。** エラー文の主張と guard の実際の条件がずれている。コピー(とテストの期待文字列)をコードの実挙動に合わせる。
- [ ] **locale key が片方の言語にだけ追加 / 変更された**、または参照 key が欠落。
- [ ] **自動生成ファイルの手編集**(codegen 出力、`schema.rb`、スキーマアノテーション等)。生成元を直して再生成すべき。生成物と生成元の食い違いも finding。
