-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
local settings = {
  "set norelativenumber",
}

for _, value in ipairs(settings) do
  vim.api.nvim_exec(value, nil)
end
