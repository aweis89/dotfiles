return {
  {
    "dense-analysis/ale",
    config = function()
      -- Configuration goes here.
      local g = vim.g

      g.ale_ruby_rubocop_auto_correct_all = 1

      g.ale_linters = {
        ruby = { "rubocop", "ruby" },
        lua = { "lua_language_server" },
        golang = { "golangci-lint" },
      }
    end,
  },
}
