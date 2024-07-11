return {
  {
    "mfussenegger/nvim-lint",
    init = function()
      vim.api.nvim_create_user_command("LintDisable", function(args)
        local lint = require('lint')
        -- get filetype of current buffer
        local ft = vim.filetype.match({ buf = 0 })
        if ft and lint.linters_by_ft[ft] then
          -- empty out the linter table for current filetype
          lint.linters_by_ft[ft] = {}
        end
        -- reset diagnostics
        vim.diagnostic.reset(nil, 0)
      end, {
        desc = "Disable autoformat-on-save",
        bang = true,
      })
    end,
    opts = function(_, opts)
      vim.tbl_deep_extend("force", {
        -- Event to trigger linters
        events = { "BufWritePost", "BufReadPost", "InsertLeave" },
        linters_by_ft = {
          go = { "golangcilint" },
          -- Use the "*" filetype to run linters on all filetypes.
          ["*"] = { "codespell" },
          -- Use the "_" filetype to run linters on filetypes that don't have other linters configured.
          -- ['_'] = { 'fallback linter' },
        },

        -- LazyVim extension to easily override linter options
        -- or add custom linters.
        --- @type table<string,table>
        linters = {
          -- -- Example of using selene only when a selene.toml file is present
          -- selene = {
          --   -- `condition` is another LazyVim extension that allows you to
          --   -- dynamically enable/disable linters based on the context.
          --   condition = function(ctx)
          --     return vim.fs.find({ "selene.toml" }, { path = ctx.filename, upward = true })[1]
          --   end,
          -- },
        },
      }, opts)
    end,
  },
}
