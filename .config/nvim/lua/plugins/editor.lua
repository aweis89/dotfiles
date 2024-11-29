local darktheme = "onedark"
local lighttheme = "onelight"

return {
  {
    "LazyVim/LazyVim",
    opts = function(_, opts)
      local function is_dark_mode_enabled()
        if vim.fn.system("uname") == "Darwin\n" then
          local handle = io.popen("defaults read -g AppleInterfaceStyle 2>/dev/null")
          if handle == nil then
            return
          end
          local result = handle:read("*a")
          handle:close()
          return result:match("^%s*Dark%s*$") ~= nil
        end
      end

      if is_dark_mode_enabled() then
        vim.cmd("set background=dark")
      else
        vim.cmd("set background=light")
      end

      if is_dark_mode_enabled() then
        opts.colorscheme = darktheme
      else
        opts.colorscheme = lighttheme
      end
    end,
  },
  {
    "olimorris/onedarkpro.nvim",
    priority = 1000, -- Ensure it loads first
  },
  {
    "almo7aya/openingh.nvim",
    keys = {
      { "<C-g>", "<cmd>OpenInGHFileLines<cr>", desc = "Open in Github (prefer branch)" },
      { "<C-G>", "<cmd>OpenInGHFileLines!<cr>", desc = "Open in Github (prefer sha)" },
    },
  },
  { "mbbill/undotree" },
  { "tpope/vim-fugitive" },
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
  { "karb94/neoscroll.nvim", enabled = false },
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
