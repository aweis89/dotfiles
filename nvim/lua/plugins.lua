-- Install packer if missing
local fn = vim.fn
local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
	fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path })
end

vim.cmd [[packadd packer.nvim]]

function LspBorder(hl_name)
	return {
		{ "╭", hl_name },
		{ "─", hl_name },
		{ "╮", hl_name },
		{ "│", hl_name },
		{ "╯", hl_name },
		{ "─", hl_name },
		{ "╰", hl_name },
		{ "│", hl_name },
	}
end

return require('packer').startup(function(use)
	use {
		'akinsho/flutter-tools.nvim',
		requires = {
			'nvim-lua/plenary.nvim',
		},
		config = function()
			require("flutter-tools").setup({
				on_attach = require('config.lsp').on_attach,
				capabilities = vim.lsp.protocol.make_client_capabilities(),
			})
			require("flutter-tools").setup_project({
				name = 'default',
				device = 'chrome',
			})
		end
	}
	use {
		"ahmedkhalf/project.nvim",
		config = function()
			require("project_nvim").setup({
				silent_chdir = true,
				patterns = { ".git", "_darcs", ".hg", ".bzr", ".svn", "Makefile", "package.json",
					"init.lua" },
			})
		end
	}
	-- treesitter is buggy for dart
	use 'dart-lang/dart-vim-plugin'

	use { 'stevearc/dressing.nvim' } -- for vim.ui.select
	use {
		'nmac427/guess-indent.nvim',
		config = function() require('guess-indent').setup {} end,
	}
	use {
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		event = "InsertEnter",
		config = function()
			require("copilot").setup({
				suggestion = { enabled = false },
				panel = { enabled = false },
			})
		end,
	}
	use {
		"zbirenbaum/copilot-cmp",
		after = { "copilot.lua" },
		config = function()
			require("copilot_cmp").setup()
		end
	}
	use 'rebelot/kanagawa.nvim'
	use 'tpope/vim-abolish'
	use 'wbthomason/packer.nvim'
	use 'mbbill/undotree'
	use 'tpope/vim-sensible'
	use 'iamcco/markdown-preview.nvim'
	use 'aduros/ai.vim'
	use {
		"neovim/nvim-lspconfig",
		requires = {
			"williamboman/mason-lspconfig.nvim",
			"RRethy/vim-illuminate",
			"williamboman/mason.nvim",
		},
		config = function()
			require('config.lsp').setup()
		end
	}
	use {
		"jackMort/ChatGPT.nvim",
		config = function()
			require("chatgpt").setup({
				{
					-- welcome_message = WELCOME_MESSAGE, -- set to "" if you don't like the fancy godot robot
					loading_text = "loading",
					question_sign = "", -- you can use emoji if you want e.g. 🙂
					answer_sign = "ﮧ", -- 🤖
					max_line_length = 120,
					yank_register = "+",
					chat_layout = {
						relative = "editor",
						position = "50%",
						size = {
							height = "80%",
							width = "80%",
						},
					},
					settings_window = {
						border = {
							style = "rounded",
							text = {
								top = " Settings ",
							},
						},
					},
					chat_window = {
						filetype = "chatgpt",
						border = {
							highlight = "FloatBorder",
							style = "rounded",
							text = {
								top = " ChatGPT ",
							},
						},
					},
					chat_input = {
						prompt = "  ",
						border = {
							highlight = "FloatBorder",
							style = "rounded",
							text = {
								top_align = "center",
								top = " Prompt ",
							},
						},
					},
					openai_params = {
						model = "text-davinci-003",
						frequency_penalty = 0,
						presence_penalty = 0,
						max_tokens = 300,
						temperature = 0,
						top_p = 1,
						n = 1,
					},
					openai_edit_params = {
						model = "code-davinci-edit-001",
						temperature = 0,
						top_p = 1,
						n = 1,
					},
					keymaps = {
						close = { "<C-c>", "<Esc>" },
						yank_last = "<C-y>",
						scroll_up = "<C-u>",
						scroll_down = "<C-d>",
						toggle_settings = "<C-o>",
						new_session = "<C-n>",
						cycle_windows = "<Tab>",
					},
				} -- optional configuration
			})
		end,
		requires = {
			"MunifTanjim/nui.nvim",
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim"
		}
	}
	use {
		'numToStr/Comment.nvim',
		config = function()
			require('Comment').setup({
				---Create basic (operator-pending) and extended mappings for NORMAL + VISUAL mode
				---NOTE: If `mappings = false` then the plugin won't create any mappings
				---@type boolean|table
				mappings = {
					---Operator-pending mapping
					---Includes `gcc`, `gbc`, `gc[count]{motion}` and `gb[count]{motion}`
					---NOTE: These mappings can be changed individually by `opleader` and `toggler` config
					basic = true,
					---Extra mapping
					---Includes `gco`, `gcO`, `gcA`
					extra = true,
					---Extended mapping
					---Includes `g>`, `g<`, `g>[count]{motion}` and `g<[count]{motion}`
					extended = true,
				},
			})
		end
	}
	use {
		'windwp/nvim-autopairs',
		config = function() require("nvim-autopairs").setup {} end
	}
	use {
		"folke/trouble.nvim",
		requires = "kyazdani42/nvim-web-devicons",
		event = 'VimEnter',
		config = function()
			require("trouble").setup()
			Map("n", "<leader>xx", "<cmd>TroubleToggle<cr>")
			Map("n", "<leader>xw", "<cmd>Trouble workspace_diagnostics<cr>")
			Map("n", "<leader>xd", "<cmd>Trouble document_diagnostics<cr>")
			Map("n", "<leader>xl", "<cmd>Trouble loclist<cr>")
			Map("n", "<leader>xq", "<cmd>Trouble quickfix<cr>")
			Map("n", "gR", "<cmd>Trouble lsp_references<cr>")
		end
	}
	use {
		'simrat39/rust-tools.nvim',
		ft = 'rust',
		config = function() require('rust-tools').setup({}) end,
	}
	use {
		'kassio/neoterm',
		config = function() vim.g.neoterm_autoinsert = 1 end,
	}
	use {
		'ggandor/lightspeed.nvim',
		config = function()
			Map('n', 's', '<Plug>Lightspeed_omni_s', { noremap = false })
		end
	}
	use {
		'kyazdani42/nvim-tree.lua',
		requires = {
			'kyazdani42/nvim-web-devicons', -- optional, for file icons
		},
		config = function()
			Map('n', '<c-n>', '<cmd>NvimTreeToggle<cr>')
			require("nvim-tree").setup(
			-- see https://github.com/ahmedkhalf/project.nvim
				{
					sync_root_with_cwd = true,
					respect_buf_cwd = true,
					update_focused_file = {
						enable = true,
						update_root = true
					},
				}
			)
		end
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
		requires = { 'arkav/lualine-lsp-progress' },
		config = function()
			require('lualine').setup({
				sections = {
					lualine_a = {
						{ 'mode', fmt = function(str) return str:sub(1, 1) end },
					},
					lualine_b = { 'branch', 'diff', 'diagnostics' },
					lualine_c = { 'filename' },
					lualine_x = { 'fileformat', 'filetype' },
					lualine_y = { 'progress' },
					lualine_z = { 'location' }
				},
			})
		end,
		event = 'VimEnter',
	}
	use {
		'nvim-telescope/telescope.nvim',
		requires = {
			'ahmedkhalf/project.nvim',
			'nvim-lua/plenary.nvim',
			"AckslD/nvim-neoclip.lua"
		},
		config = function()
			require('telescope').setup({
				defaults = {
					preview = {
						timeout = 500,
						msg_bg_fillchar = "",
					},
					path_display = {
						"truncate",
						"smart",
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
			require("telescope").load_extension("flutter")
			require('telescope').load_extension('projects')

			local builtin = require('telescope.builtin')
			vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
			vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
			vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
			vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
			vim.keymap.set('n', '<leader>fa', vim.lsp.buf.code_action, {})

			-- Map('n', '<leader>ff', '<cmd>Telescope find_files<cr>')
			-- Map('n', '<leader>fg', '<cmd>Telescope live_grep<cr>')
			Map('n', '<leader>fb', '<cmd>Telescope buffers<cr>')
			Map('n', '<leader>fh', '<cmd>Telescope help_tags<cr>')
			Map('n', '<leader>fs', '<cmd>Telescope lsp_dynamic_workspace_symbols<cr>')
			Map('n', '<leader>fp', '<cmd>Telescope neoclip<cr>')
			Map('n', '<leader>fr', '<cmd>Telescope lsp_references<cr>')
			Map('n', '<leader>fd', '<cmd>Telescope diagnostics<cr>')
			Map('n', '<leader>fc', '<cmd>Telescope flutter commands<cr>')
			Map('n', '<leader>pp', '<cmd>Telescope projects<cr>')
		end
	}
	-- Golang plugins
	use {
		'fatih/vim-go',
		-- ft = 'go', breaks adding package to new files
		setup = function()
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
			vim.g.go_gopls_gofumpt = 0

			-- mappings
			Map('n', '<leader>i', ':GoInfo<cr>')
			Map('n', 'gf', ':GoFillStruct<cr>')
			Map('n', 'ga', ':GoAlternate<cr>')
		end,
	}
	use {
		'buoto/gotests-vim',
		ft = 'go',
		setup = function()
			vim.g.gotests_template_dir = vim.fn.stdpath('config') .. '/golang/gotests-templates'
		end,
	}
	use {
		'sebdah/vim-delve',
		ft = 'go',
		setup = function()
			-- override lsp symbols
			vim.g.delve_sign_priority = 10000
			-- map('', '<leader>dd', ':DlvToggleBreakpoint<cr>')
			Map('', '<leader>dt', ':DlvTest<cr>')
		end,
	}

	use 'junegunn/fzf'
	use 'preservim/vimux'
	use 'pwntester/octo.nvim'
	use 'kyazdani42/nvim-web-devicons'
	use 'tpope/vim-fugitive'
	use 'rafamadriz/friendly-snippets'

	use {
		'WhoIsSethDaniel/toggle-lsp-diagnostics.nvim',
		config = function()
			require 'toggle_lsp_diagnostics'.init({ start_on = true })
		end
	}
	use {
		'L3MON4D3/LuaSnip',
		requires = { 'rafamadriz/friendly-snippets' },
		config = function()
			require("luasnip.loaders.from_vscode").lazy_load()
		end
	}
	use { 'saadparwaiz1/cmp_luasnip' }
	use {
		'hrsh7th/nvim-cmp',
		requires = {
			{ 'onsails/lspkind.nvim' },
			{ 'hrsh7th/cmp-nvim-lsp-signature-help' },
			{ 'hrsh7th/cmp-nvim-lsp' },
			{ 'hrsh7th/cmp-nvim-lua' },
			{ 'hrsh7th/cmp-cmdline' },
			{ 'hrsh7th/cmp-buffer' },
			{ 'hrsh7th/cmp-path' },
			{ 'hrsh7th/vim-vsnip' },
			{ 'hrsh7th/cmp-vsnip' },
			{ 'andersevenrud/cmp-tmux' },
		},
		config = function()
			require('config.nvim-cmp-config').setup()
		end,
	}

	-- use 'RRethy/vim-illuminate'
	use {
		'nvim-treesitter/nvim-treesitter',
		config = function()
			require 'nvim-treesitter.configs'.setup {
				-- One of "all", "maintained" (parsers with maintainers), or a list of languages
				ensure_installed = "all",

				-- Install languages synchronously (only applied to `ensure_installed`)
				sync_install = false,

				-- phpdoc doesn't work on m1 chips
				ignore_install = { "phpdoc", "dart" },

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
	use 'machakann/vim-highlightedyank'
	use 'rktjmp/lush.nvim'
	use {
		'marko-cerovac/material.nvim',
		config = function()
			vim.g.material_style = "darker"
			-- vim.cmd([[colorscheme material]])
			Map('n', '<leader>mm', [[<Cmd>lua require('material.functions').toggle_style()<CR>]],
				{ noremap = true, silent = true })
		end
	}
	use 'jamespwilliams/bat.vim'
	-- use "lukas-reineke/indent-blankline.nvim"
	use {
		-- 'RRethy/nvim-base16',
		'MaxVerevkin/nvim-base16',
		requires = { { 'nvim-lua/plenary.nvim' }, { 'rktjmp/fwatch.nvim' } },
		config = function()
			require('base16-colorscheme').with_config {
				telescope = false,
			}
			local Path = require("plenary.path")
			local vim_file = Path:new({ vim.env.HOME, '.vimrc_background' })
			if vim_file:exists() then
				vim.cmd([[source ]] .. vim_file.filename)

				-- watch for changes
				local w = vim.loop.new_fs_event()
				local function on_change(err, fname, status)
					vim.cmd([[source ]] .. vim_file.filename)
				end

				function watch_file(fname)
					local fullpath = vim.api.nvim_call_function('fnamemodify', { fname, ':p' })
					w:start(fullpath, {}, vim.schedule_wrap(function(...) on_change(...) end))
				end

				watch_file(vim_file.filename)
			else
				vim.cmd([[colorscheme base16-gruvbox-dark-soft]])
			end
		end
	}
end)
