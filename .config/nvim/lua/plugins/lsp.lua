return {
  {
    "neovim/nvim-lspconfig",
    keys = {
      { "cd", "vim.diagnostic.open_float" },
    },
    ---@class PluginLspOpts
    opts = {
      servers = {
        gopls = {
          filetypes = { "go", "gomod", "gohtmltmpl", "gotexttmpl" },
          hints = false,
          settings = {
            gopls = {
              analyses = {
                -- Disable static analysis that overlaps with golangci-lint
                unusedwrite = false,
                fieldalignment = false,
                unusedparams = false,
              },
              staticcheck = false,
              hints = {
                assignVariableTypes = false,
                compositeLiteralFields = false,
                compositeLiteralTypes = false,
                constantValues = false,
                functionTypeParameters = false,
                parameterNames = false,
                rangeVariableTypes = false,
              },
            },
          },
        },
      },
      diagnostics = {
        float = {
          border = "rounded",
        },
      },
    },
  },
}
