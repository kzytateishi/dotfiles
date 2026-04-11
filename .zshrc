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

if [[ -f "$HOME/.local/share/zinit/zinit.git/zinit.zsh" ]]; then
  source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
  autoload -Uz _zinit
  (( ${+_comps} )) && _comps[zinit]=_zinit

  # NOTE: zinit annex (as-monitor / bin-gem-node / patch-dl / rust) は読み込まない。
  # どの ice でも使っておらず、同期ロードで起動が遅くなるだけだった。

  # 起動時に要らないプラグインは turbo mode (wait) で最初のプロンプト表示後に読み込む。
  # autosuggestions は遅延ロードすると自動では有効にならないので atload で start する。
  zinit wait lucid light-mode for \
    atload'_zsh_autosuggest_start' zsh-users/zsh-autosuggestions \
    paulirish/git-open \
    wfxr/forgit
  # NOTE: zsh-users/zsh-completions は入れない。Homebrew の zsh-completions と
  # 同じ上流で、両方 fpath に入ると compinit が同じ補完を二重に走査する
  # (下の Completion セクションで Homebrew 側を fpath に追加している)。
fi
# fast-syntax-highlighting はファイル末尾で読み込む (zle widget を全部ラップするため)

### ------------------------------
### Init script cache
### ------------------------------
# `eval "$(tool init zsh)"` は毎回プロセスを起動するので (1 本 5〜25ms)、出力をキャッシュして
# source する。コマンド本体 (symlink の解決先) が変わるか更新されたら作り直す。
# 出力に現在の PATH などの環境を埋め込むもの (mise activate など) には使わないこと。
# 手動で作り直すときは rm ~/.cache/zsh/*-init.zsh
function _cached_eval() {
  local name="$1"; shift
  local bin
  if [[ "$1" == */* ]]; then bin="${1:A}"; else bin="${commands[$1]:A}"; fi
  [[ -x "$bin" ]] || return 1
  # 引数も stamp に含める (.zshrc で init のオプションを変えたら作り直すため)
  local cache="$HOME/.cache/zsh/${name}-init.zsh" stamp cached_stamp
  stamp="# $bin ${(j: :)${(q)@[2,-1]}}"
  [[ -s "$cache" ]] && read -r cached_stamp < "$cache"
  if [[ "$cached_stamp" != "$stamp" || "$bin" -nt "$cache" ]]; then
    mkdir -p "${cache:h}"
    { print -r -- "$stamp"; "$@" 2>/dev/null } >| "$cache" || { rm -f "$cache"; return 1; }
  fi
  source "$cache"
}

### ------------------------------
### API keys (macOS Keychain)
### ------------------------------
# 起動のたびに security を叩くと 1 本あたり ~20ms かかるので遅延評価にする。
# 実体が必要になった時点で 1 度だけ Keychain を引き、以降はキャッシュする。
function _load_api_key() {
  local var="$1"
  [[ -n "${(P)var}" ]] && return 0
  local val
  val="$(security find-generic-password -s "$var" -a "$USER" -w 2>/dev/null)" || return 1
  export "$var=$val"
}

function load-api-keys() {
  local k
  for k in GEMINI_API_KEY XAI_API_KEY NOTION_TOKEN; do
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
  _cached_eval brew /opt/homebrew/bin/brew shellenv
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
if [[ -d "$HOME/.grok/completions/zsh" ]]; then
  fpath=("$HOME/.grok/completions/zsh" $fpath)
fi
# Docker Desktop は .zshrc 末尾に追記するが、compinit より後だと毎回走り直すのでここで足す
if [[ -d "$HOME/.docker/completions" ]]; then
  fpath=("$HOME/.docker/completions" $fpath)
fi

# キーマップを明示する。EDITOR/VISUAL に "vi" を含む値 (nvim も該当) が入って
# いると zsh は自動で viins を選ぶため、指定しないと ^A/^E などが効かず、
# Esc 後は ^T/^R などの自作バインドも外れる。
bindkey -e

autoload -Uz compinit
# 補完キャッシュの作り直しは 24 時間に 1 回だけ (#q のグロブ修飾子は extended_glob が必要)。
# 補完を新しく入れてすぐ反映されないときは rm ~/.zcompdump
# NOTE: compinit は中身に変化が無いとキャッシュを書き直さず mtime も更新しないので、
#       フル実行の後に touch しないと「24 時間超」の判定が永久に真になり、毎回 compaudit 込みの
#       フル実行 (~300ms) になる。あわせて zcompile してバイトコード化しておく (読み込みが速くなる)。
() {
  setopt local_options extended_glob
  local dump="${ZDOTDIR:-$HOME}/.zcompdump"
  if [[ ! -f "$dump" || -n ${dump}(#qN.mh+24) ]]; then
    compinit -i
    touch "$dump"
  else
    compinit -C -i
  fi
  if [[ ! -f "${dump}.zwc" || "$dump" -nt "${dump}.zwc" ]]; then
    zcompile "$dump" 2>/dev/null
  fi
}
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
# fzf-tab の推奨。標準のメニュー補完を切って fzf-tab に任せる
zstyle ':completion:*' menu no

(( $+functions[zinit] )) && zinit light Aloxaf/fzf-tab

### ------------------------------
### History
### ------------------------------
export HISTSIZE=100000
export SAVEHIST=100000
HISTFILE="${ZDOTDIR:-$HOME}/.zsh_history"

setopt hist_reduce_blanks
setopt hist_ignore_all_dups
# append_history は既定で on、かつ inc_append_history が上位なので書かない
setopt inc_append_history
# 先頭にスペースを付けたコマンドは履歴に残さない (秘密情報を含むコマンド用)
setopt hist_ignore_space
setopt extended_history
# !! などの履歴展開を即実行せず、一度プロンプトに展開する
setopt hist_verify

# Keychain に値ごと登録するコマンド (security add-generic-password ... -w <値>) は
# zsh の履歴に残さない。atuin の history_filter は atuin の DB にしか効かない。
# -w を最後に置いて値を対話入力する正しい使い方は、そのまま履歴に残る。
function _hist_skip_secrets() {
  emulate -L zsh -o extended_glob
  local line="${1%%$'\n'}"
  [[ "$line" != *security*-generic-password*-w[[:space:]]##[^[:space:]]* ]]
}
add-zsh-hook zshaddhistory _hist_skip_secrets

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
# java_home は 1 回 ~13ms かかるので結果をキャッシュする。JVM ディレクトリの中身
# (symlink の解決先。Homebrew の openjdk は更新するとバージョン付きのパスが変わる) が
# 変わるか、キャッシュしたパスが消えたら引き直す。
if [[ -x /usr/libexec/java_home ]]; then
  () {
    local cache="$HOME/.cache/zsh/java-home" stamp cached_stamp cached
    local -a jvms=(/Library/Java/JavaVirtualMachines/*(N:A) "$HOME"/Library/Java/JavaVirtualMachines/*(N:A))
    stamp="# ${(j: :)jvms}"
    [[ -s "$cache" ]] && { read -r cached_stamp; read -r cached } < "$cache"
    if [[ "$cached_stamp" == "$stamp" && -n "$cached" && -d "$cached" ]]; then
      JAVA_HOME="$cached"
    else
      JAVA_HOME="$(/usr/libexec/java_home -v 21 -F 2>/dev/null)" \
        || JAVA_HOME="$(/usr/libexec/java_home 2>/dev/null)"
      # 見つからなかった結果はキャッシュしない (一時的な失敗で空のまま固定されるのを防ぐ)
      if [[ -n "$JAVA_HOME" ]]; then
        mkdir -p "${cache:h}"
        print -rl -- "$stamp" "$JAVA_HOME" >| "$cache"
      fi
    fi
  }
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
  "$HOME/.grok/bin"
  "$PNPM_HOME"
  "$ANDROID_HOME/cmdline-tools/latest/bin"
  "$ANDROID_HOME/platform-tools"
  "$ANDROID_HOME/emulator"
  "/opt/homebrew/opt/openjdk/bin"
  "/opt/homebrew/share/git-core/contrib/diff-highlight"
  "$HOME/.local/bin"
  "$HOME/bin"
  $path
  "$HOME/.maestro/bin"
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

if command -v yazi >/dev/null 2>&1; then
  # yazi を抜けたときに最後にいたディレクトリへ cd する (公式推奨のラッパー)
  y() {
    local tmp cwd
    tmp="$(mktemp -t yazi-cwd.XXXXXX)"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(<"$tmp")" && [[ -n "$cwd" && "$cwd" != "$PWD" ]]; then
      builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
  }
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
  _cached_eval fzf fzf --zsh
  (( $+widgets[fzf-tab-complete] )) && bindkey '^I' fzf-tab-complete
fi

### ------------------------------
### Graphite (gt)
### ------------------------------
# gt は補完ファイルを同梱せず、`gt completion` の生成に 100ms 以上かかるので、
# 生成結果をキャッシュして読み込む (gt を更新すると自動で作り直す)。
command -v gt >/dev/null 2>&1 && _cached_eval gt gt completion

# PR を Graphite のレビュー画面で開く。引数は PR 番号 (省略時は現在のブランチの PR)
gpr() {
  local repo num
  repo="$(gh repo view --json nameWithOwner --jq .nameWithOwner 2>/dev/null)" || {
    echo "gpr: GitHub のリポジトリではありません" >&2
    return 1
  }
  if [[ -n "$1" ]]; then
    num="$1"
  else
    num="$(gh pr view --json number --jq .number 2>/dev/null)" || {
      echo "gpr: 現在のブランチに PR がありません (番号を指定してください)" >&2
      return 1
    }
  fi
  open "https://app.graphite.com/github/pr/${repo}/${num}"
}

### ------------------------------
### Tool initialization
### ------------------------------
command -v atuin >/dev/null 2>&1 && _cached_eval atuin atuin init zsh --disable-up-arrow
command -v zoxide >/dev/null 2>&1 && _cached_eval zoxide zoxide init zsh

# mise activate の出力は現在の PATH を埋め込むのでキャッシュできない
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi

command -v starship >/dev/null 2>&1 && _cached_eval starship starship init zsh

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
(( $+functions[zinit] )) && zinit wait lucid light-mode for zdharma-continuum/fast-syntax-highlighting

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /opt/homebrew/bin/terraform terraform

### ------------------------------
### Terminal title
### ------------------------------
# tmux の外ではタブ名を今のディレクトリ名にする (tmux の中は .tmux.conf の set-titles-string)
if [[ -z "$TMUX" ]]; then
  function _set_tab_title() { print -Pn "\e]1;%1~\a" }
  add-zsh-hook precmd _set_tab_title
fi
