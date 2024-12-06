local actions = require("telescope.actions")
local git = require("plugins.telescope.git")

return {
  {
    "danielfalk/smart-open.nvim",
    config = function()
      require("telescope").load_extension("smart_open")
    end,
    keys = {
      { "<leader><space>", "<cmd>Telescope smart_open<cr>", desc = "Smart open", remap = true },
    },
    dependencies = {
      "kkharji/sqlite.lua",
      -- Only required if using match_algorithm fzf
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      -- Optional.  If installed, native fzy will be used when match_algorithm is fzy
      { "nvim-telescope/telescope-fzy-native.nvim" },
    },
  },

  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    keys = {
      { "<leader><space>", false },
    },
    opts = function(_, opts)
      -- Git reference mappings configuration
      local git_ref_mappings = {
        previewer = git.git_ref_delta_previewer,
        mappings = {
          i = {
            ["<C-v>"] = git.git_ref_diffview_action,
          },
        },
      }

      return vim.tbl_deep_extend("force", opts, {
        -- Git-related pickers configuration
        pickers = {
          git_status = {
            -- previewer = git.git_file_delta_previewer,
            mappings = {
              i = {
                ["<C-g>"] = git.git_add_file,
              },
            },
          },
          git_commits = git_ref_mappings,
          git_bcommits = git_ref_mappings,
          git_branches = git_ref_mappings,
        },

        -- Default configurations
        defaults = {
          mappings = {
            i = {
              ["<C-b>"] = actions.preview_scrolling_up,
              ["<C-f>"] = actions.preview_scrolling_down,
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-h>"] = actions.which_key,
              ["<C-p>"] = require("telescope.actions.layout").toggle_preview,
            },
          },
          preview = {
            highlight_line = true,
          },
          layout_config = {
            width = 0.97,
            height = 0.97,
            prompt_position = "top",
          },
          sorting_strategy = "ascending",
          file_ignore_patterns = { "node_modules", "vendor" },
        },
      })
    end,
  },
}
