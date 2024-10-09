return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "hrsh7th/nvim-cmp", -- Optional: For using slash commands and variables in the chat buffer
    "nvim-telescope/telescope.nvim", -- Optional: For using slash commands
    { "stevearc/dressing.nvim", opts = {} }, -- Optional: Improves the default Neovim UI
  },
  config = true,
  init = function()
    vim.api.nvim_set_keymap("n", "<leader>ac", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true })
    vim.api.nvim_set_keymap("n", "<leader>aa", "<cmd>CodeCompanionChat toggle<cr>", { noremap = true, silent = true })
    vim.api.nvim_set_keymap("n", "<leader>aA", "<cmd>CodeCompanionChat<cr>", { noremap = true, silent = true })

    vim.api.nvim_set_keymap("v", "<leader>aA", "<cmd>CodeCompanionChat<cr>", { noremap = true, silent = true })
    vim.api.nvim_set_keymap("v", "<leader>aa", "<cmd>CodeCompanionChat Add<cr>", { noremap = true, silent = true })

    -- Expand 'cc' into 'CodeCompanion' in the command line
    vim.cmd([[cab cc CodeCompanion]])
  end,
  opts = {
    keymaps = {
      send = {
        modes = {
          n = { "<CR>", "<C-s>" },
          i = "<C-s>",
        },
        index = 1,
        callback = function(chat)
          -- First, exit insert mode
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
          -- Then, call the send function
          chat:submit()
        end,
        description = "Send and exit insert mode",
      },
    },

    strategies = {
      chat = {
        adapter = "anthropic",
      },
      inline = {
        adapter = "anthropic",
      },
      agent = {
        adapter = "anthropic",
      },
    },
  },
}
