let mapleader = ","

nnoremap sh <C-w>h
nnoremap sj <C-w>j
nnoremap sk <C-w>k
nnoremap sl <C-w>l

" height
nnoremap + <C-w>+
nnoremap - <C-w>-
" width
nnoremap ) <C-w>>
nnoremap ( <C-w><LT>


" Tab Settings {{{
nnoremap T :tabnew<CR>
nnoremap <leader>tx :tabclose<CR>
nnoremap <leader>tp :tabprevious<CR>
nnoremap <leader>tn :tabNext<CR>
" }}} / Tab Settings

nnoremap <ESC><ESC> :nohlsearch<CR>

" インサートモードでもhjklで移動
inoremap <C-j> <Down>
inoremap <C-k> <Up>
inoremap <C-h> <Left>
inoremap <C-l> <Right>

" インサートモードを抜ける
inoremap <silent> <C-[> <esc>
inoremap <silent> jj <esc>

" 0, 9で行頭、行末へ
nmap 0 ^
nmap 9 $

" ビジュアルモード時vで行末まで選択
xnoremap v $h

"挿入モードで",date",',time'で日付、時刻挿入
inoremap <Leader>date <C-R>=strftime('%Y/%m/%d')<CR>
inoremap <Leader>time <C-R>=strftime('%H:%M')<CR>

" Buffer Settings
noremap <Space> :bn!<CR>
noremap <S-Space> :bp!<CR>

onoremap ) t)
onoremap ( t(
vnoremap ) t)
vnoremap ( t(
