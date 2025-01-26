---@param args table
local function git_exec(args)
  local root = Snacks.git.get_root()
  local cmd = { "git", "-C", root }
  for _, arg in ipairs(args) do
    table.insert(cmd, arg)
  end
  if vim.fn.confirm("Run? " .. table.concat(cmd, " "), "&Yes\n&No") == 1 then
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

---@param selected snacks.picker.Item[]
local function aider_add(selected)
  local files = {}
  for _, s in ipairs(selected) do
    table.insert(files, s.file)
  end
  require("aider.terminal").add(files)
end

---@param ctx snacks.picker.preview.ctx
local function git_diff(ctx)
  local native = ctx.picker.opts.previewers.git.native
  local cmd = {
    "git",
    "-c",
    "delta." .. vim.o.background .. "=true",
    "diff",
    "HEAD",
    "--",
    ctx.item.file,
  }
  local exec = Snacks.picker.preview.cmd(
    cmd, ctx, { ft = not native and "diff" or nil }
  )
end

vim.env.DELTA_FEATURES = '+nvim'

---@return boolean
local function is_git_dir()
  local cwd = vim.fn.getcwd()
  _G.picker_git_cwd = _G.picker_git_cwd or {}

  if _G.picker_git_cwd[cwd] == nil then
    _G.picker_git_cwd[cwd] =
        vim.fn.systemlist("git rev-parse --is-inside-work-tree")[1] == "true"
  end
  return _G.picker_git_cwd[cwd]
end

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
      {
        "<leader>fs",
        function()
          local lazypath = vim.fn.stdpath("data") .. "/lazy/"
          Snacks.picker.files({
            dirs = { lazypath },
          })
        end,
        desc = "Lazy Sources",
      },
      {
        "<leader><space>",
        function()
          if is_git_dir() then
            Snacks.picker.git_files()
          else
            Snacks.picker.files()
          end
        end,
        desc = "Files or Git Files",
      },
    },
    ---@type fun(_, opts): snacks.Config
    ---@param opts snacks.Config
    opts = function(_, opts)
      opts.dashboard.preset.header = ""
      table.insert(opts.dashboard.preset.keys, 4, {
        icon = " ", key = "p", desc = "Projects", action = ":lua Snacks.picker.projects()",
      })
      ---@type snacks.Config
      local overrides = {
        picker = {
          previewers = {
            git = { native = true },
          },
          actions = {
            ["copilot_commit"] = function()
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
            ["aider_add"] = function(picker)
              aider_add(picker:selected({ fallback = true }))
            end,
            ["rm_file"] = function(picker)
              rm_file(picker:selected({ fallback = true }))
              Snacks.picker.resume()
            end,
          },
          layout = {
            preset = "ivy",
            layout = {
              width = 0,
              height = 0,
            }
          },
          sources = {
            git_status = {
              preview = git_diff,
              win = {
                input = {
                  keys = {
                    ["<leader><space>s"] = { "git_stage", mode = { "n", "i" } },
                    ["<leader><space>g"] = { "copilot_commit", mode = { "n", "i" } },
                    ["<leader><space>r"] = { "git_reset_file", mode = { "n", "i" } },

                    ["<leader><space>l"] = { "aider_add", mode = { "n", "i" } },
                    ["<leader><space>d"] = { "rm_file", mode = { "n", "i" } },
                  },
                },
              },
            },
            git_log = {
              win = {
                input = {
                  keys = {
                    ["<leader><space>r"] = { "git_reset_soft", mode = { "n", "i" } },
                  },
                },
              },
            },
            files = {
              hidden = true,
              win = {
                input = {
                  keys = {
                    ["<leader><space>l"] = { "aider_add", mode = { "n", "i" } },
                    ["<leader><space>d"] = { "rm_file", mode = { "n", "i" } },
                  },
                },
              },
            },
            grep = {
              hidden = true,
            },
            lines = {
              layout = {
                layout = {
                  width = 0,
                  height = 0.4,
                },
              },
            },
          },
        },
      }

      return vim.tbl_deep_extend("force", opts or {}, overrides)
    end
  },
}
