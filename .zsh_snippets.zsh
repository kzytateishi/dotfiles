# ~/.zsh_snippets.zsh
# Ctrl+G で fzf から呼び出されるスニペット集
# フォーマット: <コマンド><TAB># <説明>
#   - `#` で始まる行と空行は無視される
#   - タブより前がプロンプトに挿入される
#   - git alias は自動で取り込まれるので ~/.gitconfig 側に書いたものはここに不要

### --- git (alias で省略しづらい長文系) ---
git rebase -i HEAD~	# 直近 N コミットを対話 rebase (末尾に数字)
git rebase -i $(git merge-base HEAD main)	# main から分岐した地点以降をまとめて rebase
git push --force-with-lease --force-if-includes	# 上流取り込み済みかも確認する安全な force push
git rebase HEAD~1 --committer-date-is-author-date	# amend 後に committer date を author date に揃える (HEAD~N で範囲指定)
git log -p -S ''	# 文字列が追加/削除されたコミットを検索 (pickaxe)
git log -p -G ''	# 正規表現で diff 内容を検索
git log --all --grep=''	# 全ブランチのコミットメッセージを検索
git log --author=''	# 作者で絞り込み
git log --follow -p -- 	# リネーム追跡付きでファイル履歴を表示
git log --since='1 week ago' --author="$(git config user.name)"	# 自分の直近1週間の活動
git blame -L ,: 	# 行範囲を指定して blame (例: -L 10,20:path)
git diff --stat $(git merge-base HEAD main)..HEAD	# main からの差分サマリ
git reflog	# HEAD の移動履歴 (誤操作のリカバリに)
git reset --hard ORIG_HEAD	# 直前のマージ/pull/rebase を取り消す
git revert -m 1 	# マージコミットを revert (-m 1 で親1側を残す)
git cherry-pick -x 	# 元コミット参照付きで cherry-pick
git show :	# 特定コミットのファイル内容を表示 (例: HEAD~3:path)
git clean -fdx -n	# 削除予定の未追跡ファイルを dry-run で確認
git clean -fdx	# 未追跡ファイルを gitignore 含めて削除
git submodule update --init --recursive	# サブモジュールを再帰的に取得
git fetch origin pull//head:pr-	# GitHub PR をローカルブランチに取得
git worktree add ../	# 新しい worktree を作成
git worktree list	# worktree 一覧
git worktree remove 	# worktree 削除
git bisect start	# 二分探索開始 (good/bad で絞り込む)
git config --global --edit	# グローバル gitconfig をエディタで開く
git remote set-url origin 	# remote の URL を変更

### --- gh (GitHub CLI) ---
gh pr create --fill	# コミットからタイトル/本文を自動入力して PR 作成
gh pr checkout 	# PR 番号を指定してローカル取得
gh pr view --web	# 現在ブランチの PR をブラウザで開く
gh pr list --author '@me'	# 自分の PR 一覧
gh pr checks	# 現在ブランチの CI ステータス
gh run watch	# 最新の Actions run を監視
gh repo clone 	# repo をクローン (owner/name 形式)

### --- docker ---
docker compose up -d	# コンテナをバックグラウンド起動
docker compose down	# コンテナ停止 & 削除
docker compose logs -f --tail=100 	# サービスのログを末尾から追跡
docker compose exec  bash	# 起動中のサービスでシェル
docker compose run --rm  	# 一時的に単発実行
docker run --rm -it  bash	# イメージを一時起動してシェル
docker exec -it  bash	# 起動中コンテナにシェル接続
docker system df	# Docker のディスク使用量
docker system prune -a --volumes	# 未使用リソース (ボリューム含む) を全削除

### --- macOS / shell utility ---
lsof -nP -iTCP -sTCP:LISTEN	# LISTEN 中のポート一覧
lsof -nP -i :	# 特定ポートを使ってるプロセス (末尾にポート番号)
ssh-keygen -t ed25519 -C ''	# SSH 鍵生成 (コメントにメール)
openssl rand -hex 32	# ランダム 64 文字 hex 生成
openssl rand -base64 32	# ランダム base64 文字列生成
xattr -d com.apple.quarantine 	# macOS の検疫属性を解除
caffeinate -di	# スリープを抑制 (Ctrl+C で解除)
dscacheutil -flushcache && sudo killall -HUP mDNSResponder	# DNS キャッシュクリア
tar -czvf archive.tar.gz 	# tar.gz を作成
tar -xzvf 	# tar.gz を展開
find . -type f -name ''	# 名前パターンでファイル検索
pbpaste | jq .	# クリップボードを JSON 整形

### --- tmux / task / mise ---
tmux new -s 	# 名前付きセッションを新規作成
tmux attach -t 	# 既存セッションにアタッチ
tmux ls	# セッション一覧
task -a	# 利用可能なタスク一覧
mise install	# .mise.toml の全ツールをインストール
mise use -g 	# ツールをグローバルに固定
