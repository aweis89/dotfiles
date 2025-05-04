------------------------------------------
-- Terminal Configuration
-- Handles general terminal functionality and integration
------------------------------------------

if vim.env.TMUX then
  return {}
end

------------------------------------------
-- Constants
------------------------------------------
local DEFAULT_SHELL = vim.env.SHELL or "zsh"
local WINDOW_DIMENSIONS = {
  float = { width = 0.97, height = 0.97 },
  bottom = { width = 0.5, height = 0.5 },
  top = { width = 0.5, height = 0.5 },
  left = { width = 0.5, height = 0.5 },
  right = { width = 0.5, height = 0.5 },
}

------------------------------------------
-- Terminal Functions
------------------------------------------
---Create a terminal with specified position and command
---@param position "float"|"bottom"|"top"|"left"|"right"
---@param cmd string|nil
---@return function
local function terminal(position, cmd)
  local valid_positions = { float = true, bottom = true, top = true, left = true, right = true }

  if not valid_positions[position] then
    vim.notify("Invalid terminal position: " .. tostring(position), vim.log.levels.ERROR)
    return function() end
  end

  return function()
    local dimensions = WINDOW_DIMENSIONS[position]
    return Snacks.terminal.toggle(cmd or DEFAULT_SHELL, {
      env = { id = cmd or position },
      win = {
        position = position,
        height = dimensions.height,
        width = dimensions.width,
      },
    })
  end
end

------------------------------------------
-- Plugin Configuration
------------------------------------------
return {
  {
    "folke/snacks.nvim",
    optional = true,
    event = "VeryLazy",
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
          Snacks.terminal(DEFAULT_SHELL, {
            win = {
              height = 0.99,
              width = 0.99,
            },
          })
        end,
        desc = "Open terminal",
        mode = { "n", "t" },
      },
      -- Direction-based terminal toggles
      {
        "<C-a>h",
        terminal("left"),
        mode = { "n", "t", "i" },
        desc = "Toggle left terminal",
      },
      {
        "<C-a>x",
        function()
          vim.cmd("bdelete!")
        end,
        mode = { "n", "t", "i" },
        desc = "Close terminal",
      },
      {
        "<C-a>l",
        terminal("right"),
        mode = { "n", "t", "i" },
        desc = "Toggle right terminal",
      },
      {
        "<C-a>\\",
        terminal("right"),
        mode = { "n", "t", "i" },
        desc = "Toggle right terminal",
      },
      {
        "<C-a>j",
        terminal("bottom"),
        mode = { "n", "t", "i" },
        desc = "Toggle bottom terminal",
      },
      {
        "<C-a>-",
        terminal("bottom"),
        mode = { "n", "t", "i" },
        desc = "Toggle bottom terminal",
      },
      {
        "<C-a>k",
        terminal("top"),
        mode = { "n", "t", "i" },
        desc = "Toggle top terminal",
      },
      {
        "<C-a>f",
        terminal("float"),
        mode = { "n", "t", "i" },
        desc = "Toggle floating terminal",
      },
      {
        "<C-a>c",
        function()
          vim.cmd.terminal()
          local buffer = vim.api.nvim_get_current_buf()
          local onenter = function()
            vim.cmd.startinsert()
            vim.api.nvim_buf_set_keymap(buffer, "n", "q", "<cmd>bwipeout!<cr>", { noremap = true, silent = true })
          end
          onenter()

          vim.api.nvim_create_autocmd({ "BufEnter" }, {
            buffer = buffer,
            callback = onenter,
          })
        end,
        mode = { "n", "t", "i" },
        desc = "Create new terminal",
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
