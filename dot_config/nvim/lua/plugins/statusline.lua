vim.g.tpipeline_clearstl = 1
vim.g.tpipeline_statusline = "%!tpipeline#stl#line()"
vim.opt.fillchars = { stlnc = "─", stl = "─", vert = "│" }

return {
  { "akinsho/bufferline.nvim", enabled = false },
  {
    "nvim-lualine/lualine.nvim",
    enabled = false,
  },
  {
    "vimpostor/vim-tpipeline",
    dependencies = { "nvim-mini/mini.nvim" },
    lazy = false,
  },
}
