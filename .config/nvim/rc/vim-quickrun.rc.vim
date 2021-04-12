" 初期化
let g:quickrun_config = {}
" runnerにvimprocを設定
let g:quickrun_config._ = {'runner' : 'vimproc'}
let g:quickrun_config._ = {'runner/vimproc/updatetime' : 100}
" 横分割をするようにする
let g:quickrun_config={'*': {'split': ''}}
" 横分割時は下へ､ 縦分割時は右へ新しいウィンドウが開くようにする
set splitbelow
set splitright
