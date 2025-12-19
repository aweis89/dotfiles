return {
  {
    "sudo-tee/opencode.nvim",
    lazy = false,
    config = function()
      ---@diagnostic disable
      require("opencode.state").required_version = 0
      require("opencode").setup({
        ui = {
          position = "current",
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
