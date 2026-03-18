dotfiles
===================

## Requirements

- [Task](https://taskfile.dev/) (task runner)

## Install

```
$ git clone git@github.com:kzytateishi/dotfiles.git
$ cd dotfiles
$ task install
```

## Commands

| Command | Description |
|---|---|
| `task install` | ディレクトリ作成 + シンボリックリンク作成 |
| `task uninstall` | このリポジトリを指すシンボリックリンクを削除 |
| `task status` | 各シンボリックリンクの状態を表示 |

## Contents

- Shell: zsh, starship
- Editor: Neovim
- Terminal: Ghostty, tmux
- Git: gitconfig, tig
- Tools: mise, Karabiner-Elements, Raycast, atuin, cmux
