return {
  { "akinsho/bufferline.nvim", enabled = false },
  { "vimpostor/vim-tpipeline", event = "VeryLazy" },
  {
    "nvim-lualine/lualine.nvim",
    -- https://github.com/vimpostor/vim-tpipeline/issues/53
    config = function(_, opts)
      require("lualine").setup(opts)

      if os.getenv("TMUX") then
        vim.defer_fn(function()
          vim.o.laststatus = 0
        end, 0)
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
        lualine_c = {},
        lualine_y = {},
        -- remove diff
        lualine_x = {},
        -- change time for buffers
        lualine_z = { "buffers" },
      },
    },
  },
}
