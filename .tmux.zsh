# tmuxx: tmux セッションと tmuxinator プロジェクトを fzf で選んで開くランチャー
#
#   enter   : セッションなら attach (tmux 内なら switch)、プロジェクトなら tmuxinator start
#   入力+enter: 一致する候補が無ければ、入力した名前で新規セッションを作る
#   ctrl-n  : 入力した名前 (空なら自動命名) で新規セッションを作る
#   ctrl-x  : 選んだセッションを kill (確認あり)
#   ctrl-e  : 選んだプロジェクトの yml を $EDITOR で開く
#   ctrl-r  : 候補を再読み込み
#
# tmux 内では prefix + S でポップアップ表示する (.tmux.conf)。
#
# ソケットディレクトリ (/tmp/tmux-UID) は tmux が管理する。別の -L サーバーも共有するため削除しない。

function _tmux_running_session_names() {
  tmux list-sessions -F '#{session_name}' 2>/dev/null
}

function _tmuxinator_dir() {
  print -r -- "${TMUXINATOR_CONFIG:-$HOME/.tmuxinator}"
}

# yml の name: を返す (無ければファイル名)。セッション名はこれで決まる。
function _tmuxinator_project_name() {
  local f="$1" name
  name="$(sed -n 's/^name:[[:space:]]*//p' "$f" | head -1 | tr -d "\"'")"
  print -r -- "${name:-${f:t:r}}"
}

function _tmuxinator_project_root() {
  sed -n 's/^root:[[:space:]]*//p' "$1" | head -1 | tr -d "\"'"
}

