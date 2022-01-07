-- Install packer if missing
local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
end

vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
	use 'wbthomason/packer.nvim'
	use 'tpope/vim-sensible'
	use {
		'simrat39/rust-tools.nvim',
		config = function() require('rust-tools').setup({}) end,
	}
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
		config = function()
			vim.cmd([[
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
			]])
		end,
		event = 'VimEnter',
	}

	use 'mrk21/yaml-vim'

	use {
		'karb94/neoscroll.nvim',
		config = function() require('neoscroll').setup() end,
	}

	use 'arkav/lualine-lsp-progress'
	use {
		'nvim-lualine/lualine.nvim',
		requires = {{'arkav/lualine-lsp-progress'}},
		config = function()
			require('lualine').setup({
				sections = {
					lualine_c = {
						'lsp_progress'
					}
				}
			})
		end,
		event = 'VimEnter',
	}
	use {
		'nvim-telescope/telescope.nvim',
		requires = {{'nvim-lua/plenary.nvim'}},
		config = function()
			require('telescope').setup({
				defaults = {
					previewer = true,
					layout_strategy = "flex",
				},
			})
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
	use {
		'fatih/vim-go',
		ft = 'go',
		config = function ()
			vim.g.go_auto_type_info = 1
			vim.g.go_metalinter_autosave = 0
			vim.g.go_highlight_types = 1
			vim.g.go_highlight_fields = 1
			vim.g.go_highlight_functions = 1
			vim.g.go_highlight_function_calls = 1
			vim.g.go_highlight_operators = 1
			vim.g.go_highlight_extra_types = 1
			-- lspconfig gopls requires:
			vim.g.go_imports_autosave = 0
			vim.g.go_fmt_autosave = 0

			-- mappings
			vim.api.nvim_set_keymap('', 'ga', ':GoAlternate<CR>', {})
			vim.api.nvim_set_keymap('n', 'gf', ':GoFillStruct<CR>', {})
		end,
	}
	use {
		'ray-x/go.nvim',
		ft = 'go',
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
	use 'ray-x/lsp_signature.nvim'
	use 'nvim-lua/lsp-status.nvim'
	use 'hrsh7th/vim-vsnip'
	use 'hrsh7th/cmp-vsnip'
	use 'rafamadriz/friendly-snippets'
	use {
		'williamboman/nvim-lsp-installer',
		config = function() require('lsp') end,
	}
	use {
		'hrsh7th/nvim-cmp',
		config = function() require('nvim-cmp-config').setup() end,
	}

	-- debugger
	use 'mfussenegger/nvim-dap'
	use 'rcarriga/nvim-dap-ui'

	use 'nvim-treesitter/nvim-treesitter'
	use {
		'romgrk/nvim-treesitter-context',
		config = function() require'treesitter-context'.setup() end,
		requires = {{'nvim-treesitter/nvim-treesitter'}},
	}
	use 'tyru/current-func-info.vim'

	-- use 'folke/tokyonight.nvim', { 'branch': 'main' }
	use 'machakann/vim-highlightedyank'
	-- Themes
	use 'rktjmp/lush.nvim'
	use 'marko-cerovac/material.nvim'
	use 'jamespwilliams/bat.vim'
	use {
		'chriskempson/base16-vim',
		requires = {{'nvim-lua/plenary.nvim'}},
		config = function ()
			local Path = require("plenary.path")
			local vim_file = Path:new({vim.env.HOME, '.vimrc_background'})
			if vim_file:exists() then
				-- vim.cmd(vim_file:read())
				vim.cmd([[source ]] .. vim_file.filename)
				return
			end
			vim.cmd([[colorscheme base16-gruvbox-dark-soft]])
		end
	}
end)
