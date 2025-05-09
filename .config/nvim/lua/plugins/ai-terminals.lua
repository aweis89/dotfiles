local AiderModels = { "gemini", "o4-mini", "sonnet" }

return {
  {
    "aweis89/ai-terminals.nvim",
    dir = "~/p/ai-terminals.nvim",
    cmd = "AiderModel",
    ---@type ConfigType
    opts = function()
      -- Completion function for AiderModel command
      _G.AiderModelComplete = function()
        return AiderModels
      end

      local ModelFile = vim.fn.stdpath("state") .. "/aider-model.txt"
      vim.api.nvim_create_user_command("AiderModel", function(opt)
        local model = opt.args
        if model ~= "" then
          vim.notify(model)
          vim.fn.writefile({ model }, ModelFile)
        end
      end, { nargs = 1, complete = "customlist,v:lua._G.AiderModelComplete" })

      return {
        show_diffs_on_leave = { delta = true },
        terminals = {
          aichat = {
            cmd = function()
              return string.format(
                "AICHAT_LIGHT_THEME=%s GEMINI_API_BASE=http://localhost:8080/v1beta aichat -r %%functions%% --session",
                tostring(vim.o.background == "light") -- Convert boolean to string "true" or "false"
              )
            end,
          },
          aider = {
            cmd = function()
              vim.notify("called")
              local cmd = string.format("aider --watch-files --%s-mode", vim.o.background)
              if vim.fn.filereadable(ModelFile) == 1 then
                local model_override_lines = vim.fn.readfile(ModelFile)
                if #model_override_lines > 0 and model_override_lines[1] ~= nil and model_override_lines[1] ~= "" then
                  local model = vim.fn.trim(model_override_lines[1]) -- Trim whitespace
                  if model ~= "" then
                    cmd = cmd .. " --model " .. model
                  end
                end
              end
              return cmd
            end,
          },
        },
      }
      -- default_position = "right",
    end,
    keys = {
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
