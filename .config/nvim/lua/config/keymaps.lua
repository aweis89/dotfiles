-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  vim.keymap.set(mode, lhs, rhs, opts)
end

local function get_relative_path_to_repo_root()
  local handle = io.popen('git rev-parse --show-prefix')
  local git_prefix = handle:read("*a"):gsub("%s+$", "") -- Remove trailing whitespace, including newline
  handle:close()

  if git_prefix == "" then
    -- Either not in a git repo or in the root of the repo
    return vim.fn.expand('%')
  else
    return git_prefix .. vim.fn.expand('%:t')
  end
end

local function echo(str)
  vim.api.nvim_echo({ { str, None } }, false, {})
end

function GithubBrowse()
  local repo_path = get_relative_path_to_repo_root()
  local current_line = vim.api.nvim_win_get_cursor(0)[1]
  local handle = io.popen('gh browse ' .. repo_path .. ':' .. current_line)
  handle:close()
end

map("n", "L", "$", { desc = "Go to end of line", remap = true })
map("n", "H", "^", { desc = "Go to begining of line", remap = true })
map("n", "<C-q>", "<cmd>q<cr>", { desc = "Quit", remap = true })
map("n", "<C-g>", "<cmd>lua GithubBrowse()<cr>", { desc = "Github open", remap = true })
