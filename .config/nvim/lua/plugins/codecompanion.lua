local fmt = string.format

local constants = {
  LLM_ROLE = "llm",
  USER_ROLE = "user",
  SYSTEM_ROLE = "system",
}

function readFiles(directory, extension)
  local result = {}

  -- Check if directory exists
  local cmd = string.format("test -d '%s'", directory)
  local ret = os.execute(cmd)
  if not ret then
    error(string.format("Error: %s is not a valid directory", directory))
  end

  -- Find all files with the given extension
  local find_cmd = string.format("find '%s' -type f -name '*.%s'", directory, extension)
  local find = io.popen(find_cmd)
  if not find then
    error("Failed to execute find command")
  end

  -- Process each file
  for filepath in find:lines() do
    local cat = io.popen(string.format("cat '%s'", filepath))
    if cat then
      table.insert(result, "### " .. filepath .. "\n\n")
      table.insert(result, cat:read("*all"))
      table.insert(result, "\n\n================================================================================\n\n")
      cat:close()
    end
  end

  find:close()
  return table.concat(result)
end

return {
  {
    "echasnovski/mini.diff",
    config = function()
      local diff = require("mini.diff")
      diff.setup({
        -- Disabled by default
        source = diff.gen_source.none(),
      })
    end,
  },
  {
    "olimorris/codecompanion.nvim",
    -- dir = "/Users/aaron.weisberg/p/codecompanion.nvim",
    config = true,
    opts = {
      strategies = {
        chat = {
          adapter = "anthropic",
          roles = { llm = "  Anthropic", user = "Anthropic" },
        },
        inline = { adapter = "anthropic" },
        agent = {
          adapter = "anthropic",
        },
      },

      adapters = {
        anthropic = function()
          return require("codecompanion.adapters").extend("anthropic", {
            schema = {
              model = {
                default = "claude-3-5-sonnet-20241022",
              },
            },
          })
        end,
      },

      display = {
        diff = {
          close_chat_at = 500,
          provider = "mini_diff",
        },
        chat = {
          window = {
            layout = "float", -- float|vertical|horizontal|buffer
            height = 100,
            width = 100,
          },
        },
      },
      opts = {
        log_level = "DEBUG",
      },
    },

    init = function()
      -- Expand 'cc' into 'CodeCompanion' in the command line
      vim.cmd([[cab cc CodeCompanion]])
      require("legendary").keymaps({
        {
          itemgroup = "CodeCompanion",
          icon = "",
          description = "Use the power of AI...",
          keymaps = {
            {
              "<leader>ac",
              "<cmd>CodeCompanionActions<CR>",
              description = "Open the CodeCompanion action picker",
              mode = { "n", "v" },
            },
            {
              "<leader>aa",
              "<cmd>CodeCompanionChat toggle<CR>",
              description = "Open CodeCompanion chat prompt",
              mode = { "n", "v" },
            },
            {
              "<leader>aA",
              "<cmd>CodeCompanionChat<CR>",
              description = "Open CodeCompanion chat prompt",
              mode = { "n", "v" },
            },
            {
              "ga",
              "<cmd>CodeCompanionChat add<CR>",
              description = "Add selected text to CodeCompanion",
              mode = { "n", "v" },
            },
          },
        },
      })
    end,
  },
}
