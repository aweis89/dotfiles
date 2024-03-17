return {
  {
    "yanskun/gotests.nvim",
    ft = "go",
    config = function()
      require("gotests").setup()
    end,
  },
  {
    "ray-x/go.nvim",
    dependencies = { -- optional packages
      "ray-x/guihua.lua",
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("go").setup({
        -- trouble = true,
      })

      local format_sync_grp = vim.api.nvim_create_augroup("GoTest", {})
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*.go",
        callback = function()
          require("go.gotest").test_file()
        end,
        group = format_sync_grp,
      })
    end,
    event = { "CmdlineEnter" },
    ft = { "go", "gomod" },
    build = ':lua require("go.install").update_all_sync()', -- if you need to install/update all binaries
    keys = {
      { "ga", "<cmd>GoAlt<cr>", desc = "GoAlt" },
      { "<leader>re", "<cmd>GoGenReturn<cr>", desc = "GoGenReturn" },
    },
  },
}
