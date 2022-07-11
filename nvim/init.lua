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

set("termguicolors")
set("termguicolors")
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
set("termguicolors")
set("scrolloff", 8)

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

Map('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
Map('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
Map('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
Map('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
Map('n', '<C-k>', '^f(<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
Map('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
Map('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
Map('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
Map('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
Map('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
Map('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
Map('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
Map('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
Map('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
Map('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
Map('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)
Map('n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)

-- auto formatt
vim.api.nvim_create_autocmd("BufWritePre", {
	group = vim.api.nvim_create_augroup("Format", { clear = true }),
	pattern = { "*" },
	callback = function()
		vim.lsp.buf.formatting_sync(nil, 3000)
	end,
})

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
	end,
})
