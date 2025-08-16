-- auto triggering breaks in neovide
if vim.g.neovide then
  return {}
end

return {
  {
    "lewis6991/gitsigns.nvim",
    opts = function(_, opts)
      local gs = require("gitsigns")
      local super_on_attach = opts.on_attach

      -- auto preview hunk inline
      local function nav_hunk(direction)
        gs.nav_hunk(direction)
        vim.defer_fn(function()
          gs.preview_hunk_inline()
        end, 500)
      end

      opts.on_attach = function(bufnr)
        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc, remap = true, silent = true })
        end

        super_on_attach(bufnr)

        local function close_git_signs(key)
          key = key or "q"
          vim.keymap.set("n", key, function()
            for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
              local buf = vim.api.nvim_win_get_buf(win)
              local bufname = vim.api.nvim_buf_get_name(buf)
              if bufname:find("^gitsigns://") then
                vim.api.nvim_win_close(win, true)
                break
              end
            end
            vim.wo.diff = false
          end, { buffer = true, silent = true })
        end

        map("n", "<leader>ghD", function()
          gs.diffthis("~")
          close_git_signs("q")
        end, "Diff This! ~")

        map("n", "<leader>ghd", function()
          gs.diffthis()
          close_git_signs("q")
        end, "Diff This!")

        map("n", "<leader>ghU", function()
          gs.reset_buffer_index()
        end, "Undo staged buffer")

        map("n", "]h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            nav_hunk("next")
          end
        end, "Next Hunk")
        map("n", "[h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            nav_hunk("prev")
          end
        end, "Prev Hunk")
        map("n", "]H", function()
          nav_hunk("last")
        end, "Last Hunk")
        map("n", "[H", function()
          nav_hunk("first")
        end, "First Hunk")
      end
    end,
  },
}
