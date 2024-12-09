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

vim.api.nvim_create_autocmd("TermOpen", {
  callback = function()
    local function tmap(key, val)
      local opts = { buffer = 0 }
      vim.keymap.set("t", key, val, opts)
    end
    -- exit insert mode
    tmap("<Esc>", "<C-\\><C-n>")
    tmap("jj", "<C-\\><C-n>")
    -- enter command mode
    tmap(":", "<C-\\><C-n>:")
    -- scrolling up/down
    tmap("<C-u>", "<C-\\><C-n><C-u>")
    tmap("<C-d>", "<C-\\><C-n><C-d>")
    -- remove line numbers
    vim.wo.number = false
    vim.wo.relativenumber = false
    -- auto start terminal in insert mode
    vim.cmd("startinsert")
  end,
})

vim.diagnostic.config({
  float = { border = "rounded" },
})

-- Create command mode alias for git=Git only when it's the first word
vim.cmd([[
  cnoreabbrev <expr> git getcmdtype() == ':' && getcmdline() =~ '^git$' ? 'Neogit' : 'git'
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
