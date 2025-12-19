return {
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
