local actions = require("telescope.actions")

-- Table to keep track of added files

return {
  {
    "nvim-telescope/telescope.nvim",
    opts = {
      defaults = {
        file_ignore_patterns = { "node_modules", "vendor" },
        mappings = {
          i = {
            ["<C-c>"] = actions.close,
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
            ["<C-u>"] = actions.preview_scrolling_down,
            ["<C-d>"] = actions.preview_scrolling_up,
            ["<C-g>"] = function(_) -- only works Telescope git_status
              local selection = require("telescope.actions.state").get_selected_entry()
              -- Git root command
              local git_root = vim.fn.system("git rev-parse --show-toplevel"):gsub("\n", "")
              local file_path = git_root .. "/" .. selection.value
              -- Git add command
              local result = vim.fn.system("git add " .. file_path)
              if result == "" then
                vim.notify("Added file: " .. file_path)
              else
                vim.notify("Failed to add file: " .. file_path .. ". Error: " .. result)
              end
            end,
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
          utils = require("telescope.utils")
          require("telescope.builtin").find_files({ cwd = utils.buffer_dir() })
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
        desc = "Command history",
        mode = { "n", "v" },
      },
      {
        "<leader>fC",
        function()
          require("telescope.builtin").commands()
        end,
        desc = "Commands",
      },
    },
  },
}
