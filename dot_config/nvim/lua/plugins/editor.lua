return {
  {
    "LazyVim/LazyVim",
    priority = 10000,
    lazy = false,
    opts = {},
    cond = true,
    -- set to false to use latest main
    version = "*",
  },
  {
    "nvim-neotest/neotest",
    opts = {
      quickfix = {
        enabled = false,
      },
    },
  },
  {
    "nvim-mini/mini.splitjoin",
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
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      --remove markdown from ensure_installed
      opts.ensure_installed = vim.tbl_filter(function(lang)
        return lang ~= "markdown" or lang ~= "jsonc"
      end, opts.ensure_installed)

      vim.filetype.add({
        extension = {
          tf = "terraform",
          sh = "bash",
          env = "bash",
          html = "html",
          h = "cpp",
          gotmpl = "gotmpl",
          tmpl = "gotmpl",
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
    "nvim-mini/mini.snippets",
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
