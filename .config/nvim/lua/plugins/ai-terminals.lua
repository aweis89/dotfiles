local Core = require("utils.ai_terminals_core")

------------------------------------------
-- Plugin Configuration
------------------------------------------
return {
  { "willothy/flatten.nvim" },
  {
    "folke/snacks.nvim",
    optional = true,
    event = "VeryLazy",
    keys = {
      -- Diff Tools
      {
        "<leader>dvo",
        function()
          Core.diff_with_tmp()
        end,
        desc = "Compare with tmp directory backup",
      },
      -- Claude Keymaps
      {
        "<leader>ass",
        function()
          Core.claude_terminal()
        end,
        desc = "Toggle Claude terminal",
      },
      {
        "<leader>ass",
        function()
          Core.send_selection(Core.claude_terminal)
        end,
        desc = "Send selection to Claude",
        mode = { "v" },
      },
      {
        "<leader>asd",
        function()
          local diagnostics = Core.diagnostics()
          Core.claude_terminal()
          Core.send(diagnostics)
        end,
        desc = "Send diagnostics to Claude",
        mode = { "v" },
      },
      -- Goose Keymaps
      {
        "<leader>agg",
        function()
          Core.goose_terminal()
        end,
        desc = "Toggle Goose terminal",
      },
      {
        "<leader>agg",
        function()
          Core.send_selection(Core.goose_terminal)
        end,
        desc = "Send selection to Goose",
        mode = { "v" },
      },
      {
        "<leader>agd",
        function()
          local diagnostics = Core.diagnostics()
          Core.goose_terminal()
          Core.send(diagnostics)
        end,
        desc = "Send diagnostics to Goose",
        mode = { "v" },
      },
      -- Aider Keymaps
      {
        "<leader>aa",
        function()
          Core.aider_terminal()
        end,
        desc = "Toggle Aider terminal",
      },
      {
        "<leader>aa",
        function()
          Core.send_selection(Core.aider_terminal, { prefix = "{e\n" })
        end,
        desc = "Send selection to Aider",
        mode = { "v" },
      },
      {
        "<leader>ad",
        function()
          local diagnostics = Core.diagnostics()
          Core.aider_terminal()
          Core.send(diagnostics, { prefix = "{e\n" })
        end,
        desc = "Send diagnostics to Aider",
        mode = { "v" },
      },
    },
  },
}
