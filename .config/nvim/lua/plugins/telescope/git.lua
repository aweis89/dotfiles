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

local function git_cmd(...)
  local build = {
    "git",
    "-c",
    "delta.paging=always",
    "-c",
    "delta.side-by-side=false",
    "-c",
    "pager.diff=delta",
    "-c",
    "color.diff=always",
  }
  for _, arg in ipairs({ ... }) do
    table.insert(build, arg)
  end
  vim.notify("running: " .. table.concat(build, " "))
  return build
end

-- Git reference delta previewer
M.git_ref_delta_previewer = previewers.new_termopen_previewer({
  get_command = function(entry)
    return git_cmd("diff", entry.value .. "^!")
  end,
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
