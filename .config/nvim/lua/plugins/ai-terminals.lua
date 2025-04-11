local plug = function()
  return require("ai-terminals")
end

------------------------------------------
-- Plugin Configuration
------------------------------------------
return {
  {
    "aweis89/ai-terminals.nvim",
    -- dir = "/Users/aaron.weisberg/p/ai-terminals.nvim",
    dependencies = { "folke/snacks.nvim" },
    optional = false,
    event = "VeryLazy",
    keys = {
      -- Diff Tools
      {
        "<leader>dvo",
        function()
          plug().diff_with_tmp()
        end,
        desc = "Compare with tmp directory backup",
      },
      -- Claude Keymaps
      {
        "<leader>ass",
        function()
          plug().claude_terminal()
        end,
        desc = "Toggle Claude terminal",
      },
      {
        "<leader>ass",
        function()
          plug().send_selection(plug().claude_terminal)
        end,
        desc = "Send selection to Claude",
        mode = { "v" },
      },
      {
        "<leader>asd",
        function()
          local diagnostics = plug().diagnostics()
          plug().claude_terminal()
          plug().send(diagnostics)
        end,
        desc = "Send diagnostics to Claude",
        mode = { "v" },
      },
      -- Goose Keymaps
      {
        "<leader>agg",
        function()
          plug().goose_terminal()
        end,
        desc = "Toggle Goose terminal",
      },
      {
        "<leader>agg",
        function()
          plug().send_selection(plug.goose_terminal)
        end,
        desc = "Send selection to Goose",
        mode = { "v" },
      },
      {
        "<leader>agd",
        function()
          local diagnostics = plug().diagnostics()
          plug().goose_terminal()
          plug().send(diagnostics)
        end,
        desc = "Send diagnostics to Goose",
        mode = { "v" },
      },
      -- Aider Keymaps
      {
        "<leader>aa",
        function()
          plug().aider_terminal()
        end,
        desc = "Toggle Aider terminal",
      },
      {
        "<leader>ac",
        function()
          plug().add_comment_above_line("AI!")
        end,
        desc = "Add comment above line",
      },
      {
        "<leader>aC",
        function()
          plug().add_comment_above_line("AI?")
        end,
        desc = "Add comment above line",
      },
      {
        "<leader>al",
        function()
          local current_file = vim.fn.expand("%:p")
          plug().aider_terminal()
          plug().send("/add " .. current_file .. "\n")
        end,
        desc = "Add file to Aider",
      },
      {
        "<leader>aa",
        function()
          plug().send_selection(plug().aider_terminal, { prefix = "{e\n" })
        end,
        desc = "Send selection to Aider",
        mode = { "v" },
      },
      {
        "<leader>ad",
        function()
          local diagnostics = plug().diagnostics()
          plug().aider_terminal()
          plug().send(diagnostics, { prefix = "{e\n" })
        end,
        desc = "Send diagnostics to Aider",
        mode = { "v" },
      },
    },
  },
}
