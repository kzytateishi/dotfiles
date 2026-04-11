return {
  {
    "stevearc/conform.nvim",
    cmd = "ConformInfo",
    keys = {
      {
        "<leader>cf",
        function() require("conform").format({ async = true }) end,
        mode = { "n", "x" },
        desc = "Format buffer / selection",
      },
    },
    opts = {
      -- ruby は ruby_lsp (プロジェクトの rubocop 設定を使う) に任せるので書かない。
      -- 未導入の formatter は :ConformInfo で確認できる。
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "ruff_format" },
        go = { "goimports", "gofmt" },
        javascript = { "prettierd", "prettier", stop_after_first = true },
        typescript = { "prettierd", "prettier", stop_after_first = true },
        javascriptreact = { "prettierd", "prettier", stop_after_first = true },
        typescriptreact = { "prettierd", "prettier", stop_after_first = true },
        json = { "prettierd", "prettier", stop_after_first = true },
        yaml = { "prettierd", "prettier", stop_after_first = true },
      },
      -- formatter が無い filetype は LSP の整形に落とす
      default_format_opts = { lsp_format = "fallback" },
      -- format_on_save は付けない。整形されていない既存リポジトリで
      -- 保存のたびに無関係な差分が出るため、<leader>cf で明示的に実行する。
    },
  },
}
