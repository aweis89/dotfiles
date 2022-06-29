-- Install packer if missing
local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
	fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
end

vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
	use 'wbthomason/packer.nvim'
	use 'mbbill/undotree'
	use 'tpope/vim-sensible'
	use 'iamcco/markdown-preview.nvim'
	use 'github/copilot.vim'
	use {
		"folke/trouble.nvim",
		requires = "kyazdani42/nvim-web-devicons",
		event = 'VimEnter',
		config = function()
			require("trouble").setup()
			map("n", "<leader>xx", "<cmd>TroubleToggle<cr>")
			map("n", "<leader>xw", "<cmd>Trouble workspace_diagnostics<cr>")
			map("n", "<leader>xd", "<cmd>Trouble document_diagnostics<cr>")
			map("n", "<leader>xl", "<cmd>Trouble loclist<cr>")
			map("n", "<leader>xq", "<cmd>Trouble quickfix<cr>")
			map("n", "gR", "<cmd>Trouble lsp_references<cr>")
		end
	}
	use {
		'simrat39/rust-tools.nvim',
		ft = 'rust',
		config = function() require('rust-tools').setup({}) end,
	}
	use {
		'kassio/neoterm',
		config = function () vim.g.neoterm_autoinsert = 1 end,
	}
	use {
		'phaazon/hop.nvim',
		branch = 'v1', -- optional but strongly recommended
		cmd = 'HopWord',
		setup = function()
			map('n', 's', '<cmd>HopWord<cr>')
			map('n', '<leader>j', '<cmd>HopLineStart<cr>')
		end,
		config = function()
			require'hop'.setup()
		end
	}
	use {
		'preservim/nerdtree',
		cmd = 'NERDTreeToggle',
		keys = '<c-n>',
		config = function () map('n', '<c-n>', '<cmd>NERDTreeToggle<cr>') end,
	}
	use {
		'airblade/vim-gitgutter',
		config = function()
			vim.g.gitgutter_max_signs = 500
			vim.g.gitgutter_map_keys = 0
			vim.g.gitgutter_override_sign_column_highlight = 0
			vim.g.highlightedyank_highlight_duration = 150
			vim.g.gitgutter_sign_allow_clobber = 0
			vim.g.gitgutter_sign_priority = 1

			vim.cmd([[
			highlight GitGutterAdd ctermfg=2
			highlight GitGutterChange ctermfg=3
			highlight GitGutterDelete ctermfg=1
			highlight GitGutterChangeDelete ctermfg=4
			highlight HighlightedyankRegion cterm=reverse gui=reverse
			]])
		end,
		event = 'VimEnter',
	}
	use 'mrk21/yaml-vim'
	use 'towolf/vim-helm'
	use {
		'karb94/neoscroll.nvim',
		config = function() require('neoscroll').setup() end,
	}
	use {
		'nvim-lualine/lualine.nvim',
		requires = {'arkav/lualine-lsp-progress'},
		config = function()
			require('lualine').setup({
				sections = {
					lualine_b = {
						{
							'filename',
							path = 1 -- 0 = just filename, 1 = relative path, 2 = absolute path
						}
					},
					lualine_c = {
						"lsp_progress",
					},
				}
			})
		end,
		event = 'VimEnter',
	}
	use {
		'nvim-telescope/telescope.nvim',
		requires = {'nvim-lua/plenary.nvim', "AckslD/nvim-neoclip.lua"},
		config = function()
			require('telescope').setup({
				defaults = {
					preview = {
						timeout = 500,
						msg_bg_fillchar = "",
					},
					multi_icon = " ",
					vimgrep_arguments = {
						"rg",
						"--color=never",
						"--no-heading",
						"--with-filename",
						"--line-number",
						"--column",
						"--smart-case",
						"--hidden",
					},
					prompt_prefix = "❯ ",
					selection_caret = "❯ ",
					sorting_strategy = "ascending",
					color_devicons = true,
					layout_config = {
						prompt_position = "bottom",
						horizontal = {
							width_padding = 0.04,
							height_padding = 0.1,
							preview_width = 0.6,
						},
						vertical = {
							width_padding = 0.05,
							height_padding = 1,
							preview_height = 0.5,
						},
					},
				},
			})
			require('neoclip').setup()
			require('telescope').load_extension('neoclip')
			map('n', '<leader>ff', '<cmd>Telescope find_files<cr>')
			map('n', '<leader>fg', '<cmd>Telescope live_grep<cr>')
			map('n', '<leader>fb', '<cmd>Telescope buffers<cr>')
			map('n', '<leader>fh', '<cmd>Telescope help_tags<cr>')
			map('n', '<leader>fa', '<cmd>Telescope builtin.lsp_code_actions<cr>')
			map('n', '<leader>fs', '<cmd>Telescope lsp_document_symbols<cr>')
			map('n', '<leader>fp', '<cmd>Telescope neoclip<cr>')
		end
	}
	-- Golang plugins
	use {
		'fatih/vim-go',
		-- ft = 'go', breaks adding package to new files
		setup = function ()
			vim.g.go_auto_type_info = 0
			vim.g.go_metalinter_autosave = 0
			vim.g.go_highlight_types = 0
			vim.g.go_highlight_fields = 0
			vim.g.go_highlight_functions = 0
			vim.g.go_highlight_function_calls = 0
			vim.g.go_highlight_operators = 0
			vim.g.go_highlight_extra_types = 0
			vim.g.go_addtags_transform = "camelcase"

			-- lspconfig gopls requires:
			vim.g.go_imports_autosave = 1
			vim.g.go_fmt_autosave = 1
			vim.g.go_gopls_gofumpt = 1

			-- mappings
			map('n', '<leader>i', ':GoInfo<cr>')
			map('n', 'gf', ':GoFillStruct<cr>')
			map('n', 'ga', ':GoAlternate<cr>')
		end,
	}
	use {
		'buoto/gotests-vim',
		ft = 'go',
		setup = function ()
			vim.g.gotests_template_dir = vim.fn.stdpath('config') .. '/golang/gotests-templates'
		end,
	}
	use {
		'sebdah/vim-delve',
		ft = 'go',
		setup = function ()
			-- override lsp symbols
			vim.g.delve_sign_priority = 10000
			-- map('', '<leader>dd', ':DlvToggleBreakpoint<cr>')
			map('', '<leader>dt', ':DlvTest<cr>')
		end,
	}

	use 'junegunn/fzf'
	use 'preservim/vimux'
	use {
		'tyru/open-browser-github.vim',
		requires = {'tyru/open-browser.vim'}
	}
	use 'pwntester/octo.nvim'
	use 'kyazdani42/nvim-web-devicons'
	use 'tpope/vim-fugitive'
	use 'rafamadriz/friendly-snippets'

	use {
		'WhoIsSethDaniel/toggle-lsp-diagnostics.nvim',
		config = function ()
			require'toggle_lsp_diagnostics'.init({start_on = true})
		end
	}

	-- LSP
	use {
		'williamboman/nvim-lsp-installer',
		requires = {
			'RRethy/vim-illuminate',
			'neovim/nvim-lspconfig',
		},
		config = function() require('lsp') end,
	}
	use {
		'L3MON4D3/LuaSnip',
		config = function ()
			-- require("luasnip.loaders.from_vscode").lazy_load()
			require("luasnip.loaders.from_snipmate").lazy_load()

			vim.api.nvim_set_keymap("i", "<C-E>", "<Plug>luasnip-next-choice", {})
			vim.api.nvim_set_keymap("s", "<C-E>", "<Plug>luasnip-next-choice", {})
		end
	}
	use { 'saadparwaiz1/cmp_luasnip' }
	use {
		'hrsh7th/nvim-cmp',
		requires = {
			{'onsails/lspkind.nvim'},
			{'hrsh7th/cmp-nvim-lsp-signature-help'},
			{'hrsh7th/cmp-nvim-lsp'},
			{'hrsh7th/cmp-cmdline'},
			{'hrsh7th/cmp-buffer'},
			{'hrsh7th/cmp-path'},
			{'hrsh7th/vim-vsnip'},
			{'hrsh7th/cmp-vsnip'},
			{'andersevenrud/cmp-tmux'},
		},
		config = function()
			require('nvim-cmp-config').setup()
		end,
	}

	use 'RRethy/vim-illuminate'
	use {
		'nvim-treesitter/nvim-treesitter',
		config = function ()
			require'nvim-treesitter.configs'.setup {
				-- One of "all", "maintained" (parsers with maintainers), or a list of languages
				ensure_installed = "all",

				-- Install languages synchronously (only applied to `ensure_installed`)
				sync_install = false,

				-- phpdoc doesn't work on m1 chips
				ignore_install = { "phpdoc" },

				highlight = {
					-- `false` will disable the whole extension
					enable = true,

					-- list of language that will be disabled
					-- disable = { "c", "rust" },

					-- Setting this to true will run `:h syntax` and tree-sitter at the same time.
					-- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
					-- Using this option may slow down your editor, and you may see some duplicate highlights.
					-- Instead of true it can also be a list of languages
					additional_vim_regex_highlighting = false,
				},
			}
		end,
	}
	use 'tyru/current-func-info.vim'
	use {
		'kyazdani42/nvim-tree.lua',
		requires = {'kyazdani42/nvim-web-devicons'},
		cmd = {'NvimTreeToggle', 'NvimTreeOpen'},
		config = function() require'nvim-tree'.setup {} end
	}
	use 'machakann/vim-highlightedyank'
	use 'rktjmp/lush.nvim'
	use {
		'marko-cerovac/material.nvim',
		config = function()
			vim.g.material_style = "darker"
			-- vim.cmd([[colorscheme material]])
			map('n', '<leader>mm', [[<Cmd>lua require('material.functions').toggle_style()<CR>]], { noremap = true, silent = true })
		end
	}
	use 'jamespwilliams/bat.vim'
	-- use "lukas-reineke/indent-blankline.nvim"
	use {
		-- 'RRethy/nvim-base16',
		'MaxVerevkin/nvim-base16',
		requires = {{'nvim-lua/plenary.nvim'}, {'rktjmp/fwatch.nvim'}},
		config = function ()
			require('base16-colorscheme').with_config {
				telescope = false,
			}
			local Path = require("plenary.path")
			local vim_file = Path:new({vim.env.HOME, '.vimrc_background'})
			if vim_file:exists() then
				vim.cmd([[source ]] .. vim_file.filename)

				-- watch for changes
				local w = vim.loop.new_fs_event()
				local function on_change(err, fname, status)
					vim.cmd([[source ]] .. vim_file.filename)
				end
				function watch_file(fname)
					local fullpath = vim.api.nvim_call_function('fnamemodify', {fname, ':p'})
					w:start(fullpath, {}, vim.schedule_wrap(function(...) on_change(...) end))
				end
				watch_file(vim_file.filename)
			else
				vim.cmd([[colorscheme base16-gruvbox-dark-soft]])
			end
		end
	}
end)
