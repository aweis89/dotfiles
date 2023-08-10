return {
  {
    "filipdutescu/renamer.nvim",
    dependencies = { { "nvim-lua/plenary.nvim" } },
    keys = {
      {
        "<leader>rn",
        function()
          require("renamer").rename()
        end,
        { desc = "LSP Rename" },
      },
    },
    init = function()
      require("renamer").setup({})
    end,
  },
}
