local copilot_icons = function()
  return {
    Error = { " ", "DiagnosticError" },
    Inactive = { " ", "MsgArea" },
    Warning = { " ", "DiagnosticWarn" },
    Normal = { LazyVim.config.icons.kinds.Copilot, "Special" },
  }
end

return {
  { "akinsho/bufferline.nvim", enabled = false },
  { "vimpostor/vim-tpipeline", event = "VeryLazy" },
  {
    "nvim-lualine/lualine.nvim",
    -- https://github.com/vimpostor/vim-tpipeline/issues/53
    config = function(_, opts)
      require("lualine").setup(opts)

      if vim.env.TMUX then
        vim.api.nvim_create_autocmd({ "FocusGained", "ColorScheme" }, {
          callback = function()
            vim.defer_fn(function()
              vim.opt.laststatus = 0
            end, 100)
          end,
        })

        vim.o.laststatus = 0
      end
    end,
    opts = {
      sections = {
        lualine_b = {
          {
            "branch",
            fmt = function(str)
              if str == nil or str == "" then
                return ""
              end
              -- strip out jira ticket prefixes
              local _, rest = str:match(".*%-(%d+)%-(.*)")
              if rest then
                str = rest
              end
              -- truncate long branch names
              if #str > 25 then
                str = str:sub(1, 25) .. "…"
              end
              return str
            end,
          },
        },
        lualine_c = {
          {
            function()
              local status = require("sidekick.status").get()
              return status and vim.tbl_get(copilot_icons(), status.kind, 1)
            end,
            cond = function()
              return require("sidekick.status").get() ~= nil
            end,
            color = function()
              local status = require("sidekick.status").get()
              local hl = status and (status.busy and "DiagnosticWarn" or vim.tbl_get(copilot_icons(), status.kind, 2))
              return { fg = Snacks.util.color(hl) }
            end,
          },
        },
        lualine_y = {},
        -- remove diff
        lualine_x = {},
        -- change time for buffers
        lualine_z = { "buffers" },
      },
    },
  },
}
