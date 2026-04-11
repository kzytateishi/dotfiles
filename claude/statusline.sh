#!/bin/bash
# Claude Code statusline: モデル名 | ディレクトリ | gitブランチ | コンテキスト使用率
input=$(cat)

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
if [ -n "$branch" ]; then
  line="$line | $branch"
fi
if [ -n "$ctx" ]; then
  line="$line | ctx ${ctx}%"
fi

printf '%s' "$line"
