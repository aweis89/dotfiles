return {
  {
    "aweis89/aider.nvim",
    dependencies = {
      "akinsho/toggleterm.nvim",
      "nvim-telescope/telescope.nvim",
      "j-hui/fidget.nvim",
    },
    dir = "/Users/aaron.weisberg/p/aider.nvim",
    lazy = false,
    opts = {
      win = {
        -- direction = "tab",
      },
      after_update_hook = function()
        require("telescope.command").load_command("git_commits")

        -- require("diffview").open({ "HEAD^" })
      end,
      -- remove these comments ai!
      -- on_term_open = function()
      --   local function tmap(key, val)
      --     local opt = { buffer = 0 }
      --     vim.keymap.set("t", key, val, opt)
      --   end
      --   -- exit insert mode
      --   tmap("<Esc>", "<C-\\><C-n>")
      --   tmap("jj", "<C-\\><C-n>")
      --   -- enter command mode
      --   tmap(":", "<C-\\><C-n>:")
      --   -- scrolling up/down
      --   tmap("<C-u>", "<C-\\><C-n><C-u>")
      --   tmap("<C-d>", "<C-\\><C-n><C-d>")
      --   -- remove line numbers
      --   vim.wo.number = false
      --   vim.wo.relativenumber = false
      -- end,
      -- aider_args = "--no-auto-commits",
    },
    keys = {
      {
        "<leader>dvh",
        "<cmd>DiffviewOpen HEAD^<CR>",
        desc = "Diffview HEAD^",
      },
      {
        "<leader>dvo",
        "<cmd>DiffviewOpen<CR>",
        desc = "Diffview",
      },
      {
        "<leader>dvc",
        "<cmd>DiffviewClose!<CR>",
        desc = "Diffview close",
      },
      {
        "<leader>a<space>",
        "<cmd>AiderToggle<CR>",
        desc = "Toggle Aider",
      },
      {
        "<leader>am",
        desc = "Change model",
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
        "<leader>amg",
        "<cmd>AiderSend /model gemini/gemini-exp-1206<CR>",
        desc = "Switch to haiku",
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
        "<cmd>AiderLoad<CR>",
        desc = "Add file to aider",
      },
      {
        "<leader>ad",
        "<cmd>AiderAsk<CR>",
        desc = "Ask with selection",
        mode = { "v", "n" },
      },
    },
  },
}
