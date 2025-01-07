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

vim.opt.timeoutlen = 1000

-- Set up key remaps
local keymap = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

-- Keep cursor at the bottom of the visual selection after you yank it.
keymap('v', 'y', 'ygv<Esc>', opts)
-- Prevent selecting and pasting from overwriting what you originally copied.
keymap('x', 'p', 'pgvy', opts)

-- add an autoccommand to set terminal to startinsert
vim.api.nvim_create_autocmd("TermOpen", {
  callback = function()
    vim.cmd.startinsert()
  end
})

require("config.neovide")
