local actions = require("telescope.actions")

return {
  {
    "nvim-telescope/telescope.nvim",
    opts = {
      defaults = {
        file_ignore_patterns = { "node_modules", "vendor" },
        mappings = {
          i = {
            ["C-c"] = actions.close,
            ["<c-t>"] = open_with_trouble,
            ["<a-t>"] = open_selected_with_trouble,
            ["<a-i>"] = find_files_no_ignore,
            ["<a-h>"] = find_files_with_hidden,
            ["<C-Down>"] = actions.cycle_history_next,
            ["<C-Up>"] = actions.cycle_history_prev,
            ["<C-u>"] = actions.preview_scrolling_down,
            ["<C-d>"] = actions.preview_scrolling_up,
          },
        },
      },
    },
    keys = {
      -- LSP
      {
        "<leader>ll",
        function()
          require("telescope.builtin").lsp_document_symbols()
        end,
        desc = "LSP Types",
      },
      {
        "<leader>lL",
        function()
          require("telescope.builtin").lsp_dynamic_workspace_symbols()
        end,
        desc = "LSP Types",
      },

      -- Search
      {
        "<leader>fg",
        function()
          require("telescope.builtin").live_grep()
        end,
        desc = "Search files",
      },

      -- Files
      {
        "<leader>fp",
        function()
          require("telescope.builtin").find_files({ cwd = require("lazy.core.config").options.root })
        end,
        desc = "Find Plugin File",
      },
      {
        "<leader>ff",
        function()
          require("telescope.builtin").find_files()
        end,
        desc = "Find Plugin File",
      },
      {
        "<leader><space>",
        function()
          require("telescope.builtin").find_files()
        end,
        desc = "Find local files",
      },
      {
        "<leader>fc",
        function()
          require("telescope.builtin").command_history()
        end,
        desc = "Find quickfix",
      },
    },
  },
}
