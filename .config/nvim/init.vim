if &compatible
  set nocompatible
endif

function! s:source_rc(path, ...) abort
  let use_global = get(a:000, 0, !has('vim_starting'))
  let abspath = resolve(expand('~/.config/nvim/rc/' . a:path))
  if !use_global
    execute 'source' fnameescape(abspath)
    return
  endif

  " substitute all 'set' to 'setglobal'
  let content = map(readfile(abspath),
        \ 'substitute(v:val, "^\\W*\\zsset\\ze\\W", "setglobal", "")')
  " create tempfile and source the tempfile
  let tempfile = tempname()
  try
    call writefile(content, tempfile)
    execute 'source' fnameescape(tempfile)
  finally
    if filereadable(tempfile)
      call delete(tempfile)
    endif
  endtry
endfunction

call s:source_rc('dein.rc.vim')
call s:source_rc('options.rc.vim')
call s:source_rc('color.rc.vim')
call s:source_rc('keymap.rc.vim')
call s:source_rc('markdown.rc.vim')
call s:source_rc('vim-quickrun.rc.vim')
call s:source_rc('functions.rc.vim')

if filereadable(expand('~/.vimrc.local'))
  source ~/.vimrc.local
endif
