vim.g.mapleader = ","

local map = vim.keymap.set

map("n", "sh", "<C-w>h", { desc = "Move to left window" })
map("n", "sj", "<C-w>j", { desc = "Move to below window" })
map("n", "sk", "<C-w>k", { desc = "Move to above window" })
map("n", "sl", "<C-w>l", { desc = "Move to right window" })

map("n", "+", "<C-w>+", { desc = "Increase window height" })
map("n", "-", "<C-w>-", { desc = "Decrease window height" })
map("n", ")", "<C-w>>", { desc = "Increase window width" })
map("n", "(", "<C-w><", { desc = "Decrease window width" })

map("n", "T", ":tabnew<CR>", { desc = "New tab" })
map("n", "<leader>tx", ":tabclose<CR>", { desc = "Close tab" })
map("n", "<leader>tp", ":tabprevious<CR>", { desc = "Previous tab" })
-- NOTE: :tabNext は :tabprevious のエイリアス。次のタブは :tabnext (小文字)
map("n", "<leader>tn", ":tabnext<CR>", { desc = "Next tab" })

map("n", "<ESC><ESC>", ":nohlsearch<CR>", { silent = true, desc = "Clear search highlight" })

map("i", "<C-j>", "<Down>", { desc = "Move down in insert mode" })
map("i", "<C-k>", "<Up>", { desc = "Move up in insert mode" })
map("i", "<C-h>", "<Left>", { desc = "Move left in insert mode" })
map("i", "<C-l>", "<Right>", { desc = "Move right in insert mode" })

map("i", "jj", "<esc>", { silent = true, desc = "Exit insert mode" })

-- 0 は Vim がカウント入力中だけ特別扱いするので 10j などは壊れない。
-- 一方 9 を張るとカウント中も置換されて 9j が 1j、9G が G になるため張らない
-- (行末は $ をそのまま使う)。
map("n", "0", "^", { desc = "Go to first non-blank character" })

map("x", "v", "$h", { desc = "Select to end of line" })

-- leader (,) 始まりだと insert mode で読点を打つたびに timeoutlen 待ちになるため <C-g> 始まりにする
map("i", "<C-g>d", function() return os.date("%Y/%m/%d") end, { expr = true, desc = "Insert date" })
map("i", "<C-g>t", function() return os.date("%H:%M") end, { expr = true, desc = "Insert time" })

map("o", ")", "t)", { desc = "Till )" })
map("o", "(", "t(", { desc = "Till (" })
map("x", ")", "t)", { desc = "Till )" })
map("x", "(", "t(", { desc = "Till (" })

-- 旧 cp / cfp / cf から <leader>y* に変更:
--   cf が標準の `cf{char}` オペレータを潰し、さらに cfp を timeoutlen 待ちにしていた
local function copy_path(modifier, label)
  return function()
    local value = vim.fn.expand("%" .. modifier)
    if value == "" then
      vim.notify("No file name", vim.log.levels.WARN)
      return
    end
    vim.fn.setreg("*", value)
    vim.notify(label .. ": " .. value)
  end
end

map("n", "<leader>yp", copy_path("", "Copied relative path"), { silent = true, desc = "Copy relative path" })
map("n", "<leader>yP", copy_path(":p", "Copied full path"), { silent = true, desc = "Copy full path" })
map("n", "<leader>yn", copy_path(":t", "Copied filename"), { silent = true, desc = "Copy filename" })

vim.api.nvim_create_user_command("Jq", function(opts)
  local filter = opts.args ~= "" and opts.args or "."
  -- リスト形式で渡して shell を経由させない (フィルタが引用符を含んでも壊れない)。
  -- jq が失敗したときにバッファを空にしないよう、成否を見てから差し替える。
  local src = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
  local out = vim.fn.systemlist({ "jq", filter }, src)
  if vim.v.shell_error ~= 0 then
    vim.notify("jq failed: " .. table.concat(out, "\n"), vim.log.levels.ERROR)
    return
  end
  vim.api.nvim_buf_set_lines(0, 0, -1, false, out)
end, { nargs = "?", desc = "Format buffer through jq" })
