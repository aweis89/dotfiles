return {
  {
    "nathom/filetype.nvim",
    opts = {
      overrides = {
        -- extensions = {
        --   -- Set the filetype of *.pn files to potion
        --   pn = "potion",
        -- },
        literal = {
          config = "toml",
          [".zshrc"] = "bash",
          [".sh"] = "bash",
        },
        -- The same as the ones above except the keys map to functions
        function_extensions = {
          ["keymap"] = function()
            vim.cmd("set syntax=dts")
          end,
        },
        shebang = {
          -- Set the filetype of files with a dash shebang to sh
          dash = "sh",
        },
        complex = {
          ["templates/.*yaml"] = "helm",
          [".*Dockerfile.*"] = "dockerfile",
        },
      },
    },
  },
}
