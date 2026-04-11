return {
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      modes = {
        char = {
          -- 既定では f/F/t/T を奪う。T は <leader>tn 等と別に :tabnew に
          -- 割り当てているので、flash 側から除外して衝突を防ぐ。
          keys = { "f", "F", "t" },
        },
      },
    },
    keys = {
      { "<leader>s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "<leader>S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
    },
  },
}
