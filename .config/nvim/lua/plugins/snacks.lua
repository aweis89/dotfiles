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

return {
  {
    "folke/snacks.nvim",
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
              ["<leader><space>r"] = { "git_reset_soft", mode = { "n", "i" } },
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
            ["copilot_commit"] = function(picker)
              picker:close()
              vim.cmd("CopilotChatCommit")
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
                ["<leader><space>a"] = { "aider_add", mode = { "n", "i" } },
                ["<leader><space>A"] = { "aider_read_only", mode = { "n", "i" } },
                ["<leader><space>d"] = { "rm_file", mode = { "n", "i" } },
                ["<leader><space>s"] = { "aider_search", mode = { "n", "i" } },
              },
            },
          },
        })
      end

      return vim.tbl_deep_extend("force", opts or {}, overrides)
    end,
  },
}
