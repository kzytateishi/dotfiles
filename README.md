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

新しい Mac は `~/workspace/mac-provisioning` の Ansible playbook が Homebrew パッケージの導入からこの `task install` までをまとめて行う。Homebrew のパッケージ一覧はそちら(`roles/homebrew/defaults/main.yml`)が正で、このリポジトリには置かない。アプリを新しく入れるときもそちらに足す(手順は mac-provisioning の README の「アプリを追加するとき」)。

## Commands

| Command | Description |
|---|---|
| `task install` | ディレクトリ作成 + シンボリックリンク作成 |
| `task uninstall` | このリポジトリを指すシンボリックリンクを削除 |
| `task status` | 各シンボリックリンクの状態を表示 |
| `task doctor` | 依存コマンド・外部管理の前提条件をチェック |
| `task codex-config` | `codex/config.toml`(model・effort・MCP など自分で決める設定)を `~/.codex/config.toml` に反映する。アプリが書く部分には触らない。`~/.codex/config.toml` はアプリが書き換え、プロジェクトのパスも入るのでリンクしていない |
| `task lint` | シェルスクリプト・zsh・plist・JSON・ssh config・tmuxinator 定義の構文チェック |
| `task clean` | 再生成できる開発キャッシュを消す(Xcode DerivedData、機種ごとに最新以外の iOS DeviceSupport、シミュレータの XCUITest 添付、mise の未使用版、uv・Homebrew・pnpm・npm・go・Gradle のキャッシュ、Docker のビルドキャッシュ)。Docker のイメージとボリュームには触らない。実行前に確認が出る(Claude Code の `!` など端末でない環境では `task clean --yes`) |

## Contents

- Shell: zsh (zinit), starship
- Editor: Neovim (lazy.nvim)
- Terminal: iTerm2, tmux (tpm)
- Git: gitconfig (delta), gitignore_global, tig
- SSH: ssh/config (共通設定のみ。鍵名などは `~/.ssh/config.local`)。`~/.ssh/config` はリンクではなく `ssh/config` を `Include` する 1 行のファイルにしている(`~/.ssh` を複数マシンで同期していても、ホームのパスの違いで切れないようにするため)
- Tools: mise, Karabiner-Elements, Raycast, atuin, yazi, Graphite (gt)
- bin: `~/bin` にディレクトリごとリンクする自作コマンド。使い方は各スクリプトの先頭コメントと、Ctrl+G のスニペット集を参照。マシン固有のスクリプトはリポジトリに入れず `~/.local/bin` に置く

| Command | Description |
|---|---|
| `git clear [<branch>]` | default branch に移り、マージ済み / origin に無いローカルブランチを 1 本ずつ確認して削除 |
| `gpr [<PR>]` | PR を Graphite のレビュー画面で開く |
| `port [-k] [<port>]` | LISTEN 中のポートとプロセスを表示。`-k` で確認のうえ kill |
| `keychain-set <name>` | Keychain に汎用パスワードを対話入力で登録・上書き(`load-api-keys` 用) |
| `notify [<command...>]` | コマンドの終了を macOS の通知で知らせる |
| `simshot` / `adbshot` | iOS シミュレータ / Android 端末のスクショを Desktop に保存してクリップボードへ |
| `extract <archive>...` | 拡張子から展開方法を選んで展開 |
| `serve [<port>]` | カレントディレクトリを `127.0.0.1` で HTTP 配信 |

## このリポジトリの管理外にあるもの

`task install` だけでは揃わない前提がある。`task doctor` で確認できる。

