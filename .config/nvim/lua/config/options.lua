-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
-- Edgy recommended options
-- views can only be fully collapsed with the global statusline
vim.opt.laststatus = 3
-- Default splitting will cause your main splits to jump when opening an edgebar.
-- To prevent this, set `splitkeep` to either `screen` or `topline`.
vim.opt.splitkeep = "screen"
-- Enable line wrapping with visual indicator
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakindent = true
vim.opt.showbreak = "↪ "

-- Configure clipboard
vim.opt.clipboard = { 'unnamed', 'unnamedplus' }

-- Set up key remaps
local keymap = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }
local opts_f = { noremap = false, silent = true }

-- Use 'y' to yank selected text; 'yy' to yank the current line

-- Keep cursor at the bottom of the visual selection after you yank it.
keymap('v', 'y', 'ygv<Esc>', opts)

-- Prevent selecting and pasting from overwriting what you originally copied.
keymap('x', 'p', 'pgvy', opts)

if vim.g.neovide then
  vim.api.nvim_set_keymap('v', '<sc-c>', '"+y', { noremap = true })
  vim.api.nvim_set_keymap('n', '<sc-v>', 'l"+P', { noremap = true })
  vim.api.nvim_set_keymap('v', '<sc-v>', '"+P', { noremap = true })
  vim.api.nvim_set_keymap('c', '<sc-v>', '<C-o>l<C-o>"+<C-o>P<C-o>l', { noremap = true })
  vim.api.nvim_set_keymap('i', '<sc-v>', '<ESC>l"+Pli', { noremap = true })
  vim.api.nvim_set_keymap('t', '<sc-v>', '<C-\\><C-n>"+Pi', { noremap = true })
  vim.g.neovide_theme = 'gruvybox'

  -- modity to add italic to `Operator Mono Book Italic` and bold to `Operator Mono Medium` using these docs: https://neovide.dev/configuration.html ai!
  vim.o.guifont = "Operator Mono Book:h21" -- text below applies for VimScript
  vim.env.DEEPSEEK_API_KEY = 'sk-0d415e9c1f95418fa1ed4268d792d3c4'
end
