set number
syntax enable

"------------------------------------
" Load Settings
"------------------------------------
if filereadable(expand('~/.vimrc.local'))
  source ~/.gvimrc.local
endif
