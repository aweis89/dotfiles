if true then
  return {}
end

return {
  "aweis89/aider.nvim",
  dir = "/Users/aaron.weisberg/p/aider.nvim",
  config = function()
    require("aider").setup({
      auto_manage_context = true,
      default_bindings = true,
    })
  end,
  keys = {
    {
      "<leader>a<space>",
      function()
        require("aider").AiderOpen("--no-auto-commits")
        vim.api.nvim_input("A")
      end,
      desc = "Aider Open",
    },
    {
      "<leader>ab",
      function()
        require("aider").AiderBackground("--no-auto-commits")
      end,
      desc = "Aider Background",
    },
  },
}
