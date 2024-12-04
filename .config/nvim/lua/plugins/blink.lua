return {
  {
    "neovim/nvim-lspconfig",
    opts = function()
      -- disable a keymap
      local keys = require("lazyvim.plugins.lsp.keymaps").get()
      keys[#keys + 1] = { "<c-k>", mode = { "i" }, false }
    end,
  },
  { "niuiic/blink-cmp-rg" },
  {
    "saghen/blink.cmp",
    dependencies = { "niuiic/blink-cmp-rg" },
    opts = {
      keymap = {
        ["<C-k>"] = { "select_prev", "fallback" },
        ["<C-j>"] = { "select_next", "fallback" },
      },
      accept = {
        auto_brackets = {
          enable = true,
        },
      },
      completion = {
        enabled_providers = { "ripgrep" }, -- add "ripgrep" here
        documentation = {
          auto_show = true,
        },
        menu = {
          max_height = math.floor(vim.o.lines / 2),
          draw = {
            columns = { { "label", "source_name", gap = 1 }, { "kind_icon", "kind" } },
          },
        },
      },
      signature = {
        enable = true,
      },
    },
  },
}