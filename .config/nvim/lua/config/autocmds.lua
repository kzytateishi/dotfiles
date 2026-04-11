local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Remove trailing whitespace on save
augroup("RemoveDust", { clear = true })
autocmd("BufWritePre", {
  group = "RemoveDust",
  pattern = { "*.rb", "*.erb", "*.yml", "*.feature", "*.html", "*.xhtml", "*.css", "*.scss", "*.js", "*.coffee", "*.sh", "*.sql", "*.yaml" },
  callback = function()
    local cursor = vim.api.nvim_win_get_cursor(0)
    vim.cmd([[%s/\s\+$//ge]])
    vim.api.nvim_win_set_cursor(0, cursor)
  end,
})

-- Highlight zenkaku (full-width) spaces
augroup("ZenkakuSpace", { clear = true })
autocmd("ColorScheme", {
  group = "ZenkakuSpace",
  callback = function()
    vim.api.nvim_set_hl(0, "ZenkakuSpace", { underline = true, fg = "red" })
  end,
})
autocmd({ "VimEnter", "WinEnter", "BufRead" }, {
  group = "ZenkakuSpace",
  callback = function()
    vim.fn.matchadd("ZenkakuSpace", "\u{3000}")
  end,
})
-- Set highlight immediately
vim.api.nvim_set_hl(0, "ZenkakuSpace", { underline = true, fg = "red" })
