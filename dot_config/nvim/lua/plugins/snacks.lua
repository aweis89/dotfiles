--- Helper function to extract files from a snacks picker and send them to aider
---@param picker snacks.Picker
---@param term string
---@param opts? { read_only?: boolean } Options for the command
local function add_files_from_picker(picker, term, opts)
  local selected = picker:selected({ fallback = true })
  local files_to_add = {}
  for _, item in pairs(selected) do
    if item.file then
      -- Use Snacks.picker.util.path() to get the absolute path
      -- This is necessary to get the absolute path from project picker
      local abs_path = Snacks.picker.util.path(item)
      if abs_path then
        table.insert(files_to_add, abs_path)
      end
    end
  end
  require("ai-terminals").add_files_to_terminal(term, files_to_add, opts)
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

local function defer_insert()
  vim.defer_fn(function()
    vim.cmd.startinsert()
  end, 200)
end

return {
  {
    "folke/snacks.nvim",
    repo = "aweis89/snacks.nvim",
    branch = "fix-relative-path",
    -- use fork for zoom/unzoom fix for neovim terminal buffers
    url = "https://github.com/aweis89/snacks.nvim",
    keys = {
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
        },
        gitbrowse = {
          config = function(opts, defaults)
            -- Strip user:password@
            table.insert(opts.remote_patterns, { "^https://.*@(.*)", "https://%1" })
          end,
        },
        picker = {
          formatters = {
            file = {
              truncate = 90,
            },
          },
          previewers = {
            -- use delta for git diffs
            -- git = { builtin = false },
            -- diff = { builtin = false },
          },
          win = {
            input = {
              keys = { ["<c-v>"] = { "explorer_paste", mode = { "n", "x" } } },
            },
          },
          actions = {
            ["aider_search"] = function(picker)
              picker:close()
              send_search(picker)
            end,
            ["aider_add"] = function(picker)
              picker:close()
              add_files_from_picker(picker, "aider")
            end,
            ["aider_read_only"] = function(picker)
              picker:close()
              add_files_from_picker(picker, "aider", { read_only = true }) -- Send /read-only
            end,
            ["claude_add"] = function(picker)
              picker:close()
              add_files_from_picker(picker, "claude")
            end,
            ["codex_add"] = function(picker)
              picker:close()
              add_files_from_picker(picker, "codex")
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
            ["copy_preview"] = function(picker)
              local selected = picker:selected({ fallback = true })
              if selected[1] and selected[1].preview and selected[1].preview.text then
                vim.fn.setreg("*", selected[1].preview.text)
              end
              picker:close()
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
              ["<localleader>aa"] = { "aider_add", mode = { "n", "i" } },
              ["<localleader>Aa"] = { "aider_read_only", mode = { "n", "i" } },
              ["<localleader>ac"] = { "claude_add", mode = { "n", "i" } },
              ["<localleader>ad"] = { "codex_add", mode = { "n", "i" } },
              ["<localleader>d"] = { "rm_file", mode = { "n", "i" } },
              -- ["<localleader>s"] = { "aider_search", mode = { "n", "i" } },
            },
          },
        },
      }

      -- Apply fullscreen settings
      for _, picker_name in ipairs(fullscreen_pickers) do
        local fullscreen_config = {
          hidden = true,
          layout = {
            layout = {
              width = 0,
              height = 0,
            },
          },
        }
        overrides.picker.sources[picker_name] =
          vim.tbl_deep_extend("force", overrides.picker.sources[picker_name] or {}, fullscreen_config)
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
