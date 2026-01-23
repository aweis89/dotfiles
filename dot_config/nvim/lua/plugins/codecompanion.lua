return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        actions = {
          codecompanion_send = function(picker)
            local selected = picker:selected({ fallback = true })
            if selected and #selected > 0 then
              local files = {}
              for _, item in ipairs(selected) do
                if item.file then
                  table.insert(files, item.file)
                end
              end
              picker:close()
              local chat = require("codecompanion").last_chat() or require("codecompanion").chat()
              local helpers = require("codecompanion.interactions.chat.helpers")
              for _, file in ipairs(files) do
                local content, id = helpers.format_file_for_llm(file)
                chat:add_context({ content = content }, "snacks", id, { path = file })
              end
            end
          end,
        },
        win = {
          input = {
            keys = {
              ["<localleader>r"] = { "codecompanion_send", mode = { "n", "i" } },
            },
          },
        },
      },
    },
  },
  {
    "olimorris/codecompanion.nvim",
    cmd = { "CodeCompanionChat" },
    keys = {
      {
        "<LocalLeader>a",
        "<cmd>CodeCompanionChat Toggle<cr>",
        desc = "CodeCompanion Chat Toggle",
        mode = { "n", "v" },
      },
      { "ga", "<cmd>CodeCompanionChat Add<cr>", desc = "CodeCompanion Chat Add", mode = "v" },
      { "<leader>fa", "<cmd>CodeCompanionActions<cr>", desc = "CodeCompanion Actions", mode = { "n", "v" } },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "franco-ruggeri/codecompanion-spinner.nvim",
      "ravitemer/codecompanion-history.nvim",
    },
    opts = {
      extensions = {
        history = {
          enabled = true,
          opts = {
            -- Keymap to open history from chat buffer (default: gh)
            keymap = "gh",
            -- Keymap to save the current chat manually (when auto_save is disabled)
            save_chat_keymap = "sc",
            -- Save all chats by default (disable to save only manually using 'sc')
            auto_save = true,
            -- Number of days after which chats are automatically deleted (0 to disable)
            expiration_days = 0,
            -- Picker interface (auto resolved to a valid picker)
            picker = "snacks", --- ("telescope", "snacks", "fzf-lua", or "default")
            picker_keymaps = {
              rename = { n = "r", i = "<localleader>r" },
              delete = { n = "d", i = "<localleader>d" },
              duplicate = { n = "<C-y>", i = "<C-y>" },
            },
            ---Automatically generate titles for new chats
            auto_generate_title = true,
            title_generation_opts = {
              ---Adapter for generating titles (defaults to current chat adapter)
              adapter = "copilot", -- "copilot"
              ---Model for generating titles (defaults to current chat model)
              model = "claude-haiku-4.5", -- "gpt-4o"
              ---Number of user prompts after which to refresh the title (0 to disable)
              refresh_every_n_prompts = 0, -- e.g., 3 to refresh after every 3rd user prompt
              ---Maximum number of times to refresh the title (default: 3)
              max_refreshes = 3,
              format_title = function(original_title)
                -- this can be a custom function that applies some custom
                -- formatting to the title.
                return original_title
              end,
            },
            ---On exiting and entering neovim, loads the last chat on opening chat
            continue_last_chat = false,
            ---When chat is cleared with `gx` delete the chat from history
            delete_on_clearing_chat = true,
            ---Directory path to save the chats
            dir_to_save = vim.fn.stdpath("data") .. "/codecompanion-history",
            ---Enable detailed logging for history extension
            enable_logging = false,

            -- Summary system
            summary = {
              -- Keymap to generate summary for current chat (default: "gcs")
              create_summary_keymap = "gcs",
              -- Keymap to browse summaries (default: "gbs")
              browse_summaries_keymap = "gbs",

              generation_opts = {
                adapter = nil, -- defaults to current chat adapter
                model = nil, -- defaults to current chat model
                context_size = 90000, -- max tokens that the model supports
                include_references = true, -- include slash command content
                include_tool_outputs = true, -- include tool execution results
                system_prompt = nil, -- custom system prompt (string or function)
                format_summary = nil, -- custom function to format generated summary e.g to remove <think/> tags from summary
              },
            },

            -- Memory system (requires VectorCode CLI)
            memory = {
              -- Automatically index summaries when they are generated
              auto_create_memories_on_summary_generation = true,
              -- Path to the VectorCode executable
              vectorcode_exe = "vectorcode",
              -- Tool configuration
              tool_opts = {
                -- Default number of memories to retrieve
                default_num = 10,
              },
              -- Enable notifications for indexing progress
              notify = true,
              -- Index all existing memories on startup
              -- (requires VectorCode 0.6.12+ for efficient incremental indexing)
              index_on_startup = false,
            },
          },
        },
        spinner = {},
      },
      adapters = {
        acp = {
          opencode = function()
            return require("codecompanion.adapters").extend("opencode", {
              env = {
                OPENCODE_MODEL = vim.env.OPENCODE_MODEL,
              },
            })
          end,
        },
      },
      strategies = {
        chat = {
          adapter = "opencode",
          opts = {
            system_prompt = "",
          },
          keymaps = {
            send = {
              modes = { n = "<CR>", i = "<CR>" },
            },
            close = {
              modes = { n = "q" },
            },
            select_model = {
              modes = { n = "gm" },
              description = "Select Model",
              callback = function(chat)
                if not chat.acp_connection then
                  vim.notify("No ACP connection", vim.log.levels.WARN)
                  return
                end
                vim.system({ "opencode", "models", "cursor" }, { text = true }, function(result)
                  vim.schedule(function()
                    if result.code ~= 0 then
                      vim.notify("Failed to fetch models: " .. (result.stderr or ""), vim.log.levels.ERROR)
                      return
                    end
                    local models = {}
                    for line in result.stdout:gmatch("[^\r\n]+") do
                      if line:match("^cursor/") then
                        table.insert(models, line)
                      end
                    end
                    vim.ui.select(models, { prompt = "Select Model:" }, function(choice)
                      if choice then
                        chat.acp_connection:set_model(choice)
                        vim.notify("Model set to: " .. choice)
                      end
                    end)
                  end)
                end)
              end,
            },
          },
        },
        inline = {
          adapter = "copilot",
          model = "opus",
        },
        cmd = {
          adapter = "copilot",
          model = "opus",
        },
      },
      interactions = {
        chat = {
          tools = {
            opts = {
              default_tools = {
                "full_stack_dev",
              },
            },
          },
        },
      },
      display = {
        chat = {
          fold_context = true,
          icons = {
            chat_context = "📎️", -- You can also apply an icon to the fold
          },
          window = {
            layout = "buffer", -- float|vertical|horizontal|buffer
            relative = "editor",
            width = 1.0, -- 1.0 => full editor width
            height = 1.0, -- 1.0 => full editor height
            border = "none", -- optional: "single", "double", "none", etc.
            title = "CodeCompanion",
            opts = { -- window options applied to the buffer
              breakindent = true,
              linebreak = true,
              wrap = true,
            },
          },
        },
      },
    },
  },
}
