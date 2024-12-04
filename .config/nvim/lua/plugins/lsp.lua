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
                unusedparams = true, -- Enable/disable specific analyses
                unusedwrite = false, -- Disable static analysis that overlaps with golangci-lint
              },
              staticcheck = false, -- Disable built-in static chec
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
