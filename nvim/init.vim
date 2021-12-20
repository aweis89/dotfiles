call plug#begin('~/.config/nvim/pluglsp')
Plug 'easymotion/vim-easymotion'
Plug 'preservim/nerdtree'
Plug 'airblade/vim-gitgutter'

Plug 'itchyny/lightline.vim'
" TODO
" Plug 'nvim-lua/lsp-status.nvim'
" Plug 'glepnir/galaxyline.nvim', {'branch': 'main'}

Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-lua/plenary.nvim'


Plug 'fatih/vim-go', { 'tag': '*' }
Plug 'buoto/gotests-vim'
Plug 'sebdah/vim-delve'

Plug 'preservim/vimux'

" github
Plug 'ruanyl/vim-gh-line'
Plug 'pwntester/octo.nvim'
Plug 'kyazdani42/nvim-web-devicons'

" git
Plug 'tpope/vim-fugitive'

" LSP
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
" Plug 'hrsh7th/nvim-cmp'
Plug 'ray-x/lsp_signature.nvim'
Plug 'nvim-lua/lsp-status.nvim'
" Plug 'onsails/lspkind-nvim'

" For vsnip users.
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/vim-vsnip'

" Plug 'rakr/vim-one'
Plug 'nvim-treesitter/nvim-treesitter'
Plug 'folke/tokyonight.nvim', { 'branch': 'main' }
Plug 'marko-cerovac/material.nvim'

" For luasnip users.
" Plug 'L3MON4D3/LuaSnip'
" Plug 'saadparwaiz1/cmp_luasnip'

" For ultisnips users.
" Plug 'SirVer/ultisnips'
" Plug 'quangnguyen30192/cmp-nvim-ultisnips'

" For snippy users.
" Plug 'dcampos/nvim-snippy'
" Plug 'dcampos/cmp-snippy'
call plug#end()

let mapleader = " "

lua <<EOF
  require'lsp'
EOF

" Register the components:
let g:lightline = {
  \   'colorscheme': 'wombat',
  \ }

"For Neovim 0.1.3 and 0.1.4 < https://github.com/neovim/neovim/pull/2198 >
let $NVIM_TUI_ENABLE_TRUE_COLOR=1

set termguicolors
set autoindent
set ignorecase
set number
set hlsearch
set ai
set completeopt=menu,menuone,noselect
set cursorline

let g:material_style = 'lighter'
" ColorScheme
colorscheme material
"hi! PmenuThumb ctermfg=0 ctermbg=13 guifg=#a9b7c6 guibg=#323232
"hi! PmenuSbar ctermfg=0 ctermbg=13 guifg=#a9b7c6 guibg=#323232

let g:gh_line_map = '<leader>hh'

" FZF
" nmap <Leader>f [fzf-p]
" xmap <Leader>f [fzf-p]
" nnoremap <C-g>    :<C-u>:FzfPreviewProjectGrepRpc<Space>
" nnoremap <silent> <C-r> :<C-u>FzfPreviewFromResources project_mru git<CR>
" nnoremap <C-p> :FzfPreviewFromResources project_mru git<CR>

" Telescope
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>
nnoremap <leader>fa <cmd>Telescope builtin.lsp_code_actions<cr>

nmap <C-n> :NERDTreeToggle<cr>
nmap s <Plug>(easymotion-s)

" Nav Mappings
imap jj <ESC>
imap <C-c> <ESC>
map L $
map H ^

" Golang
map <C-k> :GoDeclsDir<cr>
nmap gf :GoFillStruct<cr>
map ga :GoAlternate<cr>
map tt :!gotestsum<cr>
let g:go_fmt_command = "goimports"
let g:go_auto_type_info = 0
nmap <leader>i :GoInfo<cr>
nmap <C-i> :GoInfo<cr>
let g:go_metalinter_autosave = 0
let g:go_highlight_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_operators = 0 
let g:go_highlight_extra_types = 0
let g:delve_sign_priority = 10000
" let g:delve_use_vimux = 1

" Set custom templates for tests
let g:gotests_template_dir = $HOME . '/.config/nvim/gotests-templates'

" Git Gutter"
set updatetime=250
let g:gitgutter_max_signs = 500
" No mapping
let g:gitgutter_map_keys = 0
" Colors
let g:gitgutter_override_sign_column_highlight = 0
highlight GitGutterAdd ctermfg=2
highlight GitGutterChange ctermfg=3
highlight GitGutterDelete ctermfg=1
highlight GitGutterChangeDelete ctermfg=4

let g:gitgutter_sign_allow_clobber = 0

" terminal settings
tnoremap <c-q> <c-\><c-n> " scrolling
tnoremap <Esc> <C-\><C-n>:q!<CR>
