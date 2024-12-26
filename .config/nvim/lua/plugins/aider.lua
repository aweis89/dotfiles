return {
  {
    "aweis89/aider.nvim",
    dependencies = {
      "akinsho/toggleterm.nvim",
      "nvim-telescope/telescope.nvim",
      "j-hui/fidget.nvim",
      "willothy/flatten.nvim",
      "ibhagwan/fzf-lua",
    },
    dir = "/Users/aaron.weisberg/p/aider.nvim",
    lazy = false,
    opts = {
      -- win = {
      --   direction = "float",
      -- },
      after_update_hook = function()
        -- require("telescope.command").load_command("git_commits")

        vim.cmd("DiffviewFileHistory")
      end,
      -- aider_args = "--no-auto-commits",
    },
    keys = {
      {
        "<leader>ghh",
        "<cmd>Gitsigns change_base HEAD^<CR>",
        desc = "Gitsigns pick reversals",
      },
      {
        "<leader>dvh",
        "<cmd>DiffviewFileHistory<CR>",
        desc = "Diffview History Log",
      },
      {
        "<leader>dvo",
        "<cmd>DiffviewOpen<CR>",
        desc = "Diffview",
      },
      {
        "<leader>dvc",
        "<cmd>DiffviewClose!<CR>",
        desc = "Diffview close",
      },
      {
        "<leader>a<space>",
        "<cmd>AiderToggle<CR>",
        desc = "Toggle Aider",
      },
      {
        "<leader>af",
        "<cmd>AiderToggle float<CR>",
        desc = "Toggle Aider Float",
      },
      {
        "<leader>av",
        "<cmd>AiderToggle vertical<CR>",
        desc = "Toggle Aider Float",
      },
      {
        "<C-x>",
        "<cmd>AiderToggle<CR>",
        desc = "Toggle Aider",
        mode = { "i", "t", "n" },
      },
      {
        "<leader>as",
        "<cmd>AiderSpawn<CR>",
        desc = "Toggle Aidper (default)",
      },
      {
        "<leader>al",
        "<cmd>AiderLoad<CR>",
        desc = "Add file to aider",
      },
      {
        "<leader>ad",
        "<cmd>AiderAsk<CR>",
        desc = "Ask with selection",
        mode = { "v", "n" },
      },

      {
        "<leader>ams",
        "<cmd>AiderSend /model sonnet<CR>",
        desc = "Switch to sonnet",
      },
      {
        "<leader>amh",
        "<cmd>AiderSend /model haiku<CR>",
        desc = "Switch to haiku",
      },
      {
        "<leader>amd",
        "<cmd>AiderSend /model deepseek/deepseek-chat<CR>",
        desc = "Switch to haiku",
      },
      {
        "<leader>amg",
        "<cmd>AiderSend /model gemini/gemini-exp-1206<CR>",
        desc = "Switch to haiku",
      },
    },
  },
}
