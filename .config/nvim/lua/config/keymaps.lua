-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  vim.keymap.set(mode, lhs, rhs, opts)
end

map("i", "<C-l>", "<Right>", { desc = "Insert mode move right", remap = true })
map("i", "<C-h>", "<Left>", { desc = "Insert mode move left", remap = true })
map("i", "jj", "<Esc>", { desc = "escape", remap = true })

map("n", "L", "$", { desc = "Go to end of line", remap = true })
map("n", "H", "^", { desc = "Go to beginning of line", remap = true })
map("n", "<C-q>", "<cmd>q<cr>", { desc = "Quit", remap = true })
map("n", "<C-w>i", "<cmd>only<cr>", { desc = "Make current split full screen", remap = true })
map("n", "<leader>rr", ":!%:p<cr>", { desc = "Run current file", remap = true })

map("t", "<Esc>", "<C-\\><C-n>", { desc = "escape", remap = true })
map("t", "jj", "<C-\\><C-n>", { desc = "escape", remap = true })
map("t", ":", "<C-\\><C-n>:", { desc = "Enter command mode", remap = true })

vim.api.nvim_exec2(
  [[
    set wrap |
    set norelativenumber |
    au colorscheme * hi normal guibg=none |
    highlight normalfloat guibg=none
  ]],
  {}
)

vim.diagnostic.config({
  float = { border = "rounded" },
})

vim.api.nvim_command([[command! TmuxSplitV silent execute '!tmux split-window -v -e "cd %:p:h"']])
vim.api.nvim_command([[command! TmuxSplitH silent execute '!tmux split-window -h -e "cd %:p:h"']])
