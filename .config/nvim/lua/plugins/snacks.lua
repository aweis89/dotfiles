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
      git_exec { "clean", "-f", s.file }
    else
      git_exec { "checkout", "HEAD", "--", s.file }
    end
  end
end

---@param selected snacks.picker.Item[]
local function git_reset_soft(selected)
  local text = selected[1].text
  local commit_hash = text:match("^(%x+)")
  git_exec { "reset", "--soft", commit_hash }
end

vim.env.DELTA_FEATURES = '+nvim'

---@param selected snacks.picker.preview.ctx
local function rm_file(selected)
  for _, s in ipairs(selected) do
    vim.fn.delete(s.file)
    vim.notify("Deleted: " .. s.file)
  end
end

return {
  {
    "folke/snacks.nvim",
    keys = {
      { "<leader><space>", function() Snacks.picker.smart() end,        desc = "Smart Find Files" },
      { "<leader>gL",      function() Snacks.picker.git_log_file() end, desc = "Git Log (file)" },
      { "<leader>sp",      function() Snacks.picker.pick() end,         desc = "Snacks pick pickers" },
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
              ["<leader><space>r"] = { "git_reset_soft", mode = { "n", "i" } },
            },
          },
        },
      }
      ---@type snacks.Config
      ---@diagnostic disable
      local overrides = {
        picker = {
          previewers = { git = { native = true }},
          actions = {
            ["copilot_commit"] = function(picker)
              picker:close()
              vim.cmd("CopilotChatCommit")
            end,
            ---@param picker snacks.Picker
            ["git_reset_file"] = function(picker)
              git_reset_file(picker:selected({ fallback = true }))
              Snacks.picker.resume()
            end,
            ["git_reset_soft"] = function(picker)
              git_reset_soft(picker:selected({ fallback = true }))
            end,
            ["rm_file"] = function(picker)
              rm_file(picker:selected({ fallback = true }))
              Snacks.picker.resume()
            end,
          },
          sources = {
            git_status = {
              win = {
                input = {
                  keys = {
                    ["<leader><space>s"] = { "git_stage", mode = { "n", "i" } },
                    ["<leader><space>g"] = { "copilot_commit", mode = { "n", "i" } },
                    ["<leader><space>r"] = { "git_reset_file", mode = { "n", "i" } },
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

      overrides.picker.sources = overrides.picker.sources or {}
      local file_sources = {
        "buffers",
        "files",
        "git_files",
        "git_status",
        "recent",
        "smart",
      }
      for _, fp in ipairs(file_sources) do
        overrides.picker.sources[fp] = vim.tbl_deep_extend("force",
          overrides.picker.sources[fp] or {},
          {
            hidden = true,
            win = {
              input = {
                keys = {
                  ["<leader><space>l"] = { "aider_add", mode = { "n", "i" } },
                  ["<leader><space>L"] = { "aider_read_only", mode = { "n", "i" } },
                  ["<leader><space>d"] = { "rm_file", mode = { "n", "i" } },
                },
              },
            },
          }

        )
      end

      local fullscreen = {
        "buffers",
        "files",
        "git_files",
        "git_log",
        "git_log_file",
        "git_status",
        "grep",
        "grep_buffers",
        "grep_word",
        "recent",
        "smart",
        "projects",
      }
      for _, fp in ipairs(fullscreen) do
        overrides.picker.sources[fp] = vim.tbl_deep_extend("force",
          overrides.picker.sources[fp] or {}, {
            layout = {
              layout = {
                width = 0,
                height = 0,
              },
            },
          }
        )
      end

      return vim.tbl_deep_extend("force", opts or {}, overrides)
    end
  },
}
