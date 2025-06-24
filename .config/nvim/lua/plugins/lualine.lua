-- use lualine as bufferline
return {
  { "akinsho/bufferline.nvim", enabled = false },
  --  vim-tpipeline integrates terminal statuslines with lualine.
  {
    "vimpostor/vim-tpipeline",
    dependencies = {
      -- lauline needs to load first
      "nvim-lualine/lualine.nvim",
    },
    event = "VeryLazy",
  },
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
        -- remove file path
        lualine_c = {},
        -- remove progress and location
        lualine_y = {},
        -- remove diff
        lualine_x = {},
        -- change time for buffers
        lualine_z = { "buffers" },
      },
    },
  },
}
