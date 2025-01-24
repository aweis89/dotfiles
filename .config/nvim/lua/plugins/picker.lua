---@param cmd table
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


return {
  {
    "folke/snacks.nvim",
    keys = {
      {
        "<leader>fs",
        function()
          local lazypath = vim.fn.stdpath("data") .. "/lazy/"
          require("snacks").picker.files({
            dirs = { lazypath },
          })
        end,
        desc = "Lazy Sources",
      },
      {
        "<leader><space>",
        function()
          local cwd = vim.fn.getcwd()
          if not _G.picker_git_cwd then
            _G.picker_git_cwd = {}
          end
          if _G.picker_git_cwd[cwd] == nil then
            _G.picker_git_cwd[cwd] =
                vim.fn.systemlist("git rev-parse --is-inside-work-tree")[1] == "true"
          end
          if _G.picker_git_cwd[cwd] then
            require("snacks").picker.git_files()
          else
            require("snacks").picker.files()
          end
        end,
        desc = "Files or Git Files",
      },
    },
    ---@type snacks.Config
    opts = {
      picker = {
        actions = {
          ["copilot_commit"] = function()
            vim.cmd("CopilotChatCommit")
          end,
          ---@param picker snacks.Picker
          ["git_reset_file"] = function(picker)
            git_reset_file(picker:selected({ fallback = true }))
            require("snacks").picker.git_status()
          end,
          ["git_reset_soft"] = function(picker)
            git_reset_soft(picker:selected({ fallback = true }))
          end,
        },
        layout = {
          layout = {
            width = 0.9,
            height = 0.9,
          }
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
        }
      }
    }
  },
}
