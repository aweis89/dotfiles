local function close_gitsigns_diff(key)
  key = key or "q"
  vim.keymap.set("n", key, function()
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      local buf = vim.api.nvim_win_get_buf(win)
      local bufname = vim.api.nvim_buf_get_name(buf)
      if bufname:find("^gitsigns://") then
        vim.api.nvim_win_close(win, true)
      end
    end
    vim.wo.diff = false
  end, { buffer = true, silent = true })
end

local function close_diffview_diff(key)
  key = key or "q"
  vim.keymap.set("n", key, function()
    local diffview = require("diffview")
    diffview.close()
  end, { buffer = true, silent = true })
end

return {
  {
    "tpope/vim-fugitive",
    cmd = { "Git" },
    keys = {
      -- see autocmds.lua for AI auto-generated functionality
      { "<leader>gc", "<cmd>tab Git commit -v<cr>", desc = "Git commit" },
      { "<leader>gp", "<cmd>Git pull | Git push<cr>", desc = "Git commit" },
      {
        "<leader>gp",
        "<cmd>Git pull --rebase --autostash | Git push<cr>",
        desc = "Git push (pull+rebase+stash)",
      },
      { "<leader>gA", "<cmd>Git add --all<cr>", desc = "Git add --all" },
    },
  },
  {
    -- AI-powered commit message generation
    "aweis89/ai-commit-msg.nvim",
    -- dir = "~/p/ai-commit-msg.nvim",
    ft = "gitcommit",
    cmd = { "AiCommitMsgAllModels" },
    config = true,
    ---@class AiCommitMsgConfig
    opts = {
      provider = "gemini",
    },
  },
  {
    "lewis6991/gitsigns.nvim",
    opts = function(_, opts)
      local gs = require("gitsigns")
      local super_on_attach = opts.on_attach

      -- auto preview hunk inline
      local function nav_hunk(direction)
        gs.nav_hunk(direction)
        vim.defer_fn(function()
          gs.preview_hunk_inline()
        end, 500)
      end

      opts.on_attach = function(bufnr)
        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc, remap = true, silent = true })
        end

        super_on_attach(bufnr)

        map("n", "<leader>ghD", function()
          gs.diffthis("~")
          close_gitsigns_diff("q")
        end, "Diff This! ~")

        map("n", "<leader>ghd", function()
          gs.diffthis()
          close_gitsigns_diff("q")
        end, "Diff This!")

        map("n", "<leader>ghU", function()
          gs.reset_buffer_index()
        end, "Undo staged buffer")

        map("n", "]h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            nav_hunk("next")
          end
        end, "Next Hunk")
        map("n", "[h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            nav_hunk("prev")
          end
        end, "Prev Hunk")
        map("n", "]H", function()
          nav_hunk("last")
        end, "Last Hunk")
        map("n", "[H", function()
          nav_hunk("first")
        end, "First Hunk")
      end
    end,
  },
  {
    "sindrets/diffview.nvim",
    cmd = {
      "DiffviewOpen",
      "DiffviewClose",
      "DiffviewFileHistory",
      "DiffviewFocusFiles",
      "DiffviewLog",
      "DiffviewRefresh",
      "DiffviewToggleFiles",
    },
    config = true,
    init = function()
      local diffview = require("diffview")
      local orig = diffview.open
      diffview.open = function(args)
        orig(args)
        close_diffview_diff("q")
      end
    end,
    opts = {
      default_args = {
        -- required to be able to modify diffs against remote branches
        DiffviewOpen = { "--imply-local" },
      },
    },
    keys = {
      {
        "<leader>dvh",
        function()
          local diffview = require("diffview")
          diffview.open({ "HEAD" })
        end,
        desc = "DiffviewOpen HEAD",
      },
      {
        "<leader>dvo",
        function()
          local diffview = require("diffview")
          diffview.open()
        end,
        desc = "DiffviewOpen",
      },
      {
        "<leader>dvs",
        function()
          local diffview = require("diffview")
          diffview.open({ "--staged" })
        end,
        desc = "DiffviewOpen --staged",
      },
      {
        "<leader>dvp",
        function()
          vim.cmd("DiffviewOpen origin/HEAD...HEAD")
        end,
        desc = "DiffviewOpen origin/HEAD...HEAD (fetches first)",
      },
      {
        "<leader>dvc",
        function()
          vim.cmd("DiffviewClose")
        end,
        desc = "DiffviewClose",
      },
    },
  },
}
