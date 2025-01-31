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
    dark = "tokyonight-night",
  },
  gruvbox = {
    light = "gruvbox",
    dark = "gruvbox",
  },
}

local light_theme = themes.tokyonight.light
local dark_theme = themes.tokyonight.dark
local reload_theme_path = "~/tmp/theme-reload"

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
    vim.cmd.colorscheme(dark_theme)
  end
end

return {
  {
    "LazyVim/LazyVim",
    opts = function()
      set_background()

      local theme_reload_path = vim.fn.expand(reload_theme_path)
      local watcher = vim.uv.new_fs_event()
      if watcher then
        watcher:start(theme_reload_path, {}, function()
          vim.schedule(function()
            set_background()
          end)
        end)
      end

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
}
