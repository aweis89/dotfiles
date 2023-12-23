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
  { "mbbill/undotree" },
  { "tpope/vim-fugitive" },
  { "towolf/vim-helm" },
  { "mrjosh/helm-ls" },
  { "akinsho/bufferline.nvim", enabled = false },
  { "rcarriga/nvim-notify", enabled = true },
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
  { "echasnovski/mini.surround", version = "*" },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = COLORSCHEME,
      -- colorscheme catppuccin, catppuccin-latte, catppuccin-frappe, catppuccin-macchiato, catppuccin-mocha
    },
  },

  {
    "L3MON4D3/LuaSnip",
    -- follow latest release.
    version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
    -- install jsregexp (optional!).
    build = "make install_jsregexp",
  },

  {
    "nvim-telescope/telescope.nvim",
    optional = true,
    opts = function(_, opts)
      local function flash(prompt_bufnr)
        require("flash").jump({
          pattern = "^",
          label = { after = { 0, 0 } },
          search = {
            -- disable for regular search behavior (including not auto exiting)
            enabled = false,
            -- mode = "search",
            -- exclude = {
            --   function(win)
            --     return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "TelescopeResults"
            --   end,
            -- },
          },
          action = function(match)
            local picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
            picker:set_selection(match.pos[1] - 1)
          end,
        })
      end
      opts.defaults = vim.tbl_deep_extend("force", opts.defaults or {}, {
        mappings = {
          n = { s = flash },
          i = { ["<c-s>"] = flash },
        },
      })
    end,
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
}
