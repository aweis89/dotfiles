local M = {}

local previewers = require("telescope.previewers")

local function git_action(command_template)
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
  git_action("DiffviewOpen %s^!")
end

-- Git reference diffview action
M.git_ref_reset_soft = function()
  git_action("Git reset --soft %s")
end

-- Git reference diffview action
M.git_ref_reset_hard = function()
  git_action("Git reset %s")
end

local function git_cmd(...)
  local build = {
    "git",
    "-c",
    "delta.paging=always",
    "-c",
    "pager.diff=delta",
    "-c",
    "color.diff=always",
  }
  for _, arg in ipairs({ ... }) do
    table.insert(build, arg)
  end
  return build
end

-- Git status delta previewer
M.git_status_delta_previewer = previewers.new_termopen_previewer({
  get_command = function(entry)
    return git_cmd("diff", entry.path)
  end,
})

-- Git reference delta previewer
M.git_ref_delta_previewer = previewers.new_termopen_previewer({
  get_command = function(entry)
    return git_cmd("diff", entry.value .. "^!")
  end,
})

-- refacotr the below two funcs to reduce duplicatoin ai!
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

-- Git checkout file
M.git_checkout_file = function(_)
  local selection = require("telescope.actions.state").get_selected_entry()
  local git_root = vim.fn.system("git rev-parse --show-toplevel"):gsub("\n", "")
  local file_path = git_root .. "/" .. selection.value
  local cmd = "git checkout -- " .. file_path
  local result = vim.fn.system(cmd)
  if result == "" then
    vim.notify("Ran: " .. cmd)
  else
    vim.notify("Faile to run: " .. cmd .. ". Error: " .. result)
  end
end

return M
