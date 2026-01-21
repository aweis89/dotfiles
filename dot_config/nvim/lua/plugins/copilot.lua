local nodejs_version = "24.3.0"
return {
  {
    "zbirenbaum/copilot.lua",
    opts = {
      -- force node version to override local .node-version or nvm settings
      copilot_node_command = vim.fn.expand("~/.asdf/installs/nodejs/" .. nodejs_version .. "/bin/node"),
    },
  },
}
