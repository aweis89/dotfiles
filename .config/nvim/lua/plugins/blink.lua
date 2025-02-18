return {
  {
    "neovim/nvim-lspconfig",
    opts = function()
      -- disable a keymap
      local keys = require("lazyvim.plugins.lsp.keymaps").get()
      keys[#keys + 1] = { "<c-k>", mode = { "i" }, false }
    end,
  },
  {
    "saghen/blink.cmp",
    ---@module 'blink.cmp'
    ---@param opts blink.cmp.Config
    opts = function(_, opts)
      opts = vim.tbl_deep_extend("force", opts or {}, {
        ---@type blink.cmp.Config
        sources = {
          providers = {
            lsp = {
              score_offset = 5,
            },
            lazydev = {
              score_offset = 5,
            },
            copilot = {
              score_offset = 4,
            },
            snippets = {
              score_offset = 2,
            },
            path = {
              score_offset = 2,
            },
            buffer = {
              score_offset = 1,
            },
          },
        },
        keymap = {
          ["<C-k>"] = { "select_prev", "fallback" },
          ["<C-j>"] = { "select_next", "fallback" },
        },
        cmdline = {
          keymap = {
            ["<C-k>"] = { "select_prev", "fallback" },
            ["<C-j>"] = { "select_next", "fallback" },
          },
          enabled = true,
          -- remove once lazy update no longer specifies override
          sources = function()
            local type = vim.fn.getcmdtype()
            if type == "/" or type == "?" then
              return { "buffer" }
            end
            if type == ":" then
              return { "cmdline" }
            end
            return {}
          end,
        },
        signature = {
          enabled = true,
        },
        completion = {
          documentation = {
            auto_show = true,
          },
          menu = {
            max_height = vim.o.lines,
            draw = {
              columns = { { "label", "source_name", gap = 1 }, { "kind_icon" } },
            },
          },
          list = {
            selection = {
              auto_insert = function(ctx)
                return ctx.mode ~= "cmdline"
              end,
              preselect = function(ctx)
                return ctx.mode ~= "cmdline" and not require("blink.cmp").snippet_active({ direction = 1 })
              end,
            },
          },
        },
      })
      return opts
    end,
  },
}
