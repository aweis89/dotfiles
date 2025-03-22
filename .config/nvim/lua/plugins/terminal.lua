-- if vim.env.TMUX then
--   return {}
-- end
--
---Get the current visual selection
---@param bufnr number|nil Buffer number (defaults to current buffer)
---@return string[] lines Selected lines
---@return string filepath Filepath of the buffer
---@return number start_line Starting line number
---@return number end_line Ending line number
local function get_visual_selection(bufnr)
  local api = vim.api
  local esc_feedkey = api.nvim_replace_termcodes("<ESC>", true, false, true)
  bufnr = bufnr or 0

  api.nvim_feedkeys(esc_feedkey, "n", true)
  api.nvim_feedkeys("gv", "x", false)
  api.nvim_feedkeys(esc_feedkey, "n", true)

  local end_line, end_col = unpack(api.nvim_buf_get_mark(bufnr, ">"))
  local start_line, start_col = unpack(api.nvim_buf_get_mark(bufnr, "<"))
  local lines = api.nvim_buf_get_lines(bufnr, start_line - 1, end_line, false)

  -- get whole buffer if there is no current/previous visual selection
  if start_line == 0 then
    lines = api.nvim_buf_get_lines(bufnr, 0, -1, false)
    start_line = 1
    start_col = 0
    end_line = #lines
    end_col = #lines[#lines]
  end

  -- use 1-based indexing and handle selections made in visual line mode
  start_col = start_col + 1
  end_col = math.min(end_col, #lines[#lines] - 1) + 1

  -- shorten first/last line according to start_col/end_col
  lines[#lines] = lines[#lines]:sub(1, end_col)
  lines[1] = lines[1]:sub(start_col)

  local filepath = vim.api.nvim_buf_get_name(0)
  local root_dir = vim.fn.finddir(".git", vim.fn.fnamemodify(filepath, ":h") .. ";") -- Looks for .git directory
  if root_dir ~= "" then
    root_dir = vim.fn.fnamemodify(root_dir, ":p:h") -- Get the absolute path of the root
    local relative_path = vim.fn.fnamemodify(filepath, ":." .. root_dir)
    filepath = relative_path
  end

  return lines, filepath, start_line, end_line
end

---@param bufnr integer|nil
---@return string|nil
local function get_visual_selection_with_header(bufnr)
  local lines, path = get_visual_selection(bufnr)
  if #lines == 0 then
    return nil
  end
  local slines = table.concat(lines, "\n")
  local filetype = vim.o.filetype
  slines = "```" .. filetype .. "\n" .. slines .. "\n```\n"
  return string.format("# File: %s\n\n%s", path, slines)
end

local function terminal(position, cmd)
  return function()
    local width = {
      float = 0.97,
    }
    local height = {
      float = 0.97,
    }
    return Snacks.terminal.toggle(cmd or "zsh", {
      env = {
        id = cmd or position,
      },
      win = {
        --@field position? "float"|"bottom"|"top"|"left"|"right"
        position = position,
        height = height[position] or 0.5,
        width = width[position] or 0.5,
      },
    })
  end
end

local function claude_terminal()
  local theme = vim.o.background
  local cmd = string.format("claude config set -g theme %s; claude", theme)
  terminal("float", cmd)()
end

return {
  {
    "folke/snacks.nvim",
    optional = true,
    opts = function(_, opts)
      table.insert(opts.dashboard.preset.keys, 2, {
        action = terminal("float"),
        desc = "Terminal",
        icon = " ",
        key = "t",
      })
    end,
  },
  {
    "folke/snacks.nvim",
    keys = {
      {
        "<C-t>",
        function()
          Snacks.terminal(vim.env.SHELL or "zsh", {
            win = {
              height = 0.99,
              width = 0.99,
            },
          })
        end,
        desc = "Opent terminal",
        mode = { "n", "t" },
      },
      {
        "<leader>as",
        claude_terminal,
        desc = "Toggle Claude (default)",
      },
      {
        "<leader>as",
        function()
          local selection = nil
          local bufnr = vim.api.nvim_get_current_buf()
          selection = get_visual_selection_with_header(bufnr)
          vim.api.nvim_feedkeys("i", "n", false)
          vim.ui.input({ prompt = "Claude" }, function(ai_prompt)
            claude_terminal()
            if selection then
              ai_prompt = selection .. "\n\n" .. ai_prompt
            end
            vim.fn.chansend(vim.b.terminal_job_id, ai_prompt)
          end)
        end,
        desc = "Toggle Claude (default)",
        mode = { "v" },
      },
      {
        "<C-a>h",
        terminal("left"),
        mode = { "n", "t", "i" },
      },
      {
        "<C-a>l",
        terminal("right"),
        mode = { "n", "t", "i" },
      },
      {
        "<C-a>j",
        terminal("bottom"),
        mode = { "n", "t", "i" },
      },
      {
        "<C-a>k",
        terminal("top"),
        mode = { "n", "t", "i" },
      },
      {
        "<C-a>f",
        terminal("float"),
        mode = { "n", "t", "i" },
      },
    },
    opts = {
      dashboard = {
        preset = {
          header = [[
          ]],
        },
      },
    },
  },
}
