vim.g.tpipeline_clearstl = 1
vim.g.tpipeline_statusline = "  %{FugitiveHead()} %m%=%<%.40f  "
vim.opt.fillchars = { stlnc = "─", stl = "─", vert = "│" }

return {
  { "akinsho/bufferline.nvim", enabled = false },
  { "nvim-lualine/lualine.nvim", enabled = false },
  { "tpope/vim-fugitive", lazy = false },
  { "vimpostor/vim-tpipeline", lazy = false },
}
