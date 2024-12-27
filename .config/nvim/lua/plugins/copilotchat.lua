return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "zbirenbaum/copilot.lua" }, -- or zbirenbaum/copilot.lua
      { "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log and async functions
    },

    cmd = {
      "CopilotChat",
      "CopilotChatCommit",
      "CopilotChatCommitStaged",
      "CopilotChatDocs",
      "CopilotChatExplain",
      "CopilotChatFix",
      "CopilotChatFixDiagnostic",
      "CopilotChatModels",
      "CopilotChatOptimize",
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
            local command = string.format("Git commit -m %s | Git push | bdelete", vim.fn.shellescape(message))
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
      system_prompt = [[
You are an AI programming assistant.
Keep your answers short and impersonal.
The user works in an IDE called Neovim which has a concept for editors with open files, integrated unit test support, an output pane that shows the output of running the code as well as an integrated terminal.
The user is working on a Darwin machine. Please respond with system specific commands if applicable.
      ]],
      model = "claude-3.5-sonnet",
      context = nil,
      -- default selection
      selection = function(source)
        local select = require("CopilotChat.select")
        return select.visual(source) or nil
      end,
      window = {
        layout = "float", -- 'vertical', 'horizontal', 'float', 'replace'
        height = vim.api.nvim_win_get_height(0),
        width = vim.api.nvim_win_get_width(0),
      },
    },
    keys = {
      { "<leader>ac", "<cmd>Git add % | CopilotChatCommitStaged<cr>", desc = "Commit staged" },
    },
  },
}
