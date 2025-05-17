-- needs to match initial state in lspconfig
return {
  -- {
  --   "rachartier/tiny-inline-diagnostic.nvim",
  --   event = "VeryLazy", -- Or `LspAttach`
  --   priority = 1000,    -- needs to be loaded in first
  --   config = true,
  --   opts = {
  --     options = {
  --       show_source = true,
  --       use_icons_from_diagnostic = true,
  --       break_line = {
  --         enabled = true,
  --         after = 70,
  --       },
  --     },
  --   },
  -- },
  {
    "nvimtools/none-ls.nvim",
    enabled = false,
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
          prefix = function(diagnostic)
            local icons = LazyVim.config.icons.diagnostics
            for d, icon in pairs(icons) do
              if diagnostic.severity == vim.diagnostic.severity[d:upper()] then
                return icon
              end
            end
            return "●"
          end
        },
        severity_sort = true,
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = " ",
            [vim.diagnostic.severity.WARN] = " ",
            [vim.diagnostic.severity.HINT] = " ",
            [vim.diagnostic.severity.INFO] = " ",
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
      { "cd",         "vim.diagnostic.open_float" },
      { "<leader>lt", "<cmd>LintToggle<cr>",      desc = "Toggle Lint", mode = { "n", "v" }, remap = true },
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
