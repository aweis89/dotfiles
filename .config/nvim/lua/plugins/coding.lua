global_system_prompt =
  [[You are an AI programming assistant. You are currently plugged in to the Neovim text editor on a user's machine.

Your core tasks include:
- Answering general programming questions.
- Explaining how the code in a Neovim buffer works.
- Reviewing the selected code in a Neovim buffer.
- Generating unit tests for the selected code.
- Proposing fixes for problems in the selected code.
- Scaffolding code for a new workspace.
- Finding relevant code to the user's query.
- Proposing fixes for test failures.
- Answering questions about Neovim.
- Running tools.
- If the request falls outside these tasks, always try to answer as best you can while using available tools when appropriate.

You must:
- Follow the user's requirements carefully and to the letter.
- Keep your answers short and impersonal, especially if the user responds with context outside of your tasks.
- Minimize other prose.
- Use Markdown formatting in your answers.
- Include the programming language name at the start of the Markdown code blocks.
- Avoid line numbers in code blocks.
- Avoid wrapping the whole response in triple backticks.
- Only return code that's relevant to the task at hand. You may not need to return all of the code that the user has shared.

When given a task:
1. Think step-by-step and describe your plan for what to build in pseudocode, written out in great detail, unless asked not to do so.
2. Output the code in a single code block, being careful to only return relevant code.
3. You should always generate short suggestions for the next user turns that are relevant to the conversation.
4. You can only give one reply for each conversation turn.]]

