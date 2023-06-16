vim.cmd("set background=light")
vim.api.nvim_command([[command! TmuxSplitV silent execute '!tmux split-window -v -e "cd %:p:h"']])
vim.api.nvim_command([[command! TmuxSplitH silent execute '!tmux split-window -h -e "cd %:p:h"']])

return {
  -- add gruvbox
  { "ellisonleao/gruvbox.nvim" },

  -- Configure LazyVim to load gruvbox
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "gruvbox",
    },
  },
  {
    "ahmedkhalf/project.nvim",
    opts = {
      patterns = {
        ".git",
        "_darcs",
        ".hg",
        ".bzr",
        ".svn",
        "Makefile",
        "package.json",
        "init.lua",
        "helmfile.yaml",
        "Chart.yaml",
        "Dockerfile",
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "akinsho/flutter-tools.nvim",
      init = function()
        require("flutter-tools").setup({
          on_attach = require("lazyvim.plugins.lsp.keymaps").on_attach,
          capabilities = vim.lsp.protocol.make_client_capabilities(),
        })
        require("flutter-tools").setup_project({
          name = "default",
          device = "chrome",
        })
      end,
    },
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    keys = {
      {
        "<leader>fe",
        function()
          require("neo-tree.command").execute({ toggle = true, dir = require("lazyvim.util").get_root() })
        end,
        desc = "Explorer NeoTree (root dir)",
      },
      {
        "<leader>fE",
        function()
          require("neo-tree.command").execute({ toggle = true, dir = vim.loop.cwd() })
        end,
        desc = "Explorer NeoTree (cwd)",
      },
      { "<leader>e", "<leader>fe", desc = "Explorer NeoTree (root dir)", remap = true },
      { "<leader>E", "<leader>fE", desc = "Explorer NeoTree (cwd)", remap = true },
      { "<C-n>", "<leader>fe", desc = "Explorer NeoTree (root dir)", remap = true },
    },
  },

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
        cmake = {},
        jsonls = {},
        jdtls = {},
        vimls = {},
        -- java_language_server = {},
        bashls = {
          cmd_env = {
            GLOB_PATTERN = "*@(.sh|.inc|.bash|.command|.zsh)",
          },
        },
        golangci_lint_ls = {},
        gopls = {
          -- capabilities = cap,
          filetypes = { "go", "gomod", "gohtmltmpl", "gotexttmpl" },
          message_level = vim.lsp.protocol.MessageType.Error,
          cmd = {
            "gopls", -- share the gopls instance if there is one already
            "-remote=auto", --[[ debug options ]] --
            -- "-logfile=auto",
            -- "-debug=:0",
            "-remote.debug=:0",
            -- "-rpc.trace",
          },
          flags = { allow_incremental_sync = true, debounce_text_changes = 1000 },
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
            },
          },
        },
        terraformls = {},
        pyright = {},
        rust_analyzer = {
          -- settings = {
          --   serverPath = "/Users/aweisberg/rust-analyzer-docker",
          -- },
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
      },
    },
  },

  -- add more treesitter parsers
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "bash",
        "html",
        "javascript",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "query",
        "regex",
        "tsx",
        "typescript",
        "vim",
        "yaml",
        "rust",
        "go",
      },
    },
  },

  -- add any tools you want to have installed below
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "stylua",
        "shellcheck",
        "shfmt",
        "flake8",
      },
    },
  },
}
