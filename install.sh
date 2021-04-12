#!/usr/bin/env bash

set -e

cd "$(dirname "${BASH_SOURCE}")"

CWD=$(pwd)

echo "Sync Start\n"

function syncFile() {
    echo "$CWD/$1 => $HOME/$1"
    ln -sf "$CWD/$1" "$HOME/$1"
}

function sync() {
  mkdir -p $HOME/.config/nvim
  mkdir -p $HOME/.zsh
  mkdir -p $HOME/bin

  syncFile ".agignore"
  syncFile ".asdfrc"
  syncFile ".gemrc"
  syncFile ".gitattributes"
  syncFile ".gitconfig"
  syncFile ".gitconfig_local"
  syncFile ".gitignore"
  syncFile ".gitmessage"
  syncFile ".gitmodules"
  syncFile ".gvimrc"
  syncFile ".railsrc"
  syncFile ".tigrc"
  syncFile ".tmux.conf"
  syncFile ".tmux.zsh"
  syncFile ".zshenv"
  syncFile ".zshrc"

  syncFile ".config/karabiner/karabiner.json"
  syncFile ".config/starship.toml"

  syncFile ".config/nvim/init.vim"
  syncFile ".config/nvim/dein.toml"
  syncFile ".config/nvim/deinlazy.toml"
  syncFile ".config/nvim/ftplugin"
  syncFile ".config/nvim/plugins"
  syncFile ".config/nvim/rc"
  syncFile ".config/nvim/snippets"

  syncFile "bin/tmux-pbcopy"

  ln -sf ~/.zsh/.zshenv ~/.zshenv
}

sync

echo ""
echo "Done!"
