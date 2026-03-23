return {
  -- Comment toggle (gcc, gc)
  {
    "numToStr/Comment.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
  },
  -- vim-abolish (cr commands for case conversion)
  { "tpope/vim-abolish" },
  -- Window resizer
  { "simeji/winresizer" },
  -- vim-rails
  {
    "tpope/vim-rails",
    ft = "ruby",
  },
}
