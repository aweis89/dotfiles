return {
  {
    "tpope/vim-fugitive",
    cmd = { "Git" },
  },
  {
    "echasnovski/mini.splitjoin",
    version = false,
    config = true,
    keys = { {
      "<leader>ms",
      function()
        require("mini.splitjoin").split()
      end,
    } },
  },
  {
    "nvim-neotest/neotest",
    opts = {
      neotest = {
        diagnostic = true,
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, _)
      vim.filetype.add({
        extension = {
          tf = "terraform",
          sh = "bash",
          env = "bash",
          html = "html",
          h = "cpp",
        },
        filename = {
          config = "toml",
          [".zshrc"] = "bash",
        },
        pattern = {
          ["templates/.*yaml"] = "helm",
          [".*Dockerfile.*"] = "dockerfile",
        },
      })
    end,
  },
  {
    "echasnovski/mini.snippets",
    opts = function()
      local gen_loader = require("mini.snippets").gen_loader
      return {
        snippets = {
          gen_loader.from_lang({
            lang_patterns = {
              yaml = { -- Map 'yaml' filetype to 'kubernetes'
                "**/kubernetes.json",
                "**/kubernetes.lua",
                "kubernetes/**/*.json",
                "kubernetes/**/*.lua",
              },
            },
          }),
        },
      }
    end,
  },
}
