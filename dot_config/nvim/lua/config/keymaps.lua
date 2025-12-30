-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local keymaps = {
  -- Insert mode navigation
  { "i", "<C-l>", "<Right>", { desc = "Insert mode move right" } },
  { "i", "<C-h>", "<Left>", { desc = "Insert mode move left" } },
  { "i", "jj", "<Esc>", { desc = "escape" } },
  { "i", "<C-j>", "<C-n>", { desc = "next" } },
  { "i", "<C-k>", "<C-p>", { desc = "prev" } },

  -- Insert mode - signature help
  { "i", "<C-s>", "<Esc>:lua vim.lsp.buf.signature_help()<cr>a", { desc = "Show signature help" } },

  -- Insert mode - escape
  { "i", "<C-c>", "<Esc>", { desc = "Escape" } },

  -- Normal mode - line navigation
  { "n", "L", "$", { desc = "Go to end of line" } },
  { "n", "H", "^", { desc = "Go to beginning of line" } },
  { "n", "<C-q>", "<cmd>q<cr>", { desc = "Quit" } },
  { "n", "<C-w>i", "<cmd>only<cr>", { desc = "Make current split full screen" } },
  { "n", "<leader>rr", ":!%:p<cr>", { desc = "Run current file" } },

  -- Make it harder to accidentally enter macro recording mode (which breaks keymapings)
  { "n", "Q", "q", { noremap = true, silent = false } },
  { "n", "q", "<nop>", { noremap = false, silent = false } },

  -- Move focus between splits - normal mode
  { "n", "<C-a>h", "<C-w>h", { desc = "Focus left split" } },
  { "n", "<C-a>j", "<C-w>j", { desc = "Focus down split" } },
  { "n", "<C-a>k", "<C-w>k", { desc = "Focus up split" } },
  { "n", "<C-a>l", "<C-w>l", { desc = "Focus right split" } },

  -- Move focus between splits - terminal mode
  { "t", "<C-a>h", "<C-\\><C-n><C-w>h", { desc = "Focus left split" } },
  { "t", "<C-a>j", "<C-\\><C-n><C-w>j", { desc = "Focus down split" } },
  { "t", "<C-a>k", "<C-\\><C-n><C-w>k", { desc = "Focus up split" } },
  { "t", "<C-a>l", "<C-\\><C-n><C-w>l", { desc = "Focus right split" } },

  -- Terminal/normal mode - close
  { { "t", "n" }, "<C-a>x", "<cmd>bwipeout!<cr>", { desc = "Close terminal" } },
  { { "t", "n" }, "<localleader>q", "<cmd>bwipeout!<cr>" },
  { { "t", "n" }, "<localleader>c", "<cmd>close<cr>" },

  -- Paste from clipboard
  { "t", "<C-v>", "<C-\\><C-n>pA", { noremap = false, desc = "Paste from clipboard" } },
  { "i", "<C-v>", "<ESC>pA", { noremap = false, desc = "Paste from clipboard" } },
  { "c", "<C-v>", "<C-R>+", { noremap = false, desc = "Paste from clipboard" } },

  -- Visual mode - keep cursor at bottom after yank
  { "v", "y", "ygv<Esc>" },

  -- Visual mode - prevent paste from overwriting original copy
  { "x", "p", "pgvy" },

  -- Execute current file
  {
    "n",
    "<C-x>",
    function()
      local current_file = vim.fn.expand("%")
      if current_file == "" then
        vim.notify("No file to execute", vim.log.levels.WARN)
        return
      end

      -- Create vertical split
      vim.cmd("vsplit")

      -- Create terminal and run the command
      local cmd = "sh " .. vim.fn.shellescape(current_file)
      vim.cmd("terminal " .. cmd)
    end,
    { desc = "Run current file in shell (terminal)" },
  },

  -- Zoom toggle
  {
    { "t", "n", "i" },
    "<C-a>i",
    function()
      require("snacks.zen").zoom()
    end,
    { desc = "Zoom toggle" },
  },

  -- cd to LazyVim root
  {
    "n",
    "<leader>W",
    function()
      local root = LazyVim.root()
      vim.fn.chdir(root)
      vim.notify("cd " .. root)
    end,
    { desc = "cd to Root" },
  },
}

-- Apply all keymaps
for _, keymap in ipairs(keymaps) do
  vim.keymap.set(keymap[1], keymap[2], keymap[3], keymap[4] or {})
end

-- Create command mode alias for git=Git only when it's the first word
vim.cmd([[
  cnoreabbrev <expr> git getcmdtype() == ':' && getcmdline() =~ '^git$' ? 'Git' : 'git'
]])

local function create_tmux_split_command(cmd_suffix, tmux_flag)
  vim.api.nvim_create_user_command("TmuxSplit" .. cmd_suffix, function()
    local path = vim.fn.expand("%:p:h")
    vim.cmd(string.format('silent !tmux split-window -%s -e "cd %s"', tmux_flag, path))
  end, {})
end
create_tmux_split_command("V", "v")
create_tmux_split_command("H", "h")

-- neovim pager: https://github.com/I60R/page
vim.env.PAGER = "page" -- -q 90000 -z 90000

if vim.g.neovide then
  require("config.neovide")
end
