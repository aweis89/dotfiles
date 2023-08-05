-- Don't auto select first item
vim.cmd([[set completeopt=menu,menuone,noselect]])
vim.cmd([[set noswapfile]])

return {
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "onsails/lspkind.nvim",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lua",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/vim-vsnip",
      "hrsh7th/cmp-vsnip",
      "andersevenrud/cmp-tmux",
    },
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      local cmp = require("cmp")
      opts.sources = cmp.config.sources({
        { name = "nvim_lsp", group_index = 2 },
        { name = "nvim_lsp_signature_help", group_index = 2 },
        { name = "copilot", group_index = 2 },
        { name = "path", group_index = 2 },
        { name = "luasnip", group_index = 2 },
        { name = "nvim_lua", group_index = 2 },
        { name = "buffer", group_index = 3, max_item_count = 3 },
        { name = "tmux", group_index = 3, max_item_count = 3 },
      })
      opts.window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      }

      opts.completion = {
        completeopt = "menu,menuone,noinsert,noselect",
      }
      opts.preselect = "None"

      opts.mapping = vim.tbl_extend("force", opts.mapping, {
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<CR>"] = cmp.mapping.confirm({ select = false }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
      })

      cmp.setup.cmdline("/", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "buffer" },
        },
      })
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path" },
        }, {
          { name = "cmdline" },
        }),
      })

      local has_words_before = function()
        unpack = unpack or table.unpack
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end

      local luasnip = require("luasnip")
      opts.mapping = vim.tbl_extend("force", opts.mapping, {
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
            -- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable()
            -- this way you will only jump inside the snippet region
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          elseif has_words_before() then
            cmp.complete()
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
      })
    end,
  },

  {
    "neovim/nvim-lspconfig",
    ---@class PluginLspOpts
    opts = {
      ---@type lspconfig.options
      servers = {
        taplo = {},
        cmake = {},
        jsonls = {},
        jdtls = {},
        vimls = {},
        -- java_language_server = {},
        bashls = {
          filetypes = { "sh", "zsh", "bash" },
        },
        golangci_lint_ls = { autostart = false },
        gopls = {
          -- capabilities = cap,
          filetypes = { "go", "gomod", "gohtmltmpl", "gotexttmpl" },
          message_level = vim.lsp.protocol.MessageType.Error,
          flags = { allow_incremental_sync = true, debounce_text_changes = 1000 },
          hints = false,
          settings = {
            gopls = {
              -- more settings: https://github.com/golang/tools/blob/master/gopls/doc/settings.md
              -- not supported
              analyses = { unusedparams = true, unreachable = true },
              codelenses = {
                generate = true, -- show the `go generate` lens.
                gc_details = false, --  // Show a code lens toggling the display of gc's choices.
                test = true,
                tidy = true,
              },
              usePlaceholders = true,
              completeUnimported = true,
              staticcheck = true,
              matcher = "fuzzy",
              diagnosticsDelay = "500ms",
              symbolMatcher = "fuzzy",
              gofumpt = false, -- true, -- turn on for new repos, gofmpt is good but also create code turmoils
              buildFlags = { "-tags", "integration" },
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
        terraformls = {},
        pyright = {},
        rust_analyzer = {
          settings = {
            ["rust-analyzer"] = {
              checkOnSave = {
                command = "clippy",
              },
              inlayHints = {
                enable = true,
              },
              imports = {
                granularity = {
                  group = "module",
                },
                prefix = "self",
              },
              -- cargo = {
              --   buildScripts = {
              --     enable = true,
              --   },
              -- },
              procMacro = {
                enable = true,
              },
            },
          },
        },
        kotlin_language_server = {},
        lua_ls = {
          settings = {
            Lua = {
              runtime = {
                -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                version = "LuaJIT",
              },
              diagnostics = {
                -- Get the language server to recognize the `vim` global
                globals = { "vim", "hs" },
              },
              workspace = {
                -- Make the server aware of Neovim runtime files
                library = vim.api.nvim_get_runtime_file("", true),
              },
              -- Do not send telemetry data containing a randomized but unique identifier
              telemetry = {
                enable = false,
              },
            },
          },
        },
        tsserver = {},
        helm_ls = {},
      },
    },
  },
}
