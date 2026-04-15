local M = {}

local function getCurrentHostname()
	local handle = io.popen("hostname")
	local hostname = handle and handle:read("*a"):gsub("%s+", "")
	if handle then
		handle:close()
	end
	return hostname
end

local function loadHostnameDefaultBrowser()
	local hostname = getCurrentHostname()
	local overridesPath = hs.configdir .. "/hostname-app-overrides.lua"

	if not hs.fs.attributes(overridesPath) then
		return nil
	end

	local success, overrides = pcall(dofile, overridesPath)
	if not success or type(overrides) ~= "table" then
		return nil
	end

	local hostnameOverrides = overrides[hostname]
	if type(hostnameOverrides) ~= "table" then
		return nil
	end

	return hostnameOverrides.default_browser
end

M.EDGE_BROWSER = "Microsoft Edge"
M.CHROME_BROWSER = "Google Chrome"
M.CHROMIUM_BROWSER = "Chromium"

M.CHROMIUM_PROFILE_RULES = {
	{ pattern = "calendly", profile = "calendly" },
	{ pattern = "evisort", profile = "workday" },
	{ pattern = "workday", profile = "workday" },
}

M.fallback_browser = M.CHROMIUM_BROWSER
M.default_browser = loadHostnameDefaultBrowser() or M.fallback_browser

return M
