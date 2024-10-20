-- look at coding.lua
if true then
  return {}
end

return {
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        { "<leader>a", group = "ai", mode = { "n", "v" } },
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "yaml", "markdown" } },
  },
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "hrsh7th/nvim-cmp", -- Optional: For using slash commands and variables in the chat buffer
      "nvim-telescope/telescope.nvim", -- Optional: For using slash commands
    },
    cmd = { "CodeCompanionActions", "CodeCompanionChat", "CodeCompanion" },
    config = function()
      local config = require("codecompanion.config")
      local strategies = require("codecompanion.strategies")
      local prompt_library = require("codecompanion.prompt_library")

      -- Import the variables from the config file
      local SYSTEM_PROMPT = config.SYSTEM_PROMPT
      local COPILOT_EXPLAIN = config.COPILOT_EXPLAIN
      local COPILOT_REVIEW = config.COPILOT_REVIEW
      local COPILOT_REFACTOR = config.COPILOT_REFACTOR
      local mapping_key_prefix = config.mapping_key_prefix

      require("codecompanion").setup({
        strategies = {
          chat = {
            adapter = "copilot",
            roles = { llm = "  Copilot Chat", user = "CodeCompanion" },
            slash_commands = {
              ["buffer"] = {
                callback = "helpers.slash_commands.buffer",
                description = "Insert open buffers",
                opts = {
                  contains_code = true,
                  provider = "telescope", -- default|telescope|mini_pick|fzf_lua
                },
              },
              ["file"] = {
                callback = "helpers.slash_commands.file",
                description = "Insert a file",
                opts = {
                  contains_code = true,
                  max_lines = 1000,
                  provider = "telescope", -- telescope|mini_pick|fzf_lua
                },
              },
            },
            keymaps = {
              send = {
                modes = {
                  n = "<CR>",
                  i = "<C-s>",
                },
                index = 1,
                callback = "keymaps.send",
                description = "Send",
              },
              close = {
                modes = {
                  n = "q",
                },
                index = 3,
                callback = "keymaps.close",
                description = "Close Chat",
              },
              stop = {
                modes = {
                  n = "<C-c>",
                },
                index = 4,
                callback = "keymaps.stop",
                description = "Stop Request",
              },
            },
          },
          inline = { adapter = "copilot" },
          agent = { adapter = "copilot" },
        },
        inline = {
          layout = "buffer", -- vertical|horizontal|buffer
        },
        display = {
          chat = {
            -- Change to true to show the current model
            show_settings = false,
            window = {
              layout = "buffer", -- float|vertical|horizontal|buffer
              height = 90,
              width = 90,
            },
          },
        },
        log_level = "DEBUG",
        system_prompt = SYSTEM_PROMPT,
        prompt_library = {
          -- Custom the default prompt
          ["Generate a Commit Message"] = {
            prompts = {
              {
                role = "user",
                content = function()
                  return "Write commit message with commitizen convention. Write clear, informative commit messages that explain the 'what' and 'why' behind changes, not just the 'how'."
                    .. "\n\n```\n"
                    .. vim.fn.system("git diff")
                    .. "\n```"
                end,
                opts = {
                  contains_code = true,
                },
              },
            },
          },
          ["Explain"] = {
            strategy = "chat",
            description = "Explain how code in a buffer works",
            opts = {
              index = 4,
              default_prompt = true,
              mapping = "<LocalLeader>ce",
              modes = { "v" },
              slash_cmd = "explain",
              auto_submit = true,
              user_prompt = false,
              stop_context_insertion = true,
            },
            prompts = {
              {
                role = "system",
                content = COPILOT_EXPLAIN,
                opts = {
                  visible = false,
                },
              },
              {
                role = "user",
                content = function(context)
                  local code = require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)

                  return "Please explain how the following code works:\n\n```"
                    .. context.filetype
                    .. "\n"
                    .. code
                    .. "\n```\n\n"
                end,
                opts = {
                  contains_code = true,
                },
              },
            },
          },
          -- Add custom prompts
          ["Generate a Commit Message for Staged"] = {
            strategy = "chat",
            description = "Generate a commit message for staged change",
            opts = {
              index = 9,
              mapping = "<LocalLeader>cM",
              slash_cmd = "staged-commit",
              auto_submit = true,
            },
            prompts = {
              {
                role = "user",
                content = function()
                  return "Write commit message for the change with commitizen convention. Write clear, informative commit messages that explain the 'what' and 'why' behind changes, not just the 'how'."
                    .. "\n\n```\n"
                    .. vim.fn.system("git diff --staged")
                    .. "\n```"
                end,
                opts = {
                  contains_code = true,
                },
              },
            },
          },
          ["Inline-Document"] = {
            strategy = "inline",
            description = "Add documentation for code.",
            opts = {
              mapping = "<LocalLeader>cd",
              modes = { "v" },
              slash_cmd = "inline-doc",
              auto_submit = true,
              user_prompt = false,
              stop_context_insertion = true,
            },
            prompts = {
              {
                role = "user",
                content = function(context)
                  local code = require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)

                  return "Please provide documentation in comment code for the following code and suggest to have better naming to improve readability.\n\n```"
                    .. context.filetype
                    .. "\n"
                    .. code
                    .. "\n```\n\n"
                end,
                opts = {
                  contains_code = true,
                },
              },
            },
          },
          ["Document"] = {
            strategy = "chat",
            description = "Write documentation for code.",
            opts = {
              mapping = "<LocalLeader>cD",
              modes = { "v" },
              slash_cmd = "doc",
              auto_submit = true,
              user_prompt = false,
              stop_context_insertion = true,
            },
            prompts = {
              {
                role = "user",
                content = function(context)
                  local code = require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)

                  return "Please brief how it works and provide documentation in comment code for the following code. Also suggest to have better naming to improve readability.\n\n```"
                    .. context.filetype
                    .. "\n"
                    .. code
                    .. "\n```\n\n"
                end,
                opts = {
                  contains_code = true,
                },
              },
            },
          },
          ["Review"] = {
            strategy = "chat",
            description = "Review the provided code snippet.",
            opts = {
              index = 11,
              mapping = "<LocalLeader>cR",
              modes = { "v" },
              slash_cmd = "review",
              auto_submit = true,
              user_prompt = false,
              stop_context_insertion = true,
            },
            prompts = {
              {
                role = "system",
                content = COPILOT_REVIEW,
                opts = {
                  visible = false,
                },
              },
              {
                role = "user",
                content = function(context)
                  local code = require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)

                  return "Please review the following code and provide suggestions for improvement then refactor the following code to improve its clarity and readability:\n\n```"
                    .. context.filetype
                    .. "\n"
                    .. code
                    .. "\n```\n\n"
                end,
                opts = {
                  contains_code = true,
                },
              },
            },
          },
          ["Refactor"] = {
            strategy = "inline",
            description = "Refactor the provided code snippet.",
            opts = {
              index = 11,
              mapping = "<LocalLeader>cr",
              modes = { "v" },
              slash_cmd = "refactor",
              auto_submit = true,
              user_prompt = false,
              stop_context_insertion = true,
            },
            prompts = {
              {
                role = "system",
                content = COPILOT_REFACTOR,
                opts = {
                  visible = false,
                },
              },
              {
                role = "user",
                content = function(context)
                  local code = require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)

                  return "Please refactor the following code to improve its clarity and readability:\n\n```"
                    .. context.filetype
                    .. "\n"
                    .. code
                    .. "\n```\n\n"
                end,
                opts = {
                  contains_code = true,
                },
              },
            },
          },
          ["Naming"] = {
            strategy = "inline",
            description = "Give betting naming for the provided code snippet.",
            opts = {
              index = 12,
              mapping = "<LocalLeader>cn",
              modes = { "v" },
              slash_cmd = "naming",
              auto_submit = true,
              user_prompt = false,
              stop_context_insertion = true,
            },
            prompts = {
              {
                role = "user",
                content = function(context)
                  local code = require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)

                  return "Please provide better names for the following variables and functions:\n\n```"
                    .. context.filetype
                    .. "\n"
                    .. code
                    .. "\n```\n\n"
                end,
                opts = {
                  contains_code = true,
                },
              },
            },
          },
        },
      })
    end,
    keys = {
      -- Recommend setup
      {
        "<leader>aa",
        "<cmd>CodeCompanionChat Toggle<cr>",
        desc = "Code Companion - Toggle",
        mode = { "n", "v" },
      },
      {
        "<leader>av",
        "<cmd>CodeCompanionActions<cr>",
        desc = "Code Companion - Actions",
      },
      {
        "<leader>aa",
        "<cmd>CodeCompanionChat Add<cr>",
        desc = "Code Companion - Add",
        mode = { "v" },
      },
      -- Some common usages with visual mode
      {
        "<leader>ae",
        "<cmd>CodeCompanion /explain<cr>",
        desc = "Code Companion - Explain code",
        mode = "v",
      },
      {
        "<leader>af",
        "<cmd>CodeCompanion /fix<cr>",
        desc = "Code Companion - Fix code",
        mode = "v",
      },
      {
        "<leader>al",
        "<cmd>CodeCompanion /lsp<cr>",
        desc = "Code Companion - Explain LSP diagnostic",
        mode = { "n", "v" },
      },
      {
        "<leader>at",
        "<cmd>CodeCompanion /tests<cr>",
        desc = "Code Companion - Generate unit test",
        mode = "v",
      },
      {
        "<leader>am",
        "<cmd>CodeCompanion /commit<cr>",
        desc = "Code Companion - Git commit message",
      },
      -- Custom prompts
      {
        "<leader>aM",
        "<cmd>CodeCompanion /staged-commit<cr>",
        desc = "Code Companion - Git commit message (staged)",
      },
      {
        "<leader>ad",
        "<cmd>CodeCompanion /inline-doc<cr>",
        desc = "Code Companion - Inline document code",
        mode = "v",
      },
      { "<leader>aD", "<cmd>CodeCompanion /doc<cr>", desc = "Code Companion - Document code", mode = "v" },
      {
        "<leader>ar",
        "<cmd>CodeCompanion /refactor<cr>",
        desc = "Code Companion - Refactor code",
        mode = "v",
      },
      {
        "<leader>aR",
        "<cmd>CodeCompanion /review<cr>",
        desc = "Code Companion - Review code",
        mode = "v",
      },
      {
        "<leader>an",
        "<cmd>CodeCompanion /naming<cr>",
        desc = "Code Companion - Better naming",
        mode = "v",
      },
      -- Quick chat
      {
        "<leader>aq",
        function()
          local input = vim.fn.input("Quick Chat: ")
          if input ~= "" then
            vim.cmd("CodeCompanion " .. input)
          end
        end,
        desc = "Code Companion - Quick chat",
      },
    },
  },
}
