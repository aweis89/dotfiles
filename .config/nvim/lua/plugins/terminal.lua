------------------------------------------
-- Terminal Configuration
-- Simulates similar mappings to tmux using neovmi terminals
------------------------------------------

if vim.env.TMUX then
  return {}
end

local function create_term()
  vim.cmd.terminal()
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
      -- Define local map function *inside* opts function scope if needed elsewhere in opts
      local function map(mode, lhs, rhs, map_opts)
        map_opts = map_opts or { noremap = true, silent = true }
        vim.keymap.set(mode, lhs, rhs, map_opts) -- Use vim.keymap.set for consistency
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
      -- Close terminal (using buffer wipeout)
      map("t", "<C-a>x", "<cmd>bwipeout!<cr>", { desc = "Close terminal buffer" })

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
