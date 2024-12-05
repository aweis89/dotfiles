return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    opts = function()
      local actions = require("telescope.actions")
      require("telescope").setup({
        defaults = {
          mappings = {
            i = {
              ["<C-b>"] = actions.preview_scrolling_up,
              ["<C-f>"] = actions.preview_scrolling_down,
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-h>"] = actions.which_key,
              ["<C-p>"] = require("telescope.actions.layout").toggle_preview,
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
          preview = {
            highlight_line = true, -- Enable line highlighting in preview
          },
          layout_config = {
            width = 0.97, -- 97% of screen width
            height = 0.97, -- 97% of screen height
            prompt_position = "top", -- Place the prompt at the top
          },
          sorting_strategy = "ascending", -- Display results from top to bottom
          file_ignore_patterns = { "node_modules", "vendor" },
          pickers = {
            find_files = {
              i = {
                ["<C-h>"] = "which_key",
                ["<C-p>"] = require("telescope.actions.layout").toggle_preview,
              },
            },
          },
        },
      })
    end,
  },
}
