
### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

### End of Zinit's installer chunk

### Added by Zinit's Custom Settings
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-completions
zinit light zdharma/history-search-multi-word
zinit light zdharma/fast-syntax-highlighting
zinit light paulirish/git-open
### End of Zinit's Custom Settings

HISTFILE=~/.zsh_history
STSIZE=100000
SAVEHIST=100000
setopt share_history
setopt hist_reduce_blanks
setopt hist_ignore_all_dups

export LANG=ja_JP.UTF-8

export JAVA_HOME=`/usr/libexec/java_home -v 21`

eval "$(/opt/homebrew/bin/brew shellenv)"

eval "$(starship init zsh)"

# zsh-completions
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH

  autoload -Uz compinit
  compinit
fi
# End of zsh-completions

export LC_ALL='ja_JP.UTF-8'
export EDITOR=vim

# MacVim
if [[ -d /Applications/MacVim.app ]]; then
  alias vim=/Applications/MacVim.app/Contents/MacOS/Vim
fi

# Android
export ANDROID_SDK_ROOT="/usr/local/share/android-sdk"
export ANDROID_HOME=$HOME/Library/Android/sdk
export ANDROID_AVD_HOME=$HOME/.android/avd

# Flutter
export FLUTTER_ROOT="$(asdf where flutter)"
export PATH="$PATH":"$HOME/.pub-cache/bin"

# asdf
#. /opt/homebrew/opt/asdf/libexec/asdf.sh

# mise
eval "$(/opt/homebrew/bin/mise activate zsh)"

# direnv
eval "$(direnv hook zsh)"

# vim
alias vi=vim
alias vim=nvim

# VimFiler
alias f='vim +VimFiler'

# tmux
alias tmux='tmux -u'

# ls
alias ls="ls -G"
alias ll="ls -lG"
alias la="ls -laG"

# rails
alias be='bundle exec'
alias bi='bundle install'

# docker-compose
alias d='docker'
alias dc='docker compose'

# colordiff
if [[ -x `which colordiff` ]]; then
  alias diff='colordiff -u'
else
  alias diff='diff -u'
fi

hash tmux 2>/dev/null && source "$HOME/.tmux.zsh"

export SHELL="/opt/homebrew/bin/zsh"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
