local darktheme = "onedark"
local lighttheme = "onelight"

return {
  {
    "olimorris/onedarkpro.nvim",
    priority = 1000, -- Ensure it loads first
  },
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "VeryLazy", -- Or `LspAttach`
    priority = 1000, -- needs to be loaded in first
    config = true,
  },
  {
    "f-person/auto-dark-mode.nvim",
    opts = {
      update_interval = 5000,
      set_dark_mode = function()
        vim.api.nvim_set_option_value("background", "dark", {})
        if darktheme ~= lighttheme then
          vim.cmd("colorscheme " .. darktheme)
        end
      end,
      set_light_mode = function()
        vim.api.nvim_set_option_value("background", "light", {})
        if darktheme ~= lighttheme then
          vim.cmd("colorscheme " .. lighttheme)
        end
      end,
    },
  },
  {
    "almo7aya/openingh.nvim",
    keys = {
      { "<C-g>", "<cmd>OpenInGHFileLines<cr>", desc = "Open in Github (prefer branch)" },
      { "<C-G>", "<cmd>OpenInGHFileLines!<cr>", desc = "Open in Github (prefer sha)" },
    },
  },
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
      "ibhagwan/fzf-lua",
    },
    config = true,
  },
  { "mbbill/undotree" },
  { "towolf/vim-helm" },
  { "mrjosh/helm-ls" },
  { "akinsho/bufferline.nvim", enabled = false },
  { "rcarriga/nvim-notify", enabled = true },
  { "echasnovski/mini.surround", version = "*" },
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
  { "karb94/neoscroll.nvim", enabled = true },
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
}
