local themes = {
  catppuccin = {
    light = "catppuccin",
    dark = "catppuccin",
  },
  onedark = {
    light = "onelight",
    dark = "onedark",
  },
  tokyonight = {
    light = "tokyonight-day",
    dark = "tokyonight",
  },
  gruvbox = {
    light = "gruvbox",
    dark = "gruvbox",
  },
}

local light_theme = themes.gruvbox.light
local dark_theme = themes.gruvbox.dark

local function set_background()
  local function is_macos()
    local handle = io.popen("uname")
    if not handle then return false end
    local os_name = handle:read("*a")
    handle:close()
    return os_name and os_name:gsub("%s+", "") == "Darwin"
  end

  if vim.o.buftype == 'prompt' then
    return
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
  else
    vim.api.nvim_set_option_value("background", "dark", {})
    vim.cmd.colorscheme(dark_theme)
  end
end

return {
  {
    "LazyVim/LazyVim",
    opts = function()
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
    "aweis89/gruvbox.nvim",
    priority = 1000,
    opts = {
      overrides = {
        LspReferenceRead = { link = "Underlined" },
        LspReferenceText = { link = "Underlined" },
        LspReferenceWrite = { link = "Underlined" },
      },
      italic = {
        emphasis = true,
        operators = false,
        folds = true,
        strings = true,
        comments = true,
        keywords = true,
      },
    },
  },
  {
    "olimorris/onedarkpro.nvim",
    priority = 1000,
    opts = function(_, opts)
      opts.highlights = {
        PmenuSel = {
          underline = true,
          -- bg = "#181818",
        },
      }
      opts.styles = {            -- For example, to apply bold and italic, use "bold,italic"
        virtual_text = "italic", -- Style that is applied to virtual text
        keywords = "italic",     -- Style that is applied to keywords
        operators = "italic",    -- Style that is applied to operators
      }
    end,
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
      vim.g.rooter_patterns = { '.git', '=nvim', '=src' }
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
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function(_, opts)
      opts.options = vim.tbl_deep_extend("force", opts.options, {
        theme = "auto",
      })
      return opts
    end,
  },
}
