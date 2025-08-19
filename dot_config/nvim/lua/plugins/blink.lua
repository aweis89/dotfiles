return {
  {
    "saghen/blink.cmp",
    ---@module 'blink.cmp'
    ---@param opts blink.cmp.Config
    opts = function(_, opts)
      ---@type blink.cmp.Config
      local overrides = {
        sources = {
          providers = {
            lsp = { score_offset = 5 },
            lazydev = { score_offset = 5 },
            copilot = { score_offset = 4 },
            path = { score_offset = 2 },
            buffer = { score_offset = 1 },
            snippets = { score_offset = -1 },
          },
        },
        keymap = {
          ["<C-k>"] = { "select_prev", "fallback" },
          ["<C-j>"] = { "select_next", "fallback" },
          ["<Tab>"] = { "select_next", "fallback" },
          ["<S-Tab>"] = { "select_prev", "fallback" },
        },
        cmdline = {
          completion = {
            list = { selection = { preselect = false } },
            menu = { auto_show = true },
          },
          keymap = {
            ["<C-k>"] = { "select_prev", "fallback" },
            ["<C-j>"] = { "select_next", "fallback" },
            ["<Tab>"] = { "select_next", "fallback" },
            ["<S-Tab>"] = { "select_prev", "fallback" },
          },
          enabled = true,
        },
        signature = {
          enabled = true,
        },
        completion = {
          menu = {
            max_height = vim.o.lines,
            draw = {
              columns = { { "label", "source_name", gap = 1 }, { "kind_icon" } },
            },
          },
          list = {
            selection = {
              preselect = false,
              -- preselect = function(ctx)
              --   return ctx.mode ~= "cmdline" and not require("blink.cmp").snippet_active({ direction = 1 })
              -- end,
            },
          },
        },
      }
      opts = vim.tbl_deep_extend("force", opts or {}, overrides)
      return opts
    end,
  },
}
