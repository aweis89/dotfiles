------------------------------------------
-- Terminal Configuration
-- Simulates similar mappings to tmux using neovmi terminals
------------------------------------------

if vim.env.TMUX then
  return {}
end

------------------------------------------
-- Terminal Functions
------------------------------------------

-- create terminal
local function create_term()
  vim.cmd.terminal()
  local onenter = function()
    vim.cmd.startinsert()
    -- defer required when opening terminal from snacks buffer picker for options to take effect
    vim.defer_fn(function()
      local winid = vim.api.nvim_get_current_win()
      vim.api.nvim_set_option_value("number", false, { win = winid, scope = "local" })
      vim.api.nvim_set_option_value("relativenumber", false, { win = winid, scope = "local" })

      local bufid = vim.api.nvim_get_current_buf()
      vim.api.nvim_buf_set_keymap(bufid, "t", "<localleader>q", "<cmd>bwipeout!<cr>", { noremap = true, silent = true })
      vim.api.nvim_buf_set_keymap(bufid, "t", "<localleader>c", "<cmd>close<cr>", { noremap = true, silent = true })
      vim.api.nvim_buf_set_keymap(bufid, "n", "<localleader>q", "<cmd>bwipeout!<cr>", { noremap = true, silent = true })
      vim.api.nvim_buf_set_keymap(bufid, "n", "<localleader>c", "<cmd>close<cr>", { noremap = true, silent = true })
    end, 100)
  end
  onenter()

  vim.api.nvim_create_autocmd({ "BufEnter" }, {
    buffer = vim.api.nvim_get_current_buf(),
    -- callback = onenter,
    callback = function(args)
      onenter()
    end,
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
      local function map(mode, lhs, rhs, opts)
        opts = opts or { noremap = true, silent = true }
        vim.api.nvim_set_keymap(mode, lhs, rhs, opts)
      end

      -- Move focus between splits
      map("n", "<C-a>h", "<C-w>h", { desc = "Focus left split" })
      map("n", "<C-a>j", "<C-w>j", { desc = "Focus down split" })
      map("n", "<C-a>k", "<C-w>k", { desc = "Focus up split" })
      map("n", "<C-a>l", "<C-w>l", { desc = "Focus right split" })
      map("t", "<C-a>h", "<C-\\><C-n><C-w>h", { desc = "Focus left split" })
      map("t", "<C-a>j", "<C-\\><C-n><C-w>j", { desc = "Focus down split" })
      map("t", "<C-a>k", "<C-\\><C-n><C-w>k", { desc = "Focus up split" })
      map("t", "<C-a>l", "<C-\\><C-n><C-w>l", { desc = "Focus right split" })
      -- Close terminal
      map("t", "<C-a>x", "<cmd>bwipeout!<cr>", { desc = "Close terminal" })

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
