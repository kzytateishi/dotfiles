return {
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    opts = {
      options = {
        diagnostics = "nvim_lsp",
        offsets = {
          {
            filetype = "neo-tree",
            text = "File Explorer",
            highlight = "Directory",
            separator = true,
          },
        },
      },
    },
    keys = {
      { "<Space>", "<cmd>BufferLineCycleNext<CR>", desc = "Next buffer" },
      { "<S-Space>", "<cmd>BufferLineCyclePrev<CR>", desc = "Previous buffer" },
      { "<leader>bp", "<cmd>BufferLineTogglePin<CR>", desc = "Toggle pin" },
      { "<leader>bx", "<cmd>BufferLineCloseOthers<CR>", desc = "Close other buffers" },
    },
  },
}
