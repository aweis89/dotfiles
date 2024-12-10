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
      notify = function(...)
        require("fidget").notify(...)
      end,
      after_update_hook = function()
        require("diffview").open({})
      end,
      toggleterm = {
        direction = "tab",
      },
      aider_args = "--no-auto-commits",
      confirm_with_vim_ui = true,
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
