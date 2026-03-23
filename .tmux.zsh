function is_tmux_running() { [[ -n "$TMUX" ]]; }

function _tmux_cleanup_stale() {
  if ! tmux list-sessions &>/dev/null; then
    /bin/rm -rf /tmp/tmux*
  fi
}

function _tmux_active_sessions() {
  tmux list-sessions 2>/dev/null
}

function _tmux_running_session_names() {
  tmux list-sessions -F '#{session_name}' 2>/dev/null
}

function _tmuxinator_available_projects() {
  local running="$(_tmux_running_session_names)"
  local all="$(command ls ~/.tmuxinator/*.yml 2>/dev/null | xargs -I{} basename {} .yml)"

  if [[ -n "$running" ]]; then
    echo "$all" | grep -vxF "$running"
  else
    echo "$all"
  fi
}

function _fzf_select() {
  echo "$1" | fzf --reverse
}

function tmuxx() {
  if is_tmux_running; then
    echo "${fg_bold[red]}TMUX is already running!${reset_color}"
    return 1
  fi

  _tmux_cleanup_stale

  local menu="Create New Session\nSelect Session"
  local sessions="$(_tmux_active_sessions)"
  if [[ -n "$sessions" ]]; then
    menu="${menu}\n${sessions}"
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
