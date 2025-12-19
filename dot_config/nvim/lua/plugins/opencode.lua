return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        actions = {
          sidekick_send = function(picker)
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
                require("opencode.ui.mention").mention(function(mention_cb)
                  for _, file in ipairs(files) do
                    mention_cb(file)
                    context.add_file(file)
                  end
                end)
              end
            end
          end,
        },
        win = {
          input = {
            keys = {
              ["<localleader>a"] = { "sidekick_send", mode = { "n", "i" } },
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
          diagnostics = {
            info = false, -- Include diagnostics info in the context (default to false
            warn = false, -- Include diagnostics warnings in the context
            error = false, -- Include diagnostics errors in the context
          },
          selection = {
            enabled = true, -- Include selected text in the context
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
