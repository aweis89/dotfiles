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
    optional = false,
    event = "VeryLazy",
    keys = {
      -- Diff Tools
      {
        "<leader>dvo",
        function()
          aiterm().diff_changes()
        end,
        desc = "Show diff of last changes made",
      },
      {
        "<leader>dvc",
        function()
          aiterm().close_diff()
        end,
        desc = "Close all diff views (and wipeout buffers)",
      },
      -- Claude Keymaps
      {
        "<leader>ass",
        function()
          aiterm().claude_toggle()
        end,
        desc = "Toggle Claude terminal",
      },
      {
        "<leader>ass",
        function()
          aiterm().send_selection(aiterm().claude_toggle)
        end,
        desc = "Send selection to Claude",
        mode = { "v" },
      },
      {
        "<leader>asd",
        function()
          local diagnostics = aiterm().diagnostics()
          local term = aiterm().claude_toggle()
          aiterm().send(diagnostics, { term = term })
        end,
        desc = "Send diagnostics to Claude",
        mode = { "v" },
      },
      -- Goose Keymaps
      {
        "<leader>agg",
        function()
          aiterm().goose_toggle()
        end,
        desc = "Toggle Goose terminal",
      },
      {
        "<leader>agg",
        function()
          local selection = aiterm().get_visual_selection_with_header() or ""
          local term = aiterm().goose_toggle()
          aiterm().send(selection, { term = term })
        end,
        desc = "Send selection to Goose",
        mode = { "v" },
      },
      {
        "<leader>agd",
        function()
          local diagnostics = aiterm().diagnostics()
          local term = aiterm().goose_toggle()
          aiterm().send(diagnostics, { term = term })
        end,
        desc = "Send diagnostics to Goose",
        mode = { "v" },
      },
      -- Aider Keymaps
      {
        "<leader>aa",
        function()
          aiterm().aider_toggle()
        end,
        desc = "Toggle Aider terminal",
      },
      {
        "<leader>ac",
        function()
          aiterm().aider_comment("AI!")
        end,
        desc = "Add comment above line",
      },
      {
        "<leader>aC",
        function()
          aiterm().aider_comment("AI?")
        end,
        desc = "Add comment above line",
      },
      {
        "<leader>al",
        function()
          local current_file = vim.fn.expand("%:p")
          aiterm().add_files_to_aider({ current_file })
        end,
        desc = "Add file to Aider",
      },
      {
        "<leader>aa",
        function()
          local selection = aiterm().get_visual_selection_with_header()
          selection = aiterm().aider_multiline(selection)
          local term = aiterm().aider_toggle()
          aiterm().send(selection, { term = term })
        end,
        desc = "Send selection to Aider",
        mode = { "v" },
      },
      {
        "<leader>ad",
        function()
          local diagnostics = aiterm().diagnostics()
          diagnostics = aiterm().aider_multiline(diagnostics)
          local term = aiterm().aider_toggle()
          aiterm().send(diagnostics, { term = term })
        end,
        desc = "Send diagnostics to Aider",
        mode = { "v" },
      },
    },
  },
}
