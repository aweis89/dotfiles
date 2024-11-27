return {
  "joshuavial/aider.nvim",
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
    {
      "<leader>cb",
      function()
        local curr_buf_num = vim.api.nvim_get_current_buf()
        local all_buf_nums = vim.api.nvim_list_bufs()

        for _, buf_num in ipairs(all_buf_nums) do
          if
            buf_num ~= curr_buf_num
            and vim.api.nvim_buf_is_valid(buf_num)
            and vim.api.nvim_buf_is_loaded(buf_num)
            and vim.fn.bufwinnr(buf_num) == -1
          then
            if vim.fn.getbufvar(buf_num, "&buftype") ~= "terminal" then
              vim.api.nvim_buf_delete(buf_num, { force = true })
            end
          end
        end
      end,
      desc = "Close hidden buffers",
    },
  },
}
