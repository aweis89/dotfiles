return {
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
    keys = {
      {
        "<leader>dvh",
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
          if remote_ref then
            -- Extract remote and branch name (e.g., "origin", "main" from "origin/main")
            local remote, branch = remote_ref:match("([^/]+)/(.+)")
            if remote and branch then
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
            else
              vim.notify("Could not parse remote and branch from ref: " .. remote_ref, vim.log.levels.WARN)
            end
          else
            vim.notify("Could not determine remote default branch for Diffview.", vim.log.levels.WARN)
          end
        end,
        { desc = "DiffviewOpen origin/default...HEAD (fetches first)" },
      },
      {
        "<leader>dvc",
        function()
          vim.cmd("DiffviewClose")
        end,
        { desc = "DiffviewClose" },
      },
    },
  },
}
