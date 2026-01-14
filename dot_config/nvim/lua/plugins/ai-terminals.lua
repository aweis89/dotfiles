local use_terminal_ai = false

local auto_terminal_keymaps = {
  { name = "aider", key = "a" },
  { name = "claude", key = "c" },
  { name = "codex", key = "d" },
  { name = "cursor", key = "u" },
  { name = "gemini", key = "g" },
  { name = "opencode", key = "o" },
}

local default_terminal_file = vim.fn.stdpath("data") .. "/default_ai_terminal.txt"

local function pick_mux_backend()
  if vim.fn.executable("tmux") == 1 then
    return "tmux"
  end
  if vim.fn.executable("zellij") == 1 then
    return "zellij"
  end
  return "terminal"
end

---@param opts? {name?:string, filter?:{name?:string}}
local function tool_name(opts)
  return opts and (opts.name or (opts.filter and opts.filter.name)) or nil
end

-- Sidekick will detect *external* opencode sessions by scanning processes/ports.
-- That creates an annoying picker when any opencode is running anywhere.
-- For opencode only, force "embedded terminal sessions only" so we only ever
-- attach to the session started by this Neovim instance.
local function sidekick_toggle(opts)
  local name = tool_name(opts)
  if name ~= "opencode" then
    return require("sidekick.cli").toggle(opts)
  end

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

local function sidekick_send(opts)
  local name = tool_name(opts)
  if name ~= "opencode" then
    return require("sidekick.cli").send(opts)
  end

  local cli = require("sidekick.cli")
  local State = require("sidekick.cli.state")
  local Config = require("sidekick.config")
  local Util = require("sidekick.util")
  -- Ensure session backends are registered (terminal/tmux/zellij/etc).
  require("sidekick.cli.session").setup()

  local msg, text = "", opts and opts.text ---@type string?, sidekick.Text[]?
  if not text then
    msg, text = cli.render(opts or {})
    if msg == "" or not text then
      Util.warn("Nothing to send.")
      return
    elseif msg == "\n" then
      msg = "" -- allow sending a new line
      text = {}
    end
  end

  local matches = State.get({ name = "opencode", attached = true, terminal = true })
  local state = matches[1]

  if not state then
    local tool = Config.get_tool("opencode")
    state = select(
      1,
      State.attach({ tool = tool, installed = vim.fn.executable(tool.cmd[1]) == 1 }, {
        show = true,
        focus = opts and opts.focus,
      })
    )
  elseif state.terminal and (opts and opts.show ~= false) then
    state.terminal:show()
    if opts.focus ~= false and state.terminal:is_running() then
      state.terminal:focus()
    end
  end

  if not state or not state.session then
    return
  end

  Util.exit_visual_mode()
  vim.schedule(function()
    msg = state.tool:format(text)
    state.session:send(msg .. "\n")
    if opts and opts.submit then
      state.session:submit()
    end
  end)
end

local function get_default_terminal()
  local file = io.open(default_terminal_file, "r")
  if file then
    local content = file:read("*a")
    file:close()
    local terminal = vim.trim(content)
    if terminal ~= "" then
      return terminal
    end
  end
  return "opencode"
end

local function set_default_terminal(name)
  local file = io.open(default_terminal_file, "w")
  if file then
    file:write(name)
    file:close()
    vim.notify("Default AI terminal set to: " .. name, vim.log.levels.INFO)
  end
end

local function get_sidekick_keys()
  local default_terminal = get_default_terminal()
  local defaults = { focus = true, filter = { name = default_terminal } }
  local keys = {
    { "<leader>at", false, mode = { "x", "n" } },
    {
      "<C-t>",
      function()
        local current_default = get_default_terminal()
        sidekick_toggle({ focus = true, filter = { name = current_default } })
      end,
    },
    {
      "<C-t>",
      function()
        local current_default = get_default_terminal()
        sidekick_send({
          focus = true,
          filter = { name = current_default },
          msg = "{file}\n\n{selection}\n",
        })
      end,
      mode = { "x" },
    },
  }
  for _, terminal in ipairs(auto_terminal_keymaps) do
    local opts = vim.tbl_deep_extend("force", defaults, { name = terminal.name })
    table.insert(keys, {
      "<leader>at" .. terminal.key,
      function()
        set_default_terminal(terminal.name)
        sidekick_toggle(opts)
      end,
      desc = "Toggle " .. terminal.name .. " in sidekick (sets as default)",
      mode = { "n" },
    })
    table.insert(keys, {
      "<leader>at" .. terminal.key,
      function()
        sidekick_send(vim.tbl_extend("force", opts, {
          msg = "{file}\n\n{selection}\n",
        }))
      end,
      desc = "Send selection to " .. terminal.name .. " in sidekick",
      mode = { "x" },
    })
    table.insert(keys, {
      "<leader>al" .. terminal.key,
      function()
        sidekick_send(vim.tbl_extend("force", opts, {
          msg = "{file}\n",
        }))
      end,
      desc = "Send file to " .. terminal.name,
    })
    table.insert(keys, {
      "<leader>ad" .. terminal.key,
      function()
        sidekick_send(vim.tbl_extend("force", opts, {
          msg = "{diagnostics}\n",
        }))
      end,
      desc = "Send diagnostics to " .. terminal.name,
      mode = { "n", "x" },
    })
  end

  -- Add <space> keymaps for the default terminal
  table.insert(keys, {
    "<leader>at<space>",
    function()
      local current_default = get_default_terminal()
      sidekick_toggle({ focus = true, filter = { name = current_default } })
    end,
    desc = "Toggle default terminal in sidekick",
    mode = { "n" },
  })
  table.insert(keys, {
    "<leader>at<space>",
    function()
      local current_default = get_default_terminal()
      sidekick_send({
        focus = true,
        filter = { name = current_default },
        msg = "{file}\n\n{selection}\n",
      })
    end,
    desc = "Send selection to default terminal in sidekick",
    mode = { "x" },
  })
  table.insert(keys, {
    "<leader>al<space>",
    function()
      local current_default = get_default_terminal()
      sidekick_send({
        focus = true,
        filter = { name = current_default },
        msg = "{file}\n",
      })
    end,
    desc = "Send file to default terminal",
  })
  table.insert(keys, {
    "<leader>ad<space>",
    function()
      local current_default = get_default_terminal()
      sidekick_send({
        focus = true,
        filter = { name = current_default },
        msg = "{diagnostics}\n",
      })
    end,
    desc = "Send diagnostics to default terminal",
    mode = { "n", "x" },
  })

  return keys
