vim.api.nvim_command([[command! TmuxSplitV silent execute '!tmux split-window -v -e "cd %:p:h"']])
vim.api.nvim_command([[command! TmuxSplitH silent execute '!tmux split-window -h -e "cd %:p:h"']])

return {
  {
    "LazyVim/LazyVim",
    -- opts = function(_, opts)
    --   opts.colorscheme = COLORSCHEME
    -- end,
  },
  { "almo7aya/openingh.nvim" },
  { "christoomey/vim-tmux-navigator" },
  { "mbbill/undotree" },
  { "tpope/vim-fugitive" },
  { "towolf/vim-helm" },
  { "mrjosh/helm-ls" },
  { "akinsho/bufferline.nvim", enabled = false },
  { "rcarriga/nvim-notify", enabled = true },
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
  { "echasnovski/mini.surround", version = "*" },
  {
    "alexghergh/nvim-tmux-navigation",
    config = function()
      local nvim_tmux_nav = require("nvim-tmux-navigation")

      nvim_tmux_nav.setup({
        disable_when_zoomed = true, -- defaults to false
      })

      vim.keymap.set("n", "<C-h>", nvim_tmux_nav.NvimTmuxNavigateLeft)
      vim.keymap.set("n", "<C-j>", nvim_tmux_nav.NvimTmuxNavigateDown)
      vim.keymap.set("n", "<C-k>", nvim_tmux_nav.NvimTmuxNavigateUp)
      vim.keymap.set("n", "<C-l>", nvim_tmux_nav.NvimTmuxNavigateRight)
      vim.keymap.set("n", "<C-\\>", nvim_tmux_nav.NvimTmuxNavigateLastActive)
      vim.keymap.set("n", "<C-Space>", nvim_tmux_nav.NvimTmuxNavigateNext)
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = "all"
      return opts
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function(_, opts)
      opts.options = vim.tbl_deep_extend("force", opts.options, {
        theme = "auto",
        section_separators = { left = "", right = "" },
        component_separators = { left = "", right = "" },
      })
      return opts
    end,
  },
  { "karb94/neoscroll.nvim", enabled = false },
  {
    "voldikss/vim-floaterm",
    keys = {
      {
        "<leader>gl",
        "<cmd>FloatermNew --height=0.9 --width=0.9 --wintype=float --name=git --position=center lazygit<cr>",
        desc = "LazyGit",
      },
    },
  },
  {
    "ahmedkhalf/project.nvim",
    opts = {
      manual_mode = true,
      patterns = {
        "helmfile.yaml",
        "Chart.yaml",
        "Dockerfile",
        "Cargo.toml",
        "Makefile",
        "package.json",
        "init.lua",
        "go.mod",
        "go.sum",
        "main.go",
        "main.rs",
        ".git",
        "_darcs",
        ".hg",
        ".bzr",
        ".svn",
      },
    },
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = function(_, opts)
      opts.filesystem = vim.tbl_extend("error", opts.filesystem, {
        filtered_items = {
          -- visible = true,
          always_show = { -- remains visible even if other settings would normally hide it
            ".github",
          },
        },
      })

      opts.default_component_configs.git_status = {
        symbols = {
          unstaged = "",
          staged = "",
        },
      }
    end,
    keys = {
      {
        "<leader>fe",
        function()
          require("neo-tree.command").execute({ toggle = true, dir = require("lazyvim.util").root.get() })
        end,
        desc = "Explorer NeoTree (root dir)",
      },
      {
        "<leader>fE",
        function()
          require("neo-tree.command").execute({ toggle = true, dir = vim.fn.getcwd() })
        end,
        desc = "Explorer NeoTree (cwd)",
      },
      { "<leader>e", "<leader>fe", desc = "Explorer NeoTree (root dir)", remap = true },
      { "<leader>E", "<leader>fE", desc = "Explorer NeoTree (cwd)", remap = true },
      { "<C-n>", "<leader>fE", desc = "Explorer NeoTree (cwd)", remap = true },
    },
  },
}
