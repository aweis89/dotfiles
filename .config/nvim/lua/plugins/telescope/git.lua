local M = {}

local previewers = require("telescope.previewers")

local function git_ref_action(command_template)
  local action_state = require("telescope.actions.state")
  local selected_entry = action_state.get_selected_entry()
  local value = selected_entry.value
  value = value:gsub("@$", "")
  vim.api.nvim_win_close(0, true)
  vim.cmd("stopinsert")
  vim.schedule(function()
    vim.cmd(command_template:format(value))
  end)
end

-- Git reference diffview action
M.git_ref_diffview_action = function()
  git_ref_action("DiffviewOpen %s^!")
end

local function git_diff(...)
  local build = {
    "git",
    "-c",
    "delta.paging=always",
    "-c",
    "pager.diff=delta",
    "-c",
    "color.diff=always",
    "diff",
  }
  for _, arg in ipairs({ ... }) do
    table.insert(build, arg)
  end
  return build
end

-- Git status delta previewer
M.git_status_delta_previewer = previewers.new_termopen_previewer({
  get_command = function(entry)
    return git_diff(entry.path)
  end,
})

-- Git reference delta previewer
M.git_ref_delta_previewer = previewers.new_termopen_previewer({
  get_command = function(entry)
    return git_diff(entry.value .. "^!")
  end,
})

return M
