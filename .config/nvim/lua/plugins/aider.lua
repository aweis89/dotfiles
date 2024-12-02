return {
  { "willothy/flatten.nvim", config = true },
  {
    "akinsho/toggleterm.nvim",
    opts = {
      shade_terminals = false,
      direction = "float",
      float_opts = {
        border = "curved",
        title_pos = "center",
      },
      open_mapping = [[<c-\>]],
      close_on_exit = true,
      size = function(term)
        if term.direction == "horizontal" then
          return vim.o.lines * 0.4
        elseif term.direction == "vertical" then
          return vim.o.columns * 0.4
        end
      end,
    },
  },
  {
    "aweis89/aider.nvim",
    dependencies = {
      "akinsho/toggleterm.nvim",
      "ibhagwan/fzf-lua",
      "nvim-telescope/telescope.nvim",
      "willothy/flatten.nvim",
    },
    dir = "/Users/aaron.weisberg/p/aider.nvim",
    init = function()
      require("aider").setup({
        -- window = {
        --   layout = "current",
        --   width = 1,
        --   height = 1,
        -- },
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
