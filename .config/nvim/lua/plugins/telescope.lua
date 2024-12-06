return {
  {
    "danielfalk/smart-open.nvim",
    branch = "0.2.x",
    config = function()
      require("telescope").load_extension("smart_open")
    end,
    keys = {
      { "<leader><space>", "<cmd>Telescope smart_open<cr>", desc = "Smart open", remap = true },
    },
    dependencies = {
      "kkharji/sqlite.lua",
      "nvim-telescope/telescope.nvim",
      -- Only required if using match_algorithm fzf
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      -- Optional.  If installed, native fzy will be used when match_algorithm is fzy
      { "nvim-telescope/telescope-fzy-native.nvim" },
    },
  },

  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    opts = function(_, opts)
      local git_ref_diffview_action = function()
        local action_state = require("telescope.actions.state")
        local selected_entry = action_state.get_selected_entry()
        local value = selected_entry.value
        -- close Telescope window properly prior to switching windows
        vim.api.nvim_win_close(0, true)
        vim.cmd("stopinsert")
        vim.schedule(function()
          vim.cmd(("DiffviewOpen %s^!"):format(value))
        end)
      end

      local previewers = require("telescope.previewers")
      local git_ref_delta_previewer = previewers.new_termopen_previewer({
        get_command = function(entry)
          return { "git", "-c", "core.pager=delta", "-c", "delta.side-by-side=false", "diff", entry.value .. "^!" }
        end,
      })
      local git_file_delta_previewer = previewers.new_termopen_previewer({
        get_command = function(entry)
          -- Check if the file is staged (first character of status)
          local is_staged = entry.status:sub(1, 1) ~= " " and entry.status:sub(1, 1) ~= "?"
          local is_unstaged = entry.status:sub(2, 2) ~= " "

          if is_staged then
            -- Show staged changes
            return {
              "git",
              "-c",
              "core.pager=delta",
              "-c",
              "delta.side-by-side=false",
              "diff",
              "--cached",
              "--",
              entry.value,
            }
          elseif is_unstaged then
            -- Show unstaged changes
            return { "git", "-c", "core.pager=delta", "-c", "delta.side-by-side=false", "diff", "--", entry.value }
          else
            -- For untracked files, try to show file content
            return { "bat", entry.value }
          end
        end,
      })

      local actions = require("telescope.actions")

      local git_ref_mappings = {
        previewer = git_ref_delta_previewer,
        mappings = {
          i = {
            ["<C-v>"] = git_ref_diffview_action,
          },
        },
      }

      return vim.tbl_deep_extend("force", opts, {
        pickers = {
          git_status = {
            previewer = git_file_delta_previewer,
            mappings = {
              i = {
                -- git add file
                ["<C-g>"] = function(_)
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

          git_commits = git_ref_mappings,
          git_bcommits = git_ref_mappings,
          git_branches = git_ref_mappings,
        },

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
            highlight_line = true, -- Enable line highlighting in preview
          },
          layout_config = {
            width = 0.97, -- 97% of screen width
            height = 0.97, -- 97% of screen height
            prompt_position = "top", -- Place the prompt at the top
          },
          sorting_strategy = "ascending", -- Display results from top to bottom
          file_ignore_patterns = { "node_modules", "vendor" },
        },
      })
    end,
  },
}
