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
          if not _G.fzf_git_cache then
            _G.fzf_git_cache = {}
          end
          if _G.fzf_git_cache[cwd] == nil then
            _G.fzf_git_cache[cwd] =
                vim.fn.systemlist("git rev-parse --is-inside-work-tree")[1] == "true"
          end
          if _G.fzf_git_cache[cwd] then
            if vim.g.lazyvim_picker == "snacks" then
              require("snacks").picker.git_files()
            else
              vim.cmd("FzfLua git_files")
            end
          else
            if vim.g.lazyvim_picker == "snacks" then
              require("snacks").picker.files()
            else
              vim.cmd("FzfLua files")
            end
          end
        end,
      },
    },
    ---@type snacks.Config
    opts = {
      picker = {
        actions = {
          ---@param picker snacks.Picker
          ["copilot_commit"] = function(picker)
            vim.cmd("CopilotChatCommitStaged")
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
                  ["<leader>s"] = { "git_stage", mode = { "n" } },
                  ["<leader>g"] = { "copilot_commit", mode = { "n" } },
                  ["<leader>r"] = { "git_reset_file", mode = { "n", "i" } },
                },
              },
            },
          },
          git_log = {
            win = {
              input = {
                keys = {
                  ["<leader>r"] = { "git_reset_soft", mode = { "n", "i" } },
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
