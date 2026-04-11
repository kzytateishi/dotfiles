#!/usr/bin/env bash
# Claude Code の設定変更(settings.json / スキル)を監査ログに記録する。
# 変更をブロックはせず、記録だけ行う。
set -uo pipefail

LOG_DIR="${HOME}/.claude/logs"
LOG_FILE="${LOG_DIR}/config-changes.log"

mkdir -p "$LOG_DIR"
chmod 700 "$LOG_DIR" 2>/dev/null || true

input=$(cat)

# ペイロードのフィールド名は source / file_path。
# 以前は .config_source を読んでいて全レコードが source=unknown になっていた。
#
# 出力は jq に組ませた 1 行 JSON にする。手組みの TSV だと cwd や
# session_id に含まれるタブ・改行がそのまま書き出され、1 イベントが
# 複数行に割れて監査ログを偽装できてしまう。
#
# jq が空入力・不正 JSON で何も出さないケースがあるため、
# 出力が空なら unparsed として記録する。
line=$(printf '%s' "$input" | jq -c \
  --arg ts "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" \
  '{
     ts: $ts,
     source: (.source // "unknown"),
     file_path: (.file_path // null),
     session_id: (.session_id // "unknown"),
     cwd: (.cwd // "unknown")
   }' 2>/dev/null)

if [ -z "$line" ]; then
  line=$(jq -nc --arg ts "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" \
    '{ts: $ts, source: "unparsed", file_path: null, session_id: "unknown", cwd: "unknown"}')
fi

printf '%s\n' "$line" >> "$LOG_FILE"
chmod 600 "$LOG_FILE" 2>/dev/null || true

exit 0
