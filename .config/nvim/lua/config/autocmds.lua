-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
local function augroup(name)
  return vim.api.nvim_create_augroup("lazyvim_" .. name, { clear = true })
end

-- Autocommand to populate commit message using c-msg
vim.api.nvim_create_autocmd("BufWinEnter", {
  group = augroup("ai_commit_msg_populate"), -- Renamed group for clarity
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

-- Autocommand to prompt for push after writing commit message
vim.api.nvim_create_autocmd("BufWritePost", {
  group = augroup("ai_commit_push_prompt"),
  pattern = "COMMIT_EDITMSG",
  callback = function(args)
    -- Defer the prompt slightly to allow git commit process to potentially start/finish
    vim.defer_fn(function()
      -- Get the current branch name
      local branch_name = vim.fn.trim(vim.fn.system("git rev-parse --abbrev-ref HEAD"))

      -- Ask the user if they want to push
      local prompt_message = string.format("Push commit to '%s'? (y/N): ", branch_name)
      vim.ui.input({ prompt = prompt_message, default = "N" }, function(input)
        if input and input:lower() == "y" then
          vim.notify("Pushing commit to " .. branch_name .. "...", vim.log.levels.INFO, { title = "Git" })
          -- Execute git push asynchronously, explicitly pushing the current branch might be safer
          -- depending on the user's git push.default setting. Using plain 'git push' for now.
          vim.system({ "git", "push" }, { text = true }, function(result)
            vim.schedule(function()
              if result.code == 0 then
                vim.notify("Git push successful.", vim.log.levels.INFO, { title = "Git" })
              else
                local error_msg = result.stderr or result.stdout or "Unknown error"
                vim.notify("Git push failed:\n" .. error_msg, vim.log.levels.ERROR, { title = "Git" })
              end
            end)
          end)
        else
          vim.notify("Push cancelled.", vim.log.levels.WARN, { title = "Git" })
        end
      end)
    end, 100) -- Small delay (100ms)
  end,
})
