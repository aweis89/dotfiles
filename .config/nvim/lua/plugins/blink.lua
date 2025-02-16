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
    dependencies = { "mikavilpas/blink-ripgrep.nvim" },
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      sources = {
        default = { "lsp", "path", "snippets", "buffer", "ripgrep" },
        providers = {
          ripgrep = {
            module = "blink-ripgrep",
            name = "Ripgrep",
            -- the options below are optional, some default values are shown
            ---@module "blink-ripgrep"
            ---@type blink-ripgrep.Options
            opts = {
              -- For many options, see `rg --help` for an exact description of
              -- the values that ripgrep expects.

              -- the minimum length of the current word to start searching
              -- (if the word is shorter than this, the search will not start)
              prefix_min_len = 3,

              -- The number of lines to show around each match in the preview
              -- (documentation) window. For example, 5 means to show 5 lines
              -- before, then the match, and another 5 lines after the match.
              context_size = 5,

              -- The maximum file size of a file that ripgrep should include in
              -- its search. Useful when your project contains large files that
              -- might cause performance issues.
              -- Examples:
              -- "1024" (bytes by default), "200K", "1M", "1G", which will
              -- exclude files larger than that size.
              max_filesize = "1M",

              -- Specifies how to find the root of the project where the ripgrep
              -- search will start from. Accepts the same options as the marker
              -- given to `:h vim.fs.root()` which offers many possibilities for
              -- configuration. If none can be found, defaults to Neovim's cwd.
              --
              -- Examples:
              -- - ".git" (default)
              -- - { ".git", "package.json", ".root" }
              project_root_marker = ".git",

              -- Enable fallback to neovim cwd if project_root_marker is not
              -- found. Default: `true`, which means to use the cwd.
              project_root_fallback = true,

              -- The casing to use for the search in a format that ripgrep
              -- accepts. Defaults to "--ignore-case". See `rg --help` for all the
              -- available options ripgrep supports, but you can try
              -- "--case-sensitive" or "--smart-case".
              search_casing = "--ignore-case",

              -- (advanced) Any additional options you want to give to ripgrep.
              -- See `rg -h` for a list of all available options. Might be
              -- helpful in adjusting performance in specific situations.
              -- If you have an idea for a default, please open an issue!
              --
              -- Not everything will work (obviously).
              additional_rg_options = {},

              -- When a result is found for a file whose filetype does not have a
              -- treesitter parser installed, fall back to regex based highlighting
              -- that is bundled in Neovim.
              fallback_to_regex_highlighting = true,

              -- Absolute root paths where the rg command will not be executed.
              -- Usually you want to exclude paths using gitignore files or
              -- ripgrep specific ignore files, but this can be used to only
              -- ignore the paths in blink-ripgrep.nvim, maintaining the ability
              -- to use ripgrep for those paths on the command line. If you need
              -- to find out where the searches are executed, enable `debug` and
              -- look at `:messages`.
              ignore_paths = {},

              -- Any additional paths to search in, in addition to the project
              -- root. This can be useful if you want to include dictionary files
              -- (/usr/share/dict/words), framework documentation, or any other
              -- reference material that is not available within the project
              -- root.
              additional_paths = {},

              -- Show debug information in `:messages` that can help in
              -- diagnosing issues with the plugin.
              debug = false,
            },
            -- (optional) customize how the results are displayed. Many options
            -- are available - make sure your lua LSP is set up so you get
            -- autocompletion help
            transform_items = function(_, items)
              for _, item in ipairs(items) do
                -- example: append a description to easily distinguish rg results
                item.labelDetails = {
                  description = "(rg)",
                }
              end
              return items
            end,
          },
        },
        cmdline = function()
          local type = vim.fn.getcmdtype()
          -- Search forward and backward
          if type == "/" or type == "?" then
            return { "buffer" }
          end
          -- Commands
          if type == ":" then
            return { "cmdline" }
          end
          return {}
        end,
      },
      keymap = {
        ["<C-k>"] = { "select_prev", "fallback" },
        ["<C-j>"] = { "select_next", "fallback" },
        ["<c-g>"] = {
          function()
            -- invoke manually, requires blink >v0.8.0
            require("blink-cmp").show({ providers = { "ripgrep" } })
          end,
        },
      },
      signature = {
        enabled = true,
      },
      completion = {
        documentation = {
          auto_show = true,
        },
        menu = {
          max_height = math.floor(vim.o.lines / 2),
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
    },
  },
}
