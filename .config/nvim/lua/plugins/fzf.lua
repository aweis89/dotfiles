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
      }
    end,
  },
  init = function()
    vim.api.nvim_create_user_command("ListFilesFromBranch", function(opts)
      require("fzf-lua").files({
        cmd = "git ls-tree -r --name-only " .. opts.args,
        prompt = opts.args .. "> ",
        actions = {
          ["default"] = false,
          ["ctrl-s"] = false,
          ["ctrl-v"] = function(selected, o)
            local file = require("fzf-lua").path.entry_to_file(selected[1], o)
            local cmd = string.format("Gvsplit %s:%s", opts.args, file.path)
            vim.cmd(cmd)
          end,
        },
        previewer = false,
        preview = {
          type = "cmd",
          fn = function(items)
            local file = require("fzf-lua").path.entry_to_file(items[1])
            return string.format("git diff %s HEAD -- %s | delta", opts.args, file.path)
          end,
        },
      })
    end, {
      nargs = 1,
      force = true,
      complete = function()
        local branches = vim.fn.systemlist("git branch --all --sort=-committerdate")
        if vim.v.shell_error == 0 then
          return vim.tbl_map(function(x)
            return x:match("[^%s%*]+"):gsub("^remotes/", "")
          end, branches)
        end
      end,
    })
  end,
}