# ~/.zsh_snippets.zsh
# Ctrl+G で fzf から呼び出されるスニペット集
# フォーマット: <コマンド><TAB># <説明>
#   - `#` で始まる行と空行は無視される
#   - タブより前がプロンプトに挿入される (最初の TAB が区切りなのでコマンド内に生 TAB は書けない)
#   - git alias は自動で取り込まれるので ~/.gitconfig 側に書いたものはここに不要

### --- git (alias で省略しづらい長文系) ---
git rebase -i HEAD~	# 直近 N コミットを対話 rebase (末尾に数字)
git rebase -i $(git merge-base HEAD main)	# main から分岐した地点以降をまとめて rebase
git push --force-with-lease --force-if-includes	# 上流取り込み済みかも確認する安全な force push
git rebase HEAD~1 --committer-date-is-author-date	# amend 後に committer date を author date に揃える (HEAD~N で範囲指定)
git commit --allow-empty -m "first commit"	# 空コミットを作成 (リポジトリ初期化直後や CI 再実行のトリガーに)
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
git fetch origin pull//head:pr-	# GitHub PR をローカルブランチに取得 (例: pull/123/head:pr-123)
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
pbpaste | jq .	# クリップボードを JSON 整形

### --- nkf (文字コード変換) ---
nkf --guess 	# ファイルの文字コードと改行コードを判定
nkf -w --overwrite 	# UTF-8 に変換して上書き
nkf -w -Lu --overwrite 	# UTF-8 + LF に変換して上書き
nkf -s -Lw --overwrite 	# Shift_JIS + CRLF に変換して上書き (Windows 向け)
nkf -w 	# UTF-8 に変換して標準出力 (元ファイルは無変更)
nkf -w --in-place=.bak 	# バックアップを残して UTF-8 に変換

### --- curl / ネットワーク ---
curl -s -o /dev/null -w '%{http_code} %{time_total}s\n' 	# ステータスコードと応答時間を計測
curl -s -H 'Content-Type: application/json' -d '{}' 	# JSON を POST (-d があれば POST になる)
curl -sI 	# レスポンスヘッダのみ表示
curl -sL -O 	# リダイレクト追従でダウンロード
dig +short 	# DNS レコードを簡潔に表示
dig @8.8.8.8 	# 指定 DNS サーバで名前解決
ssh -N -L 8080:localhost:8080 	# ポートフォワードのみ (シェルなし)
nc -zv  	# ポート疎通確認 (host port)
python3 -m http.server 8000	# カレントディレクトリを HTTP 配信

### --- ffmpeg / メディア変換 ---
ffmpeg -i  -vf 'fps=10,scale=640:-1' output.gif	# 動画→GIF 変換
ffmpeg -i  -vn -c:a copy output.m4a	# 音声を無劣化抽出 (AAC 前提、他形式なら拡張子を合わせる)
ffmpeg -i  -vf scale=1280:-2 output.mp4	# 幅 1280px にリサイズ
ffmpeg -i  -c:v libx264 -crf 28 output.mp4	# 動画を圧縮 (crf 大きいほど高圧縮)
ffmpeg -ss 00:00:10 -i  -t 30 -c copy output.mp4	# 10秒地点から30秒を無劣化切り出し (-ss は -i の前が高速)
ffprobe -hide_banner 	# メディア情報を表示

### --- brew / システム管理 ---
brew update && brew upgrade	# 全パッケージ更新
brew cleanup --prune=all -n	# 削除対象キャッシュを dry-run 確認
brew deps --tree 	# パッケージの依存関係をツリー表示
brew uses --installed 	# このパッケージに依存しているものを表示
du -sh * | sort -rh | head -20	# カレント直下のサイズランキング
df -h	# ディスク空き容量
ps aux | sort -nrk 4 | head -10	# メモリ使用量 TOP10 プロセス
top -o mem	# メモリ順で top

### --- 検索 (grep / rg / find / fd) ---
grep -rn '' .	# 再帰検索 (行番号付き)
grep -rn --include='*.' '' .	# 拡張子を絞って再帰検索
grep -rln '' .	# マッチしたファイル名だけ表示
grep -rn -C3 '' .	# マッチの前後3行も表示
rg -n ''	# 高速再帰検索 (gitignore 考慮)
rg -n -g '*.' ''	# glob で対象ファイルを絞る
rg -F ''	# 正規表現なしの固定文字列検索
rg --hidden --no-ignore ''	# 隠しファイル・ignore 対象も検索
rg -l ''	# マッチしたファイル名だけ表示
find . -type f -name ''	# 名前パターンでファイル検索
find . -type f -mtime -1	# 24時間以内に更新されたファイル
find . -type f -size +100M	# 100MB 超のファイル
find . -type f -name '' -exec  {} +	# 検索結果にコマンド実行 (例: -exec rm {} +)
find . -type d -name node_modules -prune -o -type f -name '' -print	# node_modules を除外して検索
fd ''	# 高速ファイル名検索 (gitignore 考慮)
fd -e 	# 拡張子で検索 (例: fd -e ts)
fd -H -I ''	# 隠しファイル・ignore 対象も含む
fd '' -x 	# 検索結果にコマンド実行 (例: fd -e log -x rm)

### --- jq / テキスト処理 ---
jq -r '.[]' 	# 配列を展開して raw 出力
jq 'keys' 	# トップレベルのキー一覧
jq -s '.' 	# JSON Lines を配列にまとめる
sed -i '' 's///g' 	# ファイル内を一括置換 (macOS)
sort | uniq -c | sort -rn	# 重複行をカウントして降順表示
awk -F',' '{print $1}' 	# CSV の1列目を抽出
tr '[:upper:]' '[:lower:]'	# 大文字→小文字に変換

### --- tmux / task / mise ---
tmux new -s 	# 名前付きセッションを新規作成
tmux attach -t 	# 既存セッションにアタッチ
tmux ls	# セッション一覧
task -a	# 利用可能なタスク一覧
mise install	# .mise.toml の全ツールをインストール
mise use -g 	# ツールをグローバルに固定
