local actions = require("telescope.actions")

-- Table to keep track of added files
local added_files = {}

function TelescopeGitAdd()
  require("telescope.builtin").find_files({
    attach_mappings = function(_, map)
      map("i", "<C-a>", actions.select_default)
      return true
    end,
    -- Modify the display to show if a file has been added
    entry_maker = function(entry)
      local display = entry.display
      entry.display = function(entry)
        local added = added_files[entry.value] and " [added]" or ""
        return display(entry) .. added
      end
      return entry
    end,
  })
end

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
            -- Custom mapping in insert mode
            ["<C-a>"] = function(prompt_bufnr)
              local selection = require("telescope.actions.state").get_selected_entry()
              local file_path = selection.value
              -- Git add command
              vim.cmd("!git add " .. file_path)
            end,
          },
        },
      },
    },
    keys = {
      -- Git Add
      {
        "<leader>ga",
        function()
          TelescopeGitAdd()
        end,
        desc = "Git add with Telescope",
      },
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
