vim.g.mapleader = ","

local map = vim.keymap.set

-- Window navigation
map("n", "sh", "<C-w>h", { desc = "Move to left window" })
map("n", "sj", "<C-w>j", { desc = "Move to below window" })
map("n", "sk", "<C-w>k", { desc = "Move to above window" })
map("n", "sl", "<C-w>l", { desc = "Move to right window" })

-- Window resize
map("n", "+", "<C-w>+", { desc = "Increase window height" })
map("n", "-", "<C-w>-", { desc = "Decrease window height" })
map("n", ")", "<C-w>>", { desc = "Increase window width" })
map("n", "(", "<C-w><", { desc = "Decrease window width" })

-- Tab
map("n", "T", ":tabnew<CR>", { desc = "New tab" })
map("n", "<leader>tx", ":tabclose<CR>", { desc = "Close tab" })
map("n", "<leader>tp", ":tabprevious<CR>", { desc = "Previous tab" })
map("n", "<leader>tn", ":tabNext<CR>", { desc = "Next tab" })

-- Clear search highlight
map("n", "<ESC><ESC>", ":nohlsearch<CR>", { silent = true, desc = "Clear search highlight" })

-- Insert mode movement
map("i", "<C-j>", "<Down>", { desc = "Move down in insert mode" })
map("i", "<C-k>", "<Up>", { desc = "Move up in insert mode" })
map("i", "<C-h>", "<Left>", { desc = "Move left in insert mode" })
map("i", "<C-l>", "<Right>", { desc = "Move right in insert mode" })

-- Exit insert mode
map("i", "<C-[>", "<esc>", { silent = true, desc = "Exit insert mode" })
map("i", "jj", "<esc>", { silent = true, desc = "Exit insert mode" })

-- Line start/end
map("n", "0", "^", { desc = "Go to first non-blank character" })
map("n", "9", "$", { desc = "Go to end of line" })

-- Visual mode: select to end of line
map("x", "v", "$h", { desc = "Select to end of line" })

-- Date/time insertion
map("i", "<Leader>date", function() return os.date("%Y/%m/%d") end, { expr = true, desc = "Insert date" })
map("i", "<Leader>time", function() return os.date("%H:%M") end, { expr = true, desc = "Insert time" })

-- Buffer navigation (managed by bufferline plugin)

-- Operator-pending: parentheses
map("o", ")", "t)", { desc = "Till )" })
map("o", "(", "t(", { desc = "Till (" })
map("x", ")", "t)", { desc = "Till )" })
map("x", "(", "t(", { desc = "Till (" })

-- Copy path functions
map("n", "cp", function()
  vim.fn.setreg("*", vim.fn.expand("%"))
  vim.notify("Copied: " .. vim.fn.expand("%"))
end, { silent = true, desc = "Copy relative path" })

map("n", "cfp", function()
  vim.fn.setreg("*", vim.fn.expand("%:p"))
  vim.notify("Copied: " .. vim.fn.expand("%:p"))
end, { silent = true, desc = "Copy full path" })

map("n", "cf", function()
  vim.fn.setreg("*", vim.fn.expand("%:t"))
  vim.notify("Copied: " .. vim.fn.expand("%:t"))
end, { silent = true, desc = "Copy filename" })

-- Jq command
vim.api.nvim_create_user_command("Jq", function(opts)
  local arg = opts.args ~= "" and opts.args or "."
  vim.cmd('%! jq "' .. arg .. '"')
end, { nargs = "?" })
