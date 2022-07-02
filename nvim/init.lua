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
set("autoindent")
set("ignorecase")
set("number")
set("hlsearch", false)
set("ai")
set("cursorline")
set("completeopt", "menu,menuone,noselect")
set("expandtab", false)
set("tabstop", 4)
set("softtabstop", 4)
set("shiftwidth", 4)
set("updatetime", 250)
set("cmdheight", 1)

set("smartindent")
set("errorbells", false)
set("swapfile", false)
set("backup", false)
set("undofile")
set("incsearch")
set("termguicolors")
set("scrolloff", 8)

Map('i', 'jj', '<ESC>')
Map('i', '<C-c>', '<ESC>')
Map('n', '<leader>q', ':q<cr>')
Map('n', 'L', '$')
Map('n', 'H', '^')
Map('t', 'jj', [[<C-\><C-n>]])
Map('t', 'qq', [[<C-\><C-n>:q!<CR>]])
Map('t', '<Esc>', [[<C-\><C-n>:q!<CR>]])

-- auto formatt
vim.api.nvim_create_augroup("formatt", {})
vim.api.nvim_create_autocmd("BufWritePre", {
	group = "formatt",
	pattern = { "*" },
	callback = function()
		vim.lsp.buf.formatting_sync(nil, 3000)
	end,
})

vim.api.nvim_create_augroup("auto_imports", {})
vim.api.nvim_create_autocmd("BufWritePre", {
	group = "auto_imports",
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
