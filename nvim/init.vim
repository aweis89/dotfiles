" call plug#begin('~/.config/nvim/plug')
" Plug 'tpope/vim-sensible'
" 
" Plug 'kassio/neoterm'
" 
" Plug 'easymotion/vim-easymotion'
" Plug 'preservim/nerdtree'
" Plug 'airblade/vim-gitgutter'
" Plug 'mrk21/yaml-vim'
" Plug 'karb94/neoscroll.nvim'
" 
" Plug 'nvim-lualine/lualine.nvim'
" 
" Plug 'nvim-telescope/telescope.nvim'
" Plug 'nvim-lua/plenary.nvim'
" 
" " Golang plugins
" Plug 'fatih/vim-go', { 'tag': '*' }
" Plug 'ray-x/go.nvim'
" Plug 'buoto/gotests-vim'
" Plug 'sebdah/vim-delve'
" Plug 'junegunn/fzf', { 'do': { -> fzf#install() } } " required for GoDecls
" 
" Plug 'preservim/vimux'
" 
" " github
" Plug 'ruanyl/vim-gh-line'
" Plug 'pwntester/octo.nvim'
" Plug 'kyazdani42/nvim-web-devicons'
" 
" " git
" Plug 'tpope/vim-fugitive'
" 
" " LSP
" Plug 'neovim/nvim-lspconfig'
" Plug 'hrsh7th/cmp-nvim-lsp'
" Plug 'hrsh7th/cmp-buffer'
" Plug 'hrsh7th/cmp-path'
" Plug 'hrsh7th/cmp-cmdline'
" Plug 'hrsh7th/nvim-cmp'
" Plug 'ray-x/lsp_signature.nvim'
" Plug 'nvim-lua/lsp-status.nvim'
" " Plug 'onsails/lspkind-nvim'
" " debugger
" Plug 'mfussenegger/nvim-dap'
" Plug 'rcarriga/nvim-dap-ui'
" 
" " For vsnip users.
" Plug 'hrsh7th/cmp-vsnip'
" Plug 'hrsh7th/vim-vsnip'
" Plug 'hrsh7th/vim-vsnip-integ'
" Plug 'rafamadriz/friendly-snippets'
" 
" Plug 'nvim-treesitter/nvim-treesitter'
" Plug 'folke/tokyonight.nvim', { 'branch': 'main' }
" Plug 'machakann/vim-highlightedyank'
" 
" " Themes
" Plug 'rktjmp/lush.nvim'
" Plug 'marko-cerovac/material.nvim'
" Plug 'jamespwilliams/bat.vim'
" Plug 'ellisonleao/gruvbox.nvim'
" 
" Plug 'tyru/current-func-info.vim'
" call plug#end()

let mapleader = " "

lua <<EOF
  require('plugin')
  require('lsp')
  require('neoscroll').setup()
  require('lualine').setup()
  require('go').setup()
  -- require'lspinstall'.setup()
EOF

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
set noexpandtab tabstop=4 shiftwidth=4 

let g:material_style = 'lighter'
set background=light
colorscheme gruvbox " material bat

let g:gh_line_map = '<leader>hh'

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

highlight HighlightedyankRegion cterm=reverse gui=reverse
let g:highlightedyank_highlight_duration = 150

let g:gitgutter_sign_allow_clobber = 0

" terminal settings
let g:neoterm_autoinsert = 1 " start in insert mode
tnoremap jj <C-\><C-n>
tnoremap qq <C-\><C-n>:q!<CR>
tnoremap <Esc> <C-\><C-n>:q!<CR>

" Golang
function GoSetup()
  map <C-k> :GoDeclsDir<cr>
  nmap gf :GoFillStruct<cr>
  map ga :GoAlternate<cr>
  let g:go_fmt_command = "goimports"
  let g:go_auto_type_info = 1
  nmap <leader>i :GoInfo<cr>
  nmap <C-i> :GoInfo<cr>
  let g:go_metalinter_autosave = 0
  let g:go_highlight_types = 1
  let g:go_highlight_fields = 1
  let g:go_highlight_functions = 1
  let g:go_highlight_function_calls = 1
  let g:go_highlight_operators = 1
  let g:go_highlight_extra_types = 1
  let g:delve_sign_priority = 10000
  " let g:go_addtags_transform = "camelcase"
  " Set custom templates for tests
  let g:gotests_template_dir = $HOME . '/.config/nvim/gotests-templates'
  
  map <leader>dd :DlvToggleBreakpoint<cr>
  map <leader>dt :DlvTest<cr>
  map tt :vsplit \| T go test -json -v ./... 2>&1 \| gotestfmt<cr>
  map <leader>tt :vsplit \| T go test -json -v ./... 2>&1 \| gotestfmt<cr>
endfunction

autocmd FileType go call GoSetup()
