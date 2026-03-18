local opt = vim.opt

-- Encoding
opt.encoding = "utf-8"
opt.fileformats = { "unix", "dos", "mac" }

-- Indent
opt.autoindent = true
opt.smartindent = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.smarttab = true

-- Search
opt.incsearch = true
opt.ignorecase = true
opt.hlsearch = true
opt.smartcase = true

-- Display
opt.termguicolors = true
opt.signcolumn = "yes"
opt.number = true
opt.ruler = true
opt.scrolloff = 5
opt.showcmd = true
opt.showmatch = true
opt.showmode = true
opt.title = true
opt.laststatus = 2
opt.list = true
opt.listchars = { tab = ">-", trail = "-", extends = ">", precedes = "<" }
opt.textwidth = 0
opt.modelines = 0

-- Behavior
opt.autoread = true
opt.backspace = { "indent", "eol", "start" }
opt.clipboard = "unnamedplus"
opt.hidden = true
opt.history = 50
opt.whichwrap = "b,s,h,l,<,>,[,]"
opt.wildchar = 9 -- <tab>
opt.wildmenu = true
opt.wildmode = "list:longest"
opt.ttyfast = true

-- No backup/swap
opt.backup = false
opt.swapfile = false

-- No beep
opt.visualbell = true

-- Split direction (from vim-quickrun.rc.vim)
opt.splitbelow = true
opt.splitright = true

-- Suffixes
opt.suffixes = ".bak,~,.swp,.o,.info,.aux,.log,.dvi,.bbl,.blg,.brf,.cb,.ind,.idx,.ilg,.inx,.out,.toc"

-- Markdown fenced languages
vim.g.markdown_fenced_languages = {
  "zsh", "css", "html", "erb=eruby",
  "javascript", "js=javascript", "json=javascript",
  "ruby", "sass", "xml", "php",
}