end

return {
  {
    "folke/sidekick.nvim",
    url = "https://github.com/aweis89/sidekick.nvim",
    opts = { ---@type sidekick.Config
      cli = {
        mux = {
          enabled = true,
          backend = pick_mux_backend(),
        },
        tools = {
          opencode = {
            keys = { prompt = { "<a-p>", "prompt" } },
            env = {
              OPENCODE_MODEL = vim.env.OPENCODE_MODEL or "cursor-acp/sonnet-4.5",
            },
          },
        },
        win = {
          layout = vim.o.columns > 300 and "right" or "float",
          ---@type vim.api.keyset.win_config
          float = {
            width = 1.0,
            height = 1.0,
          },
          split = {
            width = 0.5, -- set to 0 for default split width
          },
          keys = {
            hide_ctrl_t = { "<C-t>", "hide", mode = "nt", desc = "hide the terminal window" },
          },
        },
      },
    },
    keys = use_terminal_ai and {
      { "<leader>a", false, mode = { "n", "v" } },
      { "<leader>aa", false },
      { "<leader>ac", false },
      { "<leader>as", false, mode = { "n", "v" } },
      { "<leader>ap", false, mode = { "n", "v" } },
      { "<leader>at", false, mode = { "n", "v" } },
      { "<c-.>", false, mode = { "n", "x", "i", "t" } },
    } or get_sidekick_keys(),
    config = function(_, opts)
      require("sidekick").setup(opts)

      local function kill_session(state)
        if not state or not state.session then
          return
        end

        pcall(function()
          require("sidekick.cli").close()
        end)

        if state.session.mux_session and (state.session.mux_backend == "tmux" or state.session.backend == "tmux") then
          if vim.fn.executable("tmux") == 1 then
            -- Kill tmux session using vim.system
            vim.system({ "tmux", "kill-session", "-t", state.session.mux_session })
          end
        else
          pcall(function()
            require("sidekick.cli.state").detach(state)
          end)
        end
      end

      vim.api.nvim_create_autocmd("VimLeavePre", {
        callback = function()
          local ok, sidekick_state = pcall(require, "sidekick.cli.state")
          if not ok then
            return
          end

          local attached = sidekick_state.get({ attached = true })
          for _, state in ipairs(attached) do
            kill_session(state)
          end
        end,
      })
    end,
  },
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
    "aweis89/ai-terminals.nvim",
    enabled = use_terminal_ai,
    lazy = false,
    dir = (function()
      local local_dir = vim.fn.expand("~/p/ai-terminals.nvim")
      if vim.fn.isdirectory(local_dir) == 1 then
        return local_dir
      end
      return nil
    end)(),
    opts = function()
      return {
        trigger_formatting = {
          enabled = true,
        },
        auto_terminal_keymaps = {
          enabled = true,
          terminals = auto_terminal_keymaps,
        },
        enable_diffing = true,
        default_position = "right",
        terminals = {
          codex = {
            cmd = "direnv exec ~/.local/bin/codex --full-auto -s danger-full-access",
          },
          cursor = {
            cmd = "direnv exec ~/.local/bin/cursor-agent",
          },
        },
      }
    end,
    keys = {
      {
        "<leader>dva",
        function()
          require("ai-terminals").diff_changes()
        end,
        desc = "Show diff of last AI changes (using neovim diff)",
      },
      {
        "<leader>dvt",
        function()
          require("ai-terminals").diff_changes({ delta = true })
        end,
        desc = "Show diff of last AI changes using terminal cmd",
      },
      {
        "<leader>dvr",
        function()
          require("ai-terminals").revert_changes()
        end,
        desc = "Revert AI changes from backup",
      },
      {
        "<leader>aC",
        function()
          require("ai-terminals").aider_comment("AI?")
        end,
        desc = "Add 'AI?' comment above line",
      },
      {
        "<leader>aR",
        function()
          require("ai-terminals").add_files_to_terminal("aider", { vim.fn.expand("%") }, { read_only = true })
        end,
        desc = "Add current file to Aider (read-only)",
      },
      {
        "<leader>ax",
        function()
          require("ai-terminals").destroy_all()
        end,
        desc = "Close all AI terminals",
      },
      {
        "<leader>af",
        function()
          require("ai-terminals").focus()
        end,
        desc = "Focus AI terminal",
      },
    },
  },
}
