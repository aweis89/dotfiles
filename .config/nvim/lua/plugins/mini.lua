return {
  {
    'echasnovski/mini.splitjoin',
    version = false,
    config = true,
    keys = { {
      '<leader>ms',
      function() require("mini.splitjoin").split() end
    } }
  },
}
