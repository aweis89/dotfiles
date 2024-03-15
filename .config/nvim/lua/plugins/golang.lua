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
        trouble = true,
      })
      -- vim.cmd("autocmd BufWritePost <buffer> :GoVet")

      -- Run gofmt + goimport on save
      local format_sync_grp = vim.api.nvim_create_augroup("GoImport", {})
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*.go",
        callback = function()
          require("go.format").goimport()
          require("go.gotests").fun_test()
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
