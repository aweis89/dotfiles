local default_tool_state_file = vim.fn.stdpath("state") .. "/sidekick_default_tool.txt"

local function load_persisted_default_tool()
  if vim.fn.filereadable(default_tool_state_file) ~= 1 then
    return nil
  end
  local lines = vim.fn.readfile(default_tool_state_file)
  local name = lines[1] and vim.trim(lines[1]) or ""
  return name ~= "" and name or nil
end

local function persist_default_tool(name)
  pcall(function()
    vim.fn.mkdir(vim.fn.fnamemodify(default_tool_state_file, ":h"), "p")
    vim.fn.writefile({ name }, default_tool_state_file)
  end)
end

local function set_default_tool(name)
  if not name or name == "" then
    return
  end
  vim.g.sidekick_default_tool = name
  vim.env.SIDEKICK_DEFAULT = name
  persist_default_tool(name)
end

local function default_tool()
  return vim.g.sidekick_default_tool or vim.env.SIDEKICK_DEFAULT or "opencode"
end

if not vim.g.sidekick_default_tool and not vim.env.SIDEKICK_DEFAULT then
  local persisted = load_persisted_default_tool()
  if persisted then
    vim.g.sidekick_default_tool = persisted
    vim.env.SIDEKICK_DEFAULT = persisted
  end
end

local first_open_send_delay = 1000

local function sidekick_select_default_tool()
  local Config = require("sidekick.config")
  local current = default_tool()
  local items = {}

  for name, tool in pairs(Config.tools()) do
    local cmd = tool and tool.cmd and tool.cmd[1] or ""
    local installed = cmd ~= "" and vim.fn.executable(cmd) == 1
    table.insert(items, {
      name = name,
      cmd = cmd,
      installed = installed,
      text = name,
    })
  end

  table.sort(items, function(a, b)
    return a.name < b.name
  end)

  local function set_default(item)
    if not item then
      return
    end
    set_default_tool(item.name)
    vim.notify(("Sidekick default tool: %s"):format(item.name), vim.log.levels.INFO)
  end

  local Snacks = require("snacks")
  Snacks.picker({
    title = "Select Sidekick Default Tool",
    items = items,
    layout = {
      preset = "select",
    },
    preview = function()
      return false
    end,
    format = function(item)
      local ret = {}
      local selected = item.name == current and "* " or "  "
      table.insert(ret, { selected, "Comment" })
      table.insert(ret, { item.name, item.installed and "DiagnosticOk" or "DiagnosticWarn" })
      return ret
    end,
    confirm = function(picker, item)
      picker:close()
      set_default(item)
    end,
  })
end

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
  local rendered
  if from_visual_mode then
    _, rendered = require("sidekick.cli").render({
      msg = "{file}\n\n{selection}\n",
    })
  end

  local attached
  local tool_name = default_tool()
  local state = State.get({ name = tool_name, attached = true, terminal = true })
  if #state > 0 then
    attached = state[1]
    attached.terminal:toggle()

    if attached.terminal:is_open() then
      attached.terminal:focus()
    end
  else
    local tool = Config.get_tool(tool_name)
    attached = State.attach({ tool = tool, installed = true }, { show = true, focus = true })
  end

  if rendered then
    local is_new_terminal = #state == 0
    if is_new_terminal then
      -- On first open, terminal needs time to initialize before send() works.
      vim.defer_fn(function()
        require("sidekick.cli").send({ text = rendered })
      end, first_open_send_delay)
    else
      require("sidekick.cli").send({ text = rendered })
    end
  end
end

local function sidekick_open(text)
  local State = require("sidekick.cli.state")
  local Config = require("sidekick.config")
  -- Ensure session backends are registered (terminal/tmux/zellij/etc).
  -- `State.get({attached=true})` uses `Session.attached()` which does not call setup.
  require("sidekick.cli.session").setup()

  local attached
  local tool_name = default_tool()
  local state = State.get({ name = tool_name, attached = true, terminal = true })
  if #state > 0 then
    attached = state[1]

    if attached.terminal:is_open() then
      attached.terminal:focus()
    else
      attached.terminal:show()
    end
  else
    local tool = Config.get_tool(tool_name)
    attached = State.attach({ tool = tool, installed = true }, { show = true, focus = true })
  end

  if text then
    local is_new_terminal = #state == 0
    if is_new_terminal then
      -- On first open, terminal needs time to initialize before send() works.
      vim.defer_fn(function()
        attached.terminal:send(text)
      end, first_open_send_delay)
    else
      attached.terminal:send(text)
    end
  end
end

return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        actions = {
          ---@type snacks.picker.Action.fn
          sidekick_send = function(picker)
            local selected = picker:selected({ fallback = true })
            picker:close()
            local files = {}
            for _, item in ipairs(selected) do
              local path = require("snacks.picker.util").path(item)
              table.insert(files, "@" .. path)
            end
            sidekick_open(table.concat(files, " "))
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
        "<leader>aa",
        sidekick_select_default_tool,
        desc = "Select Sidekick Default Tool",
      },
      {
        "<C-t>",
        sidekick_toggle,
        desc = "Toggle Sidekick Terminal",
        mode = { "t", "n", "x" },
      },
    },
    opts = {
      cli = {
        tools = {
          codex = { cmd = { "codex", "-p", "unrestricted" } },
        },
        win = {
          layout = "current",
          keys = {
            prompt = { "<a-p>", "prompt", mode = "t", desc = "insert prompt or context" },
          },
        },
        mux = {
          enabled = true,
        },
      },
    },
  },
}
