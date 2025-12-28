---@param args table
---@param opts? { confirm?: boolean }
local function git_exec(args, opts)
  opts = opts or {}
  local confirm = opts.confirm ~= false -- default to true if not specified
  local root = Snacks.git.get_root()
  local cmd = { "git", "-C", root }
  for _, arg in ipairs(args) do
    table.insert(cmd, arg)
  end
  if not confirm or vim.fn.confirm(table.concat(cmd, " "), "&Yes\n&No") == 1 then
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

-- modify snack's git stage/unstage with -f
local function git_stage(picker)
  local items = picker:selected({ fallback = true })
  local first = items[1]
  if not first or not (first.status or (first.diff and first.staged ~= nil)) then
    Snacks.notify.error("Can't stage/unstage this change", { title = "Snacks Picker" })
    return
  end

  local done = 0
  for _, item in ipairs(items) do
    local opts = { cwd = item.cwd } ---@type snacks.picker.util.cmd.Opts
    local cmd ---@type string[]
    if item.diff and item.staged ~= nil then
      opts.input = item.diff
      cmd = { "git", "apply", "--cached", item.staged and "--reverse" or nil }
    elseif item.status then
      cmd = item.status:sub(2) == " " and { "git", "restore", "--staged", item.file }
        or { "git", "add", "-f", item.file }
    else
      Snacks.notify.error("Can't stage/unstage this change", { title = "Snacks Picker" })
      return
    end
    Snacks.picker.util.cmd(cmd, function()
      done = done + 1
      if done == #items then
        picker:refresh()
      end
    end, opts)
  end
end

local function defer_insert()
  vim.defer_fn(function()
    vim.cmd.startinsert()
  end, 200)
end

