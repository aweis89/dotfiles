-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
local function augroup(name)
  return vim.api.nvim_create_augroup("config_" .. name, { clear = true })
end

vim.api.nvim_create_autocmd("TermOpen", {
  group = augroup("terminal_setup"),
  callback = function()
    local function tmap(key, val)
      local opts = { buffer = 0 }
      vim.keymap.set("t", key, val, opts)
    end
    -- exit insert mode
    tmap("jj", "<C-\\><C-n>")
    -- enter command mode
    tmap("<C-;>", "<C-\\><C-n>:")
    -- scrolling up/down
    tmap("<C-u>", "<C-\\><C-n><C-u>")
    tmap("<C-d>", "<C-\\><C-n><C-d>")
    -- remove line numbers
    vim.wo.number = false
    vim.wo.relativenumber = false
  end,
})

vim.g.root_spec = { "lsp", { ".git", "lua", "go.mod", "base" }, "cwd" }
-- vim.g.root_spec = { ".git" }

vim.api.nvim_create_autocmd("BufEnter", {
  group = augroup("auto_root"),
  callback = function(arg)
    local root = LazyVim.root.get()
    if root == vim.fn.getcwd() then
      return
    end

    -- List of filenames to skip
    local skip_dir_change_files = { "COMMIT_EDITMSG" }
    local buf_name = vim.api.nvim_buf_get_name(arg.buf)

    if buf_name then
      local current_filename = vim.fn.fnamemodify(buf_name, ":t")
      for _, skip_file in ipairs(skip_dir_change_files) do
        if current_filename == skip_file then
          return
        end
      end
    end

    vim.fn.chdir(root)
    local display_root = root
    if vim.env.HOME and root:sub(1, #vim.env.HOME) == vim.env.HOME then
      display_root = "~" .. root:sub(#vim.env.HOME + 1)
    end
    vim.notify("cwd: " .. display_root, vim.log.levels.INFO)
  end,
})
vim.keymap.set("n", "<leader>fd", function()
  local cwd = "~" .. string.sub(vim.fn.getcwd(), #vim.env.HOME + 1)
  vim.notify(cwd)
end, { desc = "Show CWD" })

-- Run at startup and on every :cd / :lcd / :tcd or autochdir change
vim.api.nvim_create_autocmd({ "DirChanged", "VimEnter" }, {
  group = augroup("direnv_auto_load"),
  pattern = "*",
  callback = function()
    local function log(msg, level)
      vim.notify("[direnv] " .. msg, level)
    end

    local cmd = { "direnv", "export", "vim" }

    vim.system(cmd, { text = true }, function(res)
      if res.code == 0 then
        vim.schedule(function()
          local output = res.stdout
          if output and #output > 0 then
            log("Loaded environment variables", vim.log.levels.INFO)
            vim.cmd(output)
          end
        end)
      else
        vim.schedule(function()
          log(res.stderr ~= "" and res.stderr or "export failed", vim.log.levels.WARN)
        end)
      end
    end)
  end,
})

-- Auto-save current buffer when leaving insert mode or after text changes
vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
  group = augroup("auto_save_on_insert_leave"),
  command = "silent update",
})
