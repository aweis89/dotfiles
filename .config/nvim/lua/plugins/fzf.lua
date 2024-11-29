return {
  {
    "ibhagwan/fzf-lua",
    opts = function()
      return {
        winopts = {
          fullscreen = true,
        },
        keymap = {
          builtin = {
            ["<C-w>"] = "toggle-preview",
          },
          fzf = {
            ["ctrl-w"] = "toggle-preview",
          },
        },
        custom_pickers = {
          files_from_branch = {
            prompt = "Branch Files> ",
            cmd = function()
              local branch = vim.fn.input("Branch: ", "", "customlist," .. vim.fn.expand("v:lua.complete_branches"))
              if branch == "" then return end
              return "git ls-tree -r --name-only " .. branch
            end,
            actions = {
              ["default"] = false,
              ["ctrl-s"] = false,
              ["ctrl-v"] = function(selected, o)
                local file = require("fzf-lua").path.entry_to_file(selected[1], o)
                local branch = vim.b.current_branch or ""
                local cmd = string.format("Gvsplit %s:%s", branch, file.path)
                vim.cmd(cmd)
              end,
            },
            previewer = false,
            preview = {
              type = "cmd",
              fn = function(items)
                local file = require("fzf-lua").path.entry_to_file(items[1])
                local branch = vim.b.current_branch or ""
                return string.format("git diff %s HEAD -- %s | delta", branch, file.path)
              end,
            },
          },
        },
      }
    end,
    config = function(_, opts)
      -- Add branch completion function to global scope
      _G.complete_branches = function()
        local branches = vim.fn.systemlist("git branch --all --sort=-committerdate")
        if vim.v.shell_error == 0 then
          return vim.tbl_map(function(x)
            return x:match("[^%s%*]+"):gsub("^remotes/", "")
          end, branches)
        end
        return {}
      end
      
      require("fzf-lua").setup(opts)
    end,
  },
}
