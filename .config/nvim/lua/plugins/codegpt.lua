if true then
  return {}
end

return {
  {
    "dpayne/CodeGPT.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("codegpt.config")
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function(_, opts)
      local CodeGPTModule = require("codegpt")
      table.insert(opts.sections.lualine_x, { CodeGPTModule.get_status, "encoding", "fileformat" })
    end,
  },
}
