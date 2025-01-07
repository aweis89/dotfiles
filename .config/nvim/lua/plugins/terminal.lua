local function terminal(position)
  return function()
    local width = {
      float = 0.97
    }
    local height = {
      float = 0.97
    }
    Snacks.terminal.toggle("zsh", {
      env = {
        id = position,
      },
      win = {
        --@field position? "float"|"bottom"|"top"|"left"|"right"
        position = position,
        height = height[position] or 0.5,
        width = width[position] or 0.5,
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
        action = terminal("float"),
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
      {
        "<C-a>f",
        terminal("float"),
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
