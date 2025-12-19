return {
  {
    "rgroli/other.nvim",
    cmd = { "Other", "OtherSplit", "OtherVSplit", "OtherClear" },
    keys = {
      -- { "<leader>oo", "<cmd>Other<cr>", desc = "Other" },
      -- { "<leader>os", "<cmd>OtherVSplit<cr>", desc = "Other VSplit" },
      -- { "<leader>oc", "<cmd>OtherClear<cr>", desc = "Other clear" },
    },
    config = function()
      require("other-nvim").setup({
        -- https://github.com/rgroli/other.nvim/issues/31
        showMissingFiles = false,

        mappings = {
          "rails",
          "golang",
          "python",
          "react",
          "rust",
        },
      })
    end,
  },
}
