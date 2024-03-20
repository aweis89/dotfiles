local function get_all_buffers_content(skip_current)
  local buffers = vim.api.nvim_list_bufs()
  local current_buffer = vim.api.nvim_get_current_buf()
  local context = {}
  for _, buf in ipairs(buffers) do
    if not (skip_current and buf == current_buffer) then
      local content = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      table.insert(context, table.concat(content, "\n"))
    end
  end
  return table.concat(context, "\n")
end

local function visualORBuffer(source)
  local copilotSelect = require("CopilotChat.select")
  return copilotSelect.visual(source) or copilotSelect.buffer(source)
end

-- lazy.nvim
return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    -- dir = "~/dev/CopilotChat.nvim",
    branch = "canary",
    dependencies = {
      { "zbirenbaum/copilot.lua" }, -- or github/copilot.vim
      { "nvim-lua/plenary.nvim" }, -- for curl, log wrapper
    },
    config = function()
      local default_opts = require("CopilotChat.config")
      local user_opts = {
        context = "buffer", -- Context to use, 'buffers', 'buffer' or 'manual'
        mappings = {
          close = "q",
          reset = "<C-l>",
          complete = "<C-g>",
          submit_prompt = "<C-s>",
          accept_diff = "<C-y>",
          show_diff = "<C-d>",
        },
        prompts = {
          Improve = {
            prompt = "/COPILOT_IMPROVE can this be improved?",
            selection = require("CopilotChat.select").buffer,
          },
        },
        -- default selection (visual or line)
        selection = function(source)
          return visualORBuffer(source)
        end,
      }
      local final_opts = vim.tbl_deep_extend("force", default_opts, user_opts)
      require("CopilotChat").setup(final_opts)

      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "copilot-*",
        callback = function()
          -- copy last code block
          vim.keymap.set(
            "n",
            "<leader>a",
            "?```<cr>nwdwjyi`u3<C-o><C-h>",
            { noremap = true, silent = true, buffer = true }
          )
        end,
      })

      vim.api.nvim_del_user_command("CopilotChatCommit")
      vim.api.nvim_create_user_command("CopilotCommitStaged", function()
        local prompt = "Write commit message for the change with commitizen convention. "
          .. "Make sure the title has maximum 50 characters and message is wrapped "
          .. "at 72 characters. Wrap the whole message in code block with language gitcommit. "
          .. "Include the diff in the output with it's own code block with language gitdiff."
        if not prompt then
          print("No commit prompt found.")
          return
        end
        vim.api.nvim_command("Git add %")
        require("CopilotChat").ask(prompt, {
          selection = function(source)
            return require("CopilotChat.select").gitdiff(source, true)
          end,
          callback = function(res)
            local message = res:match("```gitcommit\n(.-)```")
            if message then
              vim.ui.input({ prompt = "Commit these changes? (y/n): " }, function(input)
                if input:lower() == "y" then
                  local command = "Git commit -m " .. '"' .. message .. '"'
                  vim.notify(command, 2, { title = "CopilotChat" })
                  vim.api.nvim_command("Git commit -m " .. '"' .. message .. '"')
                end
              end)
            else
              print("No commit message found.")
            end
          end,
        })
      end, {})

      vim.api.nvim_create_user_command("CopilotAddTests", function()
        local prompt = require("CopilotChat.config").prompts.Tests.prompt
        if not prompt then
          print("No prompt found.")
          return
        end
        require("CopilotChat").ask(prompt, {
          selection = require("CopilotChat.select").buffer,
          callback = function(res)
            local filetype = vim.bo.filetype
            if filetype == "go" then
              local message = res:match("```.*\n(.*)```")
              -- Switch to the left window
              vim.api.nvim_command("wincmd h")
              -- TODO use other plugin for more generic solution
              vim.api.nvim_command("GoAlt")
              -- Write message to the end of the current buffer
              local buf = vim.api.nvim_get_current_buf()
              local total_lines = vim.api.nvim_buf_line_count(buf)
              vim.api.nvim_buf_set_lines(buf, total_lines, -1, false, { message })
            end
          end,
        })
        vim.cmd("messages")
      end, {})
    end,
    event = "BufEnter",
    keys = {
      -- Telescope shortcuts
      {
        "<leader>ch",
        function()
          local actions = require("CopilotChat.actions")
          require("CopilotChat.integrations.telescope").pick(actions.help_actions())
        end,
        desc = "CopilotChat - Help actions",
        remap = true,
      },
      -- Show prompts actions with telescope
      {
        "<leader>cp",
        function()
          local actions = require("CopilotChat.actions")
          require("CopilotChat.integrations.telescope").pick(actions.prompt_actions())
        end,
        desc = "CopilotChat - Prompt actions",
        remap = true,
      },
      {
        "<leader>cb",
        function()
          local input = vim.fn.input("Quick Chat: ")
          if input ~= "" then
            require("CopilotChat").ask(input, { selection = require("CopilotChat.select").buffer })
          end
        end,
        desc = "CopilotChat - Quick chat",
        remap = true,
      },
      {
        "<leader>cB",
        function()
          local input = vim.fn.input("Quick Chat: ")
          if input ~= "" then
            require("CopilotChat").ask(input, {
              context = get_all_buffers_content(),
              selection = require("CopilotChat.select").buffer,
            })
          end
        end,
        desc = "CopilotChat - Quick chat",
        remap = true,
      },
      {
        "<leader>cq",
        "<cmd>CopilotChat<cr>",
        desc = "CopilotChat - Quick chat",
        mode = { "n", "v" },
        remap = true,
      },
      {
        "<leader>cr",
        "<cmd>CopilotChatImprove<cr>",
        desc = "CopilotChat - Refactor",
        remap = true,
      },
      {
        "<leader>cg",
        "<cmd>CopilotCommitStaged<cr>",
        desc = "CopilotChat - Commit",
        remap = true,
      },
      {
        "<leader>ct",
        "<cmd>CopilotChatAddTests<cr>",
        desc = "CopilotChat - Generate tests",
        remap = true,
      },
    },
  },
  {
    "james1236/backseat.nvim",
    config = function()
      require("backseat").setup({
        -- Alternatively, set the env var $OPENAI_API_KEY by putting "export OPENAI_API_KEY=sk-xxxxx" in your ~/.bashrc
        openai_model_id = "gpt-4", --gpt-4 (If you do not have access to a model, it says "The model does not exist")
        -- language = 'english', -- Such as 'japanese', 'french', 'pirate', 'LOLCAT'
        -- split_threshold = 100,
        -- additional_instruction = "Respond snarkily", -- (GPT-3 will probably deny this request, but GPT-4 complies)
        highlight = {
          icon = " ", -- ''
          -- group = 'Comment',
        },
      })
    end,
  },
}
