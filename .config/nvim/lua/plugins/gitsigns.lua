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
        end, 1)
      end

      opts.on_attach = function(bufnr)
        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
        end

        super_on_attach(bufnr)
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
        map("n", "]H", function() nav_hunk("last") end, "Last Hunk")
        map("n", "[H", function() nav_hunk("first") end, "First Hunk")
      end
    end
  }
}
