-- Consolidated Hyper app mappings and bindings
-- Previously split across `hyper.lua` and `hyper-apps.lua`.

-- Enable Spotlight-backed name searches for app launching
hs.application.enableSpotlightForNameSearches(true)

-- Get current hostname for hostname-specific configuration
local function getCurrentHostname()
	local handle = io.popen("hostname")
	local hostname = handle:read("*a"):gsub("%s+", "") -- Remove whitespace
	handle:close()
	return hostname
end

-- Load hostname-specific app overrides
local function loadHostnameOverrides()
	local hostname = getCurrentHostname()
	local overridesPath = hs.configdir .. "/hostname-app-overrides.lua"

	-- Load the overrides file
	if hs.fs.attributes(overridesPath) then
		local success, overrides = pcall(dofile, overridesPath)
		if success and overrides and overrides[hostname] then
			hs.console.printStyledtext("Loading hostname overrides for: " .. hostname)
			return overrides[hostname]
		elseif not success then
			hs.console.printStyledtext("Error loading hostname overrides: " .. tostring(overrides))
		end
	end

	-- No overrides found for this hostname
	hs.console.printStyledtext("No hostname overrides found for: " .. hostname)
	return nil
end

-- Helper to focus main app window, avoiding popouts/floating panels
local function focusMainWindow(appName)
	return function()
		local app = hs.application.find(appName)
		if app then
			local allWindows = app:allWindows()
			-- First, try to find standard main windows (AXStandardWindow)
			local mainWindows = hs.fnutils.filter(allWindows, function(win)
				return win:isStandard() and win:isVisible() and win:subrole() == "AXStandardWindow"
			end)

			if #mainWindows > 0 then
				mainWindows[1]:focus()
			else
				-- Fallback to any standard window if no AXStandardWindow found
				local anyStandardWindows = hs.fnutils.filter(allWindows, function(win)
					return win:isStandard() and win:isVisible()
				end)
				if #anyStandardWindows > 0 then
					anyStandardWindows[1]:focus()
				end
			end
		end
	end
end

-- Default keybindings for launching apps in Hyper Mode
local defaultHyperModeAppMappings = {
	{ "m", "Music" }, -- "M" for "Music"
	{ "i", "Messages" }, -- "I" for "Imessages"
	-- { "b", "Zen Browser" }, -- "B" for "Browser"
	{ "b", "Microsoft Edge" }, -- "B" for "Browser"
	{ "f", "Finder" }, -- "F" for "Finder"
	{ "s", "Slack" }, -- "S" for "Slack"
	{ "t", "Ghostty", focusMainWindow("Ghostty") }, -- "T" for "Terminal"
	{ "c", "Microsoft Outlook" }, -- "C" for "Calendar"
	{ "z", "zoom.us" }, -- "Z" for "Zoom"
	{ "a", "ChatGPT" }, -- "A" for "AI"
	{ "n", "Neovide" }, -- "N" for "Neovide"
	{
		"s",
		"Slack", -- Slack workspace #1
		function()
			hs.eventtap.keyStroke({ "cmd" }, "1")
		end,
	},
	{
		"q",
		"Slack", -- Slack workspace #3
		function()
			hs.eventtap.keyStroke({ "cmd" }, "3")
		end,
	},
}

-- Load hostname-specific overrides and apply them to default config
local hostnameOverrides = loadHostnameOverrides()
local hyperModeAppMappings = {}

-- Start with default mappings
for i, mapping in ipairs(defaultHyperModeAppMappings) do
	hyperModeAppMappings[i] = { mapping[1], mapping[2], mapping[3] }
end

-- Apply hostname-specific overrides
if hostnameOverrides then
	for key, appName in pairs(hostnameOverrides) do
		-- Find the mapping with this key and update it
		for i, mapping in ipairs(hyperModeAppMappings) do
			if mapping[1] == key then
				hyperModeAppMappings[i][2] = appName
				hs.console.printStyledtext("Override: " .. key .. " -> " .. appName)
				break
			end
		end
	end
end

-- Bind Option (alt) to launch/focus applications
for _, mapping in ipairs(hyperModeAppMappings) do
	local key = mapping[1]
	local app = mapping[2]
	local postOpen = mapping[3]
	hs.hotkey.bind(HYPER, key, function()
		hs.application.open(app)
		if type(postOpen) == "function" then
			postOpen()
		end
	end)
end
