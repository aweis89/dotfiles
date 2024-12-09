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
      notify = function(msg, level, opts)
        require("fidget").notify(msg, level, opts)
      end,
      after_update_hook = function()
        require("diffview").open({ "HEAD^" })
      end,
      toggleterm = {
        direction = "tab",
      },
    },
    keys = {
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
        "<leader>a<space>",
        "<cmd>AiderToggle<CR>",
        desc = "Toggle Aider",
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
