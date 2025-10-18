local AiderModels = {
  { model = "github_copilot/gemini-2.5-pro", alias = "copilot-gemini" },
  { model = "github_copilot/claude-sonnet-4.5", alias = "copilot-sonnet-4" },
  { model = "github_copilot/gpt-5", alias = "copilot-gpt-5" },
}

local function get_cache_filepath(key)
  return vim.fn.stdpath("state") .. "/" .. key .. ".txt"
end

local function read_cache(key)
  local filepath = get_cache_filepath(key)
  if vim.fn.filereadable(filepath) == 1 then
    local lines = vim.fn.readfile(filepath)
    if #lines > 0 and lines[1] ~= nil and lines[1] ~= "" then
      return vim.fn.trim(lines[1])
    end
  end
  return nil
end

local function write_cache(key, value)
  local filepath = get_cache_filepath(key)
  vim.fn.writefile({ value }, filepath)
end

local function get_use_terminal_ai()
  local cached = read_cache("use-terminal-ai")
  if cached == "false" then
    return false
  end
  return true
end

local function toggle_ai_plugin()
  local current = get_use_terminal_ai()
  local new_value = not current
  write_cache("use-terminal-ai", tostring(new_value))
  local plugin_name = new_value and "terminal-ai" or "sidekick"
  vim.notify(
    string.format("Switched to %s. Please restart Neovim for changes to take effect.", plugin_name),
    vim.log.levels.WARN
  )
end

local function select_aider_model_picker()
  local picker_items = {}
  for _, entry in ipairs(AiderModels) do
    local display_text = entry.alias or entry.model
    if entry.alias and entry.alias ~= entry.model then
      display_text = entry.alias .. " (" .. entry.model .. ")"
    end
    table.insert(picker_items, {
      text = display_text,
      model = entry.model,
      alias = entry.alias,
    })
  end

  Snacks.picker.pick({
    items = picker_items,
    format = "text",
    layout = {
      title = "Select Aider Model",
      layout = { width = 5, height = 20 },
    },
    preview = function()
      return false
    end,
    confirm = function(_, selected_item)
      if selected_item and selected_item.model then
        local model_to_write = selected_item.model
        local notify_msg = "Aider model set to: " .. model_to_write
        if selected_item.alias and selected_item.alias ~= model_to_write then
          notify_msg = notify_msg .. " (selected via alias: " .. selected_item.alias .. ")"
        end
        vim.notify(notify_msg)
        write_cache("aider-model", model_to_write)
        require("ai-terminals").destroy_all()
        require("ai-terminals").toggle("aider")
      end
    end,
  })
end

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
  local keys = { { "<leader>at", false, mode = { "x", "n" } } }
  for _, terminal in ipairs(auto_terminal_keymaps) do
    table.insert(keys, {
      "<leader>at" .. terminal.key,
      function()
        require("sidekick.cli").toggle({ name = terminal.name, focus = true })
      end,
      desc = "Toggle " .. terminal.name .. " in sidekick",
      mode = { "n" },
    })
    table.insert(keys, {
      "<leader>at" .. terminal.key,
      function()
        require("sidekick.cli").send({ name = terminal.name, focus = true })
      end,
      desc = "Send selection to " .. terminal.name .. " in sidekick",
      mode = { "x" },
    })
    table.insert(keys, {
      "<leader>al" .. terminal.key,
      function()
        require("sidekick.cli").send({ msg = "{file}", name = terminal.name, focus = true })
      end,
      desc = "Send file to " .. terminal.name,
    })
  end
  return keys
end

return {
  {
    "folke/sidekick.nvim",
    opts = {
      cli = {
        win = {
          layout = "float",
          keys = {
            hide_ctrl_q = { "<c-h>", "hide", mode = "nt", desc = "hide the terminal window" },
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
          aider = {
            cmd = function()
              local cmd_parts = {
                "direnv",
                "exec",
                "~/.config/bin/aider",
                "--watch-files --no-auto-commits",
                string.format("--%s-mode", vim.o.background),
              }
              local selected_model_name = read_cache("aider-model")

              if selected_model_name and selected_model_name ~= "" then
                table.insert(cmd_parts, "--model")
                table.insert(cmd_parts, "'" .. selected_model_name .. "'")
              end
              return table.concat(cmd_parts, " ")
            end,
          },
        },
      }
    end,
    keys = {
      {
        "<leader>am",
        function()
          select_aider_model_picker()
        end,
        desc = "Select Aider Model (Picker)",
      },
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
      {
        "<leader>aT",
        toggle_ai_plugin,
        desc = "Toggle between terminal-ai and sidekick",
      },
    },
  },
}