return {
  -- "tpope/vim-sleuth", -- Automatically detects which indents should be used in the current buffer
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
    config = function()
      require("codecompanion").setup({
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
                  default = "claude-3-5-sonnet-latest",
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
              height = 90,
              width = 90,
            },
          },
        },
        opts = {
          log_level = "DEBUG",
          system_prompt = global_system_prompt,
        },

        prompt_library = {
          ["Generic Chat"] = {
            strategy = "chat",
            description = "Chat about anything",
            opts = {
              mapping = "<LocalLeader>ce",
              modes = { "v" },
              short_name = "/claude",
              auto_submit = false,
              stop_context_insertion = true,
              user_prompt = true,
              global_system_prompt = "The assistant is Claude. Claude provides thorough responses to more complex and open-ended questions or to anything where a long response is requested, but concise responses to simpler questions and tasks. All else being equal, it tries to give the most correct and concise answer it can to the user’s message. Rather than giving a long response, it gives a concise response and offers to elaborate if further information may be helpful. Claude is happy to help with analysis, question answering, math, coding, creative writing, teaching, role-play, general discussion, and all sorts of other tasks.",
            },
          },
        },
      })
    end,

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
  {
    "kylechui/nvim-surround", -- Use vim commands to surround text, tags with brackets, parenthesis etc
    config = true,
  },
  {
    "ThePrimeagen/refactoring.nvim", -- Refactor code like Martin Fowler
    lazy = true,
    init = function()
      require("legendary").keymaps({
        {
          itemgroup = "Refactoring",
          icon = "",
          description = "Refactor code...",
          keymaps = {
            {
              "<LocalLeader>re",
              function()
                require("telescope").extensions.refactoring.refactors()
              end,
              description = "Open Refactoring.nvim",
              mode = { "n", "v", "x" },
            },
            {
              "<LocalLeader>rd",
              function()
                require("refactoring").debug.printf({ below = false })
              end,
              description = "Insert Printf statement for debugging",
            },
            {
              "<LocalLeader>rv",
              {
                n = function()
                  require("refactoring").debug.print_var({ normal = true })
                end,
                x = function()
                  require("refactoring").debug.print_var({})
                end,
              },
              description = "Insert Print_Var statement for debugging",
              mode = { "n", "v" },
            },
            {
              "<LocalLeader>rc",
              function()
                require("refactoring").debug.cleanup()
              end,
              description = "Cleanup debug statements",
            },
          },
        },
      })
    end,
    config = true,
  },
  {
    "zbirenbaum/copilot.lua", -- AI programming
    event = "InsertEnter",
    init = function()
      require("legendary").commands({
        itemgroup = "Copilot",
        commands = {
          {
            ":CopilotToggle",
            function()
              require("copilot.suggestion").toggle_auto_trigger()
            end,
            description = "Toggle on/off for buffer",
          },
        },
      })
      require("legendary").keymaps({
        itemgroup = "Copilot",
        description = "Copilot suggestions...",
        icon = "",
        keymaps = {
          {
            "<C-a>",
            function()
              require("copilot.suggestion").accept()
            end,
            description = "Accept suggestion",
            mode = { "i" },
          },
          {
            "<C-x>",
            function()
              require("copilot.suggestion").dismiss()
            end,
            description = "Dismiss suggestion",
            mode = { "i" },
          },
          {
            "<C-\\>",
            function()
              require("copilot.panel").open()
            end,
            description = "Show Copilot panel",
            mode = { "n", "i" },
          },
        },
      })
    end,
    opts = {
      panel = {
        auto_refresh = true,
      },
      suggestion = {
        auto_trigger = true, -- Suggest as we start typing
        keymap = {
          accept_word = "<C-l>",
          accept_line = "<C-j>",
        },
      },
    },
  },
  {
    "mfussenegger/nvim-dap", -- Debug Adapter Protocol for Neovim
    lazy = true,
    dependencies = {
      "theHamsta/nvim-dap-virtual-text", -- help to find variable definitions in debug mode
      "rcarriga/nvim-dap-ui", -- Nice UI for nvim-dap
      "suketa/nvim-dap-ruby", -- Debug Ruby
      "mfussenegger/nvim-dap-python", -- Debug Python
    },
    init = function()
      require("legendary").keymaps({
        {
          itemgroup = "Debug",
          description = "Debugging functionality...",
          icon = "",
          keymaps = {
            {
              "<F1>",
              "<cmd>lua require('dap').toggle_breakpoint()<CR>",
              description = "Set breakpoint",
            },
            { "<F2>", "<cmd>lua require('dap').continue()<CR>", description = "Continue" },
            { "<F3>", "<cmd>lua require('dap').step_into()<CR>", description = "Step into" },
            { "<F4>", "<cmd>lua require('dap').step_over()<CR>", description = "Step over" },
            {
              "<F5>",
              "<cmd>lua require('dap').repl.toggle({height = 6})<CR>",
              description = "Toggle REPL",
            },
            { "<F6>", "<cmd>lua require('dap').repl.run_last()<CR>", description = "Run last" },
            {
              "<F9>",
              function()
                local _, dap = require("dap")
                dap.disconnect()
                require("dapui").close()
              end,
              description = "Stop",
            },
          },
        },
      })
    end,
    config = function()
      local dap = require("dap")
      require("dap-ruby").setup()
      require("dap-python").setup("~/.virtualenvs/debugpy/bin/python")

      ---Show the nice virtual text when debugging
      ---@return nil|function
      local function virtual_text_setup()
        local ok, virtual_text = pcall(require, "nvim-dap-virtual-text")
        if not ok then
          return
        end

        return virtual_text.setup()
      end

      ---Show custom virtual text when debugging
      ---@return nil
      local function signs_setup()
        vim.fn.sign_define("DapBreakpoint", {
          text = "",
          texthl = "DebugBreakpoint",
          linehl = "",
          numhl = "DebugBreakpoint",
        })
        vim.fn.sign_define("DapStopped", {
          text = "",
          texthl = "DebugHighlight",
          linehl = "",
          numhl = "DebugHighlight",
        })
      end

      ---Slick UI which is automatically triggered when debugging
      ---@param adapter table
      ---@return nil
      local function ui_setup(adapter)
        local ok, dapui = pcall(require, "dapui")
        if not ok then
          return
        end

        dapui.setup({
          layouts = {
            {
              elements = {
                "scopes",
                "breakpoints",
                "stacks",
              },
              size = 35,
              position = "left",
            },
            {
              elements = {
                "repl",
              },
              size = 0.30,
              position = "bottom",
            },
          },
        })
        adapter.listeners.after.event_initialized["dapui_config"] = dapui.open
        adapter.listeners.before.event_terminated["dapui_config"] = dapui.close
        adapter.listeners.before.event_exited["dapui_config"] = dapui.close
      end

      dap.set_log_level("TRACE")

      virtual_text_setup()
      signs_setup()
      ui_setup(dap)
    end,
  },
  {
    "stevearc/overseer.nvim", -- Task runner and job management
    opts = {
      component_aliases = {
        default_neotest = {
          "on_output_summarize",
          "on_exit_set_status",
          "on_complete_dispose",
        },
      },
    },
    init = function()
      require("legendary").commands({
        {
          itemgroup = "Overseer",
          icon = "省",
          description = "Task running functionality...",
          commands = {
            {
              ":OverseerRun",
              description = "Run a task from a template",
            },
            {
              ":OverseerBuild",
              description = "Open the task builder",
            },
            {
              ":OverseerToggle",
              description = "Toggle the Overseer window",
            },
          },
        },
      })
      require("legendary").keymaps({
        itemgroup = "Overseer",
        keymaps = {
          {
            "<Leader>o",
            function()
              local overseer = require("overseer")
              local tasks = overseer.list_tasks({ recent_first = true })
              if vim.tbl_isempty(tasks) then
                vim.notify("No tasks found", vim.log.levels.WARN)
              else
                overseer.run_action(tasks[1], "restart")
              end
            end,
            description = "Run the last Overseer task",
          },
        },
      })
    end,
  },
  {
    "nvim-neotest/neotest",
    lazy = true,
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "antoinemadec/FixCursorHold.nvim",

      -- Adapters
      "nvim-neotest/neotest-plenary",
      "nvim-neotest/neotest-python",
      "olimorris/neotest-rspec",
      "olimorris/neotest-phpunit",
    },
    init = function()
      require("legendary").keymaps({
        {
          itemgroup = "Neotest",
          icon = "ﭧ",
          description = "Testing functionality...",
          keymaps = {
            -- Neotest plugin
            {
              "<LocalLeader>tn",
              function()
                require("neotest").run.run()
              end,
              description = "Test nearest",
            },
            {
              "<LocalLeader>tf",
              function()
                require("neotest").run.run(vim.fn.expand("%"))
              end,
              description = "Test file",
            },
            {
              "<LocalLeader>tl",
              function()
                require("neotest").run.run_last()
              end,
              description = "Run last test",
            },
            {
              "<LocalLeader>ts",
              function()
                local neotest = require("neotest")
                for _, adapter_id in ipairs(neotest.run.adapters()) do
                  neotest.run.run({ suite = true, adapter = adapter_id })
                end
              end,
              description = "Test suite",
            },
            {
              "<LocalLeader>to",
              function()
                require("neotest").output.open({ short = true })
              end,
              description = "Open test output",
            },
            {
              "`",
              function()
                require("neotest").summary.toggle()
              end,
              description = "Toggle test summary",
            },
            {
              "<LocalLeader>twn",
              function()
                require("neotest").watch.toggle()
              end,
              description = "Watch nearest test",
            },
            {
              "<LocalLeader>twf",
              function()
                require("neotest").watch.toggle({ vim.fn.expand("%") })
              end,
              description = "Watch file",
            },
            {
              "<LocalLeader>twa",
              function()
                require("neotest").watch.toggle({ suite = true })
              end,
              description = "Watch all tests",
            },
            {
              "<LocalLeader>twa",
              function()
                require("neotest").watch.stop()
              end,
              description = "Stop watching",
            },
          },
        },
      })
    end,
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-plenary"),
          require("neotest-python")({
            dap = { justMyCode = false },
          }),
          require("neotest-rspec"),
          require("neotest-phpunit"),
        },
        consumers = {
          overseer = require("neotest.consumers.overseer"),
        },
        diagnostic = {
          enabled = false,
        },
        log_level = vim.log.levels.TRACE,
        icons = {
          expanded = "",
          child_prefix = "",
          child_indent = "",
          final_child_prefix = "",
          non_collapsible = "",
          collapsed = "",

          passed = "",
          running = "",
          failed = "",
          unknown = "",
          skipped = "",
        },
        floating = {
          border = "single",
          max_height = 0.8,
          max_width = 0.9,
        },
        summary = {
          mappings = {
            attach = "a",
            expand = { "<CR>", "<2-LeftMouse>" },
            expand_all = "e",
            jumpto = "i",
            output = "o",
            run = "r",
            short = "O",
            stop = "u",
          },
        },
      })
    end,
  },
}
