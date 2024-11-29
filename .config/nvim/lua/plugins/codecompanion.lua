return {
  {
    "echasnovski/mini.diff",
    config = function()
      local diff = require("mini.diff")
      diff.setup({
        -- Disabled by default
        source = diff.gen_source.none(),
      })
    end,
  },
  {
    "olimorris/codecompanion.nvim",
    config = true,
    opts = {
      strategies = {
        chat = {
          adapter = "anthropic",
          roles = { llm = "  Anthropic", user = "Anthropic" },
        },
        inline = { adapter = "anthropic" },
        agent = {
          adapter = "anthropic",
        },
      },

      display = {
        diff = {
          close_chat_at = 500,
          provider = "mini_diff",
        },
        chat = {
          window = {
            layout = "vertical", -- float|vertical|horizontal|buffer
            height = 100,
            width = 150,
          },
        },
      },
      opts = {
        log_level = "DEBUG",
      },
    },

    init = function()
      -- Expand 'cc' into 'CodeCompanion' in the command line
      vim.cmd([[cab cc CodeCompanion]])
    end,
    keys = {
      {
        "<leader>ac",
        "<cmd>CodeCompanionActions<CR>",
        desc = "Open the CodeCompanion action picker",
        mode = { "n", "v" },
      },
      {
        "<leader>aa",
        "<cmd>CodeCompanionChat toggle<CR>",
        desc = "Toggle CodeCompanion chat prompt",
        mode = { "n", "v" },
      },
      {
        "<leader>aA",
        "<cmd>CodeCompanionChat<CR>",
        desc = "Open new CodeCompanion chat prompt",
        mode = { "n", "v" },
      },
      {
        "ga",
        "<cmd>CodeCompanionChat add<CR>",
        desc = "Add selected text to CodeCompanion",
        mode = { "n", "v" },
      },
    },
  },
}
