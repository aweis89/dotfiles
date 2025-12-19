return {
  {
    "saghen/blink.cmp",
    ---@module 'blink.cmp'
    ---@param opts blink.cmp.Config
    opts = function(_, opts)
      ---@type blink.cmp.Config
      local overrides = {
        keymap = {
          preset = "super-tab",
          ["<C-j>"] = { "select_next", "fallback" },
          ["<C-k>"] = { "select_prev", "fallback" },
        },
      }
      opts = vim.tbl_deep_extend("force", opts or {}, overrides)
      return opts
    end,
  },
}
