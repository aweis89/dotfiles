local M = {}

-- Helper to find the correct Zen Browser app name
-- Tries to launch both "Zen Browser" and "Zen" to see which one exists
local function findZenBrowser()
	-- Try "Zen Browser" first (newer naming)
	local _, status = hs.execute("open -a 'Zen Browser' --background 2>/dev/null")
	if status then
		return "Zen Browser"
	end

	-- Fall back to "Zen" (older naming)
	local _, status2 = hs.execute("open -a 'Zen' --background 2>/dev/null")
	if status2 then
		return "Zen"
	end

	-- Default to "Zen Browser" if we can't determine
	return "Zen Browser"
end

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

M.ZEN_BROWSER = findZenBrowser()
M.EDGE_BROWSER = "Microsoft Edge"
M.CHROME_BROWSER = "Google Chrome"

M.default_browser = loadHostnameDefaultBrowser() or M.ZEN_BROWSER

return M
