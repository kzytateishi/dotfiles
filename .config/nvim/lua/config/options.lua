-- Neovim のデフォルトから変えたい項目だけを書く
local opt = vim.opt

-- "mac" (CR のみ) は誤検出の原因になりやすいので Neovim デフォルトのまま unix,dos
opt.fileformats = { "unix", "dos" }

opt.autoindent = true
opt.smartindent = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true

opt.ignorecase = true
opt.smartcase = true

opt.signcolumn = "yes"
opt.number = true
opt.scrolloff = 5
opt.showmatch = true
opt.title = true
opt.list = true
opt.listchars = { tab = ">-", trail = "-", extends = ">", precedes = "<" }
opt.textwidth = 0
opt.modelines = 0

opt.clipboard = "unnamedplus"
opt.whichwrap = "b,s,h,l,<,>,[,]"
opt.wildmode = "list:longest" -- 補完候補を一覧表示 (デフォルトの popup ではなく)

opt.swapfile = false
opt.visualbell = true
opt.splitbelow = true
opt.splitright = true
opt.suffixes = ".bak,~,.swp,.o,.info,.aux,.log,.dvi,.bbl,.blg,.brf,.cb,.ind,.idx,.ilg,.inx,.out,.toc"

-- 未使用の provider を無効化して起動を軽くする / checkhealth の警告を消す
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

vim.g.markdown_fenced_languages = {
  "zsh", "css", "html", "erb=eruby",
  "javascript", "js=javascript", "json=javascript",
  "ruby", "sass", "xml", "php",
}
