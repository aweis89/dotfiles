local function ai_review(term_name, prefix)
  term_name = term_name or "aider"
  prefix = prefix or ""
  return function(p, item)
    p:close()
    local pr_num = item.number

    vim.notify("Reviewing PR #" .. pr_num)
    local pr_view_system = vim.system({ "gh", "pr", "view", pr_num }, {})
    local pr_diff_system = vim.system({ "gh", "pr", "diff", pr_num }, {})
    local context = "PR Body\n:" .. pr_view_system:wait().stdout .. "\n\nDiff\n" .. pr_diff_system:wait().stdout
    if term_name == "aider" then
      context = "/ask " .. context
    end
    local term = require("ai-terminals").get(term_name)
    require("ai-terminals").send(context .. "\n Review this PR", { term = term, submit = false, insert_mode = true })
  end
end
return {

  {
    "pwntester/octo.nvim",
    cmd = "Octo",
    opts = {
      gh_cmd = "/opt/homebrew/bin/gh",
      gh_env = function()
        local home = vim.fn.expand("~")
        local token_config = {
          [home .. "/q"] = "Q_GITHUB_TOKEN",
          [home .. "/c"] = "C_GITHUB_TOKEN",
        }

        local token_env_var = "P_GITHUB_TOKEN" -- Default token

        local cwd = vim.fn.getcwd()
        for path_prefix, env_var_name in pairs(token_config) do
          if cwd:sub(1, #path_prefix) == path_prefix then
            vim.notify("Using token from " .. path_prefix, vim.log.levels.WARN)
            token_env_var = env_var_name
            break
          end
        end

        return {
          GH_TOKEN = vim.env[token_env_var],
        }
      end,
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
                fn = ai_review("aider"),
              },
              {
                name = "ai_review_claude",
                lhs = "<localleader>R",
                desc = "Review PR",
                mode = { "n", "i" },
                fn = ai_review("claude"),
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
