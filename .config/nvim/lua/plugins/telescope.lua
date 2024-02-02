local actions = require("telescope.actions")

return {
  {
    "nvim-telescope/telescope.nvim",
    opts = {
      defaults = {
        file_ignore_patterns = { "./node_modules/*", "vendor" },
        mappings = {
          i = {
            ["C-c"] = actions.close,
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
    },
  },
}
