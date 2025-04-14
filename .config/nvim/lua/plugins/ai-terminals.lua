local aiterm = function()
  return require("ai-terminals")
end

------------------------------------------
-- Plugin Configuration
------------------------------------------
return {
  {
    "aweis89/ai-terminals.nvim",
    dir = "/Users/aaron.weisberg/p/ai-terminals.nvim",
    config = true,
    opts = {
      terminals = {
        goose = {
          cmd = function()
            return string.format("GOOSE_CLI_THEME=%s goose", vim.o.background)
          end,
        },
        claude = {
          cmd = function()
            return string.format("claude config set -g theme %s && claude", vim.o.background)
          end,
        },
        aider = {
          cmd = function()
            return string.format("aider --watch-files --%s-mode", vim.o.background)
          end,
        },
        aichat = {
          cmd = function()
            return string.format(
              "AICHAT_LIGHT_THEME=%s GEMINI_API_BASE=http://localhost:8080/v1beta aichat -r %%functions%% --session",
              tostring(vim.o.background == "light") -- Convert boolean to string "true" or "false"
            )
          end,
        },
        -- Example of a simple string command
        -- my_simple_ai = { cmd = "my_ai_tool --interactive" },
      },
    },
    keys = {
      -- Diff Tools
      {
        "<leader>dvo",
        function()
          require("ai-terminals").diff_changes()
        end,
        desc = "Show diff of last changes made",
      },
      {
        "<leader>dvc",
        function()
          require("ai-terminals").close_diff()
        end,
        desc = "Close all diff views (and wipeout buffers)",
      },
      -- Claude Keymaps
      -- Example Keymaps (using default terminal names: 'claude', 'goose', 'aider')
      -- Claude Keymaps
      {
        "<leader>atc", -- Mnemonic: AI Terminal Claude
        function()
          require("ai-terminals").toggle("claude")
          -- Note: toggle() returns the terminal instance.
          -- If you need to send data immediately after toggling,
          -- capture the return value like in the 'send selection' keymap.
        end,
        desc = "Toggle Claude terminal",
      },
      {
        "<leader>atc", -- Same keybinding, but in visual mode
        function()
          local selection = require("ai-terminals").get_visual_selection_with_header()
          if selection then
            -- Ensure the terminal is open and get its instance
            local term = require("ai-terminals").toggle("claude")
            -- Send the selection to the specific terminal instance
            require("ai-terminals").send(selection, { term = term })
          else
            vim.notify("No text selected", vim.log.levels.WARN)
          end
        end,
        desc = "Send selection to Claude",
        mode = { "v" },
      },
      {
        "<leader>adc", -- Mnemonic: AI Diagnostics Claude
        function()
          local diagnostics = require("ai-terminals").diagnostics()
          if diagnostics then
            local term = require("ai-terminals").toggle("claude") -- Ensure terminal is open
            require("ai-terminals").send(diagnostics, { term = term })
          else
            vim.notify("No diagnostics found in buffer", vim.log.levels.INFO)
          end
        end,
        desc = "Send diagnostics to Claude",
        mode = { "n", "v" }, -- Allow sending buffer or selection diagnostics
      },
      -- Goose Keymaps
      {
        "<leader>atg", -- Mnemonic: AI Terminal Goose
        function()
          require("ai-terminals").toggle("goose")
        end,
        desc = "Toggle Goose terminal",
      },
      {
        "<leader>atg", -- Same keybinding, visual mode
        function()
          local selection = require("ai-terminals").get_visual_selection_with_header()
          if selection then
            local term = require("ai-terminals").toggle("goose")
            require("ai-terminals").send(selection, { term = term })
          else
            vim.notify("No text selected", vim.log.levels.WARN)
          end
        end,
        desc = "Send selection to Goose",
        mode = { "v" },
      },
      {
        "<leader>adg", -- Mnemonic: AI Diagnostics Goose
        function()
          local diagnostics = require("ai-terminals").diagnostics()
          if diagnostics then
            local term = require("ai-terminals").toggle("goose")
            require("ai-terminals").send(diagnostics, { term = term })
          else
            vim.notify("No diagnostics found in buffer", vim.log.levels.INFO)
          end
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
          local current_file = vim.fn.expand("%:p")
          -- add_files_to_aider handles toggling the terminal if needed
          require("ai-terminals").add_files_to_aider({ current_file })
        end,
        desc = "Add current file to Aider",
      },
      {
        "<leader>ata", -- Same keybinding, visual mode
        function()
          local selection = require("ai-terminals").get_visual_selection_with_header()
          if selection then
            local term = require("ai-terminals").toggle("aider") -- Ensure terminal is open
            require("ai-terminals").send(selection, { term = term })
          else
            vim.notify("No text selected", vim.log.levels.WARN)
          end
        end,
        desc = "Send selection to Aider",
        mode = { "v" },
      },
      {
        "<leader>ada", -- Mnemonic: AI Diagnostics Aider
        function()
          local diagnostics = require("ai-terminals").diagnostics()
          if diagnostics then
            local term = require("ai-terminals").toggle("aider") -- Ensure terminal is open
            require("ai-terminals").send(diagnostics, { term = term })
          else
            vim.notify("No diagnostics found in buffer", vim.log.levels.INFO)
          end
        end,
        desc = "Send diagnostics to Aider",
        mode = { "n", "v" },
      },
      -- Example: Run a command and send output to a specific terminal (e.g., Aider)
      {
        "<leader>ar", -- Mnemonic: AI Run command
        function()
          -- Ensure the Aider terminal is open first
          local term = require("ai-terminals").get("aider")
          term:focus()

          -- Prompt user or use a fixed command
          require("ai-terminals").run_command_and_send_output()
        end,
        desc = "Run 'make test' and send output to Aider terminal",
      },
    },
  },
}
