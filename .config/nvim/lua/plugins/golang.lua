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
      local function org_imports()
        local clients = vim.lsp.get_active_clients()
        for _, client in pairs(clients) do
          local params = vim.lsp.util.make_range_params(nil, client.offset_encoding)
          params.context = { only = { "source.organizeImports" } }

          local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 5000)
          for _, res in pairs(result or {}) do
            for _, r in pairs(res.result or {}) do
              if r.edit then
                vim.lsp.util.apply_workspace_edit(r.edit, client.offset_encoding)
              else
                vim.lsp.buf.execute_command(r.command)
              end
            end
          end
        end
      end
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = { "*.go" },
        callback = org_imports,
      })

      require("go").setup()
    end,
    event = { "CmdlineEnter" },
    ft = { "go", "gomod" },
    build = ':lua require("go.install").update_all_sync()', -- if you need to install/update all binaries
    keys = { { "ga", "<cmd>GoAlt<cr>", desc = "GoAlt" } },
  },
}
