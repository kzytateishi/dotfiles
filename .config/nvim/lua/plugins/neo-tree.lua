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
      -- ウィンドウ設定
      window = {
        width = 35,
        mappings = {
          -- VSCode風キーマップ
          ["<CR>"] = "open",              -- Enter で開く
          ["l"] = "open",                 -- l でも開く
          ["h"] = "close_node",           -- h で閉じる
          ["<C-v>"] = "open_vsplit",      -- Ctrl-v で縦分割
          ["<C-x>"] = "open_split",       -- Ctrl-x で横分割
          ["<C-t>"] = "open_tabnew",      -- Ctrl-t でタブ
          ["P"] = { "toggle_preview", config = { use_float = true } },
          ["a"] = { "add", config = { show_path = "relative" } },
          ["d"] = "delete",
          ["r"] = "rename",
          ["c"] = "copy_to_clipboard",
          ["x"] = "cut_to_clipboard",
          ["p"] = "paste_from_clipboard",
          ["y"] = "copy",                 -- ファイルコピー
          ["m"] = "move",
          ["R"] = "refresh",
          ["?"] = "show_help",
          ["z"] = "collapse_all",
          ["Q"] = "close_all",            -- ツリー + 全バッファを閉じる
          ["<"] = "prev_source",          -- ソース切替（Files/Git/Buffers）
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
      -- ファイルシステム設定
      filesystem = {
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = false,
          hide_by_name = { ".git", "node_modules", ".DS_Store" },
        },
        follow_current_file = { enabled = false },
        use_libuv_file_watcher = true,              -- ファイル変更を自動検知
        group_empty_dirs = true,                    -- 空ディレクトリをまとめて表示
      },
      -- デフォルト設定
      default_component_configs = {
        indent = {
          with_expanders = true,   -- VSCode風の折りたたみ矢印
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
      vim.keymap.set("n", "<leader>f", ":Neotree reveal<CR>", { silent = true, desc = "Reveal current file in Neo-tree" })
    end,
  },
}
