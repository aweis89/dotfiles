return {
  {
    "ibhagwan/fzf-lua",
    opts = function()
      return {
        winopts = {
          fullscreen = true,
        },
        defaults = {
          keymap = {
            builtin = {
              ["ctrl-w"] = "toggle-preview",
            },
            fzf = {
              ["ctrl-w"] = "toggle-preview",
            },
          },
        },
      }
    end,
  },
}
