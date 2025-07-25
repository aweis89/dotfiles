-- needs to match initial state in lspconfig
return {
  {
    "nvimtools/none-ls.nvim",
    enabled = true,
    opts = function(_, opts)
      local nls = require("null-ls")
      opts.sources = vim.list_extend(opts.sources or {}, {
        nls.builtins.diagnostics.golangci_lint,
      })

      ---@type vim.diagnostic.Opts
      opts.diagnostic_config = {
        underline = true,
        update_in_insert = false,
        virtual_text = {
          spacing = 4,
          source = "if_many",
        },
        severity_sort = true,
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = LazyVim.config.icons.diagnostics.Error,
            [vim.diagnostic.severity.WARN] = LazyVim.config.icons.diagnostics.Warn,
            [vim.diagnostic.severity.HINT] = LazyVim.config.icons.diagnostics.Hint,
            [vim.diagnostic.severity.INFO] = LazyVim.config.icons.diagnostics.Info,
          },
        },
      }
    end,
  },
  {
    "williamboman/mason.nvim",
    opts = { ensure_installed = { "golangci-lint" } },
  },
  {
    "neovim/nvim-lspconfig",
    keys = {
      { "cd", "vim.diagnostic.open_float" },
      { "<leader>lt", "<cmd>LintToggle<cr>", desc = "Toggle Lint", mode = { "n", "v" }, remap = true },
    },
    ---@class PluginLspOpts
    opts = function(_, opts)
      local lint = {
        visible = true,
      }
      vim.api.nvim_create_user_command("LintToggle", function(_)
        local inline_diagnostic = require("tiny-inline-diagnostic")
        if lint.visible then
          vim.diagnostic.hide(nil, 0)
          inline_diagnostic.disable()
          lint.visible = false
        else
          vim.diagnostic.show(nil, 0)
          inline_diagnostic.enable()
          lint.visible = true
        end
      end, {
        desc = "Toggle between full diagnostics, signs-only, and hidden",
        bang = true,
      })

      return vim.tbl_deep_extend("force", opts, {
        -- diagnostics = {
        --   virtual_text = false,
        -- },
        servers = {
          gopls = {
            filetypes = { "go", "gomod", "gohtmltmpl", "gotexttmpl" },
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
