return {
  {
    "stevearc/conform.nvim",
    ---@param opts ConformOpts
    init = function(_, opts)
      local disable_format_file = "disable-format"
      LazyVim.ls(vim.fn.getcwd(), function(path, name, type)
        if name == disable_format_file then
          LazyVim.format.enable(false)
        end
      end)
    end,
    opts = function(_, opts)
      local ft = opts.formatters_by_ft
      ft.go = { "gofumpt", "goimports" }
      ft.tf = { "terraform_fmt" }
      ft.yaml = {}
      ft.lua = { "stylua" }
      ft.bash = { "bashls" }
      return opts
    end,
  },
}
