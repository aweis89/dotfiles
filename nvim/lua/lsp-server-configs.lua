-- key is server name and value is options used by lspconfig
-- nvim-lsp-installer will also install and setup if it has installer
local server_configs = {
    cmake = {},
    yamlls = {},
    jsonls = {},
    jdtls = {},
    vimls = {},
    java_language_server = {},
    bashls = {},
    golangci_lint_ls = {},
    gopls = {},
    -- gopls = {
    --     -- capabilities = cap,
    --     filetypes = { 'go', 'gomod', 'gohtmltmpl', 'gotexttmpl' },
    --     message_level = vim.lsp.protocol.MessageType.Error,
    --     cmd = {
    --         'gopls', -- share the gopls instance if there is one already
    --         '-remote=auto', --[[ debug options ]] --
    --         -- "-logfile=auto",
    --         -- "-debug=:0",
    --         '-remote.debug=:0',
    --         -- "-rpc.trace",
    --     },
    --     flags = { allow_incremental_sync = true, debounce_text_changes = 1000 },
    --     settings = {
    --         gopls = {
    --             -- more settings: https://github.com/golang/tools/blob/master/gopls/doc/settings.md
    --             -- not supported
    --             analyses = { unusedparams = true, unreachable = false },
    --             codelenses = {
    --                 generate = true, -- show the `go generate` lens.
    --                 gc_details = false, --  // Show a code lens toggling the display of gc's choices.
    --                 test = true,
    --                 tidy = true,
    --             },
    --             usePlaceholders = true,
    --             completeUnimported = true,
    --             staticcheck = true,
    --             matcher = 'fuzzy',
    --             diagnosticsDelay = '500ms',
    --             experimentalWatchedFileDelay = '1000ms',
    --             symbolMatcher = 'fuzzy',
    --             gofumpt = true, -- true, -- turn on for new repos, gofmpt is good but also create code turmoils
    --             buildFlags = { '-tags', 'integration' },
    --             -- buildFlags = {"-tags", "functional"}
    --         },
    --     },
    -- },

    solargraph = {
        settings = {
            solargraph = {
                diagnostics = true,
                completion = true,
                autoformat = true,
                folding = true,
                references = true,
                rename = true,
                symbols = true,
            }
        }
    },

    pyright = {},
    rust_analyzer = {},
    sumneko_lua = {
        settings = {
            Lua = {
                runtime = {
                    -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                    version = 'LuaJIT',
                    -- Setup your lua path
                    -- path = runtime_path,
                },
                diagnostics = {
                    -- Get the language server to recognize the `vim` global
                    globals = {'vim', 'hs'},
                },
                workspace = {
                    -- Make the server aware of Neovim runtime files
                    library = {
                        vim.api.nvim_get_runtime_file("", true),
                        string.format('%s/.hammerspoon/Spoons/EmmyLua.spoon/annotations', os.getenv 'HOME'),
                    }
                },
                -- Do not send telemetry data containing a randomized but unique identifier
                telemetry = {
                    enable = false,
                },
            },
        },
    },
    tsserver = {},
}

return server_configs