| 対象 | 内容 |
|---|---|
| `~/.gitconfig.local` | `user.name` / `user.email` など、コミットしたくない設定。`.gitconfig` から `[include]` している。**トークンの類をここに平文で書かないこと**(`credential.helper = osxkeychain` を使う) |
| コミット署名 (任意) | 1Password の SSH 鍵で署名するマシンだけ、`~/.gitconfig.local` に `[include] path = ~/workspace/dotfiles/.gitconfig.1password` と `[user] signingkey = <公開鍵>` を書く。前提は 1Password → 設定 → 開発者 →「SSH エージェントを使用」。手元で検証するなら `~/.config/git/allowed_signers` に `<メールアドレス> <公開鍵>` を 1 行。GitHub には同じ公開鍵を **Signing key** として登録する。状態は `task doctor` で確認できる |
| `~/.ssh/config.local` | 鍵ファイル名・HostName・会社用 GitHub アカウントの別名ホスト(`github-<名前>` で命名。`ssh/config` の `Host github.com github-*` が共通設定とソケット分離を効かせる)など、コミットしたくない SSH 設定。`ssh/config` の先頭で `Include` している(先に読まれるので共通設定を上書きできる)。`Host github.com` に `IdentityFile ~/.ssh/<鍵名>` を書く。既定の `~/.ssh/id_*` を使うなら無くてもよい |
| `~/.tmuxinator/*.yml` | `.tmux.zsh` の `tmuxx`(tmux 内では `prefix + S` でポップアップ)が参照するセッション定義。新規は `tmuxinator new <name>` で作ると `tmuxinator/default.yml` のテンプレートから生成される。現状は Dropbox 管理 |
| `~/.tmux/plugins/tpm` | tmux プラグインマネージャ。`git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm` の後、tmux 内で `prefix + I` |
| Keychain | `.zshrc` の `load-api-keys` が読む `GEMINI_API_KEY` / `XAI_API_KEY` / `NOTION_TOKEN` を `security add-generic-password -s <名前> -a "$USER" -w` で登録しておく(`-w` を最後に置いて値を書かないと対話入力になる。値をコマンドラインに書くとシェル履歴と atuin に平文で残る) |

## 手動で復元する設定 (シンボリックリンクしていない)

GUI アプリの設定はファイルを置いても読まれないため、アプリ側からインポートする。

| ファイル | 復元方法 |
|---|---|
| `com.googlecode.iterm2.plist` | iTerm2 → Settings → General → Preferences → "Load preferences from a custom folder" にこのリポジトリを指定(mac-provisioning の playbook を使うなら設定済み) |
| `Raycast.rayconfig` | Raycast → Settings → Advanced → Import |
| `iterm2/colors/*.itermcolors` | iTerm2 → Settings → Profiles → Colors → Color Presets → Import。plist を読み込んでいれば Custom Color Presets に含まれているので不要。plist を使わない環境向けの元ファイル |

エクスポートし直したら同じパスに上書きしてコミットする。

## メモ

- API キーは shell 起動時ではなく AI CLI を叩く直前に Keychain から読む(`load-api-keys` で手動ロードも可能)
- Neovim のプラグインは `.config/nvim/lazy-lock.json` で固定。更新したら `:Lazy sync` 後にこのファイルもコミットする
- `.config/mise/config.toml` は Node/Go/Ruby/Python/pnpm に `latest`、Flutter に `3.44` を指定。再現性が必要なプロジェクトでは `mise.toml` / `.tool-versions` にバージョンを固定する
- Karabiner は `~/.config/karabiner` をディレクトリごとリンクしているため `automatic_backups/` がリポジトリ内に生成される(gitignore 済み)
- `.tmux.conf` の pane border 設定は tpm の**後**に置く必要がある(nord-tmux に上書きされるため)
- `ssh/config` は `ControlMaster` で接続を再利用する。ソケットは `~/.ssh` の中ではなく `~/.cache/ssh/sockets` に置く(`~/.ssh` をクラウド同期している環境でもソケットが同期対象にならないようにするため)。ポートフォワードや踏み台で挙動がおかしいホストは `~/.ssh/config.local` 側で `ControlMaster no` にして外す。効いている設定は `ssh -G <host>` で確認できる
