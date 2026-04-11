return {
  {
    -- williamboman/* は mason-org/* に移管済み
    "mason-org/mason.nvim",
    -- 下の mason-lspconfig が dependencies で読み込むので、それ任せにする。
    -- lazy.nvim の defaults.lazy=false 下では、ハンドラ (cmd/event/keys) を
    -- 持たない spec は eager になるため lazy=true を明示する必要がある。
    lazy = true,
    opts = {},
  },
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = { "mason.nvim" },
    -- automatic_enable = false にしたので役割は ensure_installed だけ。
    -- LSP が要るときは nvim-lspconfig が dependencies 経由で先に読み込む。
    event = "VeryLazy",
    opts = {
      ensure_installed = {
        "ruby_lsp",
        "ts_ls",
        "gopls",
        "pyright",
        "lua_ls",
      },
      -- v2 の既定 (true) だと vim.lsp.config() より先に enable されてしまい、
      -- capabilities や lua_ls の settings が効かない。enable は下の
      -- nvim-lspconfig 側に一本化する。
      automatic_enable = false,
    },
  },
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason.nvim",
      "mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Neovim 0.11+ は grn (rename) / gra (code action) / grr (references) /
      -- gri (implementation) / grt (type definition) / K (hover) を標準で張るので
      -- ここでは重複させない。`gr` を単体で張ると gr* プレフィックス全部が
      -- timeoutlen 待ちになるため特に禁止。
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if client and client.name == "ruby_lsp" then
            client.server_capabilities.semanticTokensProvider = nil
          end

          local opts = { buffer = ev.buf }
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)
        end,
      })

      local servers = {
        ruby_lsp = {},
        ts_ls = {},
        gopls = {},
        pyright = {},
        lua_ls = {
          settings = {
            Lua = {
              workspace = { checkThirdParty = false },
              telemetry = { enable = false },
            },
          },
        },
      }

      for name, config in pairs(servers) do
        config.capabilities = capabilities
        vim.lsp.config(name, config)
      end

      vim.lsp.enable(vim.tbl_keys(servers))
    end,
  },
}
