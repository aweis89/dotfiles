if true then
  return {}
end

return {
  {
    "aweis89/aider.nvim",
    dependencies = {
      -- "akinsho/toggleterm.nvim",
      -- "nvim-telescope/telescope.nvim",
      -- "willothy/flatten.nvim",
      -- "ibhagwan/fzf-lua",
      "folke/snacks.nvim",
      "sindrets/diffview.nvim",
    },
    dir = "/Users/aaron.weisberg/p/aider.nvim",
    event = "VeryLazy",
    opts = {
      aider_args = {
        "--no-auto-commit",
      },

      after_update_hook = function()
        vim.cmd("DiffviewOpen")
      end,

      on_ask_cmd = "/chat-mode ask",
      on_change_req_cmd = "/chat-mode architect",

      restart_on_chdir = true,
      on_term_open = function()
        local function tmap(key, val)
          local opt = { buffer = 0 }
          vim.keymap.set("t", key, val, opt)
        end
        -- exit insert mode
        tmap("<Esc>", "<C-\\><C-n>")
        tmap("jj", "<C-\\><C-n>")
        -- enter command mode
        tmap("<C-;>", "<C-\\><C-n>:")
        -- scrolling up/down
        tmap("<C-u>", "<C-\\><C-n><C-u>")
        tmap("<C-d>", "<C-\\><C-n><C-d>")
      end,
    },
    keys = {
      {
        "<leader>ah",
        function()
          require("aider.snacks_picker").aider_changes()
        end,
        desc = "Aider history",
      },
      { "<leader>ac", "<cmd>AiderCommentAsk<cr>", desc = "Aider comment ask" },
      {
        "<leader>aC",
        "<cmd>AiderComment!<cr>",
        desc = "Aider comment make change",
      },
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
        "<leader>ama",
        "<cmd>AiderSend /architect <bar> AiderSend /model r1 <bar> AiderSend /editor-model sonnet<CR>",
        desc = "Switch to sonnet",
      },
      {
        "<leader>ams",
        "<cmd>AiderSend /model sonnet<CR>",
        desc = "Switch to sonnet",
      },
      {
        "<leader>amd",
        "<cmd>AiderSend /model deepseek/deepseek-chat<CR>",
        desc = "Switch to deepseek",
      },
      {
        "<leader>amr",
        "<cmd>AiderSend /model deepseek/deepseek-reasoner<CR>",
        desc = "Switch to deepseek reasoner",
      },
      {
        "<leader>amR",
        "<cmd>AiderSend /model openrouter/deepseek/deepseek-r1<CR>",
        desc = "Switch to deepseek reasoner",
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
