return {
  {
    "mbbill/undotree",
    event = "VeryLazy",
  },
  {
    "tpope/vim-fugitive",
    event = "VeryLazy",
  },
  { "akinsho/bufferline.nvim", enabled = true },
  { "rcarriga/nvim-notify",    enabled = true },
  {
    "nvim-neotest/neotest",
    opts = {
      neotest = {
        diagnostic = true,
      },
    },
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    enabled = true,
    keys = {
      { "<leader>e", false },
      { "<leader>E", false }
    },
  },
  {
    "echasnovski/mini.files",
    opts = {
      options = {
        use_as_default_explorer = true,
      },
    },
    keys = {
      {
        "<leader>e",
        function()
          require("mini.files").open(vim.api.nvim_buf_get_name(0), true)
        end,
        desc = "Open mini.files (Directory of Current File)",
      },
      {
        "<leader>E",
        function()
          require("mini.files").open(vim.uv.cwd(), true)
        end,
        desc = "Open mini.files (cwd)",
      }
    },
  },
}
