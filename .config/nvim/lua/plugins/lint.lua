return {
  {
    "mfussenegger/nvim-lint",
    init = function()
      vim.api.nvim_create_user_command("LintDisable", function(_)
        local lint = require("lint")
        -- get filetype of current buffer
        local ft = vim.filetype.match({ buf = 0 })
        if ft and lint.linters_by_ft[ft] then
          -- empty out the linter table for current filetype
          lint.linters_by_ft[ft] = {}
        end
        -- reset diagnostics
        vim.diagnostic.reset(nil, 0)
      end, {
        desc = "Disable autoformat-on-save",
        bang = true,
      })
    end,
    opts = {
      linters_by_ft = {
        go = { "golangcilint" },
        ["*"] = { "codespell" },
      },
    },
  },
}
