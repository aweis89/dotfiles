return {
  { "willothy/flatten.nvim", config = true },
  {
    "akinsho/toggleterm.nvim",
    opts = {
      shade_terminals = false,
      -- default direction when none specified in arg to AiderToggle
      direction = "horizontal",
      float_opts = {
        border = "curved",
        title_pos = "center",
      },
      close_on_exit = true,
      size = function(term)
        if term.direction == "horizontal" then
          -- use %40 height
          return vim.o.lines * 0.4
        elseif term.direction == "vertical" then
          -- use %40 width
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
    opts = {
      aider_args = "--watch-files",
    },
    keys = {
      {
        "<leader>a<space>",
        "<cmd>AiderToggle float<CR>",
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
