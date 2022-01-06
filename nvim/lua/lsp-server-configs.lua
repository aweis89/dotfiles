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
	gopls = {cmd = {'gopls','--remote=auto'}},

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
					globals = {'vim'},
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
}

return server_configs
