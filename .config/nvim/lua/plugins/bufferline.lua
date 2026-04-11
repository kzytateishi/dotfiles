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
      -- 旧 <Space> / <S-Space> から変更:
      --   <Space> 単体は <Space>f (Neo-tree) を毎回 timeoutlen 待ちにしていた
      --   <S-Space> は大半の端末が <Space> と区別できず実質死んでいた
      { "<Tab>", "<cmd>BufferLineCycleNext<CR>", desc = "Next buffer" },
      { "<S-Tab>", "<cmd>BufferLineCyclePrev<CR>", desc = "Previous buffer" },
      { "<leader>bp", "<cmd>BufferLineTogglePin<CR>", desc = "Toggle pin" },
      { "<leader>bx", "<cmd>BufferLineCloseOthers<CR>", desc = "Close other buffers" },
    },
  },
}
