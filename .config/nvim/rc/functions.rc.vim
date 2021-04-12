" copy path
function! CopyPath()
  let @*=expand('%')
endfunction

function! CopyFullPath()
  let @*=expand('%:p')
endfunction

function! CopyFileName()
  let @*=expand('%:t')
endfunction

command! CopyPath     call CopyPath()
command! CopyFullPath call CopyFullPath()
command! CopyFileName call CopyFileName()

nnoremap <silent>cp :CopyPath<CR>
nnoremap <silent>cfp :CopyFullPath<CR>
nnoremap <silent>cf :CopyFileName<CR>
" / copy path

" remove dust
function! s:remove_dust()
  let cursor = getpos(".")
  %s/\s\+$//ge " 保存時に行末の空白を除去する
  " %s/\t/  /ge " 保存時にtabを2スペースに変換する
  call setpos(".", cursor)
  unlet cursor
endfunction
augroup RemoveDust
  autocmd BufWritePre *.{rb,erb,yml,feature,html,xhtml,css,scss,js,coffee,sh,sql,yaml} call <SID>remove_dust()
augroup END
" / remove dust

" show zenkaku space 
function! ZenkakuSpace()
    highlight ZenkakuSpace cterm=underline ctermfg=red guibg=darkgray
endfunction

if has('syntax')
  augroup ZenkakuSpace
    autocmd!
    autocmd ColorScheme * call ZenkakuSpace()
    autocmd VimEnter,WinEnter,BufRead * let w:m1=matchadd('ZenkakuSpace', '　')
  augroup END
  call ZenkakuSpace()
endif
" / show zenkaku space 

" json format
command! -nargs=? Jq call s:Jq(<f-args>)
function! s:Jq(...)
    if 0 == a:0
        let l:arg = "."
    else
        let l:arg = a:1
    endif
    execute "%! jq \"" . l:arg . "\""
endfunction
" / json format
