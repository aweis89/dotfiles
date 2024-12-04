-- needs to match initial state in lspconfig
return {
  {
    "neovim/nvim-lspconfig",
    keys = {
      { "cd", "vim.diagnostic.open_float" },
    },
    ---@class PluginLspOpts
    opts = function(_, opts)
      -- Store original diagnostic config and ensure signs are configured
      -- local orig_config = vim.diagnostic.config()
      -- local signs = {
      --   { name = "DiagnosticSignError", text = require("lazyvim.config").icons.diagnostics.Error },
      --   { name = "DiagnosticSignWarn", text = require("lazyvim.config").icons.diagnostics.Warn },
      --   { name = "DiagnosticSignHint", text = require("lazyvim.config").icons.diagnostics.Hint },
      --   { name = "DiagnosticSignInfo", text = require("lazyvim.config").icons.diagnostics.Info },
      -- }

      -- local signs = opts.diagnostic.signs.text
      -- for _, sign in ipairs(signs) do
      --   vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = sign.name })
      -- end

      local diagnostic = opts.diagnostics

      local lint = {
        visible = false,
      }

      vim.api.nvim_create_user_command("LintToggle", function(_)
        if lint.visible then
          -- Switch to signs-only mode while preserving LazyVim's sign configuration
          vim.diagnostic.config(vim.tbl_extend("force", diagnostic, {
            virtual_text = false,
            underline = false,
            float = { show = false },
          }))
          lint.visible = false
        else
          -- Restore original configuration
          vim.diagnostic.config(diagnostic)
          vim.diagnostic.show(nil, 0)
          lint.visible = true
        end
      end, {
        desc = "Toggle between full diagnostics, signs-only, and hidden",
        bang = true,
      })

      return vim.tbl_deep_extend("force", opts, {
        diagnostics = {
          virtual_text = false,
        },
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
      })
    end,
  },
}
