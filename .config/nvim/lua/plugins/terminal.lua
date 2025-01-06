local terms = {}

local function terminal(position)
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
          terminal("float")
        end,
        desc = "Terminal",
        icon = " ",
        key = "t",
      })
    end,
  },
  {
    "folke/snacks.nvim",
    keys = {
      {
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
      },
      {
        "<C-a>h",
        terminal("left"),
        mode = { "n", "t", "i" },
      },
      {
        "<C-a>l",
        terminal("right"),
        mode = { "n", "t", "i" },
      },
      {
        "<C-a>j",
        terminal("bottom"),
        mode = { "n", "t", "i" },
      },
      {
        "<C-a>k",
        terminal("top"),
        mode = { "n", "t", "i" },
      },
    },
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
