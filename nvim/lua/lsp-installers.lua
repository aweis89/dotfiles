-- Add custom installer for golangci-lint-langserver
local go = require "nvim-lsp-installer.installers.go"
local server = require "nvim-lsp-installer.server"
local path = require "nvim-lsp-installer.path"

local M = {}

M.add_go_server = function (servers, server_name, cmd, package)
	local root_dir = server.get_server_root_path(server_name)
	local golang_ci_installer = go.packages { package }
	servers.register(server.Server:new {
		name = server_name,
		root_dir = root_dir,
		installer = golang_ci_installer,
		default_options = {
			cmd = { path.concat { root_dir, cmd }},
		},
	})
end

return M
