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
map('n', '<leader>q', ':q<cr>')
map('n', 'L', '$')
map('n', 'H', '^')
map('t', 'jj', [[<C-\><C-n>]])
map('t', 'qq', [[<C-\><C-n>:q!<CR>]])
map('t', '<Esc>', [[<C-\><C-n>:q!<CR>]])

map('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>')
map('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>')
map('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>')
map('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>')
map('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>')
map('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>')
map('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>')
map('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>')
map('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>')
map('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>')
map('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>')
map('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>')
map('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>')
map('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>')
map('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>')
map('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>')
map('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>')
map('n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>')

vim.cmd([[
    autocmd TermOpen * startinsert
    
    autocmd FileType go exec 'source ' . stdpath('config') . '/golang/init.vim'
    autocmd BufWritePre *.go,*.rs :silent! lua vim.lsp.buf.formatting()
    autocmd BufWritePre *.go,*.rs :silent! lua require('lsp_utils').org_imports(3000)

    augroup colorschemes
        autocmd!
        autocmd ColorScheme * hi! link DiagnosticWarn Comment
        autocmd ColorScheme * hi! link DiagnosticInfo Comment
        autocmd ColorScheme * hi! link DiagnosticHint Comment
        " autocmd ColorScheme * hi! link DiagnosticError Comment
    augroup end
]])
