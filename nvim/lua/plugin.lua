vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
	use 'wbthomason/packer.nvim'
	use 'tpope/vim-sensible'
	use {
		'kassio/neoterm',
		config = 'vim.g.neoterm_autoinsert = 1',
	}
	use {
		'easymotion/vim-easymotion',
		config = 'vim.cmd([[nmap s <Plug>(easymotion-s)]])',
		event = 'VimEnter',
	}
	use {
		'preservim/nerdtree',
		config = 'vim.cmd([[nnoremap <C-n> :NERDTreeToggle<cr>]])',
		event = 'VimEnter',
	}
	use {
		'airblade/vim-gitgutter',
		config = function() vim.cmd([[
			set updatetime=250
			let g:gitgutter_max_signs = 500
			let g:gitgutter_map_keys = 0
			let g:gitgutter_override_sign_column_highlight = 0
			highlight GitGutterAdd ctermfg=2
			highlight GitGutterChange ctermfg=3
			highlight GitGutterDelete ctermfg=1
			highlight GitGutterChangeDelete ctermfg=4
			highlight HighlightedyankRegion cterm=reverse gui=reverse
			let g:highlightedyank_highlight_duration = 150
			let g:gitgutter_sign_allow_clobber = 0
			]]) end,
			event = 'VimEnter',
		}

		use 'mrk21/yaml-vim'

		use {
			'karb94/neoscroll.nvim',
			config = function() require('neoscroll').setup() end,
		}

		use {
			'nvim-lualine/lualine.nvim',
			config = function() require('lualine').setup() end,
			event = 'VimEnter',
		}

		use 'nvim-lua/plenary.nvim'

		use {
			'nvim-telescope/telescope.nvim',
			-- after = {'jamespwilliams/bat.vim'},
			config = function()
				vim.cmd([[
				nnoremap <leader>ff <cmd>Telescope find_files<cr>
				nnoremap <leader>fg <cmd>Telescope live_grep<cr>
				nnoremap <leader>fb <cmd>Telescope buffers<cr>
				nnoremap <leader>fh <cmd>Telescope help_tags<cr>
				nnoremap <leader>fa <cmd>Telescope builtin.lsp_code_actions<cr>
				]])
			end
		}

		-- Golang plugins
		use 'fatih/vim-go'
		use {
			'ray-x/go.nvim',
			config = function() require('go').setup() end,
		}
		use 'buoto/gotests-vim'
		use 'sebdah/vim-delve'
		use 'junegunn/fzf'

		use 'preservim/vimux'
		-- github
		use {
			'ruanyl/vim-gh-line',
			config = function() vim.g.gh_line_map = "<leader>hh" end,
		}
		use 'pwntester/octo.nvim'
		use 'kyazdani42/nvim-web-devicons'

		-- git
		use 'tpope/vim-fugitive'

		-- LSP
		use 'neovim/nvim-lspconfig'
		use 'hrsh7th/cmp-nvim-lsp'
		use 'hrsh7th/cmp-buffer'
		use 'hrsh7th/cmp-path'
		use 'hrsh7th/cmp-cmdline'
		use 'hrsh7th/nvim-cmp'
		use 'ray-x/lsp_signature.nvim'
		use 'nvim-lua/lsp-status.nvim'

		-- debugger
		use 'mfussenegger/nvim-dap'
		use 'rcarriga/nvim-dap-ui'

		-- For vsnip users.
		use 'hrsh7th/cmp-vsnip'
		use 'hrsh7th/vim-vsnip'
		use 'hrsh7th/vim-vsnip-integ'
		use 'rafamadriz/friendly-snippets'
		use 'nvim-treesitter/nvim-treesitter'
		use {
			'romgrk/nvim-treesitter-context',
			config = function() require'treesitter-context'.setup() end,
			requires = {'nvim-treesitter/nvim-treesitter'}
		}
		use 'tyru/current-func-info.vim'

		-- use 'folke/tokyonight.nvim', { 'branch': 'main' }
		use 'machakann/vim-highlightedyank'
		-- Themes
		use 'rktjmp/lush.nvim'
		use 'marko-cerovac/material.nvim'
		use 'jamespwilliams/bat.vim'
		use {
			'ellisonleao/gruvbox.nvim',
			config = function()
				vim.cmd([[
				set background=light
				colorscheme gruvbox
				]])
			end,
		}
	end)
