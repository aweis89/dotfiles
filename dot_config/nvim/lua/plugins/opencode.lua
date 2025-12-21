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

              if #files > 0 then
                local context = require("opencode.context")
                for _, file in ipairs(files) do
                  context.add_file(file)
                end
              end
            end

            vim.defer_fn(function()
              require("opencode.api").open_input()
            end, 100)
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
    config = function()
      ---@diagnostic disable
      require("opencode.state").required_version = 0
      require("opencode").setup({
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
        hooks = {
          on_done_thinking = function()
            vim.notify("Done thinking ")
          end,
        },
        ui = {
          position = "current",
          output = {
            show_thinking_tokens = true,
          },
        },
      })
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
