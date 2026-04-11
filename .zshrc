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
# NOTE: zsh-users/zsh-completions は入れない。Homebrew の zsh-completions と
# 同じ上流で、両方 fpath に入ると compinit が同じ補完を二重に走査する
# (下の Completion セクションで Homebrew 側を fpath に追加している)。
zinit light paulirish/git-open
zinit light wfxr/forgit
# fast-syntax-highlighting はファイル末尾で読み込む (zle widget を全部ラップするため)

### ------------------------------
### API keys (macOS Keychain)
### ------------------------------
# しばらく Claude Code をサブスク(OAuth)側で使うため、ANTHROPIC_API_KEY は読み込まない。
# 戻すときはこの行を消す。
export API_KEY_SKIP="ANTHROPIC_API_KEY OPENAI_API_KEY"

# 起動のたびに security を叩くと 1 本あたり ~20ms かかるので遅延評価にする。
# 実体が必要になった時点で 1 度だけ Keychain を引き、以降はキャッシュする。
function _load_api_key() {
  local var="$1"
  [[ " ${API_KEY_SKIP:-} " == *" $var "* ]] && return 0
  [[ -n "${(P)var}" ]] && return 0
  local val
  val="$(security find-generic-password -s "$var" -a "$USER" -w 2>/dev/null)" || return 1
  export "$var=$val"
}

function load-api-keys() {
  local k
  for k in OPENAI_API_KEY GEMINI_API_KEY ANTHROPIC_API_KEY XAI_API_KEY; do
    _load_api_key "$k"
  done
}

function _api_key_preexec() {
  case "$1" in
    claude*|codex*|gemini*|grok*|llm*|aider*|openai*|task\ claude*) load-api-keys ;;
  esac
}
autoload -Uz add-zsh-hook
add-zsh-hook preexec _api_key_preexec

### ------------------------------
### Homebrew
### ------------------------------
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

### ------------------------------
### Completion
### ------------------------------
# fpath も重複排除の対象にする。brew shellenv が FPATH を export するため、
# 入れ子の対話シェルごとに同じディレクトリが積まれて compinit が余分に走査する。
typeset -U fpath FPATH

# HOMEBREW_PREFIX は上の brew shellenv が設定済みなので brew --prefix は呼ばない
if [[ -n "$HOMEBREW_PREFIX" ]]; then
  fpath=("$HOMEBREW_PREFIX/share/zsh-completions" $fpath)
fi

# キーマップを明示する。EDITOR/VISUAL に "vi" を含む値 (nvim も該当) が入って
# いると zsh は自動で viins を選ぶため、指定しないと ^A/^E などが効かず、
# Esc 後は ^T/^R などの自作バインドも外れる。
bindkey -e

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
# append_history は既定で on、かつ inc_append_history が上位なので書かない
setopt inc_append_history

### ------------------------------
### Snippet picker
### ------------------------------
function select-snippet() {
  local snippet_file selected
  snippet_file="$HOME/.zsh_snippets.zsh"

  selected="$(
    {
      [[ -f "$snippet_file" ]] && grep -v '^[[:space:]]*#' "$snippet_file" | grep -v '^[[:space:]]*$'
      git config --get-regexp '^alias\.' 2>/dev/null \
        | sed 's/^alias\.\([^ ]*\) \(.*\)$/git \1\t# \2/'
    } | fzf --reverse --delimiter=$'\t' --with-nth=1,2
  )"

  if [[ -n "$selected" ]]; then
    BUFFER="${selected%%$'\t'*}"
    CURSOR=${#BUFFER}
    zle reset-prompt
  fi
}
zle -N select-snippet
bindkey '^G' select-snippet

### ------------------------------
### Editor
### ------------------------------
# EDITOR は .zshenv で設定済み
alias vi='nvim'
alias vim='nvim'

if [[ -x /Applications/MacVim.app/Contents/MacOS/Vim ]]; then
  alias mvim='/Applications/MacVim.app/Contents/MacOS/Vim'
fi

alias f='nvim +"Neotree toggle"'

### ------------------------------
### Java
### ------------------------------
# 注意: java_home の -v は「該当が無ければ別バージョンを返す」ため指定が無視される
# (JDK 21 未導入時に -v 21 が 26 を返す)。-F を付けて厳密マッチさせる。
# Android/Flutter の Gradle は JDK 21 系までしか対応しないので 21 を優先する。
if [[ -x /usr/libexec/java_home ]]; then
  JAVA_HOME="$(/usr/libexec/java_home -v 21 -F 2>/dev/null)" \
    || JAVA_HOME="$(/usr/libexec/java_home 2>/dev/null)"
  [[ -n "$JAVA_HOME" ]] && export JAVA_HOME || unset JAVA_HOME
fi

### ------------------------------
### Android
### ------------------------------
export ANDROID_HOME="$HOME/Library/Android/sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export ANDROID_AVD_HOME="$HOME/.android/avd"

### ------------------------------
### PATH additions
### ------------------------------
# mise は下部の `mise activate` が PATH を管理するので shims は足さない (二重管理になる)
export PNPM_HOME="$HOME/Library/pnpm"

typeset -U path PATH
path=(
  "$PNPM_HOME"
  "$ANDROID_HOME/cmdline-tools/latest/bin"
  "$ANDROID_HOME/platform-tools"
  "$ANDROID_HOME/emulator"
  "/opt/homebrew/opt/openjdk/bin"
  "/opt/homebrew/share/git-core/contrib/diff-highlight"
  "$HOME/.local/bin"
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
# 空文字を明示すると fzf 側の ^T (fzf-file-widget) バインドが抑止され、
# 上で定義した select-task が ^T のまま残る
export FZF_CTRL_T_COMMAND=

if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
  bindkey '^I' fzf-tab-complete
fi

### ------------------------------
### Tool initialization
### ------------------------------
if command -v atuin >/dev/null 2>&1; then
  eval "$(atuin init zsh --disable-up-arrow)"
fi

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

### ------------------------------
### bash completion bridge
### ------------------------------
if [[ -x /opt/homebrew/bin/terraform ]]; then
  autoload -U +X bashcompinit && bashcompinit
  complete -o nospace -C /opt/homebrew/bin/terraform terraform
fi

### ------------------------------
### Syntax highlighting (必ず最後)
### ------------------------------
zinit light zdharma-continuum/fast-syntax-highlighting

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /opt/homebrew/bin/terraform terraform

# >>> grok installer >>>
export PATH="$HOME/.grok/bin:$PATH"
fpath=(~/.grok/completions/zsh $fpath)
autoload -Uz compinit && compinit -C
# <<< grok installer <<<
