return {
  {
    "aweis89/aider.nvim",
    dependencies = {
      "akinsho/toggleterm.nvim",
      "nvim-telescope/telescope.nvim",
      "willothy/flatten.nvim",
      "ibhagwan/fzf-lua",
    },
    dir = "/Users/aaron.weisberg/p/aider.nvim",
    lazy = false,
    opts = {
      after_update_hook = function()
        -- require("telescope.command").load_command("git_commits")

        vim.cmd("DiffviewFileHistory")
      end,
      on_term_open = function()
        local function tmap(key, val)
          local opt = { buffer = 0 }
          vim.keymap.set("t", key, val, opt)
        end
        -- exit insert mode
        tmap("<Esc>", "<C-\\><C-n>")
        tmap("jj", "<C-\\><C-n>")
        -- enter command mode
        tmap(":", "<C-\\><C-n>:")
        -- scrolling up/down
        tmap("<C-u>", "<C-\\><C-n><C-u>")
        tmap("<C-d>", "<C-\\><C-n><C-d>")
      end,
    },
    keys = {
      {
        "<leader>a<space>",
        "<cmd>AiderToggle<CR>",
        desc = "Toggle Aider (last window format)",
      },
      {
        "<leader>af",
        "<cmd>AiderToggle tab<CR>",
        desc = "Toggle Aider FullScreen",
      },
      {
        "<leader>av",
        "<cmd>AiderToggle vertical<CR>",
        desc = "Toggle Aider vertical",
      },
      {
        "<C-x>",
        "<cmd>AiderToggle<CR>",
        desc = "Toggle Aider",
        mode = { "i", "t", "n" },
      },
      {
        "<leader>as",
        "<cmd>AiderSpawn<CR>",
        desc = "Toggle Aidper (default)",
      },
      {
        "<leader>al",
        "<cmd>AiderAdd<CR>",
        desc = "Add file to aider",
      },
      {
        "<leader>ar",
        "<cmd>AiderReadOnly<CR>",
        desc = "Add read-only file to aider",
      },
      {
        "<leader>ad",
        "<cmd>AiderAsk<CR>",
        desc = "Ask with selection",
        mode = { "v", "n" },
      },

      {
        "<leader>ams",
        "<cmd>AiderSend /model sonnet<CR>",
        desc = "Switch to sonnet",
      },
      {
        "<leader>amh",
        "<cmd>AiderSend /model haiku<CR>",
        desc = "Switch to haiku",
      },
      {
        "<leader>amd",
        "<cmd>AiderSend /model deepseek/deepseek-chat<CR>",
        desc = "Switch to deepseek",
      },
      {
        "<leader>amg",
        "<cmd>AiderSend /model gemini/gemini-exp-1206<CR>",
        desc = "Switch to gemini",
      },
      -- Useful git diff integrations
      {
        "<leader>ghh",
        "<cmd>Gitsigns change_base HEAD^<CR>",
        desc = "Gitsigns pick reversals",
      },
      {
        "<leader>dvh",
        "<cmd>DiffviewFileHistory<CR>",
        desc = "Diffview History Log",
      },
      {
        "<leader>dvc",
        "<cmd>DiffviewClose!<CR>",
        desc = "Diffview close",
      },
    },
  },
}
