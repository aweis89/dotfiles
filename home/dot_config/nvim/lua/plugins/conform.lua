return {
  {
    "stevearc/conform.nvim",
    enabled = function()
      -- Check if none-ls extra is enabled in LazyVim
      local has_none_ls = require("lazy.core.config").spec.plugins["none-ls.nvim"] ~= nil
      return not has_none_ls
    end,
    opts = function(_, opts)
      local disable_format_file = "disable-format"
      vim.api.nvim_create_user_command("ConformToggle", function()
        local disabled = false
        local current_path
        LazyVim.ls(vim.fn.getcwd(), function(path, name, _)
          if name == disable_format_file then
            disabled = true
            current_path = path
          end
        end)
        if disabled then
          vim.cmd("!rm " .. current_path)
          LazyVim.format.enable(true)
        else
          vim.cmd("!touch " .. disable_format_file)
          LazyVim.format.enable(false)
        end
      end, { desc = "Persistently enable/disable formatting" })

      LazyVim.ls(vim.fn.getcwd(), function(_, name)
        if name == disable_format_file then
          LazyVim.format.enable(false)
        end
      end)

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
