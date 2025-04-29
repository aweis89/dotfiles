local function pull_requests(opts)
  opts = opts or {}
  if not opts.states then
    opts.states = "OPEN"
  end

  local function get_filter(opts, kind)
    local filter = ""
    local allowed_values = {}
    if kind == "issue" then
      allowed_values = { "since", "createdBy", "assignee", "mentioned", "labels", "milestone", "states" }
    elseif kind == "pull_request" then
      allowed_values = { "baseRefName", "headRefName", "labels", "states" }
    end

    for _, value in pairs(allowed_values) do
      if opts[value] then
        local val
        if #vim.split(opts[value], ",") > 1 then
          -- list
          val = vim.split(opts[value], ",")
        else
          -- string
          val = opts[value]
        end
        val = vim.json.encode(val)
        val = string.gsub(val, '"OPEN"', "OPEN")
        val = string.gsub(val, '"CLOSED"', "CLOSED")
        val = string.gsub(val, '"MERGED"', "MERGED")
        filter = filter .. value .. ":" .. val .. ","
      end
    end

    return filter
  end

  local gh = require("octo.gh")
  local graphql = require("octo.gh.graphql")
  local utils = require("octo.utils")
  local octo_config = require("octo.config")
  local navigation = require("octo.navigation")
  local Snacks = require("snacks")

  local filter = get_filter(opts, "pull_request")
  if utils.is_blank(opts.repo) then
    opts.repo = utils.get_remote_name()
  end
  if not opts.repo then
    utils.error("Cannot find repo")
    return
  end

  local owner, name = utils.split_repo(opts.repo)
  local cfg = octo_config.values
  local order_by = cfg.pull_requests.order_by
  local query =
    graphql("pull_requests_query", owner, name, filter, order_by.field, order_by.direction, { escape = false })
  utils.info("Fetching pull requests (this may take a while) ...")
  gh.run({
    args = { "api", "graphql", "--paginate", "--jq", ".", "-f", string.format("query=%s", query) },
    cb = function(output, stderr)
      if stderr and not utils.is_blank(stderr) then
        utils.error(stderr)
      elseif output then
        local resp = utils.aggregate_pages(output, "data.repository.pullRequests.nodes")
        local pull_requests = resp.data.repository.pullRequests.nodes
        if #pull_requests == 0 then
          utils.error(string.format("There are no matching pull requests in %s.", opts.repo))
          return
        end
        local max_number = -1
        for _, pull in ipairs(pull_requests) do
          if pull.number > max_number then
            max_number = pull.number
          end
          pull.text = string.format("#%d %s", pull.number, pull.title)
          pull.file = utils.get_pull_request_uri(pull.number, pull.repository.nameWithOwner)
          pull.kind = pull.__typename:lower() == "pullrequest" and "pull_request" or "unknown"
        end

        -- Prepare actions and keys for Snacks
        local final_actions = {}
        local final_keys = {}
        local default_mode = { "n", "i" }

        -- Process custom actions from config array
        local custom_actions_defined = {}
        if
          cfg.picker_config.snacks
          and cfg.picker_config.snacks.actions
          and cfg.picker_config.snacks.actions.pull_requests
        then
          for _, action_item in ipairs(cfg.picker_config.snacks.actions.pull_requests) do
            if action_item.name and action_item.fn then
              final_actions[action_item.name] = action_item.fn
              custom_actions_defined[action_item.name] = true
              if action_item.lhs then
                final_keys[action_item.lhs] = { action_item.name, mode = action_item.mode or default_mode }
              end
            end
          end
        end

        -- Add default actions/keys if not overridden
        if not custom_actions_defined["open_in_browser"] then
          final_actions["open_in_browser"] = function(_picker, item)
            navigation.open_in_browser(item.kind, item.repository.nameWithOwner, item.number)
          end
        end
        if not final_keys[cfg.picker_config.mappings.open_in_browser.lhs] then
          final_keys[cfg.picker_config.mappings.open_in_browser.lhs] = { "open_in_browser", mode = default_mode }
        end

        if not custom_actions_defined["copy_url"] then
          final_actions["copy_url"] = function(_picker, item)
            utils.copy_url(item.url)
          end
        end
        if not final_keys[cfg.picker_config.mappings.copy_url.lhs] then
          final_keys[cfg.picker_config.mappings.copy_url.lhs] = { "copy_url", mode = default_mode }
        end

        if not custom_actions_defined["check_out_pr"] then
          final_actions["check_out_pr"] = function(_picker, item)
            utils.checkout_pr(item.number)
          end
        end
        if not final_keys[cfg.picker_config.mappings.checkout_pr.lhs] then
          final_keys[cfg.picker_config.mappings.checkout_pr.lhs] = { "check_out_pr", mode = default_mode }
        end

        if not custom_actions_defined["merge_pr"] then
          final_actions["merge_pr"] = function(_picker, item)
            utils.merge_pr(item.number)
          end
        end
        if not final_keys[cfg.picker_config.mappings.merge_pr.lhs] then
          final_keys[cfg.picker_config.mappings.merge_pr.lhs] = { "merge_pr", mode = default_mode }
        end

        Snacks.picker.pick({
          title = opts.preview_title or "Pull Requests",
          items = pull_requests,
          format = function(item, _)
            ---@type snacks.picker.Highlight[]
            local ret = {}
            ---@diagnostic disable-next-line: assign-type-mismatch
            ret[#ret + 1] = utils.get_icon({ kind = item.kind, obj = item })
            ret[#ret + 1] = { string.format("#%d", item.number), "Comment" }
            ret[#ret + 1] = { (" "):rep(#tostring(max_number) - #tostring(item.number) + 1) }
            ret[#ret + 1] = { item.title, "Normal" }
            return ret
          end,
          layout = {
            fullscreen = true,
          },
          win = {
            input = {
              keys = final_keys, -- Use the constructed keys map
            },
          },
          actions = final_actions, -- Use the constructed actions map
        })
      end
    end,
  })
end

return {
  {
    "pwntester/octo.nvim",
    cmd = "Octo",
    keys = {
      {
        "<leader>gp",
        function()
          pull_requests()
        end,
        desc = "PR picker",
      },
    },
    opts = {
      picker = "snacks",
      picker_config = {
        mappings = {
          -- snacks uses <c-b> for scrolling
          open_in_browser = { lhs = "<localleader>b", desc = "Open URL issue in browser" },
        },
        snacks = {
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
