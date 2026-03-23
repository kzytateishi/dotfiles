### ------------------------------
### Plugin manager: zinit
### ------------------------------
if [[ ! -f "$HOME/.local/share/zinit/zinit.git/zinit.zsh" ]]; then
  print -P "%F{33}%F{220}Installing %F{33}Zinit%F{220}...%f"
  command mkdir -p "$HOME/.local/share/zinit" &&
  command chmod g-rwX "$HOME/.local/share/zinit" &&
  command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" &&
  print -P "%F{34}Installation successful.%f" ||
  print -P "%F{160}The clone has failed.%f"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

zinit light-mode for \
  zdharma-continuum/zinit-annex-as-monitor \
  zdharma-continuum/zinit-annex-bin-gem-node \
  zdharma-continuum/zinit-annex-patch-dl \
  zdharma-continuum/zinit-annex-rust

zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-completions
zinit light zdharma/fast-syntax-highlighting
zinit light paulirish/git-open
zinit light wfxr/forgit

### ------------------------------
### Locale
### ------------------------------
export LANG="ja_JP.UTF-8"

### ------------------------------
### API keys (macOS Keychain)
### ------------------------------
export OPENAI_API_KEY=$(security find-generic-password -s "OPENAI_API_KEY" -a "$USER" -w 2>/dev/null)
export GEMINI_API_KEY=$(security find-generic-password -s "GEMINI_API_KEY" -a "$USER" -w 2>/dev/null)

### ------------------------------
### Homebrew
### ------------------------------
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

### ------------------------------
### Completion
### ------------------------------
if command -v brew >/dev/null 2>&1; then
  FPATH="$(brew --prefix)/share/zsh-completions:$FPATH"
fi

autoload -Uz compinit
compinit -i

zinit light Aloxaf/fzf-tab

### ------------------------------
### History
### ------------------------------
export HISTSIZE=100000
export SAVEHIST=100000

setopt hist_reduce_blanks
setopt hist_ignore_all_dups
setopt append_history
setopt inc_append_history

### ------------------------------
### Snippet picker
### ------------------------------
function select-snippet() {
  local snippet_file selected
  snippet_file="$HOME/.zsh_snippets.zsh"

  [[ -f "$snippet_file" ]] || return

  selected="$(
    grep -v '^[[:space:]]*#' "$snippet_file" \
      | grep -v '^[[:space:]]*$' \
      | fzf --reverse
  )"

  if [[ -n "$selected" ]]; then
    BUFFER="$selected"
    CURSOR=${#BUFFER}
    zle reset-prompt
  fi
}
zle -N select-snippet
bindkey '^G' select-snippet

### ------------------------------
### Editor
### ------------------------------
export EDITOR="nvim"
alias vi='nvim'
alias vim='nvim'

if [[ -x /Applications/MacVim.app/Contents/MacOS/Vim ]]; then
  alias mvim='/Applications/MacVim.app/Contents/MacOS/Vim'
fi

alias f='nvim +"Neotree toggle"'

### ------------------------------
### Java
### ------------------------------
export JAVA_HOME="$("/usr/libexec/java_home" -v 21)"
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"

### ------------------------------
### Android
### ------------------------------
export ANDROID_HOME="$HOME/Library/Android/sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export ANDROID_AVD_HOME="$HOME/.android/avd"

### ------------------------------
### Runtime / env tools
### ------------------------------
export PATH="$HOME/.local/share/mise/shims:$PATH"

### ------------------------------
### PATH additions
### ------------------------------
export PNPM_HOME="$HOME/Library/pnpm"

typeset -U path PATH
path=(
  "$PNPM_HOME"
  "$ANDROID_HOME/cmdline-tools/latest/bin"
  "$ANDROID_HOME/platform-tools"
  "$ANDROID_HOME/emulator"
  "/opt/homebrew/share/git-core/contrib/diff-highlight"
  "$HOME/.local/bin"
  "$HOME/.ticloud/bin"
  "$HOME/bin"
  $path
)
export PATH

### ------------------------------
### Aliases
### ------------------------------
alias tmux='tmux -u'

if command -v eza >/dev/null 2>&1; then
  alias ls='eza --group-directories-first'
  alias ll='eza -lg --group-directories-first'
  alias la='eza -lag --group-directories-first'
else
  alias ls='ls -G'
  alias ll='ls -lG'
  alias la='ls -laG'
fi

alias be='bundle exec'
alias bi='bundle install'

alias d='docker'
alias dc='docker compose'

alias diff='diff -u'

if command -v bat >/dev/null 2>&1; then
  alias b='bat --paging=never'
fi

if command -v procs >/dev/null 2>&1; then
  alias p='procs'
fi

if command -v dust >/dev/null 2>&1; then
  alias dux='dust'
fi

### ------------------------------
### tmux helper
### ------------------------------
if command -v tmux >/dev/null 2>&1 && [[ -f "$HOME/.tmux.zsh" ]]; then
  source "$HOME/.tmux.zsh"
fi

### ------------------------------
### Custom widgets
### ------------------------------
function select-task() {
  local task_name
  task_name="$(task -a --json | jq -r '.tasks[].name' | fzf --reverse)"

  if [[ -n "$task_name" ]]; then
    BUFFER="task $task_name"
    CURSOR=${#BUFFER}
    zle reset-prompt
  fi
}
zle -N select-task
bindkey '^T' select-task

### ------------------------------
### lazygit helper
### ------------------------------
function lg() {
  export LAZYGIT_NEW_DIR_FILE="$HOME/.lazygit/newdir"

  lazygit "$@"

  if [[ -f "$LAZYGIT_NEW_DIR_FILE" ]]; then
    cd "$(cat "$LAZYGIT_NEW_DIR_FILE")" || return
    rm -f "$LAZYGIT_NEW_DIR_FILE" >/dev/null 2>&1
  fi
}

### ------------------------------
### fzf
### ------------------------------
export FZF_CTRL_T_COMMAND=

if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
  bindkey '^I' fzf-tab-complete
fi

### ------------------------------
### atuin
### ------------------------------
if command -v atuin >/dev/null 2>&1; then
  eval "$(atuin init zsh --disable-up-arrow)"
fi

### ------------------------------
### zoxide
### ------------------------------
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

### ------------------------------
### direnv
### ------------------------------
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

### ------------------------------
### mise
### ------------------------------
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi

### ------------------------------
### starship
### ------------------------------
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

### ------------------------------
### bash completion bridge
### ------------------------------
autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /opt/homebrew/bin/terraform terraform
