if vim.g.vscode then
  return {}
end

local themes = {
  evergarden = {
    light = "evergarden-summer",
    dark = "evergarden",
    plugin = {
      "everviolet/nvim",
      name = "evergarden",
      priority = 1000, -- Colorscheme plugin is loaded first before any other plugins
      opts = {
        theme = {
          variant = "fall", -- 'winter'|'fall'|'spring'|'summer'
          accent = "green",
        },
        editor = {
          transparent_background = false,
          sign = { color = "none" },
          float = {
            color = "mantle",
            invert_border = false,
          },
          completion = {
            color = "surface0",
          },
        },
      },
    },
  },
  catppuccin = {
    light = "catppuccin",
    dark = "catppuccin",
    plugin = {
      "catppuccin/nvim",
      name = "catppuccin",
      priority = 1000,
      opts = function(_, opts)
        opts = opts or {}
        opts.background = { light = "latte", dark = "mocha" }
        opts.styles = opts.styles or {}
        opts.styles.keywords = { "italic" }
        return opts
      end,
    },
  },
  onedark = {
    light = "onelight",
    dark = "onedark_dark",
    plugin = {
      "olimorris/onedarkpro.nvim",
      priority = 1000,
      opts = function(_, opts)
        opts.highlights = {
          PmenuSel = {
            underline = true,
          },
        }
        opts.styles = { -- For example, to apply bold and italic, use "bold,italic"
          virtual_text = "italic", -- Style that is applied to virtual text
          keywords = "italic", -- Style that is applied to keywords
          operators = "italic", -- Style that is applied to operators
        }
      end,
    },
  },
  tokyonight = {
    light = "tokyonight-day",
    dark = "tokyonight-night",
    plugin = { "folke/tokyonight.nvim", priority = 1000 },
  },
  gruvbox = {
    light = "gruvbox",
    dark = "gruvbox",
    plugin = {
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
  },
  kanagawa = {
    light = "kanagawa",
    dark = "kanagawa",
    plugin = { "rebelot/kanagawa.nvim" },
  },
  rosepine = {
    light = "rose-pine",
    dark = "rose-pine",
    plugin = { "rose-pine/neovim" },
  },
  everforest = {
    light = "everforest",
    dark = "everforest",
    plugin = {
      "neanias/everforest-nvim",
      config = function()
        require("everforest").setup({
          on_highlights = function(hl, palette)
            hl.CurrentWord = { fg = palette.none, bg = palette.bg_visual, underline = true }
          end,
        })
      end,
    },
  },
}

local reload_theme_path = "~/tmp/theme-reload"

local function set_background(light_theme, dark_theme)
  local function is_macos()
    local handle = io.popen("uname")
    if not handle then
      return false
    end
    local os_name = handle:read("*a")
    handle:close()
    return os_name and os_name:gsub("%s+", "") == "Darwin"
  end

  if is_macos() then
    local handle = io.popen("defaults read -g AppleInterfaceStyle 2>/dev/null")
    if not handle then
      return
    end
    local result = handle:read("*a")
    handle:close()

    if result:find("Dark") then
      if vim.g.colors_name == dark_theme and vim.o.background == "dark" then
        return
      end
      vim.api.nvim_set_option_value("background", "dark", {})
      vim.cmd.colorscheme(dark_theme)
    else
      if vim.g.colors_name == light_theme and vim.o.background == "light" then
        return
      end
      vim.api.nvim_set_option_value("background", "light", {})
      vim.cmd.colorscheme(light_theme)
    end
  else
    vim.api.nvim_set_option_value("background", "dark", {})
  end
end

-- Use Catppuccin for both light and dark; flavour maps via plugin opts
local light_theme = themes.gruvbox.light
local dark_theme = themes.everforest.dark

-- Set to true to install all theme plugins
local install_all_theme_plugins = true

local plugins = {
  {
    "LazyVim/LazyVim",
    opts = function()
      local light_name = type(light_theme) == "table" and light_theme.light or light_theme
      local dark_name = type(dark_theme) == "table" and dark_theme.dark or dark_theme
      set_background(light_name, dark_name)

      local theme_reload_path = vim.fn.expand(reload_theme_path)
      local watcher = vim.uv.new_fs_event()
      if watcher then
        watcher:start(theme_reload_path, {}, function()
          vim.schedule(function()
            set_background(light_name, dark_name)
          end)
        end)
      end

      return {
        colorscheme = vim.g.colors_name,
      }
    end,
  },
}

local function add_theme_plugin(plugin)
  if type(plugin) ~= "table" then
    return
  end
  if next(plugin) == nil then
    return
  end
  if type(plugin[1]) ~= "string" then
    return
  end
  table.insert(plugins, plugin)
end

if install_all_theme_plugins then
  local theme_names = vim.tbl_keys(themes)
  table.sort(theme_names)
  for _, theme_name in ipairs(theme_names) do
    add_theme_plugin(themes[theme_name].plugin)
  end
else
  add_theme_plugin(selected_theme.plugin)
end

return plugins
