local languages = {
  "lua", "ruby", "go", "python",
  "typescript", "javascript", "tsx",
  "json", "yaml", "html", "css",
  "markdown", "markdown_inline",
  "vim", "vimdoc", "bash",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local ts = require("nvim-treesitter")
      for _, lang in ipairs(languages) do
        if not pcall(vim.treesitter.language.inspect, lang) then
          ts.install(lang)
        end
      end

      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          pcall(vim.treesitter.start)
        end,
      })
    end,
  },
}
