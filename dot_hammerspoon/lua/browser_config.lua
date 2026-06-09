local M = {}

M.EDGE_BROWSER = "Microsoft Edge"
M.CHROME_BROWSER = "Google Chrome"
M.CHROMIUM_BROWSER = "Chromium"

M.CHROMIUM_PROFILE_RULES = {
	{ pattern = "calendly", profile = "calendly" },
	{ pattern = "evisort", profile = "workday" },
	{ pattern = "workday", profile = "workday" },
}

local function getCurrentHostname()
	local handle = io.popen("hostname")
	local hostname = handle and handle:read("*a"):gsub("%s+", "")
	if handle then
		handle:close()
	end
	return hostname
end

local function loadHostnameOverrides()
	local hostname = getCurrentHostname()
	local overridesPath = hs.configdir .. "/hostname-app-overrides.lua"

	if hs.fs.attributes(overridesPath) then
		local success, overrides = pcall(dofile, overridesPath)
		if success and overrides and overrides[hostname] then
			hs.console.printStyledtext("Loading hostname overrides for: " .. hostname)
			return overrides[hostname]
		elseif not success then
			hs.console.printStyledtext("Error loading hostname overrides: " .. tostring(overrides))
		end
	end

	hs.console.printStyledtext("No hostname overrides found for: " .. hostname)
	return nil
end

M.app_overrides = loadHostnameOverrides()
M.default_browser = (M.app_overrides and M.app_overrides["b"]) or M.CHROMIUM_BROWSER

return M
