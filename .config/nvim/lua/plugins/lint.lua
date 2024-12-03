return {
  {
    "mfussenegger/nvim-lint",
    init = function()
      local lint = {
        visible = true,
      }
      vim.api.nvim_create_user_command("LintToggle", function(_)
        if lint.visible then
          vim.diagnostic.hide(nil, 0)
          lint.visible = false
        else
          vim.diagnostic.show(nil, 0)
          lint.visible = true
        end
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
