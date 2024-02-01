return {
  {
    "nvim-telescope/telescope.nvim",
    opts = {
      defaults = {
        file_ignore_patterns = { "./node_modules/*", "vendor" },
      },
    },
    keys = {
      {
        "<leader>ll",
        function()
          require("telescope.builtin").lsp_document_symbols({})
        end,
        desc = "LSP Types",
      },
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
