local use_terminal_ai = false

local auto_terminal_keymaps = {
  { name = "aider", key = "a" },
  { name = "claude", key = "c" },
  { name = "codex", key = "d" },
  { name = "cursor", key = "<space>" },
  { name = "gemini", key = "g" },
  { name = "opencode", key = "o" },
}

local function get_sidekick_keys()
  local default_terminal = "claude"
  local defaults = { focus = true }
  local keys = {
    { "<leader>at", false, mode = { "x", "n" } },
    {
      "<C-t>",
      function()
        require("sidekick.cli").toggle(vim.tbl_deep_extend("force", defaults, {
          name = default_terminal,
        }))
      end,
    },
    {
      "<C-t>",
      function()
        require("sidekick.cli").send(vim.tbl_deep_extend("force", defaults, {
          name = default_terminal,
          msg = "{file}\n\n{selection}\n",
        }))
      end,
      mode = { "x" },
    },
  }
  for _, terminal in ipairs(auto_terminal_keymaps) do
    local opts = vim.tbl_deep_extend("force", defaults, { name = terminal.name })
    table.insert(keys, {
      "<leader>at" .. terminal.key,
      function()
        require("sidekick.cli").toggle(opts)
      end,
      desc = "Toggle " .. terminal.name .. " in sidekick",
      mode = { "n" },
    })
    table.insert(keys, {
      "<leader>at" .. terminal.key,
      function()
        require("sidekick.cli").send(vim.tbl_extend("force", opts, {
          msg = "{file}\n\n{selection}\n",
        }))
      end,
      desc = "Send selection to " .. terminal.name .. " in sidekick",
      mode = { "x" },
    })
    table.insert(keys, {
      "<leader>al" .. terminal.key,
      function()
        require("sidekick.cli").send(vim.tbl_extend("force", opts, {
          msg = "{file}\n",
        }))
      end,
      desc = "Send file to " .. terminal.name,
    })
    table.insert(keys, {
      "<leader>ad" .. terminal.key,
      function()
        require("sidekick.cli").send(vim.tbl_extend("force", opts, {
          msg = "{diagnostics}\n",
        }))
      end,
      desc = "Send diagnostics to " .. terminal.name,
      mode = { "n", "x" },
    })
  end
  return keys
end

return {
  {
    "folke/sidekick.nvim",
    -- url = "https://github.com/aweis89/sidekick.nvim",
    opts = { ---@type sidekick.Config
      cli = {
        mux = {
          enabled = true,
        },
        tools = {
          opencode = {
            keys = { prompt = { "<a-p>", "prompt" } },
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

        if state.session.mux_session then
          -- Kill tmux session using vim.system
          vim.system({ "tmux", "kill-session", "-t", state.session.mux_session })
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
