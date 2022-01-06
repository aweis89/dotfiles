let mapleader = " "
let $NVIM_TUI_ENABLE_TRUE_COLOR=1

lua <<EOL
  require('plugin')
EOL

set termguicolors
set autoindent
set ignorecase
set number
set hlsearch
set ai
set completeopt=menu,menuone,noselect
set cursorline
set noexpandtab tabstop=4 shiftwidth=4 

" Nav Mappings
imap jj <ESC>
imap <C-c> <ESC>
map L $
map H ^

tnoremap jj <C-\><C-n>
tnoremap qq <C-\><C-n>:q!<CR>
tnoremap <Esc> <C-\><C-n>:q!<CR>
autocmd TermOpen * startinsert

autocmd FileType go exec 'source ' . stdpath('config') . '/golang/init.vim'
autocmd BufWritePre *.go,*.rs :silent! lua vim.lsp.buf.formatting()
autocmd BufWritePre *.go,*.rs :silent! lua require('lsp_utils').org_imports(3000)

" if filereadable(expand("~/.vimrc_background"))
"   source ~/.vimrc_background
" endif
