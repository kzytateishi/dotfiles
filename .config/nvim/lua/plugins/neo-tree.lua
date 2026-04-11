return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    lazy = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function(_, opts)
      opts.commands = {
        close_all = function()
          vim.cmd("qall")
        end,
        collapse_all = function(state)
          local tree = state.tree
          local root = tree:get_nodes()[1]
          if not root then return end
          local function collapse(node)
            if node:has_children() then
              node:collapse()
              for _, child in ipairs(tree:get_nodes(node:get_id())) do
                collapse(child)
              end
            end
          end
          for _, child in ipairs(tree:get_nodes(root:get_id())) do
            collapse(child)
          end
          require("neo-tree.ui.renderer").redraw(state)
        end,
      }
      require("neo-tree").setup(opts)
    end,
    opts = {
      -- VSCode風: ソースごとのタブ表示
      source_selector = {
        winbar = true,
        sources = {
          { source = "filesystem", display_name = " Files" },
          { source = "git_status", display_name = " Git" },
          { source = "buffers", display_name = " Buffers" },
        },
      },
      window = {
        width = 35,
        mappings = {
          -- VSCode風キーマップ
          ["<CR>"] = "open",
          ["l"] = "open",
          ["h"] = "close_node",
          ["<C-v>"] = "open_vsplit",
          ["<C-x>"] = "open_split",
          ["<C-t>"] = "open_tabnew",
          ["P"] = { "toggle_preview", config = { use_float = true } },
          ["a"] = { "add", config = { show_path = "relative" } },
          ["d"] = "delete",
          ["r"] = "rename",
          ["c"] = "copy_to_clipboard",
          ["x"] = "cut_to_clipboard",
          ["p"] = "paste_from_clipboard",
          ["y"] = "copy",
          ["m"] = "move",
          ["R"] = "refresh",
          ["?"] = "show_help",
          ["z"] = "collapse_all",
          ["Q"] = "close_all",   -- commands.close_all = qall なので Neovim ごと終了する
          ["<"] = "prev_source",
          [">"] = "next_source",
        },
      },
      -- VSCode風ソート: ディレクトリ優先 → 大文字小文字無視のアルファベット順
      sort_function = function(a, b)
        if a.type ~= b.type then
          return a.type < b.type -- directory < file
        end
        return a.path:lower() < b.path:lower()
      end,
      filesystem = {
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = false,
          hide_by_name = { ".git", "node_modules", ".DS_Store" },
        },
        follow_current_file = { enabled = false },
        use_libuv_file_watcher = true,
        group_empty_dirs = true,
      },
      default_component_configs = {
        indent = {
          with_expanders = true,
          expander_collapsed = "",
          expander_expanded = "",
        },
        git_status = {
          symbols = {
            added     = "",
            modified  = "",
            deleted   = "",
            renamed   = "➜",
            untracked = "★",
            ignored   = "◌",
            unstaged  = "✗",
            staged    = "✓",
            conflict  = "",
          },
        },
      },
    },
    init = function()
      vim.keymap.set("n", "<Space>f", ":Neotree toggle<CR>", { silent = true, desc = "Toggle Neo-tree" })
      -- <leader>f だと <leader>ft (TodoTelescope) が毎回 timeoutlen 待ちになるため <Space>r に変更
      vim.keymap.set("n", "<Space>r", ":Neotree reveal<CR>", { silent = true, desc = "Reveal current file in Neo-tree" })
    end,
  },
}
