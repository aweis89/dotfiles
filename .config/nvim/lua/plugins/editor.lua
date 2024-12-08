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
        colorscheme = "catppuccin",
      }
    end,
  },
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
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
  { "rcarriga/nvim-notify", enabled = true },
  { "karb94/neoscroll.nvim", enabled = true },
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
        section_separators = { left = "", right = "" },
        component_separators = { left = "", right = "" },
      })
      return opts
    end,
  },
}
