#!/bin/bash
# Claude Code 通知 hook (Stop / Notification 共用)
# iTerm2 名義の通知の代わりに terminal-notifier で「Claude Code」名義の通知を出す。
# osascript は親プロセス (iTerm2) 名義になるため使わない。
input=$(cat)

cwd=$(echo "$input" | jq -r '.cwd // ""')
project=$(basename "${cwd:-.}")
event=$(echo "$input" | jq -r '.hook_event_name // "Stop"')
message=$(echo "$input" | jq -r '.message // empty')

case "$event" in
  Notification) body="${message:-入力待ちです}"; sound="Ping" ;;
  *)            body="応答が完了しました";        sound="Glass" ;;
esac

if command -v terminal-notifier >/dev/null 2>&1; then
  terminal-notifier \
    -title "Claude Code" \
    -subtitle "$project" \
    -message "$body" \
    -sound "$sound" \
    -group "claude-code-$project" \
    -activate com.googlecode.iterm2
else
  # フォールバック (iTerm2 名義になるが通知は届く)。
  # $body は通知ペイロード由来で二重引用符を含みうるため、AppleScript の
  # 文字列に直接埋め込まず argv 経由で渡す (埋め込むと構文が壊れ、
  # AppleScript を注入できてしまう)。
  osascript - "$project" "$body" "$sound" <<'APPLESCRIPT' 2>/dev/null
on run argv
  set proj to item 1 of argv
  set body to item 2 of argv
  set snd to item 3 of argv
  display notification (proj & ": " & body) with title "Claude Code" sound name snd
end run
APPLESCRIPT
fi

exit 0
