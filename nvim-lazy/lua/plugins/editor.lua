vim.cmd("set background=light")
vim.api.nvim_command([[command! TmuxSplitV silent execute '!tmux split-window -v -e "cd %:p:h"']])
vim.api.nvim_command([[command! TmuxSplitH silent execute '!tmux split-window -h -e "cd %:p:h"']])

return {
  { -- Use gruvbox
    "LazyVim/LazyVim",
    dependencies = { "ellisonleao/gruvbox.nvim" },
    opts = { colorscheme = "gruvbox" },
  },
  {
    "karb94/neoscroll.nvim",
    init = function()
      require("neoscroll").setup()
    end,
  },
  { "mbbill/undotree" },
  {
    "ahmedkhalf/project.nvim",
    opts = {
      patterns = {
        ".git",
        "_darcs",
        ".hg",
        ".bzr",
        ".svn",
        "Makefile",
        "package.json",
        "init.lua",
        "helmfile.yaml",
        "Chart.yaml",
        "Dockerfile",
      },
    },
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    keys = {
      {
        "<leader>fe",
        function()
          require("neo-tree.command").execute({ toggle = true, dir = require("lazyvim.util").get_root() })
        end,
        desc = "Explorer NeoTree (root dir)",
      },
      {
        "<leader>fE",
        function()
          require("neo-tree.command").execute({ toggle = true, dir = vim.loop.cwd() })
        end,
        desc = "Explorer NeoTree (cwd)",
      },
      { "<leader>e", "<leader>fe", desc = "Explorer NeoTree (root dir)", remap = true },
      { "<leader>E", "<leader>fE", desc = "Explorer NeoTree (cwd)", remap = true },
      { "<C-n>", "<leader>fe", desc = "Explorer NeoTree (root dir)", remap = true },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "bash",
        "dart",
        "go",
        "html",
        "javascript",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "query",
        "regex",
        "rust",
        "tsx",
        "typescript",
        "vim",
        "yaml",
      },
    },
  },
}
