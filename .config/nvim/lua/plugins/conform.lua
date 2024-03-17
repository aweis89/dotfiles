return {
  {
    "stevearc/conform.nvim",
    dependencies = { "mason.nvim" },
    opts = function(_, opts)
      opts.format_by_ft = {
        go = {"gofumpt", "golines" "goimports"}
        tf = {"terraform_fmt"}
        yaml = {"yamlfmt"}
      }
    end,
  },
}
