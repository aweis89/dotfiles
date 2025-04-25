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

---@param opts snacks.picker.Config
---@type snacks.picker.finder
local function prs(opts, ctx)
  local args = {
    "pr",
    "list",
    "--json",
    "number,title,body",
    "--jq",
    ".[] | [.number, .title, .body] | @tsv",
  }
  return require("snacks.picker.source.proc").proc({
    opts,
    {
      cmd = "gh",
      args = args,
      layout = {
        fullscreen = true,
      },
      ---@param item snacks.picker.finder.Item
      transform = function(item)
        -- Split the tab-separated string "number\ttitle"
        local parts = vim.split(item.text, "\t", { plain = true, trimempty = false })
        item.number = tonumber(parts[1]) -- Convert the first part to a number
        item.title = parts[2] -- The second part is the title
        item.body = parts[3]
      end,
    },
  }, ctx)
end

---@return snacks.Picker
local function pr_picker()
  local picker = require("snacks.picker")
  return picker("pull_requests", {
    title = "Pull requests",
    finder = prs,
    layout = {
      fullscreen = true,
    },
    win = {
      input = {
        keys = {
          ["<CR>"] = { "checkout", mode = { "n", "i" } },
          ["<localleader>r"] = { "ai_review", mode = { "n", "i" } },
        },
      },
    },
    actions = {
      checkout = function(p)
        vim.notify("Checkout action started!") -- DEBUG
        local item = p:current({ fallback = true })
        if not item then
          vim.notify("No item selected!")
          return
        end
        vim.notify("Checking out PR #" .. item.number)
        vim.system({ "gh", "pr", "checkout", item.number }, {}, function(res)
          if res.code ~= 0 then
            vim.notify(res.stderr)
          else
            vim.notify(res.stdout)
          end
        end)
        p:close()
      end,
      ai_review = function(p)
        local item = p:current({ fallback = true })
        if not item then
          vim.notify("No item selected!")
          return
        end
        local pr_num = item.number
        vim.notify("Reviewing PR #" .. pr_num)
        local pr_view_system = vim.system({ "gh", "pr", "view", pr_num }, {})
        local pr_diff_system = vim.system({ "gh", "pr", "diff", pr_num }, {})
        local result = pr_view_system:wait().stdout
        result = result .. pr_diff_system:wait().stdout
        local term = require("ai-terminals").get("aider")
        require("ai-terminals").send("Review this PR carefully\n" .. result, { term = term, submit = true })
      end,
    },
    format = function(item, p)
      return { { string.format("#%d ", item.number), "Function" }, { item.title } }
    end,
    preview = function(ctx)
      ctx.preview:highlight({ ft = "markdown" })
      local lines = vim.split(ctx.item.body, "\\r\\n", { plain = true, trimempty = true })
      ctx.preview:set_lines(lines)
      return true
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
          previewers = { git = { native = true, builtin = true } },
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
    opts = {
      picker = "snacks",
      picker_config = {
        mappings = {
          -- snacks uses <c-b> for scrolling
          open_in_browser = { lhs = "<C-u>", desc = "Open URL issue in browser" },
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
                  local result = pr_view_system:wait().stdout
                  result = result .. pr_diff_system:wait().stdout
                  local term = require("ai-terminals").get("aider")
                  require("ai-terminals").send(
                    "/ask Review this PR carefully\n" .. result,
                    { term = term, submit = true }
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
