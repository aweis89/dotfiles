return {
  {
    "akinsho/flutter-tools.nvim",
    ft = "dart",
    dependencies = {
      "neovim/nvim-lspconfig",
      config = function()
        require("flutter-tools").setup({
          on_attach = require("lazyvim.plugins.lsp.keymaps").on_attach,
          capabilities = vim.lsp.protocol.make_client_capabilities(),
        })
        require("flutter-tools").setup_project({
          name = "default",
          device = "chrome",
        })
      end,
    },
  },
}
