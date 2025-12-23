local function open_with_files(files)
  if #files == 0 then
    return
  end

  local context = require("opencode.context")
  for _, file in ipairs(files) do
    context.add_file(file)
  end

  vim.defer_fn(function()
    require("opencode.core").open_if_closed():and_then(function()
      require("opencode.api").open_input()
    end)
  end, 100)
end

return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        actions = {
          opencode_send = function(picker)
            local selected = picker:selected({ fallback = true })
            if selected and #selected > 0 then
              local files = {}
              for _, item in ipairs(selected) do
                if item.file then
                  table.insert(files, item.file)
                end
              end
              picker:close()

              open_with_files(files)
            end
          end,
        },
        win = {
          input = {
            keys = {
              ["<localleader>o"] = { "opencode_send", mode = { "n", "i" } },
            },
          },
        },
      },
    },
  },
  {
    "sudo-tee/opencode.nvim",
    lazy = false,
    opts = {
      -- default_global_keymaps = false, -- If false, disables all default global keymaps
      context = {
        enabled = true,
        cursor_data = {
          enabled = false,
        },
        diagnostics = {
          enabled = false,
        },
        current_file = {
          enabled = false,
        },
        files = {
          enabled = true,
        },
        selection = {
          enabled = true,
        },
        agents = {
          enabled = false,
        },
      },
      keymap = {
        editor = {
          ["<leader>om"] = { "configure_provider" }, -- Open provider configuration
          ["<leader>ol"] = {
            function()
              open_with_files({ vim.api.nvim_buf_get_name(0) })
            end,
          },
        },
        input_window = {
          ["<C-p>"] = { "switch_mode", mode = { "n", "i" } }, -- Switch between modes (build/plan)
          ["<C-u>"] = {
            function()
              local core = require("opencode.core")
              core.open({ new_session = false, focus = "output" }):wait()
              vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-b>", true, false, true), "n", true)
            end,
            mode = { "n", "i" },
          },
          ["<C-o>"] = {
            function()
              require("opencode.core").open({ new_session = false, focus = "output" })
            end,
            mode = { "n", "i" },
          },
        },
        output_window = {
          ["<C-i>"] = {
            function()
              require("opencode.core").open({ new_session = false, focus = "input" })
            end,
            mode = { "n", "i" },
          },
        },
      },
      ui = {
        position = "current",
        output = {
          show_thinking_tokens = true,
        },
      },
    },
    config = function(_, opts)
      -- enable local build version to work
      ---@diagnostic disable
      require("opencode.state").required_version = 0
      require("opencode").setup(opts)

      vim.keymap.set("n", "<leader>ol", function()
        local current_file = vim.api.nvim_buf_get_name(0)
        open_with_files({ current_file })
      end, { desc = "Opencode add file" })
    end,
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
          anti_conceal = { enabled = false },
          file_types = { "markdown", "opencode_output" },
        },
        ft = { "markdown", "Avante", "copilot-chat", "opencode_output" },
      },
      "saghen/blink.cmp",
      "folke/snacks.nvim",
    },
  },
}
