let mapleader = " "
let $NVIM_TUI_ENABLE_TRUE_COLOR=1

lua require('init')

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

autocmd FileType go source ~/.config/nvim/golang/init.vim
