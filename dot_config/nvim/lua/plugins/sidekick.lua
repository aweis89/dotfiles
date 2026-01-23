-- Sidekick will detect *external* opencode sessions by scanning processes/ports.
-- That creates an annoying picker when any opencode is running anywhere.
-- For opencode only, force "embedded terminal sessions only" so we only ever
-- attach to the session started by this Neovim instance.
local function sidekick_toggle(opts)
  local State = require("sidekick.cli.state")
  local Config = require("sidekick.config")
  -- Ensure session backends are registered (terminal/tmux/zellij/etc).
  -- `State.get({attached=true})` uses `Session.attached()` which does not call setup.
  require("sidekick.cli.session").setup()

  local attached = State.get({ name = "opencode", attached = true, terminal = true })
  if #attached > 0 then
    local state = attached[1]
    if not state.terminal then
      return
    end
    state.terminal:toggle()

    -- check if in visual mode
    if vim.fn.mode() == "v" or vim.fn.mode() == "V" or vim.fn.mode() == "\22" then
      state.terminal:send("{file}\n\n{selection}\n")
    end

    if state.terminal:is_open() and (not opts or opts.focus ~= false) then
      state.terminal:focus()
    end
    return
  end

  local tool = Config.get_tool("opencode")
  local state = { tool = tool, installed = vim.fn.executable(tool.cmd[1]) == 1 }
  local new_state = select(1, State.attach(state, { show = false, focus = opts and opts.focus }))
  if new_state and new_state.terminal then
    new_state.terminal:toggle()
    if new_state.terminal:is_open() and (not opts or opts.focus ~= false) then
      new_state.terminal:focus()
    end
  end
end

return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        actions = {
          sidekick_send = function(...)
            return require("sidekick.cli.picker.snacks").send(...)
          end,
        },
        win = {
          input = {
            keys = {
              ["<localleader>a"] = { "sidekick_send", mode = { "n", "i" } },
            },
          },
        },
      },
    },
  },
  {
    "folke/sidekick.nvim",
    keys = {
      {
        "<C-t>",
        function()
          sidekick_toggle({ focus = true, filter = { name = "opencode" } })
        end,
        desc = "Toggle Sidekick Terminal",
        mode = { "t", "n", "x" },
      },
    },
    opts = {
      -- add any options here
      cli = {
        win = {
          layout = "float",
          float = {
            width = 1.0,
            height = 1.0,
          },
        },
        mux = {
          enabled = false,
        },
      },
    },
  },
}
