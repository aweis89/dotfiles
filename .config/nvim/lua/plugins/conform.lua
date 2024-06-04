return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        go = { "gofumpt", "goimports", "golines" },
        tf = { "terraform_fmt" },
        yaml = { "yamlfmt" },
        lua = { "stylua" },
      },
    },
  },
}
