local AiderModels = {
  { model = "openai/gemini-2.5-pro", alias = "copilot-gemini" },
  { model = "openai/claude-sonnet-4", alias = "copilot-sonnet-4" },
  { model = "openai/claude-sonnet-4-thought", alias = "copilot-sonnet-4" },
  { model = "openai/gpt-5", alias = "copilot-gpt-5" },
  { model = "vertex_ai/claude-sonnet-4", alias = "vertex-sonnet-4" },
  { model = "vertex_ai/claude-opus-4", alias = "vertex-opus-4" },
  { model = "gemini/gemini-2.5-pro" },
  { model = "o4-mini", openai_env_key = "OPENAI_API_KEY_ORIG" },
}

-- Function to get the full path for a cache file
local function get_cache_filepath(key)
  return vim.fn.stdpath("state") .. "/" .. key .. ".txt"
end

-- Read a value from cache
local function read_cache(key)
  local filepath = get_cache_filepath(key)
  if vim.fn.filereadable(filepath) == 1 then
    local lines = vim.fn.readfile(filepath)
    if #lines > 0 and lines[1] ~= nil and lines[1] ~= "" then
      return vim.fn.trim(lines[1]) -- Trim whitespace
    end
  end
  return nil
end

-- Write a value to cache
local function write_cache(key, value)
  local filepath = get_cache_filepath(key)
  vim.fn.writefile({ value }, filepath)
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
    confirm = function(_, selected_item) -- First arg is picker instance, we don't need it
      if selected_item and selected_item.model then
        local model_to_write = selected_item.model
        local notify_msg = "Aider model set to: " .. model_to_write
        if selected_item.alias and selected_item.alias ~= model_to_write then
          notify_msg = notify_msg .. " (selected via alias: " .. selected_item.alias .. ")"
        end
        vim.notify(notify_msg)
        write_cache("aider-model", model_to_write)
        -- restart aider
        require("ai-terminals").destroy_all()
        require("ai-terminals").toggle("aider")
      end
    end,
  })
end

return {
  {
    "aweis89/ai-terminals.nvim",
    lazy = false,
    -- dir = "~/p/ai-terminals.nvim",
    opts = function()
      return {
        watch_cwd = {
          enabled = true,
        },
        trigger_formatting = {
          enabled = true,
        },
        auto_terminal_keymaps = {
          enabled = true,
          terminals = {
            { name = "aider", key = "a" },
            { name = "claude", key = "c" },
            { name = "codex", key = "d" },
            { name = "cursor", key = "s" },
            { name = "gemini", key = "g" },
            { name = "opencode", key = "o" },
          },
        },
        enable_diffing = true,
        default_position = "right",
        -- show_diffs_on_leave = { delta = true },
        terminals = {
          goose = {
            cmd = function()
              return string.format("unset GITHUB_TOKEN; GOOSE_CLI_THEME=%s goose", vim.o.background)
            end,
          },
          claude = {
            cmd = function()
              local claude_path = "~/.config/bin/claude"
              return string.format(
                "%s config set -g theme %s && direnv exec %s --permission-mode default",
                claude_path,
                vim.o.background,
                claude_path
              )
            end,
          },
          codex = {
            cmd = "direnv exec ~/.local/bin/codex --full-auto -s danger-full-access",
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

                -- Check for openai_env_key for the selected model
                for _, model_entry in ipairs(AiderModels) do
                  if model_entry.model == selected_model_name and model_entry.openai_env_key then
                    local api_key = vim.fn.getenv(model_entry.openai_env_key)
                    if api_key and api_key ~= "" then
                      table.insert(cmd_parts, "--openai-api-key")
                      table.insert(cmd_parts, api_key)
                    end
                    break -- Found the model, no need to continue loop
                  end
                end
              end
              return table.concat(cmd_parts, " ")
            end,
          },
        },
      }
    end,
    keys = {
      -- Aider model selection
      {
        "<leader>am",
        function()
          select_aider_model_picker()
        end,
        desc = "Select Aider Model (Picker)",
      },
      -- Diff Tools
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
        "<leader>dvr", -- Mnemonic: Diff View Revert
        function()
          require("ai-terminals").revert_changes()
        end,
        desc = "Revert AI changes from backup",
      },
      {
        "<leader>aC",
        function()
          require("ai-terminals").aider_comment("AI?") -- Adds comment and saves file
        end,
        desc = "Add 'AI?' comment above line",
      },
      {
        "<leader>aR", -- Mnemonic: AI add Read-only
        function()
          require("ai-terminals").add_files_to_terminal("aider", { vim.fn.expand("%") }, { read_only = true })
        end,
        desc = "Add current file to Aider (read-only)",
      },
      {
        "<leader>ax", -- Mnemonic: AI Close (X) all terminals
        function()
          require("ai-terminals").destroy_all()
        end,
        desc = "Close all AI terminals",
      },
      {
        "<leader>af", -- Mnemonic: AI focus
        function()
          require("ai-terminals").focus()
        end,
        desc = "Focus AI terminal",
      },
    },
  },
}
