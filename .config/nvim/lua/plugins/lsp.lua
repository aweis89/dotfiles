-- Don't auto select first item
vim.cmd([[set completeopt=menu,menuone,noselect]])
vim.cmd([[set noswapfile]])

return {
  {
    "zbirenbaum/copilot-cmp",
    config = function()
      require("copilot_cmp").setup({ fix_pairs = true })
    end,
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

      -- Add the length comparator to prioritize shorter items
      opts.sorting = {
        priority_weight = 2,
        comparators = {
          cmp.config.compare.offset,
          cmp.config.compare.exact,
          cmp.config.compare.score,
          function(entry1, entry2)
            local len1 = string.len(entry1.completion_item.label)
            local len2 = string.len(entry2.completion_item.label)
            if len1 ~= len2 then
              return len1 < len2
            end
          end,
          cmp.config.compare.kind,
          cmp.config.compare.sort_text,
          cmp.config.compare.length,
          cmp.config.compare.order,
        },
      }

      vim.list_extend(opts.sources, {
        { name = "nvim_lsp", group_index = 1 },
        { name = "nvim_lsp_signature_help", group_index = 1 },
        { name = "copilot", group_index = 2 },
        { name = "path", group_index = 2 },
        { name = "luasnip", group_index = 2 },
        { name = "nvim_lua", group_index = 2 },
        { name = "buffer", group_index = 3, max_item_count = 3 },
        { name = "tmux", group_index = 3, max_item_count = 3 },
      })

      opts.completion.completeopt = "menu,menuone,noinsert,noselect"
      opts.preselect = "None"

      local has_words_before = function()
        unpack = unpack or table.unpack
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end

      opts.mapping = vim.tbl_extend("force", opts.mapping, {
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<CR>"] = cmp.mapping.confirm({ select = false }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
          elseif vim.snippet.active({ direction = 1 }) then
            vim.schedule(function()
              vim.snippet.jump(1)
            end)
          elseif has_words_before() then
            cmp.complete()
          else
            fallback()
          end
        end, { "i", "s" }),

        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
          elseif vim.snippet.active({ direction = -1 }) then
            vim.schedule(function()
              vim.snippet.jump(-1)
            end)
          else
            fallback()
          end
        end, { "i", "s" }),
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
    end,
  },

  {
    "neovim/nvim-lspconfig",
    init = function()
      require("legendary").keymaps({
        {
          "cd",
          vim.diagnostic.open_float,
          mode = "n",
          description = "Open diagnostic float window",
        },
      })
    end,
    ---@class PluginLspOpts
    opts = function(_, opts)
      local servers = {
        -- Enable the following language servers
        taplo = {},
        cmake = {},
        jsonls = {},
        jdtls = {},
        vimls = {},
        sourcekit = {},
        -- java_language_server = {},
        bashls = {
          filetypes = { "sh", "zsh", "bash" },
        },
        html = {
          filetypes = { "html", "templ" },
        },
        htmx = {
          filetypes = { "html", "templ" },
        },
        templ = {},
        tailwindcss = {
          filetypes = { "templ", "astro", "javascript", "typescript", "react" },
          init_options = { userLanguages = { templ = "html" } },
        },
        gopls = {
          filetypes = { "go", "gomod", "gohtmltmpl", "gotexttmpl" },
          message_level = vim.lsp.protocol.MessageType.Error,
          flags = { allow_incremental_sync = true, debounce_text_changes = 1000 },
          hints = false,
          settings = {
            gopls = {
              -- more settings: https://github.com/golang/tools/blob/master/gopls/doc/settings.md
              -- not supported
              analyses = {
                unusedparams = true,
                unreachable = true,
                fieldalignment = false,
              },
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
              -- buildFlags = { "-tags", "integration" },
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
        kotlin_language_server = {},
        tsserver = {},
        -- helm_ls = {},
      }
      opts.servers = vim.tbl_extend("force", opts.servers, servers)
    end,
  },
}
