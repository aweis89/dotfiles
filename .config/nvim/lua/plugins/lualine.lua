-- use lualine as bufferline
return {
  { "akinsho/bufferline.nvim", enabled = false },
  {
    "nvim-lualine/lualine.nvim",
    opts = {
      sections = {
        -- remove progress and location
        lualine_y = {},
        -- change time for buffers
        lualine_z = { "buffers" },
      },
    },
  },
}
