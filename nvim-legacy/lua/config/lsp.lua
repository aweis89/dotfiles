local M = {}

local border = {
	{ "╭", "FloatBorder" },
	{ "─", "FloatBorder" },
	{ "╮", "FloatBorder" },
	{ "│", "FloatBorder" },
	{ "╯", "FloatBorder" },
	{ "─", "FloatBorder" },
	{ "╰", "FloatBorder" },
	{ "│", "FloatBorder" },
}

-- key is server name and value is options used by lspconfig
-- mason will also install and setup if it has installer
local server_configs = {
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
		filetypes = { 'go', 'gomod', 'gohtmltmpl', 'gotexttmpl' },
		message_level = vim.lsp.protocol.MessageType.Error,
		cmd = {
			'gopls',         -- share the gopls instance if there is one already
			'-remote=auto', --[[ debug options ]] --
			-- "-logfile=auto",
			-- "-debug=:0",
			'-remote.debug=:0',
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
				matcher = 'fuzzy',
				diagnosticsDelay = '500ms',
				experimentalWatchedFileDelay = '1000ms',
				symbolMatcher = 'fuzzy',
				gofumpt = false, -- true, -- turn on for new repos, gofmpt is good but also create code turmoils
				buildFlags = { '-tags', 'integration' },
				-- buildFlags = {"-tags", "functional"}
			},
		},
	},
	terraformls = {},
	pyright = {},
	rust_analyzer = {
		settings = {
			serverPath = "/Users/aweisberg/rust-analyzer-docker",
		},
	},
	kotlin_language_server = {},
	lua_ls = {
		settings = {
			Lua = {
				runtime = {
					-- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
					version = 'LuaJIT',
				},
				diagnostics = {
					-- Get the language server to recognize the `vim` global
					globals = { 'vim', 'hs' },
				},
				workspace = {
					-- Make the server aware of Neovim runtime files
					library = {
						vim.api.nvim_get_runtime_file("", true),
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
	-- dartls = {},
}

require("mason").setup()
require("mason-lspconfig").setup({ automatic_installation = true })

local lspconfig = require('lspconfig')

-- Add border
local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
	opts = opts or {}
	opts.border = opts.border or LspBorder('LspConfig')
	return orig_util_open_floating_preview(contents, syntax, opts, ...)
end

function M.on_attach(client, bufnr)
	require 'illuminate'.on_attach(client)

	local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end

	-- Mappings.
	local opts = { noremap = true, silent = true }
	buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
	buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
	buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
	buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
	buf_set_keymap('n', '<C-k>', '^f(<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
	buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
	buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
	buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
	buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
	buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
	buf_set_keymap('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
	-- buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
	buf_set_keymap('n', 'gr', '<cmd>Telescope lsp_references<CR>', opts)
	buf_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
	buf_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
	buf_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
	buf_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)
	buf_set_keymap('n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
	if vim.bo[bufnr].buftype ~= "" or vim.bo[bufnr].filetype == "helm" then
		vim.diagnostic.disable()
	end
end

local signs = { Error = "✘", Warn = "", Hint = "", Info = "" }
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


function M.setup()
	for lsp, config in pairs(server_configs) do
		local default = {
			on_attach = M.on_attach,
			capabilities = capabilities,
			flags = {
				debounce_text_changes = 150,
			}
		}

		for k, v in pairs(default) do
			if config[k] == nil then config[k] = v end
		end

		-- Add to lspconfig directly
		lspconfig[lsp].setup(config)
	end

	vim.diagnostic.config({
		float = {
			show_header = false,
			prefix_diagnostic = false,
			border = border,
			focusable = true,
		},
		virtual_text = {
			spacing = 2,
			prefix = "",
			-- severity = vim.diagnostic.severity.ERROR,
		},
		underline = false,
		update_in_insert = false,
		severity_sort = true,
	})
end

return M
