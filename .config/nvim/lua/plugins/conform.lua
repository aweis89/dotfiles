return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      local ft = opts.formatters_by_ft
      ft.go = { "gofumpt", "goimports" }
      ft.tf = { "terraform_fmt" }
      ft.yaml = {}
      ft.lua = { "stylua" }
      return opts
    end,
  },
}
