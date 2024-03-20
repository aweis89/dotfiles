local copilotChat
local actions
local copilotSelect
local config
local copilotTelescope

local function load_requirements()
  copilotSelect = require("CopilotChat.select")
  actions = require("CopilotChat.actions")
  copilotChat = require("CopilotChat")
  config = require("CopilotChat.config")
  copilotTelescope = require("CopilotChat.integrations.telescope")
end

-- This function retrieves the content of all buffers in the current Neovim session.
-- If `skip_current` is true, it will skip the content of the current buffer.
-- @param skip_current A boolean value indicating whether to skip the current buffer.
-- @return A string containing the content of all buffers (or all but the current buffer).
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

-- This function selects the visual or buffer source based on the CopilotChat selection.
-- @param source The source to select from.
-- @return The selected source.
local function visual_or_buffer(source)
  return copilotSelect.visual(source) or copilotSelect.buffer(source)
end

-- This function retrieves the last code block from the given response.
-- If `lang` is provided, it will match the last code block of that language.
-- @param response The response to extract the code block from.
-- @param lang The language of the code block to match.
-- @return The matched code block, or nil if no match was found.
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
      load_requirements()

      local user_mappings = {
        ["<C-g>"] = function(response)
          local message = last_code_block(response, "gitcommit")
          if message then
            local command = "Git commit -m " .. '"' .. message .. '" | Git push'
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
      }
      for mapping, val in pairs(user_mappings) do
        vim.api.nvim_create_autocmd("BufEnter", {
          pattern = "copilot-*",
          callback = function()
            vim.api.nvim_buf_set_keymap(0, "n", mapping, "", {
              callback = function()
                val(copilotChat.response())
              end,
              noremap = true,
              silent = true,
            })
          end,
        })
      end

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
        auto_insert_mode = true,
        prompts = {
          Improve = {
            prompt = [[
COPILOT_IMPROVE You must identify any readability issues in the code snippet.
Some readability issues to consider:
- Unclear naming
- Unclear purpose
- Redundant or obvious comments
- Lack of comments
- Long or complex one liners
- Too much nesting
- Long variable names
- Inconsistent naming and code style.
- Code repetition
You may identify additional problems. The user submits a section of code.
Only list lines with aforementioned issues, in the format line=<num>: <issue and proposed solution>
Each commentary must fit on a single line]],
            selection = copilotSelect.buffer,
            callback = function(response)
              -- Namespace ID
              local namespace_id = vim.api.nvim_create_namespace("copilot")

              -- Get the current tabpage
              local tabpage = vim.api.nvim_get_current_tabpage()

              -- Get the list of windows in the current tabpage
              local windows = vim.api.nvim_tabpage_list_wins(tabpage)

              -- Assuming the leftmost window is what you're looking for
              local leftmost_win = windows[1]

              -- Get the buffer associated with the leftmost window
              local left_pane = vim.api.nvim_win_get_buf(leftmost_win)

              -- Retrieve current diagnostics for the buffer
              local existing_diagnostics = vim.diagnostic.get(left_pane, { namespace = namespace_id })

              -- Split the input into lines
              for line in response:gmatch("[^\r\n]+") do
                -- Extract the line number and message from the input
                local lnum, message = line:match("line=(%d+): (.*)")

                -- Create a new diagnostic
                local new_diagnostic = {
                  lnum = tonumber(lnum) - 1, -- Lua is 1-indexed, but Neovim's diagnostics are 0-indexed
                  col = 0,
                  severity = vim.diagnostic.severity.WARN,
                  message = message,
                }

                -- Append the new diagnostic to the existing ones
                table.insert(existing_diagnostics, new_diagnostic)
              end

              -- Set the updated diagnostics for the current buffer
              vim.diagnostic.set(namespace_id, left_pane, existing_diagnostics)
            end,
          },
        },
        -- default selection (visual or line)
        selection = function(source)
          return visual_or_buffer(source)
        end,
      }
      local final_opts = vim.tbl_deep_extend("force", config, user_opts)
      copilotChat.setup(final_opts)
    end,
    event = "BufEnter",
    keys = {
      -- Telescope shortcuts
      {
        "<leader>ch",
        function()
          copilotTelescope.pick(actions.help_actions())
        end,
        desc = "CopilotChat - Help actions",
        remap = true,
      },
      {
        "<leader>cp",
        function()
          copilotTelescope.pick(actions.prompt_actions())
        end,
        desc = "CopilotChat - Prompt actions",
        remap = true,
      },

      {
        "<leader>cb",
        function()
          local input = vim.fn.input("Quick Chat: ")
          if input ~= "" then
            copilotChat.ask(input, { selection = copilotSelect.buffer })
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
            copilotChat.ask(input, {
              context = get_all_buffers_content(),
              selection = copilotSelect.buffer,
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
          icon = " ",
          -- group = 'Comment',
        },
      })
    end,
  },
}
