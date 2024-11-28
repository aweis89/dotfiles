return {
  {
    "aweis89/aider.nvim",
    dependencies = { "ibhagwan/fzf-lua" },
    -- dir = "/Users/aaron.weisberg/p/aider.nvim",
    init = function()
      require("aider").setup()
    end,
    keys = {
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
