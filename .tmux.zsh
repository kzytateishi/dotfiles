function is_tmux_running() { [[ -n "$TMUX" ]]; }

function _tmux_active_sessions() {
  tmux list-sessions 2>/dev/null
}

function _tmux_running_session_names() {
  tmux list-sessions -F '#{session_name}' 2>/dev/null
}

function _tmuxinator_available_projects() {
  local running="$(_tmux_running_session_names)"
  local -a projects
  local all
  projects=("$HOME"/.tmuxinator/*.yml(N))
  (( ${#projects} )) || return 0
  all="$(printf '%s\n' "${projects[@]:t:r}")"

  if [[ -n "$running" ]]; then
    printf '%s\n' "$all" | grep -vxF -- "$running"
  else
    printf '%s\n' "$all"
  fi
}

function _fzf_select() {
  printf '%s\n' "$1" | fzf --reverse
}

function tmuxx() {
  if is_tmux_running; then
    echo "${fg_bold[red]}TMUX is already running!${reset_color}"
    return 1
  fi

  # ソケットディレクトリは tmux が管理する。別の -L サーバーも共有するため削除しない。
  local menu=$'Create New Session\nSelect Session'
  local sessions="$(_tmux_active_sessions)"
  if [[ -n "$sessions" ]]; then
    menu+=$'\n'"${sessions}"
  fi

  local choice="$(_fzf_select "$menu" | cut -d: -f1)"

  case "$choice" in
    "Create New Session")
      tmux new-session
      ;;
    "Select Session")
      local projects="$(_tmuxinator_available_projects)"
      if [[ -z "$projects" ]]; then
        echo "No available tmuxinator projects."
        return 0
      fi
      local project="$(_fzf_select "$projects")"
      [[ -n "$project" ]] && tmuxinator start "$project"
      ;;
    ?*)
      tmux attach-session -t "$choice"
      ;;
  esac
}
