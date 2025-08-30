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
    },
  },
  {
    -- AI-powered commit message generation
    "aweis89/ai-commit-msg.nvim",
    dir = "~/p/ai-commit-msg.nvim",
    ft = "gitcommit",
    config = true,
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
          -- Function to get the remote default branch reference (e.g., origin/main)
          local function get_remote_default_branch_ref()
            -- Try rev-parse first (most reliable)
            local ref = vim.fn.trim(vim.fn.system("git rev-parse --abbrev-ref origin/HEAD"))
            if vim.v.shell_error == 0 and ref ~= "" and ref ~= "origin/HEAD" then
              return ref -- e.g., "origin/main"
            end

            -- Fallback: Check remote show
            local head_branch_cmd = "git remote show origin | grep 'HEAD branch' | cut -d' ' -f5"
            local branch_name = vim.fn.trim(vim.fn.system(head_branch_cmd))
            if vim.v.shell_error == 0 and branch_name ~= "" then
              return "origin/" .. branch_name -- Construct e.g., "origin/main"
            end

            -- Fallback: Check common names explicitly if they exist remotely
            vim.fn.system("git show-ref --verify --quiet refs/remotes/origin/main")
            if vim.v.shell_error == 0 then
              return "origin/main"
            end
            vim.fn.system("git show-ref --verify --quiet refs/remotes/origin/master")
            if vim.v.shell_error == 0 then
              return "origin/master"
            end

            -- If all checks fail
            return nil
          end

          local remote_ref = get_remote_default_branch_ref()
          if not remote_ref then
            vim.notify("Could not determine remote default branch for Diffview.", vim.log.levels.WARN)
            return
          end

          -- Extract remote and branch name (e.g., "origin", "main" from "origin/main")
          local remote, branch = remote_ref:match("([^/]+)/(.+)")
          if not remote or not branch then
            vim.notify("Could not parse remote and branch from ref: " .. remote_ref, vim.log.levels.WARN)
            return
          end

          vim.notify(string.format("Fetching latest %s...", remote_ref), vim.log.levels.INFO)
          local fetch_cmd = string.format("git fetch %s %s", remote, branch)
          vim.fn.system(fetch_cmd) -- Execute the fetch command

          if vim.v.shell_error == 0 then
            vim.notify(string.format("Opening diff against %s...", remote_ref), vim.log.levels.INFO)
            vim.cmd(string.format("DiffviewOpen %s...HEAD", remote_ref))
          else
            vim.notify(
              string.format("Failed to fetch %s. Opening diff against potentially stale ref.", remote_ref),
              vim.log.levels.WARN
            )
            -- Still try to open, it might work with the last known state
            vim.cmd(string.format("DiffviewOpen %s...HEAD", remote_ref))
          end
        end,
        desc = "DiffviewOpen origin/default...HEAD (fetches first)",
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
