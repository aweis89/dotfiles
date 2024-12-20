local M = {}

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
  return build
end

M.git_delta = function(state, get_entry)
  return function(buf, win)
    local entry = get_entry(state, buf, win)
    if not entry then
      return
    end
    local file = require("fzf-lua").path.entry_to_file(entry)
    local cmd = git_cmd("diff", file.path)
    vim.api.nvim_buf_set_option(buf, "filetype", "diff")
    vim.fn.termopen(cmd, {
      cwd = state.cwd,
      on_exit = function()
        vim.api.nvim_win_close(win, true)
      end,
    })
  end
end

return M
