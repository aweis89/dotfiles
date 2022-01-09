-- Install packer if missing
local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
	fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
end

vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
	use 'wbthomason/packer.nvim'
	use 'tpope/vim-sensible'
    -- Lua
    use {
        "folke/trouble.nvim",
        requires = "kyazdani42/nvim-web-devicons",
        event = 'VimEnter',
        config = function()
            require("trouble").setup()
            map("n", "<leader>xx", "<cmd>Trouble<cr>")
            map("n", "<leader>xw", "<cmd>Trouble workspace_diagnostics<cr>")
            map("n", "<leader>xd", "<cmd>Trouble document_diagnostics<cr>")
            map("n", "<leader>xl", "<cmd>Trouble loclist<cr>")
            map("n", "<leader>xq", "<cmd>Trouble quickfix<cr>")
            map("n", "gR", "<cmd>Trouble lsp_references<cr>")
        end
    }
    use {
        'simrat39/rust-tools.nvim',
        config = function() require('rust-tools').setup({}) end,
    }
    use {
        'kassio/neoterm',
        config = function () vim.g.neoterm_autoinsert = 1 end,
    }
    use {
        'phaazon/hop.nvim',
        branch = 'v1', -- optional but strongly recommended
        config = function()
            require'hop'.setup()
            map('n', 's', '<cmd>HopWord<cr>')
            map('n', '<leader>j', '<cmd>HopLineStart<cr>')
        end
    }
	use {
		'preservim/nerdtree',
		config = function () map('n', '<c-n>', ':NERDTreeToggle<cr>') end,
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
			map('n', '<leader>ff', '<cmd>Telescope find_files<cr>')
			map('n', '<leader>fg', '<cmd>Telescope live_grep<cr>')
			map('n', '<leader>fb', '<cmd>Telescope buffers<cr>')
			map('n', '<leader>fh', '<cmd>Telescope help_tags<cr>')
			map('n', '<leader>fa', '<cmd>Telescope builtin.lsp_code_actions<cr>')
			map('n', '<leader>fs', '<cmd>Telescope lsp_document_symbols<cr>')
		end
	}
	-- Golang plugins
    use {
        'fatih/vim-go',
        ft = 'go',
        setup = function ()
            vim.g.go_auto_type_info = 1
            vim.g.go_metalinter_autosave = 0
            vim.g.go_highlight_types = 0
            vim.g.go_highlight_fields = 0
            vim.g.go_highlight_functions = 0
            vim.g.go_highlight_function_calls = 0
            vim.g.go_highlight_operators = 0
            vim.g.go_highlight_extra_types = 0
            -- vim.g.go_addtags_transform = "camelcase"

            -- lspconfig gopls requires:
            vim.g.go_imports_autosave = 0
            vim.g.go_fmt_autosave = 0
            vim.g.go_imports_mode = 'gopls'
            vim.g.go_fmt_command = "gopls"
            vim.g.go_gopls_gofumpt = 1

            -- mappings
            map('', 'C-i', ':GoInfo<cr>')
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
			map('', '<leader>dd', ':DlvToggleBreakpoint<cr>')
			map('', '<leader>dt', ':DlvTest<cr>')
		end,
	}

	use 'junegunn/fzf'
	use 'preservim/vimux'
	use {
		'ruanyl/vim-gh-line',
		setup = function() vim.g.gh_line_map = "<leader>hh" end,
	}
	use 'pwntester/octo.nvim'
	use 'kyazdani42/nvim-web-devicons'
	use 'tpope/vim-fugitive'
	-- LSP
	use 'neovim/nvim-lspconfig'
	use 'hrsh7th/cmp-nvim-lsp'
	use 'hrsh7th/cmp-cmdline'
	use 'hrsh7th/cmp-buffer'
	use 'hrsh7th/cmp-path'
	use 'hrsh7th/vim-vsnip'
	use 'hrsh7th/cmp-vsnip'

	use 'ray-x/lsp_signature.nvim'
	use 'nvim-lua/lsp-status.nvim'
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

	use {
		'nvim-treesitter/nvim-treesitter',
		config = function ()
			require'nvim-treesitter.configs'.setup {
				-- One of "all", "maintained" (parsers with maintainers), or a list of languages
				ensure_installed = "all",

				-- Install languages synchronously (only applied to `ensure_installed`)
				sync_install = false,

				-- List of parsers to ignore installing
				ignore_install = { "javascript" },

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
	-- Themes
	use 'rktjmp/lush.nvim'
	use 'marko-cerovac/material.nvim'
	use 'jamespwilliams/bat.vim'
	use {
		'RRethy/nvim-base16',
		requires = {{'nvim-lua/plenary.nvim'}, {'rktjmp/fwatch.nvim'}},
		config = function ()
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
