return {
  {
    "neovim/nvim-lspconfig",
    keys = {
      { "cd", "vim.diagnostic.open_float" },
    },
    ---@class PluginLspOpts
    opts = {
      servers = {
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
      },
      diagnostics = {
        float = {
          border = "rounded",
        },
      },
    },
  },
}
