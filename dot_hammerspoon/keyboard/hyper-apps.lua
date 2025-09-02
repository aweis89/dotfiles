-- Default keybindings for launching apps in Hyper Mode
hs.application.enableSpotlightForNameSearches(true)

-- Helper function to focus main windows, avoiding popouts and floating windows
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

return {
	{ "m", "Music" }, -- "M" for "Music"
	-- { "b", "Arc" }, -- "B" for "Browser"
	{ "b", "Zen Browser" }, -- "B" for "Browser"
	{ "f", "Finder" }, -- "F" for "Finder"
	{ "s", "Slack" }, -- "S" for "Slack"
	-- { "t", "Neovide" }, -- "T" for "Terminal"
	-- { "t", "Kitty" }, -- "T" for "Terminal"
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
