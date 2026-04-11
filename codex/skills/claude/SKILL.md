---
name: claude
description: Anthropic Claude (Claude Code) に質問・相談する。セカンドオピニオンが欲しいとき、Claude の見解を求められたとき、コードのレビューや別解を Claude に出させたいときに使う。
---

# Claude に質問する

Codex から Claude Code CLI を非対話モード (`-p`) で実行して回答を得る。Claude 側の `codex` スキルと対になる、Codex 専用のスキル。

## 使い方

質問は **heredoc で stdin に渡す**。コマンド引数に直接埋め込まない。

```bash
claude -p --tools "Read,Grep,Glob" --no-session-persistence <<'EOF'
<質問内容>
EOF
```

- 引数があればそれをそのまま質問として渡す。なければ会話の文脈から質問を組み立てる。
- リポジトリ内で実行すると Claude がファイルを読んで回答できる。
- `--tools "Read,Grep,Glob"` で使えるツールを読み取り系だけに絞る。質問するだけなので、編集やコマンド実行はさせない。
- `--no-session-persistence` は、問い合わせのたびに Claude Code のセッション履歴が増えないようにするため。
- モデルを指定したい場合は `--model` を使う (例: `--model opus`)。指定がなければ Claude Code の既定のまま。

> **`claude -p "..."` に質問を埋め込んではいけない。** コード関連の質問にはバッククォート・`$(...)`・`"` が高確率で含まれ、ダブルクォート内ではシェルがそれらを**実行してしまう**。`<<'EOF'` (EOF をクォート) ならシェル展開が一切起きず原文がそのまま届く。

## 注意

- 認証は Claude Code のログイン状態を使う (`claude` で一度ログインしてあること)。
- Codex のサンドボックス内ではネットワークに出られず失敗することがある。その場合は権限の昇格を求めて実行する。
- 実行後は Claude の回答をそのまま貼るのではなく、要点をまとめてユーザーに伝える。
