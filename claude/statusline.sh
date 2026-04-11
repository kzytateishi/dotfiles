#!/bin/bash
# Claude Code statusline: セッション名 | モデル名 | ディレクトリ | gitブランチ | コンテキスト使用率
input=$(cat)

# 名前も自動のタイトルも無いうちは項目自体が無いので空にしておく
session_name=$(echo "$input" | jq -r '.session_name // empty')
model=$(echo "$input" | jq -r '.model.display_name // "Claude"')
dir=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // "."')
# 最初の API 応答までは null なので空にしておく
ctx=$(echo "$input" | jq -r '.context_window.used_percentage // empty | floor')

branch=$(git -C "$dir" branch --show-current 2>/dev/null)

dir_disp="$dir"
case "$dir" in
  "$HOME"|"$HOME"/*) dir_disp="~${dir#"$HOME"}" ;;
esac

line="$model | $dir_disp"
if [ -n "$session_name" ]; then
  line="$session_name | $line"
fi
if [ -n "$branch" ]; then
  line="$line | $branch"
fi
if [ -n "$ctx" ]; then
  line="$line | ctx ${ctx}%"
fi

printf '%s' "$line"
