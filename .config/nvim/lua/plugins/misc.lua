return {
  -- Comment.nvim は入れない (Neovim 0.10+ の組込み gc と重複するため)

  -- vim-abolish (crs/crc/crm/cru などの case 変換、:Subvert)
  {
    "tpope/vim-abolish",
    cmd = { "Abolish", "Subvert", "S" },
    keys = { { "cr", mode = "n", desc = "Coerce case (abolish)" } },
  },

  {
    "simeji/winresizer",
    cmd = "ResizeMode",
    keys = { { "<C-e>", "<cmd>ResizeMode<CR>", desc = "Window resize mode" } },
  },

  {
    "tpope/vim-rails",
    ft = "ruby",
  },
}
