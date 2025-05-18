local AiderModels = {
  { model = "openai/gemini-2.5-pro", alias = "copilot-gemini" }, -- Used by <leader>amg keybinding
  { model = "openai/claude-3.7-sonnet", alias = "copilot-sonnet" }, -- Used by <leader>amc keybinding
  { model = "o4-mini" }, -- Used by <leader>amo keybinding
}

-- File to store the selected Aider model
local ModelFile = vim.fn.stdpath("state") .. "/aider-model.txt"

-- Read the saved Aider model from file
local function read_aider_model()
  if vim.fn.filereadable(ModelFile) == 1 then
    local model_override_lines = vim.fn.readfile(ModelFile)
    if #model_override_lines > 0 and model_override_lines[1] ~= nil and model_override_lines[1] ~= "" then
      return vim.fn.trim(model_override_lines[1]) -- Trim whitespace
    end
  end
  return nil
end

-- Write an Aider model to file
local function write_aider_model(model)
  vim.fn.writefile({ model }, ModelFile)
end

return {
  {
    "aweis89/ai-terminals.nvim",
    dir = "~/p/ai-terminals.nvim",
    cmd = "AiderModel",
    ---@type fun(): ConfigType
    opts = function()
      -- Completion function for AiderModel command
      _G.AiderModelComplete = function()
        local completions = {}
        for _, entry in ipairs(AiderModels) do
          if entry.alias and entry.alias ~= "" then
            table.insert(completions, entry.alias)
          else
            table.insert(completions, entry.model)
          end
        end
        return completions
      end

      vim.api.nvim_create_user_command("AiderModel", function(opt)
        local input_arg = opt.args
        local model_to_write = nil

        if input_arg ~= "" then
          for _, entry in ipairs(AiderModels) do
            if entry.alias and entry.alias == input_arg then
              model_to_write = entry.model
              break
            elseif entry.model == input_arg then
              model_to_write = entry.model
              break
            end
          end

          if model_to_write then
            local notify_msg = "Aider model set to: " .. model_to_write
            if input_arg ~= model_to_write then
              notify_msg = notify_msg .. " (selected via alias: " .. input_arg .. ")"
            end
            vim.notify(notify_msg)
            write_aider_model(model_to_write)
            -- restart aider
            require("ai-terminals").destroy_all()
            require("ai-terminals").toggle("aider")
          else
            vim.notify("Unknown Aider model or alias: " .. input_arg, vim.log.levels.WARN)
          end
        end
      end, { nargs = 1, desc = "Select Aider Model", complete = "customlist,v:lua._G.AiderModelComplete" })

      return {
        -- enable_diffing = false,
        default_position = "right",
        -- show_diffs_on_leave = { delta = true },
        terminals = {
          goose = {
            cmd = function()
              return string.format("unset GITHUB_TOKEN; GOOSE_CLI_THEME=%s goose", vim.o.background)
            end,
          },
          aider = {
            cmd = function()
              local cmd = string.format("aider --watch-files --%s-mode", vim.o.background)
              local model = read_aider_model()
              if model and model ~= "" then
                cmd = cmd .. " --model " .. model
              end
              return cmd
            end,
          },
        },
      }
    end,
    keys = {
      -- Aider model selection
      {
        "<leader>amg",
        "<cmd>AiderModel copilot-gemini<cr>",
        desc = "Aider Model: gemini",
      },
      {
        "<leader>amc",
        "<cmd>AiderModel copilot-sonnet<cr>",
        desc = "Aider Model: claude",
      },
      {
        "<leader>amo",
        "<cmd>AiderModel o4-mini<cr>",
        desc = "Aider Model: o4-mini",
      },
      -- Diff Tools
      {
        "<leader>dvo",
        function()
          require("ai-terminals").diff_changes()
        end,
        desc = "Show diff of last AI changes (using neovim diff)",
      },
      {
        "<leader>dvt",
        function()
          require("ai-terminals").diff_changes({ delta = true })
        end,
        desc = "Show diff of last AI changes using terminal cmd",
      },
      {
        "<leader>dvr", -- Mnemonic: Diff View Revert
        function()
          require("ai-terminals").revert_changes()
        end,
        desc = "Revert AI changes from backup",
      },
      -- Claude Keymaps
      -- Example Keymaps (using default terminal names: 'claude', 'goose', 'aider')
      -- Claude Keymaps
      {
        "<leader>atc", -- Mnemonic: AI Terminal Claude
        function()
          require("ai-terminals").toggle("claude")
        end,
        desc = "Toggle Claude terminal",
        mode = { "n", "v" },
      },
      {
        "<leader>adc", -- Mnemonic: AI Diagnostics Claude
        function()
          require("ai-terminals").send_diagnostics("claude")
        end,
        desc = "Send diagnostics to Claude",
        mode = { "n", "v" }, -- Allow sending buffer or selection diagnostics
      },
      {
        "<leader>atk", -- Mnemonic: AI Terminal Kode
        function()
          require("ai-terminals").toggle("kode")
        end,
        desc = "Toggle Kode terminal",
        mode = { "n", "v" },
      },
      {
        "<leader>adk", -- Mnemonic: AI Diagnostics Kode
        function()
          require("ai-terminals").send_diagnostics("Kode")
        end,
        desc = "Send diagnostics to Kode",
        mode = { "n", "v" }, -- Allow sending buffer or selection diagnostics
      },
      {
        "<leader>ati", -- Mnemonic: AI Terminal AI Chat
        function()
          require("ai-terminals").toggle("aichat")
        end,
        desc = "Toggle AI Chat terminal (sends selection in visual mode)",
        mode = { "n", "v" },
      },
      {
        "<leader>adi", -- Mnemonic: AI Diagnostics AI Chat
        function()
          require("ai-terminals").send_diagnostics("aichat")
        end,
        desc = "Send diagnostics to AI Chat",
        mode = { "n", "v" }, -- Allow sending buffer or selection diagnostics
      },
      -- Goose Keymaps
      {
        "<leader>atg", -- Mnemonic: AI Terminal Goose
        function()
          require("ai-terminals").toggle("goose")
        end,
        desc = "Toggle Goose terminal",
        mode = { "n", "v" },
      },
      {
        "<leader>adg", -- Mnemonic: AI Diagnostics Goose
        function()
          require("ai-terminals").send_diagnostics("goose")
        end,
        desc = "Send diagnostics to Goose",
        mode = { "n", "v" },
      },
      -- Aider Keymaps
      {
        "<leader>ata", -- Mnemonic: AI Terminal Aider
        function()
          require("ai-terminals").toggle("aider")
        end,
        desc = "Toggle Aider terminal",
        mode = { "n", "v" },
      },
      {
        "<leader>ac",
        function()
          require("ai-terminals").aider_comment("AI!") -- Adds comment and saves file
        end,
        desc = "Add 'AI!' comment above line",
      },
      {
        "<leader>aC",
        function()
          require("ai-terminals").aider_comment("AI?") -- Adds comment and saves file
        end,
        desc = "Add 'AI?' comment above line",
      },
      {
        "<leader>al",
        function()
          -- add current file
          require("ai-terminals").aider_add_files(vim.fn.expand("%"))
        end,
        desc = "Add current file to Aider",
      },
      {
        "<leader>aR", -- Mnemonic: AI add Read-only
        function()
          -- add current file as read-only
          require("ai-terminals").aider_add_files(vim.fn.expand("%"), { read_only = true })
        end,
        desc = "Add current file to Aider (read-only)",
      },
      {
        "<leader>ada", -- Mnemonic: AI Diagnostics Aider
        function()
          require("ai-terminals").send_diagnostics("aider")
        end,
        desc = "Send diagnostics to Aider",
        mode = { "n", "v" },
      },
      -- Example: Run a command and send output to a specific terminal (e.g., Aider)
      {
        "<leader>ar", -- Mnemonic: AI Run command
        function()
          -- Prompt user or use a fixed command
          require("ai-terminals").send_command_output("aider")
        end,
        desc = "Run 'make test' and send output to Aider terminal",
      },
      {
        "<leader>aL", -- Mnemonic: AI Run command
        function()
          require("ai-terminals").aider_add_buffers()
        end,
        desc = "Add all buffers to aider",
      },
      {
        "<leader>ax", -- Mnemonic: AI Close (X) all terminals
        function()
          require("ai-terminals").destroy_all()
        end,
        desc = "Close all AI terminals",
      },
      {
        "<leader>af", -- Mnemonic: AI focus
        function()
          require("ai-terminals").focus()
        end,
        desc = "Close all AI terminals",
      },
    },
  },
}