# セッション名に対応する tmuxinator プロジェクト名 (= ファイル名) を返す。無ければ空で終了コード 1。
function _tmuxinator_project_for_session() {
  local f
  for f in "$(_tmuxinator_dir)"/*.yml(N); do
    [[ "${f:t:r}" == default ]] && continue
    if [[ "$(_tmuxinator_project_name "$f")" == "$1" ]]; then
      print -r -- "${f:t:r}"
      return 0
    fi
  done
  return 1
}

# tmuxinator のプロジェクト名 (= ファイル名) のうち、まだセッションが起動していないものを出す。
# 起動済みかどうかはセッション名で判定する。セッション名は yml の name: で決まり、
# ファイル名と違うことがあるので、ファイル名ではなく name: を読んで比較する。
function _tmuxinator_available_projects() {
  local running="$(_tmux_running_session_names)"
  local -a projects
  local f name
  projects=("$(_tmuxinator_dir)"/*.yml(N))
  (( ${#projects} )) || return 0

  for f in "${projects[@]}"; do
    [[ "${f:t:r}" == default ]] && continue   # tmuxinator new のテンプレート
    name="$(_tmuxinator_project_name "$f")"
    if [[ -n "$running" ]] && printf '%s\n' "$running" | grep -qxF -- "$name"; then
      continue
    fi
    printf '%s\n' "${f:t:r}"
  done
}

# fzf に渡す候補。1 行 = kind<TAB>name<TAB>表示ラベル<TAB>補足
# fzf には --with-nth=3,4 で表示ラベルと補足だけ見せる。--nth は表示後の列番号で解釈されるので、
# 検索対象を表示ラベル (= 名前) に限定するには --nth=1 を指定する (補足のパスで誤ヒットさせない)。
function _tmuxx_candidates() {
  local green=$'\e[32m' blue=$'\e[34m' yellow=$'\e[33m' dim=$'\e[2m' reset=$'\e[0m'

  tmux list-sessions \
    -F $'session\t#{session_name}\t'"${green}"$'● #{session_name}'"${reset}"$'\t'"${dim}"$'#{session_windows} windows#{?session_attached, · attached,}'"${reset}" \
    2>/dev/null

  local p f root
  for p in $(_tmuxinator_available_projects); do
    f="$(_tmuxinator_dir)/$p.yml"
    root="$(_tmuxinator_project_root "$f")"
    printf 'project\t%s\t%s○ %s%s\t%s%s%s\n' "$p" "$blue" "$p" "$reset" "$dim" "${root:-tmuxinator}" "$reset"
  done

  printf 'new\t\t%s＋ new session%s\t%s名前を入力して enter%s\n' "$yellow" "$reset" "$dim" "$reset"
}

function _tmuxx_attach() {
  if [[ -n "$TMUX" ]]; then
    tmux switch-client -t "$1"
  else
    tmux attach-session -t "$1"
  fi
}

function _tmuxx_new() {
  # tmux のセッション名に使えない . と : は置き換える
  local name="${1//[.:]/_}"
  if [[ -n "$name" ]] && tmux has-session -t "=$name" 2>/dev/null; then
    _tmuxx_attach "$name"
    return
  fi
  # zsh は ${name:+-s "$name"} を 1 語に展開するので、配列で渡す
  local -a opts
  [[ -n "$name" ]] && opts=(-s "$name")
  if [[ -n "$TMUX" ]]; then
    # 名前なしで作ると tmux が番号を振るので、作成後に新しいセッション名を取り直して切り替える
    local created
    created="$(tmux new-session -d -P -F '#{session_name}' "${opts[@]}")" && tmux switch-client -t "=$created"
  else
    tmux new-session "${opts[@]}"
  fi
}

function tmuxx() {
  local preview='case {1} in
    session) tmux list-windows -t {2} -F "#{window_index}: #{window_name}#{?window_active, *,}  (#{window_panes} pane)  #{pane_current_path}" ;;
    project) f="${TMUXINATOR_CONFIG:-$HOME/.tmuxinator}"/{2}.yml
             if command -v bat >/dev/null 2>&1; then bat --style=plain --color=always --language=yaml "$f"; else cat "$f"; fi ;;
    *)       echo "名前を入力して enter で新規セッションを作成"
             echo "(空のまま enter なら tmux が自動で番号を付ける)" ;;
  esac'

  local out
  out="$(_tmuxx_candidates | fzf \
    --ansi --reverse --delimiter=$'\t' --with-nth=3,4 --nth=1 --tabstop=4 \
    --prompt='tmux > ' \
    --header=$'enter: attach / start   ctrl-n: new   ctrl-x: kill   ctrl-e: edit yml   ctrl-r: reload' \
    --print-query --expect=ctrl-n,ctrl-x,ctrl-e \
    --bind="ctrl-r:reload(zsh -c 'source \$HOME/.tmux.zsh; _tmuxx_candidates')" \
    --preview="$preview" --preview-window=right,55%,wrap)"

  local -a lines
  lines=("${(@f)out}")
  local query="${lines[1]}" key="${lines[2]}" sel="${lines[3]}"
  local kind="${sel%%$'\t'*}"
  local name="${${sel#*$'\t'}%%$'\t'*}"

  case "$key" in
    ctrl-n)
      _tmuxx_new "$query"
      return
      ;;
    ctrl-x)
      if [[ "$kind" == session ]]; then
        if read -q "?Kill session '$name'? [y/N] "; then
          echo
          # tmuxinator のプロジェクトなら stop 経由にして on_project_stop フックを走らせる
          local proj="$(_tmuxinator_project_for_session "$name")"
          if [[ -n "$proj" ]]; then
            tmuxinator stop "$proj"
          else
            tmux kill-session -t "=$name"
          fi
        else
          echo
        fi
      fi
      tmuxx
      return
      ;;
    ctrl-e)
      local f="$(_tmuxinator_dir)/$name.yml"
      if [[ -n "$name" && -f "$f" ]]; then
        "${EDITOR:-nvim}" "$f"
      fi
      tmuxx
      return
      ;;
  esac

  case "$kind" in
    session) _tmuxx_attach "$name" ;;
    project) tmuxinator start "$name" ;;
    new)     _tmuxx_new "$query" ;;
    "")      [[ -n "$query" ]] && _tmuxx_new "$query" ;;   # 候補なし + enter → 入力名で新規作成
  esac
}
