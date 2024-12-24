return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "zbirenbaum/copilot.lua" }, -- or zbirenbaum/copilot.lua
      { "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log and async functions
    },

    config = function(_, opts)
      local function get_last_code_block(response, lang)
        if lang then
          return response:match("```" .. lang .. "\n(.-)```[^```]*$")
        else
          return response:match("```.-\n(.-)```[^```]*$")
        end
      end

      local user_key_mappings = {
        ["<C-g>"] = function(response)
          local message = get_last_code_block(response, "gitcommit")
          if message then
            local command = string.format("Git commit -m %s | Git push", vim.fn.shellescape(message))
            vim.notify("Executing: " .. command)
            vim.api.nvim_command(command)
          else
            print("No git commit message found in response.")
          end
        end,
        ["<C-f>"] = function(response)
          vim.ui.input({ prompt = "Write to file: " }, function(input)
            local message = get_last_code_block(response)
            local file, err = io.open(input, "a")
            if file and message then
              file:write(message)
              file:close()
            else
              print("Failed to write to file: " .. err)
            end
          end)
        end,
        ["<C-y>"] = function(response) -- copy last code block
          local message = get_last_code_block(response)
          vim.fn.setreg('"', message)
        end,
      }
      for mapping, val in pairs(user_key_mappings) do
        vim.api.nvim_create_autocmd("BufEnter", {
          pattern = "copilot-*",
          callback = function()
            local modes = { "n", "i" }
            for _, mode in ipairs(modes) do
              vim.api.nvim_buf_set_keymap(0, mode, mapping, "", {
                callback = function()
                  val(require("CopilotChat").response())
                end,
                noremap = true,
                silent = true,
              })
            end
          end,
        })
      end
      require("CopilotChat").setup(opts)
    end,
    build = "make tiktoken", -- Only on MacOS or Linux
    opts = {
      model = "claude-3.5-sonnet",
    },
    keys = {
      -- add a command here after commit to close the current buffer ai!
      { "<leader>ac", "<cmd>Git add % | CopilotChatCommitStaged<cr>", desc = "Commit staged" },
    },
  },
}
