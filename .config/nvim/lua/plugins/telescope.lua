return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    keys = {
      { "<C-g>", function() require("telescope.builtin").live_grep() end, desc = "Live grep (Rg)" },
      { "<C-p>", function() require("telescope.builtin").git_files() end, desc = "Git files (GFiles)" },
      { "<C-f>", function() require("telescope.builtin").oldfiles() end, desc = "Old files (History)" },
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          file_ignore_patterns = { "node_modules", ".git/" },
        },
      })
      telescope.load_extension("fzf")
    end,
  },
}
