#!/bin/bash
# Claude Code statusline: モデル名 | ディレクトリ | gitブランチ
input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // "Claude"')
dir=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // "."')

branch=$(git -C "$dir" branch --show-current 2>/dev/null)

dir_disp="$dir"
case "$dir" in
  "$HOME"*) dir_disp="~${dir#"$HOME"}" ;;
esac

line="$model | $dir_disp"
if [ -n "$branch" ]; then
  line="$line | $branch"
fi

printf '%s' "$line"
