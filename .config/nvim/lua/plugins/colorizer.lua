return {
  {
    "NvChad/nvim-colorizer.lua",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      user_default_options = {
        css = true,
        tailwind = true,
        names = false,
      },
      -- "*" だとログや minify 済みファイルにも tailwind マッチャが走って重い
      filetypes = {
        "css", "scss", "sass", "less",
        "html", "heex", "eruby",
        "javascript", "javascriptreact",
        "typescript", "typescriptreact",
        "vue", "svelte", "dart", "lua", "conf",
      },
    },
  },
}
