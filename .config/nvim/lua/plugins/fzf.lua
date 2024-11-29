return {
  {
    "ibhagwan/fzf-lua",
    opts = function()
      return {
        winopts = {
          fullscreen = true,
        },
        keymap = {
          builtin = {
            ["<C-w>"] = "toggle-preview",
          },
          fzf = {
            ["<C-w>"] = "toggle-preview",
          },
        },
      }
    end,
  },
}
