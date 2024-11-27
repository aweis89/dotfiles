local actions = require("fzf-lua.actions")
local path = require("fzf-lua.path")

local aider = {}

local load_in_aider = function(selected, opts)
  local cleaned_paths = {}
  for _, entry in ipairs(selected) do
    local file_info = path.entry_to_file(entry, opts)
    table.insert(cleaned_paths, file_info.path)
  end
  local paths = table.concat(cleaned_paths, " ")

  if aider.buf and vim.api.nvim_buf_is_valid(aider.buf) then
    local paths_to_add = "/add " .. paths
    vim.fn.chansend(aider.job_id, paths_to_add .. "\n")
    vim.api.nvim_input("A")
    return
  end

  local command = "aider " .. paths
  vim.api.nvim_command("vnew")
  aider.job_id = vim.fn.termopen(command, {
    on_exit = function()
      vim.cmd("bd!")
    end,
  })
  aider.buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_input("A")
end

local function toggle_aider()
  if aider.buf and vim.api.nvim_buf_is_valid(aider.buf) then
    -- Get list of windows containing the aider buffer
    local wins = vim.fn.win_findbuf(aider.buf)

    if #wins > 0 then
      -- Buffer is visible, close all windows containing it
      for _, win in ipairs(wins) do
        vim.api.nvim_win_close(win, false)
      end
    else
      -- Buffer isn't visible, show it in a vertical split
      vim.cmd("vnew")
      vim.api.nvim_win_set_buf(0, aider.buf)
      vim.api.nvim_input("A")
    end
  else
    load_in_aider({})
  end
end

return {
  {
    "ibhagwan/fzf-lua",
    opts = {
      actions = {
        files = {
          ["ctrl-l"] = load_in_aider,
        },
      },
    },
    keys = {
      {
        "<leader>a<space>",
        function()
          toggle_aider()
        end,
        desc = "Toggle Aider",
      },
      {
        "<leader>al",
        function()
          local curren_file = vim.api.nvim_buf_get_name(0)
          load_in_aider({ curren_file })
        end,
        desc = "Add file to aider",
      },
    },
  },
}
