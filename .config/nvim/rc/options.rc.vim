set encoding=utf-8
set fileformats=unix,dos,mac

set autoindent
set autoread " 自動読み直し
set backspace=indent,eol,start "バックスペースキーで削除できるものを指定
set clipboard=unnamedplus " コピーしたものがレジスタにも入るようにする
set hidden " 複数ファイルの編集を可能にする
set history=50 " コマンド・検索パターン履歴数
set laststatus=2 " 常にステータラスラインを表示
set list " 不可視文字表示
set listchars=tab:>-,trail:-,extends:>,precedes:<
set modelines=0 " モードラインは無効
set nobackup
set noswapfile
set number " 行番号表示
set ruler " ルーラーを表示
set scrolloff=5 " スクロール時の余白確保
set showcmd " コマンドをステータス行に表示
set showmatch " 対応する括弧をハイライト
set showmode " 現在のモードを表示
set smartindent
set suffixes=.bak,~,.swp,.o,.info,.aux,.log,.dvi,.bbl,.blg,.brf,.cb,.ind,.idx,.ilg,.inx,.out,.toc  " ワイルドカードで表示するときに優先度を低くする拡張子
set textwidth=0 " 自動で折り返しをしない
set title " タイトルを表示する
set ttyfast " ターミナル接続を高速にする
set vb t_vb= " ビープ音を鳴らさない
set whichwrap=b,s,h,l,<,>,[,] " カーソルを行頭、行末で止まらないようにする
set wildchar=<tab> " コマンド補完開始キー
set wildmenu " コマンド補完を強化
set wildmode=list:longest " リスト表示

" set backup
" set backupdir=~/.config/nvim/backups
" set swapfile
" set directory=~/.config/nvim/swaps

set incsearch
set ignorecase
set hlsearch
set smartcase

set tabstop=2
set shiftwidth=2
set expandtab
set smarttab
