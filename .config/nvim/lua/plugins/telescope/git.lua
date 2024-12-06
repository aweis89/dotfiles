local M = {}

local previewers = require("telescope.previewers")

-- Git reference diffview action
M.git_ref_diffview_action = function()
  local action_state = require("telescope.actions.state")
  local selected_entry = action_state.get_selected_entry()
  local value = selected_entry.value
  vim.api.nvim_win_close(0, true)
  vim.cmd("stopinsert")
  vim.schedule(function()
    vim.cmd(("DiffviewOpen %s^!"):format(value))
  end)
end

-- Git reference delta previewer
M.git_ref_delta_previewer = previewers.new_termopen_previewer({
  get_command = function(entry)
    return git_cmd("diff", entry.value .. "^!")
  end,
})

local function git_cmd(...)
  local build = {
    "git",
    "-c",
    "core.pager=delta",
    "-c",
    "delta.side-by-side=false",
    -- Force git to always pipe through the pager
    "-c",
    "pager.diff=delta",
    "-c",
    "delta.paging=never",
    "-c",
    "color.diff=always",
  }
  for _, arg in ipairs({ ... }) do
    table.insert(build, arg)
  end
  return build
end

local function get_git_root()
  local output = vim.fn.systemlist("git rev-parse --show-toplevel")
  if vim.v.shell_error ~= 0 then
    return vim.fn.getcwd()
  end
  return output[1]
end

-- Git file delta previewer
M.git_file_delta_previewer = previewers.new_termopen_previewer({
  get_command = function(entry)
    if not entry or not entry.status then
      return { "echo", "Invalid entry" }
    end

    local is_staged = entry.status:sub(1, 1) ~= " " and entry.status:sub(1, 1) ~= "?"
    local is_unstaged = entry.status:sub(2, 2) ~= " "

    if is_staged then
      return git_cmd("diff", "--cached", "--", entry.value)
    elseif is_unstaged then
      return git_cmd("diff", "--", entry.value)
    else
      return { "bat", "--style=numbers,changes", "--color=always", entry.value }
    end
  end,
  opts = {
    hide_exit_code = true,
    cwd = get_git_root(),
  },
})

-- Git add file action
M.git_add_file = function(_)
  local selection = require("telescope.actions.state").get_selected_entry()
  local git_root = vim.fn.system("git rev-parse --show-toplevel"):gsub("\n", "")
  local file_path = git_root .. "/" .. selection.value
  local result = vim.fn.system("git add " .. file_path)
  if result == "" then
    vim.notify("Added file: " .. file_path)
  else
    vim.notify("Failed to add file: " .. file_path .. ". Error: " .. result)
  end
end

return M
