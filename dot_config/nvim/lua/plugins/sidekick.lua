local default_tool = "opencode"

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

  local from_visual_mode = vim.fn.mode():find("^[vV]")

  local attached
  local state = State.get({ name = "opencode", attached = true, terminal = true })
  if #state > 0 then
    attached = state[1]
    attached.terminal:toggle()

    if attached.terminal:is_open() then
      attached.terminal:focus()
    end
  else
    local tool = Config.get_tool(default_tool)
    attached = State.attach({ tool = tool, installed = true }, { show = true, focus = true })
  end

  if from_visual_mode then
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
        sidekick_toggle,
        desc = "Toggle Sidekick Terminal",
        mode = { "t", "n", "x" },
      },
    },
    opts = {
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
