vim.cmd [[packadd packer.nvim]]
return require('packer').startup(function()
  use 'tpope/vim-sensible'
  
  use 'kassio/neoterm'
  
  use 'easymotion/vim-easymotion'
  use 'preservim/nerdtree'
  use 'airblade/vim-gitgutter'
  use 'mrk21/yaml-vim'
  use 'karb94/neoscroll.nvim'
  
  use 'nvim-lualine/lualine.nvim'
  
  use 'nvim-telescope/telescope.nvim'
  use 'nvim-lua/plenary.nvim'
  
  -- Golang plugins
  use 'fatih/vim-go'
  use 'ray-x/go.nvim'
  use 'buoto/gotests-vim'
  use 'sebdah/vim-delve'
  use 'junegunn/fzf'
  
  use 'preservim/vimux'
  
  -- github
  use 'ruanyl/vim-gh-line'
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
  -- use 'onsails/lspkind-nvim'
  -- debugger
  use 'mfussenegger/nvim-dap'
  use 'rcarriga/nvim-dap-ui'
  
  -- For vsnip users.
  use 'hrsh7th/cmp-vsnip'
  use 'hrsh7th/vim-vsnip'
  use 'hrsh7th/vim-vsnip-integ'
  use 'rafamadriz/friendly-snippets'
  
  use 'nvim-treesitter/nvim-treesitter'
  -- use 'folke/tokyonight.nvim', { 'branch': 'main' }
  use 'machakann/vim-highlightedyank'
  
  -- Themes
  use 'rktjmp/lush.nvim'
  use 'marko-cerovac/material.nvim'
  use 'jamespwilliams/bat.vim'
  use 'ellisonleao/gruvbox.nvim'
  
  use 'tyru/current-func-info.vim'
end)
