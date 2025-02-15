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

map("n", "L", "$", { desc = "Go to end of line" })
map("n", "H", "^", { desc = "Go to beginning of line" })
map("n", "<C-q>", "<cmd>q<cr>", { desc = "Quit" })
map("n", "<C-w>i", "<cmd>only<cr>", { desc = "Make current split full screen" })
map("n", "<leader>rr", ":!%:p<cr>", { desc = "Run current file" })
-- Keep cursor at the bottom of the visual selection after you yank it.
map('v', 'y', 'ygv<Esc>')
-- Prevent selecting and pasting from overwriting what you originally copied.
map('x', 'p', 'pgvy')

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
  end,
})

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


vim.g.root_spec = { "lsp", { ".git", "lua", "go.mod" }, "cwd" }

local set_root = function()
  local root = LazyVim.root.get()
  if root == vim.fn.getcwd() then
    return
  end
  vim.notify('CWD: ' .. root)
  vim.fn.chdir(root)
end

local root_augroup = vim.api.nvim_create_augroup('MyAutoRoot', {})
vim.api.nvim_create_autocmd('BufEnter', { group = root_augroup, callback = set_root })

if vim.g.neovide then
  require("config.neovide")
end
