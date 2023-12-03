vim.api.nvim_command([[command! TmuxSplitV silent execute '!tmux split-window -v -e "cd %:p:h"']])
vim.api.nvim_command([[command! TmuxSplitH silent execute '!tmux split-window -h -e "cd %:p:h"']])

COLORSCHEME = "catppuccin-frappe"

-- Check if the operating system is macOS
if vim.fn.system("uname") == "Darwin\n" then
  -- Define a function to check if dark mode is enabled
  local function is_dark_mode_enabled()
    local handle = io.popen("defaults read -g AppleInterfaceStyle 2>/dev/null")
    if handle == nil then
      return
    end
    local result = handle:read("*a")
    handle:close()
    return result:match("^%s*Dark%s*$") ~= nil
  end

  -- Use the function to set the Neovim colorscheme based on dark mode
  if is_dark_mode_enabled() then
    vim.cmd("set background=dark")
    COLORSCHEME = "catppuccin-mocha"
  else
    vim.cmd("set background=light")
    COLORSCHEME = "catppuccin-latte"
  end
  -- for reload explicitly set colorscheme
  -- vim.cmd("colorscheme " .. COLORSCHEME)
end

return {
  { "christoomey/vim-tmux-navigator" },
  { "akinsho/bufferline.nvim", enabled = false },
  { "rcarriga/nvim-notify", enabled = true },
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = COLORSCHEME,
      -- colorscheme catppuccin, catppuccin-latte, catppuccin-frappe, catppuccin-macchiato, catppuccin-mocha
    },
  },

  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function()
      return {
        options = {
          theme = "auto",
          section_separators = { left = "", right = "" },
          component_separators = { left = "", right = "" },
        },
      }
    end,
  },

  {
    "karb94/neoscroll.nvim",
    init = function()
      require("neoscroll").setup()
    end,
  },
  { "mbbill/undotree" },
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
  { "tpope/vim-fugitive" },
  {
    "ahmedkhalf/project.nvim",
    opts = {
      manual_mode = true,
      exclude_dirs = { "~/dev/mobilecoin/*" },
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
    end,
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
      { "<C-n>", "<leader>fE", desc = "Explorer NeoTree (cwd)", remap = true },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = "all",
    },
  },
  { "towolf/vim-helm" },
  { "mrjosh/helm-ls" },
}
