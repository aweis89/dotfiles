-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
local function augroup(name)
  return vim.api.nvim_create_augroup("config_" .. name, { clear = true })
end

local function log(msg, level)
  vim.notify(msg, level, { title = "autocmd.lua" })
end

vim.g.root_spec = { "lsp", { ".git", "lua", "go.mod", "base" }, "cwd" }
-- vim.g.root_spec = { ".git" }

vim.keymap.set("n", "<leader>fd", function()
  local cwd = "~" .. string.sub(vim.fn.getcwd(), #vim.env.HOME + 1)
  log(cwd, vim.log.levels.INFO)
end, { desc = "Show CWD" })

-- Run at startup and on every :cd / :lcd / :tcd or autochdir change
vim.api.nvim_create_autocmd({ "DirChanged" }, {
  group = augroup("direnv_auto_load"),
  pattern = "*",
  callback = function()
    local cmd = { "direnv", "export", "vim" }

    vim.system(cmd, { text = true }, function(res)
      if res.code ~= 0 then
        vim.schedule(function()
          log(res.stderr ~= "" and res.stderr or "direnv export failed", vim.log.levels.WARN)
        end)
        return
      end
      vim.schedule(function()
        local output = res.stdout
        if output and #output > 0 then
          log("Direnv loaded env variables", vim.log.levels.INFO)
          vim.cmd(output)
        end
      end)
    end)
  end,
})

-- Auto-save current buffer when leaving insert mode or after text changes
vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
  group = augroup("auto_save_on_insert_leave"),
  callback = function()
    if vim.bo.buftype == "" and vim.bo.filetype ~= "gitcommit" then
      vim.cmd("silent! update")
    end
  end,
})
