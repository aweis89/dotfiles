-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local function map(mode, lhs, rhs, opts)
  opts = opts or { noremap = true, silent = true }
  vim.api.nvim_set_keymap(mode, lhs, rhs, opts)
end

map("i", "<C-l>", "<Right>", { desc = "Insert mode move right" })
map("i", "<C-h>", "<Left>", { desc = "Insert mode move left" })
map("i", "jj", "<Esc>", { desc = "escape" })

map("i", "<C-j", "<C-n>", { desc = "next" })
map("i", "<C-k", "<C-p>", { desc = "prev" })

map("n", "L", "$", { desc = "Go to end of line" })
map("n", "H", "^", { desc = "Go to beginning of line" })
map("n", "<C-q>", "<cmd>q<cr>", { desc = "Quit" })
map("n", "<C-w>i", "<cmd>only<cr>", { desc = "Make current split full screen" })
map("n", "<leader>rr", ":!%:p<cr>", { desc = "Run current file" })
-- make it harder to accidentally enter macro recording mode (which breaks keymapings)
map("n", "Q", "q", { noremap = true, silent = false })
map("n", "q", "<nop>", { noremap = false, silent = false })

-- Keep cursor at the bottom of the visual selection after you yank it.
map("v", "y", "ygv<Esc>")
-- Prevent selecting and pasting from overwriting what you originally copied.
map("x", "p", "pgvy")

vim.diagnostic.config({
  float = { border = "rounded" },
})

-- Create command mode alias for git=Git only when it's the first word
vim.cmd([[
  cnoreabbrev <expr> git getcmdtype() == ':' && getcmdline() =~ '^git$' ? 'Git' : 'git'
]])

local function create_tmux_split_command(direction)
  vim.api.nvim_create_user_command("TmuxSplit" .. direction, function()
    vim.cmd(
      string.format('silent !tmux split-window -%s -e "cd %s"', direction == "H" and "h" or "v", vim.fn.expand("%:p:h"))
    )
  end, {})
end
create_tmux_split_command("V")
create_tmux_split_command("H")

-- disable the default pager
vim.env.PAGER = "cat"

if vim.g.neovide then
  require("config.neovide")
end
