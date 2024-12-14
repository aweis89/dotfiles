return {
  {
    "aweis89/aider.nvim",
    dependencies = {
      "akinsho/toggleterm.nvim",
      "nvim-telescope/telescope.nvim",
      "willothy/flatten.nvim",
      "j-hui/fidget.nvim",
    },
    dir = "/Users/aaron.weisberg/p/aider.nvim",
    lazy = false,
    opts = {
      update_hook_cmd = "DiffviewOpen HEAD^",
      spawn_on_startup = false,
      notify = function(...)
        require("fidget").notify(...)
      end,
      after_update_hook = function()
        require("diffview").open({ "HEAD^" })
      end,
      aider_args = "--no-auto-commits",
    },
    keys = {
      {
        "<leader>a<space>",
        "<cmd>AiderToggle<CR>",
        desc = "Toggle Aider",
      },
      {
        "<leader>am",
        desc = "Change model",
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
        "<leader>amg",
        "<cmd>AiderSend /model gemini/gemini-exp-1206<CR>",
        desc = "Switch to haiku",
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
        "<leader>ac",
        "<cmd>AiderSend /commit<CR>",
        desc = "Aider commit",
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
    },
  },
}
