return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    -- open_mapping は使わない (keys と二重に <C-\> を張り、terminal mode でも
    -- 奪うため <C-\><C-n> が曖昧になる)。遅延ロードは keys 側に任せる。
    -- keys だけだと :ToggleTerm / :TermExec が E492 になるので cmd も登録する
    cmd = { "ToggleTerm", "ToggleTermToggleAll", "TermExec", "TermSelect" },
    keys = {
      { "<C-\\>", "<cmd>ToggleTerm<CR>", desc = "Toggle terminal" },
    },
    opts = {
      direction = "float",
      float_opts = {
        border = "curved",
      },
    },
  },
}
