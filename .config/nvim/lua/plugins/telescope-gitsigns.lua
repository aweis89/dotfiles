return {
  {
    "radyz/telescope-gitsigns",
    dependencies = {
      "lewis6991/gitsigns.nvim",
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      require("telescope").load_extension("git_signs")
    end,
    keys = {
      {
        "<leader>fgs",
        "<cmd>Telescope git_signs<cr>",
        desc = "Commands",
      },
    },
  },
}
