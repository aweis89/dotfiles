local light_theme = "gruvbox"
local dark_theme = "onedark_dark"

local function set_background()
  local function is_macos()
    local handle = io.popen("uname")
    if not handle then return false end
    local os_name = handle:read("*a")
    handle:close()
    return os_name and os_name:gsub("%s+", "") == "Darwin"
  end

  if is_macos() then
    local handle = io.popen("defaults read -g AppleInterfaceStyle 2>/dev/null")
    if not handle then return end
    local result = handle:read("*a")
    handle:close()

    if result:find("Dark") then
      vim.api.nvim_set_option_value("background", "dark", {})
      vim.cmd.colorscheme(dark_theme)
    else
      vim.api.nvim_set_option_value("background", "light", {})
      vim.cmd.colorscheme(light_theme)
    end
  end
end

return {
  {
    "LazyVim/LazyVim",
    opts = function(_, opts)
      set_background()

      vim.uv.new_timer():start(
        5000,
        5000,
        vim.schedule_wrap(function()
          set_background()
        end)
      )

      return {
        colorscheme = vim.g.colors_name,
      }
    end,
  },
  {
    "willothy/flatten.nvim",
    config = true,
    lazy = false,
    priority = 1001,
  },
  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
    config = true,
    opts = {
      overrides = {
        LspReferenceRead = { link = "Underlined" },
        LspReferenceText = { link = "Underlined" },
        LspReferenceWrite = { link = "Underlined" },
      }
    }
  },
  {
    "olimorris/onedarkpro.nvim",
    priority = 1000,
  },
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
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
    },
    config = true,
  },
  { "mbbill/undotree" },
  { "akinsho/bufferline.nvim", enabled = false },
  { "rcarriga/nvim-notify",    enabled = true },
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
