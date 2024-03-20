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

local function last_code_block(response, lang)
  if lang then
    return response:match("```" .. lang .. "\n(.-)```[^```]*$")
  else
    return response:match("```.-\n(.-)```[^```]*$")
  end
end

-- lazy.nvim
return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dir = "~/dev/CopilotChat.nvim",
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
        user_mappings = {
          ["<C-g>"] = function(response)
            local message = last_code_block(response, "gitcommit")
            if message then
              local command = "Git commit -m " .. '"' .. message .. '"'
              vim.api.nvim_command(command)
            else
              print("No git commit message found in response.")
            end
          end,
          ["<C-w>"] = function(response)
            vim.ui.input("Write to file: ", function(input)
              local message = last_code_block(response)
              local file, err = io.open(input, "a")
              if file and message then
                file:write(message)
                file:close()
              else
                print("Failed to write to file: " .. err)
              end
            end)
          end,
          ["<C-c>"] = function(response) -- copy last code block
            local message = last_code_block(response)
            vim.fn.setreg("+", message)
          end,
        },
        -- default selection (visual or line)
        selection = function(source)
          return visualORBuffer(source)
        end,
      }
      local final_opts = vim.tbl_deep_extend("force", default_opts, user_opts)
      require("CopilotChat").setup(final_opts)
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
        function()
          vim.api.nvim_command("Git add %")
          vim.api.nvim_command("CopilotChatCommitStaged")
        end,
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
