return {
  {
    "xvzc/chezmoi.nvim",
    init = function()
      -- run chezmoi edit on file enter
      vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        pattern = { os.getenv("HOME") .. "/.local/share/chezmoi/*" },
        callback = function()
          -- skip COMMIT_EDITMSG files
          local buf_name = vim.api.nvim_buf_get_name(0)
          if buf_name:match("COMMIT_EDITMSG$") then
            return
          end
          vim.schedule(require("chezmoi.commands.__edit").watch)
        end,
      })
    end,
  },
}
