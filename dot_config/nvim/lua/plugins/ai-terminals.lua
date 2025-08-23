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

-- extract jira id from branch name
-- e.g PR-1234-ticket becomes PR-1234
local function jira_id_from_branch()
  local branch = vim.fn.trim(vim.fn.system("git branch --show-current"))
  if vim.v.shell_error ~= 0 then
    return nil
  end

  -- Match patterns like XX-1234 or XXX-1234 or PLATFORM-12345
  local jira_id = string.match(branch, "(%u+%-%d+)")
  return jira_id
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

-- Helper function to create terminal keymaps
local function create_terminal_keymaps(terminals)
  local keymaps = {}

  for _, terminal in ipairs(terminals) do
    local name = terminal.name
    local key = terminal.key
    local display_name = terminal.display_name or name:gsub("^%l", string.upper)

    -- Toggle terminal keymap
    table.insert(keymaps, {
      "<leader>at" .. key,
      function()
        require("ai-terminals").toggle(name)
      end,
      desc = "Toggle " .. display_name .. " terminal",
      mode = { "n", "v" },
    })

    -- Send diagnostics keymap
    table.insert(keymaps, {
      "<leader>ad" .. key,
      function()
        require("ai-terminals").send_diagnostics(name)
      end,
      desc = "Send diagnostics to " .. display_name,
      mode = { "n", "v" },
    })

    -- Add current file keymap
    table.insert(keymaps, {
      "<leader>al" .. key,
      function()
        require("ai-terminals").add_files_to_terminal(name, { vim.fn.expand("%") })
      end,
      desc = "Add current file to " .. display_name,
    })

    -- Add all buffers keymap
    table.insert(keymaps, {
      "<leader>aL" .. key,
      function()
        require("ai-terminals").add_buffers_to_terminal(name)
      end,
      desc = "Add all buffers to " .. display_name,
    })

    -- Send command output keymap
    table.insert(keymaps, {
      "<leader>ar" .. key,
      function()
        require("ai-terminals").send_command_output(name)
      end,
      desc = "Run command and send output to " .. display_name,
    })
  end

  return keymaps
end

return {
  {
    "aweis89/ai-terminals.nvim",
    dir = "~/p/ai-terminals.nvim",
    ---@type fun(): ConfigType
    opts = function()
      return {
        -- backend = "tmux",
        terminal_keymaps = {
          {
            key = "<localleader>j",
            action = function()
              vim.schedule(function()
                local ticket = jira_id_from_branch()
                if not ticket then
                  vim.notify("No Jira ticket found in branch name", vim.log.levels.WARN)
                end
                vim.system({ "jira", "issue", "view", "--plain", ticket }, {}, function(result)
                  if result and result.stdout and #result.stdout > 0 then
                    vim.schedule(function()
                      require("ai-terminals").send(result.stdout)
                    end)
                  else
                    vim.notify("No Jira ticket found in branch name", vim.log.levels.WARN)
                  end
                end)
              end)
            end,
            modes = { "n" },
            desc = "Get Jira ticket",
          },
        },
        enable_diffing = true,
        default_position = "right",
        -- show_diffs_on_leave = { delta = true },
        terminals = {
          env = {
            PAGER = "cat",
            GOOGLE_CLOUD_LOCATION = function()
              return vim.env.GOOGLE_CLOUD_LOCATION
            end,
            GOOGLE_CLOUD_PROJECT = function()
              return vim.env.GOOGLE_CLOUD_PROJECT
            end,
          },
          goose = {
            cmd = function()
              return string.format("unset GITHUB_TOKEN; GOOSE_CLI_THEME=%s goose", vim.o.background)
            end,
          },
          claude = {
            cmd = function()
              local claude_path = "~/.config/bin/claude"
              return string.format("%s config set -g theme %s && %s", claude_path, vim.o.background, claude_path)
            end,
          },
          codex = {
            cmd = "~/.local/bin/codex --full-auto -s danger-full-access",
          },
          aider = {
            cmd = function()
              local cmd_parts = {
                "~/.config/bin/aider",
                "--watch-files",
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
    keys = vim.list_extend(
      {
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
          "<leader>ac",
          function()
            require("ai-terminals").aider_comment("AI!") -- Adds comment and saves file
          end,
          desc = "Add 'AI!' comment above line",
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
      create_terminal_keymaps({
        { name = "aider", key = "a" },
        { name = "claude", key = "c" },
        { name = "codex", key = "d" },
        { name = "cursor", key = "s" },
        { name = "gemini", key = "g" },
        { name = "goose", key = "o" },
      })
    ),
  },
}
