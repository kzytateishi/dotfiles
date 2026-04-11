dotfiles
===================

## Requirements

- [Task](https://taskfile.dev/) (task runner)

## Install

```
$ git clone git@github.com:kzytateishi/dotfiles.git
$ cd dotfiles
$ task install
$ task doctor    # 依存コマンドと外部前提のチェック
```

## Commands

| Command | Description |
|---|---|
| `task install` | ディレクトリ作成 + シンボリックリンク作成 |
| `task uninstall` | このリポジトリを指すシンボリックリンクを削除 |
| `task status` | 各シンボリックリンクの状態を表示 |
| `task doctor` | 依存コマンド・外部管理の前提条件をチェック |

## Contents

- Shell: zsh (zinit), starship
- Editor: Neovim (lazy.nvim)
- Terminal: iTerm2, tmux (tpm)
- Git: gitconfig, gitignore_global, tig
- Tools: mise, Karabiner-Elements, Raycast, atuin

## このリポジトリの管理外にあるもの

`task install` だけでは揃わない前提がある。`task doctor` で確認できる。

| 対象 | 内容 |
|---|---|
| `~/.gitconfig.local` | `user.name` / `user.email` など、コミットしたくない設定。`.gitconfig` から `[include]` している。**トークンの類をここに平文で書かないこと**(`credential.helper = osxkeychain` を使う) |
| `~/.tmuxinator/*.yml` | `.tmux.zsh` の `tmuxx` が参照するセッション定義。現状は Dropbox 管理 |
| `~/.tmux/plugins/tpm` | tmux プラグインマネージャ。`git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm` の後、tmux 内で `prefix + I` |
| Keychain | `OPENAI_API_KEY` / `GEMINI_API_KEY` / `ANTHROPIC_API_KEY` / `XAI_API_KEY` を `security add-generic-password -s <名前> -a "$USER" -w <値>` で登録しておく |

## 手動で復元する設定 (シンボリックリンクしていない)

GUI アプリの設定はファイルを置いても読まれないため、アプリ側からインポートする。

| ファイル | 復元方法 |
|---|---|
| `com.googlecode.iterm2.plist` | iTerm2 → Settings → General → Preferences → "Load preferences from a custom folder" にこのリポジトリを指定 |
| `Raycast.rayconfig` | Raycast → Settings → Advanced → Import |

エクスポートし直したら同じパスに上書きしてコミットする。

## メモ

- API キーは shell 起動時ではなく AI CLI を叩く直前に Keychain から読む(`load-api-keys` で手動ロードも可能)
- Neovim のプラグインは `.config/nvim/lazy-lock.json` で固定。更新したら `:Lazy sync` 後にこのファイルもコミットする
- `.config/mise/config.toml` はメジャーバージョンで固定。`latest` にすると再現性が無くなる
- Karabiner は `~/.config/karabiner` をディレクトリごとリンクしているため `automatic_backups/` がリポジトリ内に生成される(gitignore 済み)
- `.tmux.conf` の pane border 設定は tpm の**後**に置く必要がある(nord-tmux に上書きされるため)
