local myservers = require('lsp-server-configs')
local lspconfig = require('lspconfig')

local on_attach = function(client, bufnr)
	require "lsp_signature".on_attach({
		floating_window = true, -- show hint in a floating window, set to false for virtual text only mode
		bind = true, -- This is mandatory, otherwise border config won't get registered.
		padding = ' ',
		handler_opts = {
			border = "none"
		}
	})

	-- See `:help vim.lsp.*` for documentation on any of the below functions
	local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end

	-- Mappings.
	local opts = { noremap=true, silent=true }
	buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
	buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
	buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
	buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
	buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
	buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
	buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
	buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
	buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
	buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
	buf_set_keymap('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
	buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
	buf_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
	buf_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
	buf_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
	buf_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)
	buf_set_keymap('n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
end

local signs = { Error = "✘", Warn = "⚠️", Hint = "", Info = "" }
for type, icon in pairs(signs) do
	local hl = "DiagnosticSign" .. type
	-- vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
	vim.fn.sign_define(hl, { text = icon })
end

local capabilities = vim.lsp.protocol.make_client_capabilities()

-- LSP snippets
capabilities.textDocument.completion.completionItem.snippetSupport = true
capabilities.textDocument.completion.completionItem.resolveSupport = {
	properties = {
		'documentation',
		'detail',
		'additionalTextEdits',
	}
}

local lsp_installer_servers = require('nvim-lsp-installer.servers')
local installers = require('lsp-installers')

installers.add_go_server(
	lsp_installer_servers,
	'golangci_lint_ls',
	'golangci-lint-langserver',
	'github.com/nametake/golangci-lint-langserver@latest'
)

for lsp, config in pairs(myservers) do
	local default = {
		on_attach = on_attach,
		capabilities = capabilities,
		flags = {
			debounce_text_changes = 150,
		}
	}

	for k, v in pairs(default) do
	 	if config[k] == nil then config[k] = v end
	end

	local server_available, requested_server = lsp_installer_servers.get_server(lsp)
	if server_available then
		requested_server:on_ready(function ()
			requested_server:setup(config)
		end)
		if not requested_server:is_installed() then
			-- Queue the server to be installed
			requested_server:install()
		end
	else
 		-- Add to lspconfig directly
		lspconfig[lsp].setup(config)
	end
end

vim.diagnostic.config({
	float = {
		show_header = false,
		prefix_diagnostic = false,
		border = 'rounded',
		focusable = true,
	},
	virtual_text = {
        spacing = 0,
        prefix = "",
    },
	signs = true,
	underline = false,
	update_in_insert = true,
	severity_sort = true,
})

-- You will likely want to reduce updatetime which affects CursorHold
-- note: this setting is global and should be set only once
-- vim.cmd [[autocmd CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focus=false})]]
