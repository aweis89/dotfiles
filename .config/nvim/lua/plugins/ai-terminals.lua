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

local BASE_COPY_DIR = vim.env.HOME .. "/tmp/"

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

  local filepath = vim.fn.fnamemodify(vim.fn.expand("%"), ":~:.")

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
---@return snacks.win|nil
function M.create_terminal(position, cmd)
  local valid_positions = { float = true, bottom = true, top = true, left = true, right = true }

  if not valid_positions[position] then
    vim.notify("Invalid terminal position: " .. tostring(position), vim.log.levels.ERROR)
    return nil
  end

  local cwd = vim.fn.getcwd()
  vim.system({ "rsync", "-av", "--delete", "--exclude", ".git", cwd, BASE_COPY_DIR })

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

---Compare current directory with its backup in ~/tmp and open differing files
---@return nil
function M.diff_with_tmp()
  local cwd = vim.fn.getcwd()
  local cwd_name = vim.fn.fnamemodify(cwd, ":t")
  local tmp_dir = BASE_COPY_DIR .. cwd_name

  -- Get list of files that differ
  local diff_cmd = string.format("diff -rq %s %s", cwd, tmp_dir)
  local diff_output = vim.fn.system(diff_cmd)

  if vim.v.shell_error == 0 then
    vim.notify("No differences found", vim.log.levels.INFO)
    return
  end

  -- Process diff output and extract file paths
  local diff_files = {}
  for line in vim.gsplit(diff_output, "\n") do
    if line:match("^Files .* and .* differ$") then
      local orig_file = line:match("Files (.-) and")
      local tmp_file = line:match("and (.-) differ")
      table.insert(diff_files, { orig = orig_file, tmp = tmp_file })
    end
  end

  -- Close all current windows
  vim.cmd("tabonly")
  vim.cmd("only")

  -- Open each differing file in a split view
  for i, files in ipairs(diff_files) do
    vim.notify(string.format("Diffing %s and %s", files.orig, files.tmp), vim.log.levels.INFO)

    if i > 1 then
      -- Create a new tab for each additional file pair
      vim.cmd("tabnew")
    end

    vim.cmd("edit " .. vim.fn.fnameescape(files.orig))
    vim.cmd("diffthis")
    vim.cmd("vsplit " .. vim.fn.fnameescape(files.tmp))
    vim.cmd("diffthis")
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
    M.send(selection)
  end

  vim.api.nvim_feedkeys("i", "n", false)
end

---Send selected text to a terminal
---@return nil
function M.send(text)
  local ok, err = pcall(vim.fn.chansend, vim.b.terminal_job_id, text)
  if not ok then
    vim.notify("Failed to send selection: " .. tostring(err), vim.log.levels.ERROR)
    return
  end
end

------------------------------------------
-- Terminal Instances
------------------------------------------

---Create a Goose terminal
---@return snacks.win|nil
function M.goose_terminal()
  local cmd = string.format("GOOSE_CLI_THEME=%s goose", vim.o.background)
  return M.create_terminal("float", cmd)
end

---Create a Claude terminal
---@return snacks.win|nil
function M.claude_terminal()
  local theme = vim.o.background
  local cmd = string.format("claude config set -g theme %s && claude", theme)
  return M.create_terminal("float", cmd)
end

---@return string
function M.diagnostics()
  local diagnostics = {}
  local mode = vim.api.nvim_get_mode().mode
  if mode:match("^[vV\22]") then -- visual, visual-line, or visual-block mode
    local start_line, _ = unpack(vim.api.nvim_buf_get_mark(0, "<"))
    local end_line, _ = unpack(vim.api.nvim_buf_get_mark(0, ">"))
    for line = start_line - 1, end_line - 1 do -- Convert to 0-based indexing
      local line_diags = vim.diagnostic.get(0, { lnum = line })
      vim.list_extend(diagnostics, line_diags)
    end
  else
    diagnostics = vim.diagnostic.get(0)
  end

  local file = vim.api.nvim_buf_get_name(0)

  local formatted = M.diag_format(diagnostics)
  return string.format("Diagnostics:\nFile: %q:\n%s\n\n", file, table.concat(formatted, "\n"))
end

---@return string[]
function M.diag_format(diagnostics)
  local output = {}
  local severity_map = {
    [vim.diagnostic.severity.ERROR] = "ERROR",
    [vim.diagnostic.severity.WARN] = "WARN",
    [vim.diagnostic.severity.INFO] = "INFO",
    [vim.diagnostic.severity.HINT] = "HINT",
  }
  for _, diag in ipairs(diagnostics) do
    local line = string.format(
      "Line %d, Col %d: [%s] %s (%s)",
      diag.lnum + 1, -- Convert from 0-based to 1-based line numbers
      diag.col + 1, -- Convert from 0-based to 1-based column numbers
      severity_map[diag.severity] or "UNKNOWN",
      diag.message,
      diag.source or "unknown"
    )
    table.insert(output, line)
  end
  return output
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
      -- Diff Tools
      {
        "<leader>dvo",
        M.diff_with_tmp,
        desc = "Compare with tmp directory backup",
      },
      -- Claude Keymaps
      {
        "<leader>ass",
        M.claude_terminal,
        desc = "Toggle Claude terminal",
      },
      {
        "<leader>ass",
        function()
          M.send_selection(M.claude_terminal)
        end,
        desc = "Send selection to Claude",
        mode = { "v" },
      },
      {
        "<leader>asd",
        function()
          local diagnostics = M.diagnostics()
          M.claude_terminal()
          M.send(diagnostics)
        end,
        desc = "Send diagnostics to Goose",
        mode = { "v" },
      },
      -- Goose Keymaps
      {
        "<leader>agg",
        M.goose_terminal,
        desc = "Toggle Goose terminal",
      },
      {
        "<leader>agg",
        function()
          M.send_selection(M.goose_terminal)
        end,
        desc = "Send selection to Goose",
        mode = { "v" },
      },
      {
        "<leader>agd",
        function()
          local diagnostics = M.diagnostics()
          M.goose_terminal()
          M.send(diagnostics)
        end,
        desc = "Send diagnostics to Goose",
        mode = { "v" },
      },
    },
  },
}
