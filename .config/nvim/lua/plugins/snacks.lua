--- Helper function to extract files from a snacks picker and send them to aider
---@param picker snacks.Picker
---@param opts? { read_only?: boolean } Options for the command
local function add_files_from_picker(picker, opts)
  local selected = picker:selected({ fallback = true })
  local files_to_add = {}
  for _, item in pairs(selected) do
    if item.file then
      table.insert(files_to_add, item.file)
    end
  end
  require("ai-terminals").aider_add_files(files_to_add, opts)
end

--- Helper function to extract search results and send them to aider
---@param picker snacks.Picker
local function send_search(picker)
  local selected = picker:selected({ fallback = true })
  local items = {}
  for _, item in pairs(selected) do
    table.insert(items, item.text)
  end
  local term = require("ai-terminals").get("aider")
  require("ai-terminals").send(table.concat(items, "\n"), { term = term })
end

---@param args table
local function git_exec(args)
  local root = Snacks.git.get_root()
  local cmd = { "git", "-C", root }
  for _, arg in ipairs(args) do
    table.insert(cmd, arg)
  end
  if vim.fn.confirm(table.concat(cmd, " "), "&Yes\n&No") == 1 then
    vim.fn.system(cmd)
    vim.cmd("checktime")
  end
end

---@param selected snacks.picker.Item[]
local function git_reset_file(selected)
  for _, s in ipairs(selected) do
    local text = s.text:gsub("^%s*", "")
    local is_untracked = text:sub(1, 1) == "?"
    if is_untracked then
      git_exec({ "clean", "-f", s.file })
    else
      git_exec({ "checkout", "HEAD", "--", s.file })
    end
  end
end

---@param selected snacks.picker.Item[]
local function git_reset_soft(selected)
  local text = selected[1].text
  local commit_hash = text:match("^(%x+)")
  git_exec({ "reset", "--soft", commit_hash })
end

---@param selected snacks.picker.preview.ctx
local function rm_file(selected)
  for _, s in ipairs(selected) do
    vim.fn.delete(s.file)
    vim.notify("Deleted: " .. s.file)
  end
end

---@param picker snacks.Picker
local function refresh_picker(picker)
  picker:close()
  Snacks.picker.resume()
end

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
    "folke/snacks.nvim",
    keys = {
      {
        "<leader>hp",
        function()
          pr_picker()
        end,
        desc = "PR picker",
      },
      {
        "<leader><space>",
        function()
          Snacks.picker.smart()
        end,
        desc = "Smart Find Files",
      },
      {
        "<leader>gL",
        function()
          Snacks.picker.git_log_file()
        end,
        desc = "Git Log (file)",
      },
      {
        "<leader>sp",
        function()
          Snacks.picker.pick()
        end,
        desc = "Snacks pick pickers",
      },
      {
        "<leader>fs",
        function()
          local lazypath = vim.fn.stdpath("data") .. "/lazy/"
          Snacks.picker.files({ dirs = { lazypath } })
        end,
        desc = "Lazy Sources",
      },
    },
    ---@type fun(_, opts): snacks.Config
    ---@param opts snacks.Config
    opts = function(_, opts)
      opts.dashboard.preset.header = ""
      local git_log_settings = {
        win = {
          input = {
            keys = {
              ["<localleader>r"] = { "git_reset_soft", mode = { "n", "i" } },
            },
          },
        },
      }

      vim.env.DELTA_FEATURES = "+nvim"

      ---@type snacks.Config
      ---@diagnostic disable
      local overrides = {
        picker = {
          previewers = {
            -- use delta for git diffs
            git = { builtin = false },
            diff = { builtin = false },
          },
          actions = {
            ["aider_search"] = function(picker)
              picker:close()
              send_search(picker) -- Defaults to { read_only = false } -> /add
            end,
            ["aider_add"] = function(picker)
              picker:close()
              add_files_from_picker(picker) -- Defaults to { read_only = false } -> /add
            end,
            ["aider_read_only"] = function(picker)
              picker:close()
              add_files_from_picker(picker, { read_only = true }) -- Send /read-only
            end,
            ["commit"] = function(picker)
              picker:close()
              -- see autocmds.lua for AI auto-generated functionality
              vim.cmd("tab Git commit -v")
            end,
            ---@param picker snacks.Picker
            ["git_reset_file"] = function(picker)
              git_reset_file(picker:selected({ fallback = true }))
              refresh_picker(picker)
            end,
            ["git_reset_soft"] = function(picker)
              git_reset_soft(picker:selected({ fallback = true }))
              refresh_picker(picker)
            end,
            ["rm_file"] = function(picker)
              rm_file(picker:selected({ fallback = true }))
              refresh_picker(picker)
            end,
          },
          sources = {
            projects = {
              dev = { "~/c", "~/q", "~/p" },
            },
            git_status = {
              win = {
                input = {
                  keys = {
                    ["<localleader>s"] = { "git_stage", mode = { "n", "i" } },
                    ["<localleader>g"] = { "commit", mode = { "n", "i" } },
                    ["<localleader>r"] = { "git_reset_file", mode = { "n", "i" } },
                  },
                },
              },
            },
            git_log = git_log_settings,
            git_log_file = git_log_settings,
            grep = {
              hidden = true,
            },
          },
        },
      }

      local fullscreen_pickers = {
        "buffers",
        "files",
        "git_diff",
        "git_files",
        "git_log_file",
        "git_log",
        "git_status",
        "grep_buffers",
        "grep_word",
        "grep",
        "projects",
        "recent",
        "smart",
      }
      for _, fp in ipairs(fullscreen_pickers) do
        overrides.picker.sources[fp] = vim.tbl_deep_extend("force", overrides.picker.sources[fp] or {}, {
          hidden = true,
          layout = {
            layout = {
              width = 0,
              height = 0,
            },
          },
          win = {
            input = {
              keys = {
                ["<localleader>a"] = { "aider_add", mode = { "n", "i" } },
                ["<localleader>A"] = { "aider_read_only", mode = { "n", "i" } },
                ["<localleader>d"] = { "rm_file", mode = { "n", "i" } },
                -- ["<localleader>s"] = { "aider_search", mode = { "n", "i" } },
              },
            },
          },
        })
      end

      return vim.tbl_deep_extend("force", opts or {}, overrides)
    end,
  },
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
