-- Sidekick will detect *external* opencode sessions by scanning processes/ports.
-- That creates an annoying picker when any opencode is running anywhere.
-- For opencode only, force "embedded terminal sessions only" so we only ever
-- attach to the session started by this Neovim instance.
local function sidekick_toggle()
  local State = require("sidekick.cli.state")
  local Config = require("sidekick.config")
  -- Ensure session backends are registered (terminal/tmux/zellij/etc).
  -- `State.get({attached=true})` uses `Session.attached()` which does not call setup.
  require("sidekick.cli.session").setup()

  -- check if in visual mode
  local send = false
  if vim.fn.mode() == "v" or vim.fn.mode() == "V" or vim.fn.mode() == "\22" then
    send = true
  end

  local attached = State.get({ name = "opencode", attached = true, terminal = true })
  if #attached > 0 then
    local state = attached[1]
    if not state.terminal then
      return
    end
    state.terminal:toggle()

    if state.terminal:is_open() then
      state.terminal:focus()
    end

    if send then
      state.terminal:send("{file}\n\n{selection}\n")
    end
    return
  end

  local tool = Config.get_tool("opencode")
  local state = { tool = tool, installed = vim.fn.executable(tool.cmd[1]) == 1 }
  attached = State.attach(state, { show = true, focus = true })
  if send then
    attached.terminal:send("{file}\n\n{selection}\n")
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
    "aweis89/sidekick.nvim",
    keys = {
      {
        "<C-t>",
        function()
          sidekick_toggle()
        end,
        desc = "Toggle Sidekick Terminal",
        mode = { "t", "n", "x" },
      },
    },
    opts = {
      -- add any options here
      cli = {
        win = {
          layout = "current",
          keys = {
            prompt = { "<a-p>", "prompt", mode = "t", desc = "insert prompt or context" },
          },
        },
        mux = {
          enabled = false,
        },
      },
    },
  },
}
