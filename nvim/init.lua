vim.g.mapleader = " "
vim.env.NVIM_TUI_ENABLE_TRUE_COLOR = 1

function Map(mode, key, target, opts)
	opts = opts or { noremap = true }
	vim.api.nvim_set_keymap(mode, key, target, opts)
end

require('plugins')

local function set(name, val)
	if val ~= false then
		val = val or true
	end
	vim.o[name] = val
end

set("ignorecase")
set("number")
set("hlsearch", false)
set("ai")
set("cursorline")
set("completeopt", "menu,menuone,noselect")
set("expandtab", false)
set("autoindent")
-- set("tabstop", 4)
-- set("softtabstop", 4)
-- set("shiftwidth", 4)
set("smartindent")
set("updatetime", 250)
set("cmdheight", 1)

set("errorbells", false)
set("swapfile", false)
set("backup", false)
set("undofile")
set("incsearch")
set("scrolloff", 8)
set("copyindent", true)

set("termguicolors")

Map('n', '<C-w>', ':execute ":!gh browse %:" . line(".")<CR>')
Map('i', 'jj', '<ESC>')
Map('i', '<C-c>', '<ESC>')
Map('i', '<C-l>', '<RIGHT>')
Map('i', '<C-h>', '<LEFT>')
Map('n', '<leader>q', ':q<cr>')
Map('n', 'L', '$')
Map('n', 'H', '^')
Map('t', 'jj', [[<C-\><C-n>]])
Map('t', 'qq', [[<C-\><C-n>:q!<CR>]])
Map('t', '<Esc>', [[<C-\><C-n>:q!<CR>]])

-- LSP mappings
Map('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>')
Map('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>')
Map('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>')
Map('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>')
Map('n', '<C-k>', '^f(<cmd>lua vim.lsp.buf.signature_help()<CR>')
Map('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>')
Map('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>')
Map('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>')
Map('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>')
Map('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>')
Map('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>')
Map('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>')
Map('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>')
Map('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>')
Map('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>')
Map('n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>')
Map('n', 'gr', '<cmd>Telescope lsp_references<CR>')

Map('v', 'f', '<ESC><cmd>lua vim.lsp.buf.range_formatting()<CR>', { noremap = true })
-- auto formatt
-- vim.api.nvim_create_autocmd("BufWritePre", {
-- 	group = vim.api.nvim_create_augroup("Format", { clear = true }),
-- 	pattern = { "*" },
-- 	callback = function()
-- 		vim.lsp.buf.formatting_sync(nil, 3000)
-- 	end,
-- })

vim.api.nvim_create_autocmd("BufWritePre", {
	group = vim.api.nvim_create_augroup("AutoImport", { clear = true }),
	pattern = { "*.go" },
	callback = function()
		local params = vim.lsp.util.make_range_params(nil, vim.lsp.util._get_offset_encoding())
		params.context = { only = { "source.organizeImports" } }

		local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 3000)
		for _, res in pairs(result or {}) do
			for _, r in pairs(res.result or {}) do
				if r.edit then
					vim.lsp.util.apply_workspace_edit(r.edit, vim.lsp.util._get_offset_encoding())
				else
					vim.lsp.buf.execute_command(r.command)
				end
			end
		end
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("YamlFileTYpe", { clear = true }),
	pattern = { "*.yaml", "*.yml" },
	callback = function()
		set("tabstop", 2)
		set("softtabstop", 2)
		set("shiftwidth", 2)
		set("expandtab", false)
	end,
})
