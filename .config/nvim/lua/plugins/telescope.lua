return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-telescope/telescope-cheat.nvim",
      "kkharji/sqlite.lua",
    },
    init = function()
      require("telescope").load_extension("cheat")
    end,
    opts = {
      defaults = {
        file_ignore_patterns = { "./node_modules/*", "vendor" },
      },
    },
    keys = {
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
