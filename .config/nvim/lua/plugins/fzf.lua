local function create_user_commands()
  vim.api.nvim_create_user_command("LazySource", function()
    require("fzf-lua-lazy").search()
  end, {})

  vim.api.nvim_create_user_command("Chdir", function(opt)
    local fzf_lua = require("fzf-lua")
    opt = opt or {}
    opt.prompt = "Directories> "
    opt.fn_transform = function(x)
      return fzf_lua.utils.ansi_codes.magenta(x)
    end
    opt.actions = {
      ["default"] = function(selected)
        vim.cmd("cd " .. selected[1])
      end,
    }
    fzf_lua.fzf_exec("fd --type d", opt)
  end, {})

  vim.api.nvim_create_user_command("ListFilesFromBranch", function(opt)
    require("fzf-lua").files({
      cmd = "git ls-tree -r --name-only " .. opt.args,
      prompt = opt.args .. "> ",
      actions = {
        ["default"] = false,
        ["ctrl-s"] = false,
        ["ctrl-v"] = function(selected, o)
          local file = require("fzf-lua").path.entry_to_file(selected[1], o)
          local cmd = string.format("Gvsplit %s:%s", opt.args, file.path)
          vim.cmd(cmd)
        end,
      },
      previewer = false,
      preview = {
        type = "cmd",
        fn = function(items)
          local file = require("fzf-lua").path.entry_to_file(items[1])
          return string.format("git diff %s HEAD -- %s", opt.args, file.path)
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
end


ProjectPicker = function()
  local fzf_lua = require("fzf-lua")
  local project = require("project_nvim.project")
  local history = require("project_nvim.utils.history")
  local results = history.get_recent_projects()
  local utils = require("fzf-lua.utils")

  local function hl_validate(hl)
    return not utils.is_hl_cleared(hl) and hl or nil
  end

  local function ansi_from_hl(hl, s)
    return utils.ansi_from_hl(hl_validate(hl), s)
  end

  local opts = {
    fzf_opts = {
      ["--header"] = string.format(
        ":: <%s> to %s | <%s> to %s | <%s> to %s",
        ansi_from_hl("FzfLuaHeaderBind", "ctrl-s"),
        ansi_from_hl("FzfLuaHeaderText", "live_grep"),
        ansi_from_hl("FzfLuaHeaderBind", "ctrl-o"),
        ansi_from_hl("FzfLuaHeaderText", "oldfiles"),
        ansi_from_hl("FzfLuaHeaderBind", "ctrl-r"),
        ansi_from_hl("FzfLuaHeaderText", "delete")
      ),
    },
    fzf_colors = true,
    actions = {
      ["default"] = {
        function(selected)
          fzf_lua.files({ cwd = selected[1] })
        end,
      },
      ["ctrl-s"] = {
        function(selected)
          fzf_lua.live_grep({ cwd = selected[1] })
        end,
      },
      ["ctrl-o"] = {
        function(selected)
          fzf_lua.oldfiles({ cwd = selected[1] })
        end,
      },
      ["ctrl-g"] = {
        function(selected)
          fzf_lua.git_status({ cwd = selected[1] })
          vim.cmd("cd " .. selected[1])
        end,
      },
      ["ctrl-r"] = function(selected)
        local path = selected[1]
        history.delete_project({ value = path })
        ProjectPicker()
      end,
    },
  }

  fzf_lua.fzf_exec(results, opts)
end

local function git_reset_soft(selected, opts)
  local match_commit_hash = function(line, opt)
    if type(opt.fn_match_commit_hash) == "function" then
      return opt.fn_match_commit_hash(line, opt)
    else
      return line:match("[^ ]+")
    end
  end

  local path = require("fzf-lua.path")
  local utils = require("fzf-lua.utils")
  local commit_hash = match_commit_hash(selected[1], opts)
  if vim.fn.confirm("Reset to commit " .. commit_hash .. "?", "&Yes\n&No") == 1 then
    local cmd_reset = path.git_cwd({ "git", "reset", "--soft" }, opts) or {}
    table.insert(cmd_reset, commit_hash)
    local output, rc = utils.io_systemlist(cmd_reset)
    if rc ~= 0 then
      utils.err(unpack(output))
      return
    end
    vim.cmd("checktime")
  end
end

return {
  {
    "folke/snacks.nvim",
    optional = true,
    opts = function(_, opts)
      if not opts.dashboard.preset.keys[3] then
        return
      end
      opts.dashboard.preset.keys[3] = {
        action = ProjectPicker,
        desc = "Projects",
        icon = " ",
        key = "p",
      }
    end,
  },
  {
    "ibhagwan/fzf-lua",
    dependencies = "roginfarrer/fzf-lua-lazy.nvim",
    keys = {
      { "<leader>fp", ProjectPicker,                 desc = "Projects" },
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
            vim.cmd("FzfLua git_files")
          else
            vim.cmd("FzfLua files")
          end
        end,
      },
      { "<leader>gb", "<cmd>FzfLua git_branches<cr>" },
      { "<leader>l",  "<cmd>FzfLua lines<cr>" },
      { "<leader>bl", "<cmd>FzfLua blines<cr>" },
      { "<leader>fk", "<cmd>FzfLua keymaps <cr>" },
      { "<leader>fs", "<cmd>LazySource<cr>" },
    },
    cmd = { "LazySource" },
    opts = function(_, opts)
      create_user_commands()

      local rg_opts = {
        "--hidden",
        "--glob",
        "!.git",
        "--column",
        "--line-number",
        "--no-heading",
        "--color=always",
        "--smart-case",
        "--max-columns=4096",
        "-e",
      }

      local actions = require("fzf-lua.actions")
      local delta_pager = [[delta --width=$COLUMNS --hunk-header-style="omit" --file-style="omit"]]

      return {
        fzf_opts = { ['--keep-right'] = '' },
        fzf_colors = true,
        header = false,
        winopts = {
          height = 1.00,
          width = 1.00,
          preview = { wrap = "wrap" }
        },
        keymap = {
          builtin = {
            ["<C-p>"] = "toggle-preview",
            ["<C-f>"] = "preview-page-down",
            ["<C-b>"] = "preview-page-up",
            ["<C-h>"] = "toggle-help",
          },
          fzf = {
            ["ctrl-p"] = "toggle-preview",
            ["ctrl-f"] = "preview-page-down",
            ["ctrl-b"] = "preview-page-up",
          },
        },
        buffers = {
          actions = {
            ["ctrl-e"] = {
              fn = function()
                vim.cmd("FzfLua files")
              end,
            },
          },
        },
        files = {
          actions = {
            ["ctrl-x"] = { fn = actions.git_reset, reload = true },
          },
        },
        grep = {
          header = "C-i: toggle ignore, C-s: toggle hidden",
          rg_glob = true,
          rg_opts = table.concat(rg_opts, " "),
          actions = {
            ["ctrl-i"] = { fn = actions.toggle_ignore, reload = true },
            ["ctrl-s"] = { fn = actions.toggle_hidden, reload = true },
          },
        },
        git = {
          status = {
            header = "C-s: toggle stage, C-x: git-reset, C-g: AI commit",
            preview_pager = delta_pager,
            winopts = {
              preview = { layout = "vertical", vertical = 'down:80%' }
            },
            actions = {
              ["ctrl-s"] = { fn = actions.git_stage_unstage, reload = true },
              ["ctrl-r"] = { fn = actions.git_reset, reload = true },
              ["ctrl-g"] = {
                fn = function()
                  vim.cmd("CopilotChatCommitStaged")
                end,
              },
            },
          },
          commits = {
            preview_pager = delta_pager,
            winopts = {
              preview = { layout = "vertical", vertical = 'down:80%' }
            },
            actions = {
              ["ctrl-r"] = { fn = git_reset_soft, reload = true },
            },
          },
          bcommits = {
            preview_pager = delta_pager,
            winopts = {
              preview = { layout = "vertical", vertical = 'down:80%' }
            },
            actions = {
              ["ctrl-r"] = { fn = git_reset_soft, reload = true },
            },
          },
        },
      }
    end,
  },
}
