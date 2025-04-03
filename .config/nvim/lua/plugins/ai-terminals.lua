local M = {}

------------------------------------------
-- Terminals Plugin Configuration
-- Handles AI tool terminal interactions (Goose, Claude, etc.)
------------------------------------------

------------------------------------------
-- Constants
------------------------------------------
local WINDOW_DIMENSIONS = {
  float = { width = 0.97, height = 0.97 },
  bottom = { width = 0.5, height = 0.5 },
  top = { width = 0.5, height = 0.5 },
  left = { width = 0.5, height = 0.5 },
  right = { width = 0.5, height = 0.5 },
}

------------------------------------------
-- Terminal Core Functions
------------------------------------------
---Get the current visual selection
---@param bufnr number|nil Buffer number (defaults to current buffer)
---@return string[] lines Selected lines
---@return string filepath Filepath of the buffer
---@return number start_line Starting line number
---@return number end_line Ending line number
function M.get_visual_selection(bufnr)
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

  local filepath = vim.fn.expand("%:p")

  return lines, filepath, start_line, end_line
end

---Format visual selection with markdown code block and file path
---@param bufnr integer|nil
---@param opts table|nil Options for formatting (preserve_whitespace, etc.)
---@return string|nil
function M.get_visual_selection_with_header(bufnr, opts)
  opts = opts or {}
  local lines, path = M.get_visual_selection(bufnr)

  if not lines or #lines == 0 then
    vim.notify("No text selected", vim.log.levels.WARN)
    return nil
  end

  local slines = table.concat(lines, "\n")
  if not opts.preserve_whitespace then
    slines = slines:gsub("^%s+", ""):gsub("%s+$", "")
  end

  local filetype = vim.bo[bufnr].filetype or ""
  slines = "```" .. filetype .. "\n" .. slines .. "\n```\n"
  return string.format("\n# Path: %s\n%s\n", path, slines)
end

---Create a terminal with specified position and command
---@param position "float"|"bottom"|"top"|"left"|"right"
---@param cmd string|nil
---@return function
function M.create_terminal(position, cmd)
  local valid_positions = { float = true, bottom = true, top = true, left = true, right = true }

  if not valid_positions[position] then
    vim.notify("Invalid terminal position: " .. tostring(position), vim.log.levels.ERROR)
    return function() end
  end

  return function()
    local dimensions = WINDOW_DIMENSIONS[position]

    return Snacks.terminal.toggle(cmd, {
      env = { id = cmd or position },
      win = {
        position = position,
        height = dimensions.height,
        width = dimensions.width,
      },
    })
  end
end

---Send selected text to a terminal
---@param terminal function Terminal creation function
---@return nil
function M.send_selection(terminal)
  local bufnr = vim.api.nvim_get_current_buf()
  local selection = M.get_visual_selection_with_header(bufnr)

  terminal()

  if selection then
    local ok, err = pcall(vim.fn.chansend, vim.b.terminal_job_id, selection)
    if not ok then
      vim.notify("Failed to send selection: " .. tostring(err), vim.log.levels.ERROR)
      return
    end
  end

  vim.api.nvim_feedkeys("i", "n", false)
end

------------------------------------------
-- Terminal Instances
------------------------------------------

---Create a Goose terminal
---@return function
function M.goose_terminal()
  return M.create_terminal("float", "goose")()
end

---Create a Claude terminal
---@return function
function M.claude_terminal()
  local theme = vim.o.background
  local cmd = string.format("claude config set -g theme %s; claude", theme)
  return M.create_terminal("float", cmd)()
end

------------------------------------------
-- Plugin Configuration
------------------------------------------
return {
  {
    "folke/snacks.nvim",
    optional = true,
    event = "VeryLazy",
    keys = {
      -- Claude Keymaps
      {
        "<leader>as",
        function()
          M.claude_terminal()
        end,
        desc = "Toggle Claude terminal",
      },
      {
        "<leader>as",
        function()
          M.send_selection(M.claude_terminal)
        end,
        desc = "Send selection to Claude",
        mode = { "v" },
      },
      -- Goose Keymaps
      {
        "<leader>ag",
        function()
          M.goose_terminal()
        end,
        desc = "Toggle Goose terminal",
      },
      {
        "<leader>ag",
        function()
          M.send_selection(M.goose_terminal)
        end,
        desc = "Send selection to Goose",
        mode = { "v" },
      },
    },
  },
}
