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
    -- Map q to close commit buffer without quitting
    vim.keymap.set("n", "q", ":w | bd<CR>", {
      buffer = 0,
      noremap = true,
      silent = true,
      desc = "Write and close commit buffer",
    })
    -- Spinner setup
    local spinner_timer -- will be vim.uv.new_timer()
    local notif_id = "commit-msg"

    -- Function to update spinner icon using hrtime for smooth animation
    local function update_spinner_icon()
      if not notif_id or (spinner_timer and spinner_timer:is_closing()) then
        if spinner_timer and not spinner_timer:is_closing() then
          spinner_timer:stop()
          spinner_timer:close()
        end
        return
      end
      vim.notify("Generating commit message...", vim.log.levels.INFO, {
        id = notif_id,
        icon = Snacks.util.spinner(),
        title = "AI Commit",
        timeout = false, -- Keep it visible
      })
    end

    -- Start spinner timer
    spinner_timer = vim.uv.new_timer()
    if spinner_timer then
      -- Start after a brief moment, then repeat every 100ms
      spinner_timer:start(100, 100, vim.schedule_wrap(update_spinner_icon))
    end

    local prompt = "Generate a conventional commit message for this change. "
      .. "Only respond with the commit message text."
    local script =
      string.format("git diff --staged | ASDF_PYTHON_VERSION=3.11.10 llm -m gpt-5-nano -r low -p '%q'", prompt)
    vim.system({ "/bin/bash", "-c", script }, {}, function(res)
      -- Stop spinner
      if spinner_timer and not spinner_timer:is_closing() then
        spinner_timer:stop()
        spinner_timer:close() -- Important to close the handle
      end
      spinner_timer = nil -- Allow garbage collection

      vim.schedule(function()
        if res.code ~= 0 then
          vim.notify(res.stderr or "Unknown error from ai-commit-msg", vim.log.levels.ERROR, {
            id = notif_id,
            title = "AI Commit Error",
            icon = "", -- Error icon (requires a Nerd Font)
            replace = notif_id,
            timeout = 5000, -- Auto-dismiss after 5 seconds
          })
        elseif res.stdout == nil or res.stdout == "" then
          vim.notify("No commit message generated.", vim.log.levels.WARN, {
            id = notif_id,
            title = "AI Commit",
            icon = "", -- Warning icon
            replace = notif_id,
            timeout = 5000,
          })
        else
          local msg = res.stdout
          -- Check if the first line is empty or only whitespace
          local first_line_content = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1]
          if first_line_content == nil or vim.fn.trim(first_line_content) == "" then
            vim.api.nvim_buf_set_lines(0, 0, 1, false, vim.split(msg, "\n"))
          else
            local comment_prefix = "# "
            local commented_msg_lines = {}
            for _, line in ipairs(vim.split(msg, "\n")) do
              table.insert(commented_msg_lines, comment_prefix .. line)
            end
            vim.api.nvim_buf_set_lines(0, 1, 1, false, { "" }) -- Insert blank line
            vim.api.nvim_buf_set_lines(0, 2, 2, false, commented_msg_lines) -- Insert commented message
          end
          vim.notify("Commit message generated.", vim.log.levels.INFO, {
            id = notif_id,
            title = "AI Commit",
            icon = "", -- Success icon
            replace = notif_id,
            timeout = 3000, -- Auto-dismiss after 3 seconds
          })
        end
      end)
    end)
  end,
})

-- Autocommand to prompt for push after closing the commit message buffer
vim.api.nvim_create_autocmd("BufDelete", {
  group = augroup("ai_commit_push_prompt"),
  pattern = "COMMIT_EDITMSG",
  callback = function()
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

vim.api.nvim_create_autocmd({ "BufEnter", "TermOpen" }, {
  group = augroup("terminal_window_options"),
  pattern = "*", -- Trigger for any buffer entered
  callback = function()
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
      elseif buftype == "" then
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

-- Run at startup and on every :cd / :lcd / :tcd or autochdir change
local group = augroup("direnv_auto_load")

vim.api.nvim_create_autocmd({ "DirChanged", "VimEnter" }, {
  group = group,
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
