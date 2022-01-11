vim.g.mapleader = " "
vim.env.NVIM_TUI_ENABLE_TRUE_COLOR = 1

function set(name, val)
	val = val or true
	vim.o[name] = val
end

function map (mode, key, target, opts)
	opts = opts or {noremap = true}
	vim.api.nvim_set_keymap(mode, key, target, opts)
end

require('plugin')

set("termguicolors")
set("termguicolors")
set("autoindent")
set("ignorecase")
set("number")
set("hlsearch")
set("ai")
set("cursorline")
set("completeopt", "menu,menuone,noselect")
set("expandtab", false)
set("tabstop", 4)
set("shiftwidth", 4)
set("updatetime", 250)
-- set("shellcmdflag", "-ic")

map('i', 'jj', '<ESC>')
map('i', '<C-c>', '<ESC>')
map('', '<leader>q', ':q<cr>')
map('', 'L', '$')
map('', 'H', '^')
map('t', 'jj', [[<C-\><C-n>]])
map('t', 'qq', [[<C-\><C-n>:q!<CR>]])
map('t', '<Esc>', [[<C-\><C-n>:q!<CR>]])

vim.cmd([[
    autocmd TermOpen * startinsert
    
    autocmd FileType go exec 'source ' . stdpath('config') . '/golang/init.vim'
    autocmd BufWritePre *.go,*.rs :silent! lua vim.lsp.buf.formatting()
    autocmd BufWritePre *.go,*.rs :silent! lua require('lsp_utils').org_imports(3000)

    augroup colorschemes
        autocmd!
        " autocmd ColorScheme * hi! link DiagnosticWarn Comment
        autocmd ColorScheme * hi! link DiagnosticInfo Comment
        autocmd ColorScheme * hi! link DiagnosticHint Comment
        " autocmd ColorScheme * hi! link DiagnosticError Comment
    augroup end
]])