return {
  {
    "folke/snacks.nvim",
    keys = {
      {
        "<leader>gP",
        function()
          Snacks.picker.gh_actions()
        end,
        desc = "Github PR Actions",
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
        desc = "Snacks Pickers",
      },
      {
        "<leader>fs",
        function()
          local lazypath = vim.fn.stdpath("data") .. "/lazy/"
          Snacks.picker.files({ dirs = { lazypath } })
        end,
        desc = "Lazy Sources",
      },
      {
        "//",
        function()
          Snacks.picker.lines()
        end,
        desc = "Buffer Search",
      },
      {
        "<C-f>f",
        function()
          Snacks.picker.files()
          defer_insert()
        end,
        desc = "Find Files",
        mode = "t",
      },
      {
        "<leader>fc",
        function()
          local cwd = vim.fn.system("chezmoi source-path " .. vim.fn.stdpath("config")):gsub("\n", "")
          Snacks.picker.files({ cwd = cwd })
          defer_insert()
        end,
        desc = "Find Config Files",
      },
      {
        "<C-f>g",
        function()
          Snacks.picker.git_files()
          defer_insert()
        end,
        desc = "Find Git Files",
        mode = "t",
      },
      {
        "<C-f>r",
        function()
          Snacks.picker.recent()
          defer_insert()
        end,
        desc = "Find Recent Files",
        mode = "t",
      },
      {
        "<C-f>p",
        function()
          Snacks.picker.projects()
          defer_insert()
        end,
        desc = "Find Recent Files",
        mode = "t",
      },
    },
    ---@type fun(_, opts): snacks.Config
    ---@param opts snacks.Config
    opts = function(_, opts)
      -- opts.dashboard.enabled = false
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
        notifier = {
          level = vim.log.levels.INFO,
          -- show messages on bottom right as not to conflict with cmdline
          top_down = false,
          style = "compact",
        },
        gitbrowse = {
          config = function(opts, defaults)
            -- Strip user:password@
            table.insert(opts.remote_patterns, { "^https://.*@(.*)", "https://%1" })
          end,
        },
        picker = {
          layout = {
            cycle = true,
            fullscreen = true,
            preset = "ivy",
          },
          formatters = {
            file = {
              truncate = 90,
            },
          },
          previewers = {
            diff = {
              style = "terminal",
              cmd = { "delta" },
            },
            git = {
              args = { "-c", "delta.side-by-side=true" },
            },
          },
          win = {
            input = {
              keys = {
                ["<C-v>"] = { "explorer_paste", mode = { "n", "x" } },
                ["<C-h>"] = { "toggle_hidden", mode = { "i", "n" } },
                ["<localleader>c"] = { "toggle_cwd", mode = { "n", "i" } },
              },
            },
          },
          actions = {
            ["commit"] = function(picker)
              picker:close()
              -- see autocmds.lua for AI auto-generated functionality
              vim.cmd("tab Git commit -v")
            end,
            ---@param picker snacks.Picker
            ["git_reset_file"] = function(picker)
              git_reset_file(picker:selected({ fallback = true }))
              picker:refresh()
            end,
            ["git_reset_soft"] = function(picker)
              git_reset_soft(picker:selected({ fallback = true }))
              picker:refresh()
            end,
            ["rm_file"] = function(picker)
              rm_file(picker:selected({ fallback = true }))
              picker:refresh()
            end,
            ["copy_preview"] = function(picker)
              local selected = picker:selected({ fallback = true })
              if selected[1] and selected[1].preview and selected[1].preview.text then
                vim.fn.setreg("*", selected[1].preview.text)
              end
              picker:close()
            end,
            ["git_stage"] = git_stage,
            ["git_reverse_hunk"] = function(picker)
              local items = picker:selected({ fallback = true })
              local done = 0
              for _, item in ipairs(items) do
                if item.diff then
                  Snacks.picker.util.cmd({ "git", "apply", "--reverse" }, function()
                    done = done + 1
                    if done == #items then
                      picker:refresh()
                    end
                  end, { cwd = item.cwd, input = item.diff })
                else
                  Snacks.notify.error("Can't reverse this change", { title = "Snacks Picker" })
                  return
                end
              end
            end,
          },
          sources = {
            projects = {
              dev = { "~/c", "~/q", "~/q/go-services/pkg/", "~/q/go-services/svc/", "~/p" },
              patterns = { "go.sum", "go.mod", ".git" },
              win = {
                input = {
                  keys = {
                    -- default to file picker
                    ["<cr>"] = { { "tcd", "picker_files" }, mode = { "n", "i" } },
                  },
                },
              },
            },
            notifications = {
              win = {
                input = {
                  keys = {
                    ["<cr>"] = { "copy_preview", mode = { "n", "i" } },
                  },
                },
              },
            },
            buffers = {
              -- don't show old buffer name when renamed (e.g. terminal buffers)
              unloaded = false,
            },
            git_status = {
              layout = {
                preview = "main",
                fullscreen = false,
              },
              win = {
                input = {
                  keys = {
                    ["<localleader>r"] = { "git_reset_file", mode = { "n", "i" } },

                    ["<localleader>s"] = { "git_stage", mode = { "n", "i" } },
                    ["<localleader>g"] = { "commit", mode = { "n", "i" } },
                  },
                },
              },
            },
            git_diff = {
              layout = {
                preview = "main",
                fullscreen = false,
              },
              win = {
                input = {
                  keys = {
                    ["<localleader>r"] = { "git_reverse_hunk", mode = { "n", "i" } },

                    ["<localleader>s"] = { "git_stage", mode = { "n", "i" } },
                    ["<localleader>g"] = { "commit", mode = { "n", "i" } },
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

      local file_action_pickers = {
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
        "explorer",
      }

      local file_picker_actions = {
        win = {
          input = {
            keys = {
              ["<localleader>d"] = { "rm_file", mode = { "n", "i" } },
              -- ["<localleader>s"] = { "aider_search", mode = { "n", "i" } },
            },
          },
        },
      }

      local ok, sa = pcall(require, "ai-terminals.snacks_actions")
      if ok then
        sa.apply(overrides)
      end

      -- Apply file action keybindings
      for _, picker_name in ipairs(file_action_pickers) do
        overrides.picker.sources[picker_name] =
          vim.tbl_deep_extend("force", overrides.picker.sources[picker_name] or {}, file_picker_actions)
      end

      return vim.tbl_deep_extend("force", opts or {}, overrides)
    end,
  },
}
