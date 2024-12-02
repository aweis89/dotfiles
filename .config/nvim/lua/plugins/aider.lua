return {
  { "willothy/flatten.nvim", config = true },
  {
    "aweis89/aider.nvim",
    dependencies = {
      "ibhagwan/fzf-lua",
      "nvim-telescope/telescope.nvim",
      "willothy/flatten.nvim",
    },
    dir = "/Users/aaron.weisberg/p/aider.nvim",
    init = function()
      require("aider").setup({
        window = {
          layout = "current",
          width = 1,
          height = 1,
        },
      })
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
