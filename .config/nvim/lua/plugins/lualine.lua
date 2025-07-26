return {
  { "akinsho/bufferline.nvim", enabled = false },
  {
    "christopher-francisco/tmux-status.nvim",
    lazy = true,
    config = function(_, opts)
      require("tmux-status").setup(opts)
    end,
    opts = {
      window = {
        -- "dir" | "name" | "index_name"
        -- if not listed above, text will be passed directly to tmux formatting
        text = "name",
      },
      colors = {
        window_active = "#e69875",
        window_inactive = "#859289",
        window_inactive_recent = "#3f5865",
        session = "#a7c080",
        datetime = "#7a8478",
        battery = "#7a8478",
      },
      force_show = false, -- Force components to be shown regardless of Tmux status
      manage_tmux_status = true, -- Set to false if you do NOT want the plugin to turn Tmux status on/off
    },
  },
  {
    "nvim-lualine/lualine.nvim",
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
          "%=",
          {
            function()
              return require("tmux-status").tmux_windows()
            end,
            cond = function()
              return require("tmux-status").show()
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
