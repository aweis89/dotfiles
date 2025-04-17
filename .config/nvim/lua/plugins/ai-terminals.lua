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
        desc = "Show diff of last changes made (using neovim diff)",
      },
      {
        "<leader>dvt",
        function()
          require("ai-terminals").diff_changes(function(code_dir, ai_dir)
            local cmd = string.format("delta --paging=never -s %s %s", ai_dir, code_dir)
            vim.cmd("tabnew")
            vim.cmd("terminal " .. cmd)
            vim.api.nvim_feedkeys("gg", "n", false)
          end)
        end,
        desc = "Show diff of last changes made using terminal cmd",
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
          require("ai-terminals").aider_add_files({ vim.fn.expand("%:p") })
        end,
        desc = "Add current file to Aider",
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
    },
  },
}
