return {
  {
    "pwntester/octo.nvim",
    cmd = "Octo",
    opts = {
      picker = "snacks",
      picker_config = {
        mappings = {
          -- snacks uses <c-b> for scrolling
          open_in_browser = { lhs = "<localleader>b", desc = "Open URL issue in browser" },
        },
        snacks = {
          layout = {
            fullscreen = true,
          },
          actions = {
            pull_requests = {
              {
                name = "ai_review",
                lhs = "<localleader>r",
                desc = "Review PR",
                mode = { "n", "i" },
                fn = function(p, item)
                  p:close()
                  local pr_num = item.number

                  vim.notify("Reviewing PR #" .. pr_num)
                  local pr_view_system = vim.system({ "gh", "pr", "view", pr_num }, {})
                  local pr_diff_system = vim.system({ "gh", "pr", "diff", pr_num }, {})
                  local context = "PR Body\n:"
                    .. pr_view_system:wait().stdout
                    .. "\n\nDiff\n"
                    .. pr_diff_system:wait().stdout
                  local term = require("ai-terminals").get("aider")
                  require("ai-terminals").send(
                    "/ask " .. context .. "\n Review this PR",
                    { term = term, submit = false, insert_mode = true }
                  )
                end,
              },
              {
                name = "delta_diff",
                lhs = "<localleader>d",
                desc = "Diff PR",
                mode = { "n", "i" },
                fn = function(p, item)
                  p:close()
                  Snacks.terminal.open(
                    { "/bin/bash", "-c", "gh pr diff " .. item.number .. "| delta --paging=never" },
                    {
                      auto_close = false,
                      win = {
                        keys = {
                          q = function(win)
                            win:destroy()
                          end,
                        },
                      },
                    }
                  )
                end,
              },
            },
          },
        },
      },
    },
  },
}
