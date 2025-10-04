-- Consolidated Hyper app mappings and bindings
-- Previously split across `hyper.lua` and `hyper-apps.lua`.

-- Enable Spotlight-backed name searches for app launching
hs.application.enableSpotlightForNameSearches(true)

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
local hyperModeAppMappings = {
	{ "m", "Music" }, -- "M" for "Music"
	{ "b", "Zen Browser" }, -- "B" for "Browser"
	{ "f", "Finder" }, -- "F" for "Finder"
	{ "s", "Slack" }, -- "S" for "Slack"
	{ "t", "Ghostty", focusMainWindow("Ghostty") }, -- "T" for "Terminal"
	{ "c", "calendar" }, -- "C" for "Calendar"
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
