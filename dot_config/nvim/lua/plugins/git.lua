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
      {
        "<leader>gc",
        function()
          vim.cmd("tab Git commit -v")
        end,
        desc = "Git commit",
      },
      {
        "<leader>ggp",
        "<cmd>Git push<cr>",
        desc = "Git push (pull+rebase+stash)",
      },
      { "<leader>ga", "<cmd>Git add %<cr>", desc = "Git add current file" },
      { "<leader>gA", "<cmd>Git add --all<cr>", desc = "Git add --all" },
    },
  },
  {
    -- AI-powered commit message generation
    "aweis89/ai-commit-msg.nvim",
    ft = "gitcommit",
    cmd = { "AiCommitMsgAllModels" },
    config = true,
    ---@class AiCommitMsgConfig
    opts = {
      provider = "copilot",
      providers = {
        copilot = {
          model = "openai/gpt-4o-mini",
        },
      },
    },
  },
  {
    "lewis6991/gitsigns.nvim",
    opts = function(_, opts)
      local gs = require("gitsigns")

      opts.on_attach = function(bufnr)
        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc, silent = true })
        end
        map("n", "]H", function()
          gs.nav_hunk("last")
        end, "Last Hunk")
        map("n", "[H", function()
          gs.nav_hunk("first")
        end, "First Hunk")
        map({ "n", "x" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
        map({ "n", "x" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
        map("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")
        map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
        map("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
        map("n", "<leader>ghp", gs.preview_hunk_inline, "Preview Hunk Inline")
        map("n", "<leader>ghb", function()
          gs.blame_line({ full = true })
        end, "Blame Line")
        map("n", "<leader>ghB", function()
          gs.blame()
        end, "Blame Buffer")
        map("n", "<leader>ghd", gs.diffthis, "Diff This")
        map("n", "<leader>ghD", function()
          gs.diffthis("~")
        end, "Diff This ~")
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")

        map("n", "]h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
            return
          end
          if require("unified.diff").is_diff_displayed() then
            require("unified.navigation").next_hunk()
            return
          end
          vim.notify("Gitsigns: Navigating hunks", vim.log.levels.INFO)
          gs.nav_hunk("next")
        end, "Next Hunk")
        map("n", "[h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
            return
          end
          if require("unified.diff").is_diff_displayed() then
            require("unified.navigation").previous_hunk()
            return
          end
          gs.nav_hunk("prev")
        end, "Prev Hunk")

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
      end
    end,
  },
  {
    "axkirillov/unified.nvim",
    cmd = "Unified",
    config = true,
    keys = {
      { "<leader>dvu", "<cmd>Unified -s origin/HEAD<cr>", desc = "Unified: Snacks diff vs origin/HEAD" },
      { "<leader>dvh", "<cmd>Unified HEAD<cr>", desc = "Unified: Default diff vs HEAD" },
      { "<leader>dvr", "<cmd>Unified reset<cr>", desc = "Unified: Reset/close diff" },
    },
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
