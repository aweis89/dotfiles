local function load_requirements()
  CopilotSelect = require("CopilotChat.select")
  CopilotActions = require("CopilotChat.actions")
  CopilotChat = require("CopilotChat")
  CopilotConfig = require("CopilotChat.config")
  CopilotTelescope = require("CopilotChat.integrations.telescope")
end

local function buffer_with_lines(_)
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

  if not lines or #lines == 0 then
    return nil
  end

  -- Prepend each line with its line number
  for i, line in ipairs(lines) do
    lines[i] = string.format("%d: %s", i, line)
  end

  return {
    lines = table.concat(lines, "\n"),
    start_row = 1,
    start_col = 1,
    end_row = #lines,
    end_col = #lines[#lines],
  }
end

-- This function retrieves the content of all buffers in the current Neovim session.
-- If `skip_current` is true, it will skip the content of the current buffer.
-- @param skip_current A boolean value indicating whether to skip the current buffer.
-- @return A string containing the content of all buffers (or all but the current buffer).
local function get_content_of_all_buffers(skip_current)
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
local function select_visual_or_buffer(source)
  return CopilotSelect.visual(source) or CopilotSelect.buffer(source)
end

-- This function retrieves the last code block from the given response.
-- If `lang` is provided, it will match the last code block of that language.
-- @param response The response to extract the code block from.
-- @param lang The language of the code block to match.
-- @return The matched code block, or nil if no match was found.
local function get_last_code_block(response, lang)
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

      local user_key_mappings = {
        ["<C-g>"] = function(response)
          local message = get_last_code_block(response, "gitcommit")
          if message then
            local command = "Git commit -m " .. '"' .. message .. '" | Git push'
            vim.api.nvim_command(command)
          else
            print("No git commit message found in response.")
          end
        end,
        ["<C-w>"] = function(response)
          vim.ui.input("Write to file: ", function(input)
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
        ["<C-c>"] = function(response) -- copy last code block
          local message = get_last_code_block(response)
          vim.fn.setreg("+", message)
        end,
      }
      for mapping, val in pairs(user_key_mappings) do
        vim.api.nvim_create_autocmd("BufEnter", {
          pattern = "copilot-*",
          callback = function()
            vim.api.nvim_buf_set_keymap(0, "n", mapping, "", {
              callback = function()
                val(CopilotChat.response())
              end,
              noremap = true,
              silent = true,
            })
          end,
        })
      end

      local user_options = {
        context = "buffer", -- Context to use, 'buffers', 'buffer' or 'manual'
        mappings = {
          complete = "<C-C>",

          show_diff = "<C-d>",
          close = "q",
          reset = "<C-l>",
          submit_prompt = "<C-s>",
          accept_diff = "<C-y>",

          -- show_diff = { "<C-d>", "<C-d>" },
          -- close = { "q", "<C-q>" },
          -- reset = { "<C-l>", "<C-l>" },
          -- submit_prompt = { "<C-s>", "<C-s>" },
          -- accept_diff = { "<C-y>", "<C-y>" },
        },
        auto_insert_mode = true,
        prompts = {
          Improve = {
            prompt = [[
/COPILOT_IMPROVE Your task is to review the provided code snippet, focusing specifically on its readability and maintainability.
  Identify any issues related to:
    - Naming conventions that is unclear, misleading or doesn't follow conventions in ]]
              .. vim.bo.filetype
              .. [[.
    - The presence of unnecessary comments, or the lack of necessary ones.
    - Overly complex expressions that could benefit from simplification.
    - High nesting levels that make the code difficult to follow.
    - The use of excessively long names for variables or functions.
    - Any inconsistencies in naming, formatting, or overall coding style.
    - Repetitive code patterns that could be more efficiently handled through abstraction or optimization.

    Your feedback must be concise, directly addressing each identified issue with:
    - The specific line number(s) where the issue is found.
    - A clear description of the problem.
    - A concrete suggestion for how to improve or correct the issue.
    
    Format your feedback as follows:
    "line=<line_number>: <issue_description>
    
    If you find multiple issues on the same line, list each issue separately within the same feedback statement, using a semicolon to separate them.
    Example feedback:
    
    line=3: The variable name 'x' is unclear. Comment next to variable declaration is unnecessary.
    line=8: Expression is overly complex. Break down the expression into simpler components.
    line=10: Using camel case here is unconventional for lua. Use snake case instead.
    
    If the code snippet has no readability issues, simply confirm that the code is clear and well-written as is.
  instructions: |
    - Review the code for readability issues.
    - Provide concise and actionable feedback.
    - Use the specified format for all feedback.]],
            selection = buffer_with_lines,
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
          return select_visual_or_buffer(source)
        end,
      }
      local final_opts = vim.tbl_deep_extend("force", CopilotConfig, user_options)
      CopilotChat.setup(final_opts)
    end,
    event = "BufEnter",
    keys = {
      -- Telescope shortcuts
      {
        "<leader>ch",
        function()
          CopilotTelescope.pick(CopilotActions.help_actions())
        end,
        desc = "CopilotChat - Help actions",
        remap = true,
      },
      {
        "<leader>cp",
        function()
          CopilotTelescope.pick(CopilotActions.prompt_actions())
        end,
        desc = "CopilotChat - Prompt actions",
        remap = true,
      },

      {
        "<leader>cb",
        function()
          local input = vim.fn.input("Quick Chat: ")
          if input ~= "" then
            CopilotChat.ask(input, { selection = CopilotSelect.buffer })
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
            CopilotChat.ask(input, {
              context = get_content_of_all_buffers(),
              selection = CopilotSelect.buffer,
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
          vim.api.nvim_command("Git add % | CopilotChatCommitStaged")
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
        openai_model_id = "gpt-4",
        highlight = {
          icon = " ",
        },
      })
    end,
  },
}
