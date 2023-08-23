-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  vim.keymap.set(mode, lhs, rhs, opts)
end

function GithubBrowse()
  local path = vim.fn.expand('%')
  local line = vim.api.nvim_win_get_cursor(0)[1]
  os.execute('gh browse ' .. path .. ':' .. line)
end

map("n", "L", "$", { desc = "Go to end of line", remap = true })
map("n", "H", "^", { desc = "Go to begining of line", remap = true })
map("n", "<C-q>", "<cmd>q<cr>", { desc = "Quit", remap = true })
map("n", "<C-g>", "<cmd>lua GithubBrowse()<cr>", { desc = "Github open", remap = true })
map("n", "<leader>h", "<cmd>lua GithubBrowse()<cr>", { desc = "Github open", remap = true })
