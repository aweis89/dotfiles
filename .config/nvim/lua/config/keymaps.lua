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

-- In-order to work in floats as well, we need to use TermOpen autocmd
vim.api.nvim_create_autocmd("TermOpen", {
  callback = function()
    local function tmap(key, val)
      vim.api.nvim_buf_set_keymap(0, "t", key, val, { noremap = true, silent = true })
    end
    tmap("<Esc>", "<C-\\><C-n>")
    tmap(":", "<C-\\><C-n>:")
    tmap("<C-u>", "<C-\\><C-n><C-u>")
    tmap("<C-d>", "<C-\\><C-n><C-d>")
    tmap("jj", "<C-\\><C-n>")
    vim.wo.number = false
    vim.wo.relativenumber = false
    print("Mappings applied for terminal buffer " .. vim.api.nvim_get_current_buf())
  end,
})

vim.diagnostic.config({
  float = { border = "rounded" },
})

-- Create command mode alias for git=Git
vim.cmd("cnoreabbrev git Neogit")

local function create_tmux_split_command(direction)
  vim.api.nvim_create_user_command("TmuxSplit" .. direction, function()
    vim.cmd(
      string.format('silent !tmux split-window -%s -e "cd %s"', direction == "H" and "h" or "v", vim.fn.expand("%:p:h"))
    )
  end, {})
end
create_tmux_split_command("V")
create_tmux_split_command("H")
