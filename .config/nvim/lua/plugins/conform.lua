return {
  {
    "stevearc/conform.nvim",
    init = function()
      vim.api.nvim_create_user_command("ConformDisable", function(args)
        if args.bang then
          -- FormatDisable! will disable formatting just for this buffer
          vim.b.disable_autoformat = true
        else
          vim.g.disable_autoformat = true
        end
      end, {
        desc = "Disable autoformat-on-save",
        bang = true,
      })

      vim.api.nvim_create_user_command("ConformEnable", function()
        vim.b.disable_autoformat = false
        vim.g.disable_autoformat = false
      end, {
        desc = "Re-enable autoformat-on-save",
      })
    end,
    opts = function(_, opts)
      local ft = opts.formatters_by_ft
      ft.go = { "gofumpt", "goimports", "golines" }
      ft.tf = { "terraform_fmt" }
      ft.yaml = { "yamlfmt" }
      ft.lua = { "stylua" }
      return opts
    end,
  },
}
