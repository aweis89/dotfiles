local M = {}

-- Example function structure based on previous context
-- Assumes 'response' is passed containing the commit message
local function git_commit(response)
  -- Placeholder for getting the commit message from the response
  -- local message = get_last_code_block(response)
  local message = response -- Simplified for this example

  -- Run the git commit command
  vim.cmd("silent !git commit -m " .. vim.fn.shellescape(message))

  -- Get the current git branch
  local branch_list = vim.fn.systemlist('git rev-parse --abbrev-ref HEAD')
  local branch = ""
  if #branch_list > 0 then
    branch = branch_list[1]
  end
  local prompt_text = "Run git push for branch '" .. branch .. "'? [y/n] "

  -- Prompt the user to push
  vim.ui.input({ prompt = prompt_text }, function(input)
    if input and input:lower() == "y" then
      vim.cmd("silent !git push")
      print("Pushed to branch: " .. branch)
    else
      print("Push cancelled.")
    end
  end)
end

-- Make the function available if needed (adjust as per your plugin structure)
M.git_commit = git_commit

return M
