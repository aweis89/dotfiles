local function is_macos()
  local handle = io.popen("uname")
  local os_name = handle:read("*a"):gsub("%s+", "")
  handle:close()
  return os_name == "Darwin"
end

local function set_background()
  if is_macos() then
    local handle = io.popen("defaults read -g AppleInterfaceStyle 2>/dev/null")
    local result = handle:read("*a")
    handle:close()

    if result:find("Dark") then
      vim.api.nvim_set_option_value("background", "dark", {})
    else
      vim.api.nvim_set_option_value("background", "light", {})
    end
  end
end

return {
  {
    "LazyVim/LazyVim",
    opts = function(_, opts)
      set_background()

      vim.loop.new_timer():start(
        5000,
        5000,
        vim.schedule_wrap(function()
          set_background()
        end)
      )

      return {
        colorscheme = "gruvbox",
      }
    end,
  },
  { "ellisonleao/gruvbox.nvim", priority = 1000, config = true },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
  },
  {
    "tpope/vim-fugitive",
  },
  {
    "nvim-neotest/neotest",
    dependencies = { "nvim-neotest/neotest-plenary" },
    opts = {
      neotest = {
        diagnostic = true,
      },
      adapters = { "neotest-plenary" },
      icons = {
        expanded = "",
        child_prefix = "",
        child_indent = "",
        final_child_prefix = "",
        non_collapsible = "",
        collapsed = "",

        passed = "",
        running = "",
        failed = "",
        unknown = ""
      },
    }
  },
  {
    "folke/snacks.nvim",
    keys = { {
      "<C-t>",
      function()
        Snacks.terminal(vim.env.SHELL or "zsh", {
          win = {
            height = 0.95,
            width = 0.95,
          }
        })
      end,
      desc = "Opent terminal",
      mode = { "n", "t" },
    } },
    opts = {
      dashboard = {
        preset = {
          header = [[
          ]],
        },
      },
    },
  },
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
    },
    config = true,
  },
  { "mbbill/undotree" },
  { "akinsho/bufferline.nvim",  enabled = false },
  { "rcarriga/nvim-notify",     enabled = true },
  { "karb94/neoscroll.nvim",    enabled = true },
  {
    "airblade/vim-rooter",
    init = function()
      vim.g.rooter_patterns = { '.git', '=nvim' }
    end
  },
  {
    "ahmedkhalf/project.nvim",
    opts = {
      manual_mode = false,
    },
    event = "VeryLazy",
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
        -- section_separators = { left = "", right = "" },
        -- component_separators = { left = "", right = "" },
      })
      return opts
    end,
  },
}
