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
    opts = function(_, opts)
      -- Move focus between splits
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
        desc = "Create terminal",
      },
      {
        "<C-a>t",
        function()
          vim.cmd.tabnew()
          create_term()
        end,
        mode = { "n", "t", "i" },
        desc = "Create terminal tab",
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
