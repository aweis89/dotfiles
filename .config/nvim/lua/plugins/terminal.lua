------------------------------------------
-- Terminal Configuration
-- Handles general terminal functionality and integration
------------------------------------------

if vim.env.TMUX then
  return {}
end

------------------------------------------
-- Constants
------------------------------------------
local DEFAULT_SHELL = vim.env.SHELL or "zsh"
local WINDOW_DIMENSIONS = {
  float = { width = 0.97, height = 0.97 },
  bottom = { width = 0.5, height = 0.5 },
  top = { width = 0.5, height = 0.5 },
  left = { width = 0.5, height = 0.5 },
  right = { width = 0.5, height = 0.5 },
}

------------------------------------------
-- Terminal Functions
------------------------------------------

-- create terminal
local function create_term()
  vim.cmd.terminal()
  local bufid = vim.api.nvim_get_current_buf()
  local winid = vim.api.nvim_get_current_win()
  local onenter = function()
    vim.cmd.startinsert()
    vim.wo[winid].number = false
    vim.wo[winid].relativenumber = false

    vim.api.nvim_buf_set_keymap(bufid, "n", "q", "<cmd>bwipeout!<cr>", { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(bufid, "n", "c", "<cmd>close<cr>", { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(bufid, "t", "<localleader>q", "<cmd>bwipeout!<cr>", { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(bufid, "t", "<localleader>c", "<cmd>close<cr>", { noremap = true, silent = true })
  end
  onenter()

  vim.api.nvim_create_autocmd({ "BufEnter" }, {
    buffer = bufid,
    callback = onenter,
  })
end

------------------------------------------
-- Plugin Configuration
------------------------------------------
return {
  {
    "folke/snacks.nvim",
    optional = true,
    event = "VeryLazy",
    opts = function(_, opts)
      opts.dashboard.preset.header = ""
      table.insert(opts.dashboard.preset.keys, 2, {
        action = create_term,
        desc = "Terminal",
        icon = " ",
        key = "t",
      })
    end,
    keys = {
      {
        "<C-a>c",
        create_term,
        mode = { "n", "t", "i" },
        desc = "Create new terminal",
      },
      {
        "<C-a>v",
        function()
          vim.cmd.vsplit()
          create_term()
        end,
        mode = { "n", "t", "i" },
        desc = "Create vsplit terminal",
      },
      {
        "<C-a>\\",
        function()
          vim.cmd.vsplit()
          create_term()
        end,
        mode = { "n", "t", "i" },
        desc = "Create vsplit terminal",
      },
      {
        "<C-a>s",
        function()
          vim.cmd.split()
          create_term()
        end,
        mode = { "n", "t", "i" },
        desc = "Create split terminal",
      },
      {
        "<C-a>-",
        function()
          vim.cmd.split()
          create_term()
        end,
        mode = { "n", "t", "i" },
        desc = "Create split terminal",
      },
    },
  },
}
