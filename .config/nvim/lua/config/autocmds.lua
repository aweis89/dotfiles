-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
local function augroup(name)
  return vim.api.nvim_create_augroup("lazyvim_" .. name, { clear = true })
end

vim.api.nvim_create_autocmd("BufWinEnter", {
  group = augroup("ai_commit_msg"),
  pattern = "COMMIT_EDITMSG",
  callback = function()
    vim.system({ "c-msg" }, {}, function(res)
      vim.schedule(function()
        if res.code ~= 0 then
          vim.notify(res.stderr)
          return
        end
        local msg = res.stdout
        if msg == nil or msg == "" then
          vim.notify("No commit message")
        else
          vim.api.nvim_buf_set_lines(0, 0, 1, false, vim.split(msg, "\n"))
        end
      end)
    end)
  end,
})
