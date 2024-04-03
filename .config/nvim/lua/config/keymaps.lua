-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

function GithubBrowse()
  local path = vim.fn.expand("%")
  local line = vim.api.nvim_win_get_cursor(0)[1]
  local handle = io.popen("gh browse " .. path .. ":" .. line)
  if handle == nil then
    vim.notify("Failed to open file in Github")
    return
  end
  local result = handle:read("*a")
  handle:close()
  vim.notify(result)
end

local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  vim.keymap.set(mode, lhs, rhs, opts)
end

map("n", "L", "$", { desc = "Go to end of line", remap = true })
map("n", "H", "^", { desc = "Go to beginning of line", remap = true })
map("n", "<C-q>", "<cmd>q<cr>", { desc = "Quit", remap = true })
map("n", "<C-g>", "<cmd>lua GithubBrowse()<cr>", { desc = "Github open", remap = true })
map("n", "<leader>h", "<cmd>lua GithubBrowse()<cr>", { desc = "Github open", remap = true })
map("i", "<C-l>", "<Right>", { desc = "Insert mode move right", remap = true })
map("i", "<C-h>", "<Left>", { desc = "Insert mode move left", remap = true })
map("n", "<C-w>i", "<cmd>only<cr>", { desc = "Make current split full screen", remap = true })
map("n", "<leader>rr", ":!%:p<cr>", { desc = "Run current file", remap = true })

local settings = {
  [[set norelativenumber]],
  [[au ColorScheme * hi Normal guibg=none]],
  [[highlight NormalFloat guibg=NONE]],
}

for _, value in ipairs(settings) do
  vim.api.nvim_exec(value, nil)
end

vim.diagnostic.config({
  float = { border = "rounded" },
})
