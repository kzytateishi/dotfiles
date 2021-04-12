let g:vimfiler_as_default_explorer = 1
" セーフモードの設定
let g:vimfiler_safe_mode_by_default = 0
" VimFiler を起動
nnoremap <Space>f :<C-u>VimFiler<CR>
" 現在ん開いているバッファをIDE風に開く
nnoremap <silent> <Leader>f :<C-u>VimFilerBufferDir -split -simple -winwidth=35 -no-quit<CR>
