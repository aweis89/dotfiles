-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  vim.keymap.set(mode, lhs, rhs, opts)
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

-- Move focus between splits
map("n", "<C-a>h", "<C-w>h", { desc = "Focus left split" })
map("n", "<C-a>j", "<C-w>j", { desc = "Focus down split" })
map("n", "<C-a>k", "<C-w>k", { desc = "Focus up split" })
map("n", "<C-a>l", "<C-w>l", { desc = "Focus right split" })
map("t", "<C-a>h", "<C-\\><C-n><C-w>h", { desc = "Focus left split" })
map("t", "<C-a>j", "<C-\\><C-n><C-w>j", { desc = "Focus down split" })
map("t", "<C-a>k", "<C-\\><C-n><C-w>k", { desc = "Focus up split" })
map("t", "<C-a>l", "<C-\\><C-n><C-w>l", { desc = "Focus right split" })
map({ "t", "n" }, "<C-a>x", "<cmd>bwipeout!<cr>", { desc = "Close terminal" })

-- zoom
map({ "t", "n", "i" }, "<C-a>i", function()
  require("snacks.zen").zoom()
end, { desc = "Zoom toggle" })

map("t", "<C-v>", "<C-\\><C-n>pA", { noremap = false, desc = "Paste from clipboard" })
map("i", "<C-v>", "<ESC>pA", { noremap = false, desc = "Paste from clipboard" })
map("c", "<C-v>", "<C-R>+", { noremap = false, desc = "Paste from clipboard" })

-- Terminal close
map({ "t", "n" }, "<localleader>q", "<cmd>bwipeout!<cr>")
map({ "t", "n" }, "<localleader>c", "<cmd>close<cr>")

-- Keep cursor at the bottom of the visual selection after you yank it.
map("v", "y", "ygv<Esc>")
-- Prevent selecting and pasting from overwriting what you originally copied.
map("x", "p", "pgvy")

map("n", "<leader>wr", function()
  -- Attempt to write the current buffer
  -- pcall (protected call) allows us to catch errors if the write fails
  local write_ok, write_err = pcall(vim.cmd, "write")

  if not write_ok then
    -- If write failed (e.g., no filename, permissions issue), notify the user and stop.
    vim.notify("Write failed: " .. (write_err or "Unknown error"), vim.log.levels.ERROR)
    return
  end

  -- If the write was successful (or the buffer was not modified, in which case :write does nothing),
  -- then attempt to switch to the alternate buffer.
  -- 'noautocmd' is used to prevent BufLeave/BufEnter autocommands from triggering during the switch,
  -- which can make the switch feel faster and avoid unintended side effects.
  local switch_ok, switch_err = pcall(vim.cmd, "noautocmd b#")

  if not switch_ok then
    -- If switching failed (e.g., "E23: No alternate file"), notify the user.
    -- Vim will usually also display its own error message for this.
    vim.notify("Could not switch to alternate buffer: " .. (switch_err or "Unknown error"), vim.log.levels.WARN)
  end

  -- Check if the returned to buffer is a terminal, if it is ensure we enter insert mode
  local current_buf_id = vim.api.nvim_get_current_buf()
  if vim.api.nvim_buf_is_valid(current_buf_id) then
    local buftype = vim.api.nvim_get_option_value("buftype", { buf = current_buf_id })
    if buftype == "terminal" then
      vim.cmd.startinsert()
    end
  end
end, {
  desc = "Writes the current buffer and then switches to the alternate buffer (#).",
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

-- neovim pager: https://github.com/I60R/page
vim.env.PAGER = "page" -- -q 90000 -z 90000

if vim.g.neovide then
  require("config.neovide")
end
