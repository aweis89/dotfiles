-- use lualine as bufferline
return {
  { "akinsho/bufferline.nvim", enabled = false },
  { "vimpostor/vim-tpipeline", event = "VeryLazy" },
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
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
        -- remove progress and location
        lualine_y = {},
        -- change time for buffers
        lualine_z = { "buffers" },
      },
    },
  },
}
