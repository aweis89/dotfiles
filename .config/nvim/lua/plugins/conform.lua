return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      vim.tbl_deep_extend("force", opts, {
        formatters_by_ft = {
          go = { "gofmt", "goimports" },
          tf = { "terraform_fmt" },
          yaml = { "yamlfmt" },
          lua = { "stylua" },
        },
      })
    end,
  },
}
