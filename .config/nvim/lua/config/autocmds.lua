-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
local function augroup(name)
  return vim.api.nvim_create_augroup("config_" .. name, { clear = true })
end

-- Autocommand to populate commit message using c-msg
vim.api.nvim_create_autocmd("BufWinEnter", {
  group = augroup("ai_commit_msg_populate"),
  pattern = "COMMIT_EDITMSG",
  callback = function()
    vim.notify("Generating commit message...", vim.log.levels.INFO)
    vim.system({ "ai-commit-msg" }, {}, function(res)
      vim.schedule(function()
        if res.code ~= 0 then
          vim.notify(res.stderr)
          return
        end
        local msg = res.stdout
        if msg == nil or msg == "" then
          vim.notify("No commit message")
        else
          -- Check if the first line is empty or only whitespace
          local first_line_content = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1]
          if first_line_content == nil or vim.fn.trim(first_line_content) == "" then
            -- First line is empty, replace it with the message
            vim.api.nvim_buf_set_lines(0, 0, 1, false, vim.split(msg, "\n"))
          else
            -- First line has content, insert below with comments
            local comment_prefix = "# "
            local commented_msg_lines = {}
            for _, line in ipairs(vim.split(msg, "\n")) do
              table.insert(commented_msg_lines, comment_prefix .. line)
            end

            -- Insert a blank line at index 1 (second line)
            vim.api.nvim_buf_set_lines(0, 1, 1, false, { "" })
            -- Insert the commented message starting at index 2 (third line)
            vim.api.nvim_buf_set_lines(0, 2, 2, false, commented_msg_lines)
          end
          vim.notify("Commit message generated", vim.log.levels.INFO)
        end
      end)
    end)
  end,
})

-- Autocommand to prompt for push after closing the commit message buffer
vim.api.nvim_create_autocmd("BufDelete", {
  group = augroup("ai_commit_push_prompt"),
  pattern = "COMMIT_EDITMSG",
  callback = function(args)
    -- Defer the prompt slightly to allow git commit process to potentially start/finish
    vim.defer_fn(function()
      -- Get the current branch name
      local branch_name = vim.fn.trim(vim.fn.system("git rev-parse --abbrev-ref HEAD"))
      -- Ask the user if they want to push
      local prompt_message = string.format("Push commit to '%s'? (y/N): ", branch_name)
      vim.ui.input({ prompt = prompt_message }, function(input)
        if input and input:lower() == "y" then
          vim.cmd("Git push")
        end
      end)
    end, 100) -- Small delay (100ms)
  end,
})

vim.api.nvim_create_autocmd("TermOpen", {
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

local patterns = vim.list_extend(vim.g.root_spec[2], {
  "go.mod",
  "base", -- quizlet-infrastructure
})

vim.g.root_spec = { "lsp", patterns, "cwd" }

local root_augroup = vim.api.nvim_create_augroup("MyAutoRoot", {})

vim.api.nvim_create_autocmd("BufEnter", {
  group = root_augroup,
  callback = function()
    local root = LazyVim.root.get()
    if root == vim.fn.getcwd() then
      return
    end
    vim.fn.chdir(root)
    vim.notify("cwd: " .. root)
  end,
})

vim.api.nvim_create_autocmd("BufEnter", { -- Trigger when entering a buffer
  group = vim.api.nvim_create_augroup("ZshEditCmdSetup", { clear = true }),
  pattern = "zsh-edit-cmd-nvim.*", -- Match buffers whose name starts with this pattern
  -- Adjust if your mktemp pattern in zsh is different
  desc = "Map q to :wq for Zsh command editing buffer",
  callback = function(args)
    vim.keymap.set("n", "q", ":wq<CR>", {
      buffer = args.buf,
      noremap = true,
      silent = true,
      desc = "Write and quit Zsh edit buffer",
    })
  end,
})

local termOptsGroup = vim.api.nvim_create_augroup("TerminalWindowOptions", { clear = true })

vim.api.nvim_create_autocmd({ "BufEnter", "TermOpen" }, {
  group = termOptsGroup,
  pattern = "*", -- Trigger for any buffer entered
  callback = function(args)
    vim.defer_fn(function()
      local bufid = vim.api.nvim_get_current_buf()
      if not vim.api.nvim_buf_is_valid(bufid) then
        return
      end
      local winid = vim.api.nvim_get_current_win()
      local buftype = vim.api.nvim_get_option_value("buftype", { buf = bufid })

      if buftype == "terminal" then
        vim.cmd.startinsert()
        vim.api.nvim_set_option_value("number", false, { win = winid, scope = "local" })
        vim.api.nvim_set_option_value("relativenumber", false, { win = winid, scope = "local" })
        vim.api.nvim_set_option_value("cursorline", false, { win = winid, scope = "local" })
        vim.api.nvim_set_option_value("signcolumn", "no", { win = winid, scope = "local" })

        vim.api.nvim_set_option_value("number", false, { win = winid, scope = "local" })
        vim.api.nvim_set_option_value("relativenumber", false, { win = winid, scope = "local" })

        local function bmap(mode, lhs, rhs)
          vim.api.nvim_buf_set_keymap(bufid, mode, lhs, rhs, { noremap = true, silent = true })
        end
        bmap("t", "<localleader>q", "<cmd>bwipeout!<cr>")
        bmap("t", "<localleader>c", "<cmd>close<cr>")
        bmap("n", "<localleader>q", "<cmd>bwipeout!<cr>")
        bmap("n", "<localleader>c", "<cmd>close<cr>")
      elseif buftype == "" then
        -- Get the current global values
        -- local global_number = vim.api.nvim_get_option_value("number", { scope = "global" })
        -- local global_relativenumber = vim.api.nvim_get_option_value("relativenumber", { scope = "global" })
        -- local global_cursorline = vim.api.nvim_get_option_value("cursorline", { scope = "global" })
        -- local global_signcolumn = vim.api.nvim_get_option_value("signcolumn", { scope = "global" })
        local global_number = true
        local global_relativenumber = true
        local global_cursorline = true
        local global_signcolumn = "yes"

        -- Apply the global values locally to this window
        vim.api.nvim_set_option_value("number", global_number, { win = winid, scope = "local" })
        vim.api.nvim_set_option_value("relativenumber", global_relativenumber, { win = winid, scope = "local" })
        vim.api.nvim_set_option_value("cursorline", global_cursorline, { win = winid, scope = "local" })
        vim.api.nvim_set_option_value("signcolumn", global_signcolumn, { win = winid, scope = "local" })
      end
    end, 100)
  end,
})
