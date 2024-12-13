return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "zbirenbaum/copilot.lua" }, -- or zbirenbaum/copilot.lua
      { "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log and async functions
    },
    build = "make tiktoken", -- Only on MacOS or Linux
    opts = {
      model = "claude-3.5-sonnet",
    },
    config = function(_, opts)
      local copilot = require("CopilotChat")
      vim.api.nvim_create_user_command("CopilotAutoCommit", function()
        local prompt =
          "> #git:staged\n\nWrite commit message for the change with commitizen convention. Make sure the title has maximum 50 characters and message is wrapped at 72 characters. Wrap the whole message in code block with language gitcommit."
        copilot.ask(
          prompt,
          vim.tbl_extend("force", opts, {
            callback = function(msg)
              vim.notify(msg)
            end,
            selection = nil,
          })
        )
      end, {})
      copilot.setup(opts)
    end,
  },
}
