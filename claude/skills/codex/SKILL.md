---
name: codex
description: OpenAI Codex (GPT) に質問・相談する。セカンドオピニオンが欲しいとき、GPT/Codex の見解を求められたとき、コードのレビューや別解を GPT に出させたいときに使う。
---

# Codex (OpenAI) に質問する

Codex CLI を非対話モードで実行して回答を得る。

## 使い方

質問は **heredoc で stdin に渡す**。コマンド引数に直接埋め込まない。

```bash
codex exec --skip-git-repo-check - <<'EOF'
<質問内容>
EOF
```

- 引数（$ARGUMENTS）があればそれをそのまま質問として渡す。なければ会話の文脈から質問を組み立てる。
- リポジトリ内で実行すると Codex がファイルを読んで回答できる。

> **`"..."` に質問を埋め込んではいけない。** コード関連の質問にはバッククォート・`$(...)`・`"` が高確率で含まれ、ダブルクォート内ではシェルがそれらを**実行してしまう**。実測で `` `echo BROKEN` `` と `$(echo INJECTED)` が実行され、その出力に置換された（＝質問文が壊れるだけでなくコマンドインジェクションになる）。`<<'EOF'`（EOF をクォート）ならシェル展開が一切起きず原文がそのまま届く。

## 注意

- 認証は `codex login --with-api-key` で設定済み（`~/.codex/auth.json`）。401 エラーが出たら `printf '%s' "$OPENAI_API_KEY" | codex login --with-api-key` で再ログインする。
- `codex exec` は既定で `approval: never` / `sandbox: read-only` で動く。読み取り専用にするために `--sandbox read-only` を付ける必要はない。
- 回答の取り出しは `-o <FILE>`（`--output-last-message`）が確実。標準出力はヘッダ → 回答 → `tokens used` → 回答の再掲、という順で出るため、末尾だけを機械的に読むと誤る。

  ```bash
  codex exec --skip-git-repo-check -o /tmp/codex-answer.txt - <<'EOF'
  <質問内容>
  EOF
  ```

- 実行後は Codex の回答をそのまま貼るのではなく、要点をまとめてユーザーに伝える。
