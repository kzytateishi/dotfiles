local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

augroup("RemoveDust", { clear = true })
autocmd("BufWritePre", {
  group = "RemoveDust",
  pattern = { "*.rb", "*.erb", "*.yml", "*.feature", "*.html", "*.xhtml", "*.css", "*.scss", "*.js", "*.coffee", "*.sh", "*.sql", "*.yaml" },
  callback = function()
    local cursor = vim.api.nvim_win_get_cursor(0)
    -- keeppatterns がないと保存のたびに \s\+$ が検索履歴に積まれる
    vim.cmd([[keeppatterns %s/\s\+$//ge]])
    vim.api.nvim_win_set_cursor(0, cursor)
  end,
})

augroup("ZenkakuSpace", { clear = true })
autocmd("ColorScheme", {
  group = "ZenkakuSpace",
  callback = function()
    vim.api.nvim_set_hl(0, "ZenkakuSpace", { underline = true, fg = "red" })
  end,
})
-- matchadd はウィンドウ単位。無条件に呼ぶと :e のたびに同じ match が積み上がるので
-- ウィンドウ変数で二重登録を防ぐ。
autocmd({ "VimEnter", "WinEnter", "BufWinEnter" }, {
  group = "ZenkakuSpace",
  callback = function()
    if vim.w.zenkaku_match_id then
      return
    end
    vim.w.zenkaku_match_id = vim.fn.matchadd("ZenkakuSpace", "\u{3000}")
  end,
})
-- Set highlight immediately
vim.api.nvim_set_hl(0, "ZenkakuSpace", { underline = true, fg = "red" })
