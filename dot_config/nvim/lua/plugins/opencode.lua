local function open_with_files(files, new_session)
  require("opencode.core").open({
    new_session = new_session,
    focus = "input",
    start_insert = true,
  })

  local context = require("opencode.context").ChatContext
  for _, file in ipairs(files) do
    context.add_file(file)
  end
end

local function add_selection_if_new(selection)
  if not selection then
    return
  end
  local context = require("opencode.context")
  for _, sel in ipairs(context.get_context().selections) do
    if sel.file.path == selection.file_info.path and sel.lines == selection.lines_str then
      return
    end
  end
  local sel_obj = context.new_selection(selection.file_info, selection.text, selection.lines_str)
  context.add_selection(sel_obj)
end

local function toggle_opencode(new_session)
  local mode = vim.fn.mode()
  local selection = nil
  if mode == "v" or mode == "V" or mode == "\22" then
    vim.cmd("normal! \27")
    local start_line = vim.fn.line("'<")
    local end_line = vim.fn.line("'>")

    local buf = vim.api.nvim_get_current_buf()
    local lines_content = vim.api.nvim_buf_get_lines(buf, start_line - 1, end_line, false)
    local text = table.concat(lines_content, "\n")

    local file = vim.api.nvim_buf_get_name(buf)
    local file_info = {
      path = file,
      name = vim.fn.fnamemodify(file, ":t"),
      extension = vim.fn.fnamemodify(file, ":e"),
    }

    local lines_str = start_line .. ", " .. end_line
    selection = { file_info = file_info, text = text, lines_str = lines_str }
  end

  -- don't toggle close if sending selection
  local state = require("opencode.state")
  if selection and state.windows ~= nil then
    add_selection_if_new(selection)
    require("opencode.api").focus_input()
    return
  end

  require("opencode.api").toggle(new_session):and_then(function()
    add_selection_if_new(selection)
  end)
end

return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        actions = {
          opencode_send = function(picker)
            local selected = picker:selected({ fallback = true })
            if selected and #selected > 0 then
              local files = {}
              for _, item in ipairs(selected) do
                if item.file then
                  table.insert(files, item.file)
                end
              end
              picker:close()

              open_with_files(files)
            end
          end,
        },
        win = {
          input = {
            keys = {
              ["<localleader>o"] = { "opencode_send", mode = { "n", "i" } },
            },
          },
        },
      },
    },
  },
  {
    "aweis89/opencode.nvim",
    lazy = false,
    opts = {
      preferred_picker = vim.g.lazyvim_picker,
      context = {
        enabled = true,
        cursor_data = {
          enabled = false,
        },
        diagnostics = {
          enabled = false,
        },
        current_file = {
          enabled = false,
        },
        files = {
          enabled = true,
        },
        selection = {
          enabled = true,
        },
        agents = {
          enabled = false,
        },
      },
      keymap = {
        editor = {
          ["<leader>oC"] = {
            function()
              vim.cmd("tab Opencode command commit-staged")
            end,
            desc = "Commit Staged Changes",
          },
          ["<leader>ot"] = {
            function()
              local position = require("opencode.config").ui.position
              if position == "current" then
                require("opencode.config").ui.position = "right"
              else
                require("opencode.config").ui.position = "current"
              end
            end,
            desc = "Toggle OpenCode Position",
          },
          ["<leader>oG"] = {
            function()
              toggle_opencode(true)
            end,
            mode = { "n", "x" },
            desc = "Toggle OpenCode (new session)",
          },
          ["<leader>og"] = {
            toggle_opencode,
            mode = { "n", "x" },
            desc = "Toggle OpenCode",
          },
          ["<C-t>"] = {
            toggle_opencode,
            mode = { "n", "x" },
            desc = "Toggle OpenCode",
          },
          ["<leader>ox"] = { "cancel", desc = "Cancel Request" },
          ["<leader>ol"] = {
            function()
              open_with_files({ vim.api.nvim_buf_get_name(0) })
            end,
            desc = "Load Current File",
          },
          ["<leader>oL"] = {
            function()
              open_with_files({ vim.api.nvim_buf_get_name(0) }, true)
            end,
            desc = "Load Current File",
          },
        },
        input_window = {
          ["<C-x>"] = { "cancel", mode = { "n", "i" } },
          ["<C-p>"] = { "switch_mode", mode = { "n", "i" } }, -- Switch between modes (build/plan)
          ["<C-u>"] = {
            function()
              local core = require("opencode.core")
              core.open({ new_session = false, focus = "output" }):wait()
              vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-b>", true, false, true), "n", true)
            end,
            mode = { "n", "i" },
          },
          ["<C-o>"] = {
            function()
              require("opencode.core").open({ new_session = false, focus = "output" })
            end,
            mode = { "n", "i" },
          },
        },
        output_window = {
          ["<C-x>"] = { "cancel", mode = { "n", "i" } },
          ["<C-i>"] = {
            function()
              require("opencode.core").open({ new_session = false, focus = "input" })
            end,
            mode = { "n", "i" },
          },
        },
      },
      ui = {
        picker_width = vim.o.columns,
        position = "current",
        input_height = 0.15, -- Input height as percentage of window height
        input_position = "bottom", -- 'bottom' (default) or 'top'. Position of the input window
        input = {
          auto_hide = true,
          text = {
            wrap = true, -- Wraps text inside input window
          },
        },
      },
    },
    config = function(_, opts)
      -- enable local build version to work
      ---@diagnostic disable
      require("opencode.state").required_version = 0
      require("opencode").setup(opts)
    end,
    dependencies = {
      "MeanderingProgrammer/render-markdown.nvim",
      "folke/snacks.nvim",
      "nvim-lua/plenary.nvim",
      "saghen/blink.cmp",
    },
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      file_types = { "markdown", "opencode_output", "codecompanion" },
      anti_conceal = { enabled = false },
      checkbox = { enabled = true },
      heading = {
        icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
      },
    },
    ft = { "markdown", "norg", "rmd", "org", "opencode_output" },
  },
}
