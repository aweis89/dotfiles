local terms = {}

local function toggle(size, direction, name)
  local terminal = require("toggleterm.terminal").Terminal

  name = name or "scratch"
  if not terms[name] then
    local term = terminal:new({
      cmd = "zsh",
      close_on_exit = true,
      auto_scroll = false,
    })
    terms[name] = term
  end
  local running = terms[name]
  running:toggle(size, direction)
end

return {
  {
    "folke/snacks.nvim",
    optional = true,
    opts = function(_, opts)
      table.insert(opts.dashboard.preset.keys, 3, {
        action = function()
          toggle(nil, "tab")
        end,
        desc = "Terminal",
        icon = " ",
        key = "t",
      })
    end,
  },
  {
    "toggleterm/toggleterm.nvim",
    config = true,
    keys = {
      {
        "<C-a>v",
        function()
          toggle(vim.o.columns * 0.5, "vertical")
        end,
        mode = { "n", "t", "i" },
      },
      {
        "<C-a>\\",
        function()
          toggle(vim.o.columns * 0.5, "vertical")
        end,
        mode = { "n", "t", "i" },
      },
      {
        "<C-a>-",
        function()
          local size = math.floor(vim.api.nvim_win_get_height(0) * 0.4)
          toggle(size, "horizontal")
        end,
        mode = { "n", "t", "i" },
      },
      {
        "<C-a>h",
        function()
          local size = math.floor(vim.api.nvim_win_get_height(0) * 0.4)
          toggle(size, "horizontal")
        end,
        mode = { "n", "t", "i" },
      },
      {
        "<C-a>t",
        function()
          toggle(nil, "tab")
        end,
        mode = { "n", "t", "i" },
      },
    },
  },
  {
    "folke/snacks.nvim",
    keys = { {
      "<C-t>",
      function()
        Snacks.terminal(vim.env.SHELL or "zsh", {
          win = {
            height = 0.99,
            width = 0.99,
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
}
