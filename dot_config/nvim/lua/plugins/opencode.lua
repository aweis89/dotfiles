local function open_with_files(files, new_session)
  if #files == 0 then
    return
  end

  require("opencode.core").open({
    new_session = new_session,
    focus = "input",
    start_insert = true,
  })

  local context = require("opencode.context")
  for _, file in ipairs(files) do
    context.add_file(file)
  end
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
    -- "sudo-tee/opencode.nvim",
    "aweis89/opencode.nvim",
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
          ["<leader>oG"] = {
            function()
              require("opencode.api").toggle(true)
            end,
            desc = "Toggle OpenCode (new session)",
          },
          ["<leader>ox"] = { "cancel", desc = "Cancel Request" },
          ["<leader>ol"] = {
            function()
              open_with_files({ vim.api.nvim_buf_get_name(0) })
            end,
            desc = "Load Current File",
          },
          ["<leader>oL"] = {
            function()
              open_with_files({ vim.api.nvim_buf_get_name(0) }, true)
            end,
            desc = "Load Current File",
          },
        },
        input_window = {
          ["<C-x>"] = { "cancel", mode = { "n", "i" } },
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
          ["<C-x>"] = { "cancel", mode = { "n", "i" } },
          ["<C-i>"] = {
            function()
              require("opencode.core").open({ new_session = false, focus = "input" })
            end,
            mode = { "n", "i" },
          },
        },
      },
      ui = {
        picker_width = vim.o.columns,
        -- position = "current",
        input_height = 0.30, -- Input height as percentage of window height
        input_position = "bottom", -- 'bottom' (default) or 'top'. Position of the input window
        input = {
          dynamic = true,
          text = {
            wrap = true, -- Wraps text inside input window
          },
        },
      },
    },
    config = function(_, opts)
      -- enable local build version to work
      ---@diagnostic disable
      require("opencode.state").required_version = 0
      require("opencode").setup(opts)
    end,
    dependencies = {
      "MeanderingProgrammer/render-markdown.nvim",
      "folke/snacks.nvim",
      "nvim-lua/plenary.nvim",
      "saghen/blink.cmp",
    },
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      file_types = { "markdown", "opencode_output" },
      anti_conceal = { enabled = false },
      checkbox = { enabled = true },
      heading = {
        icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
      },
    },
    ft = { "markdown", "norg", "rmd", "org", "opencode_output" },
  },
}
