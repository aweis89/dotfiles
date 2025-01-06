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

local function togglep(position)
  return function()
    Snacks.terminal.toggle("zsh", {
      env = {
        id = position,
      },
      win = {
        --@field position? "float"|"bottom"|"top"|"left"|"right"
        position = position,
        width = 0.5,
        height = 0.5,
      }
    })
  end
end

return {
  {
    "folke/snacks.nvim",
    optional = true,
    opts = function(_, opts)
      table.insert(opts.dashboard.preset.keys, 2, {
        action = function()
          toggle(nil, "tab")
        end,
        desc = "Terminal",
        icon = " ",
        key = "t",
      })
    end,
  },
  {
    "toggleterm/toggleterm.nvim",
    keys = {
      {
        "<C-a>h",
        togglep("left"),
        mode = { "n", "t", "i" },
      },
      {
        "<C-a>l",
        togglep("right"),
        mode = { "n", "t", "i" },
      },
      {
        "<C-a>j",
        togglep("bottom"),
        mode = { "n", "t", "i" },
      },
      {
        "<C-a>k",
        togglep("top"),
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
