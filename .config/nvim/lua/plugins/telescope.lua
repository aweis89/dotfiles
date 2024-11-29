return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    opts = function()
      require("telescope").setup({
        defaults = {
          mappings = {
            i = {
              ["<C-h>"] = "which_key",
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
          },
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
