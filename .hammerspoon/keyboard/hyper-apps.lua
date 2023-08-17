-- Default keybindings for launching apps in Hyper Mode
hs.application.enableSpotlightForNameSearches(true)

return {
	{ "d", "Deezer" }, -- "M" for "Music"
	{ "b", "Arc" }, -- "B" for "Browser"
	{ "f", "Finder" }, -- "F" for "Finder"
	{ "s", "Slack" }, -- "S" for "Slack"
	{ "t", "kitty" }, -- "T" for "Terminal"
	{ "c", "calendar" }, -- "C" for "Calendar"
	{ "z", "zoom.us" }, -- "Z" for "Zoom"
	{
		"m",
		"Slack", -- Slack workspace #2
		function()
			hs.eventtap.keyStroke({ "cmd" }, "2")
		end,
	},
	{
		"s",
		"Slack", -- Slack workspace #1
		function()
			hs.eventtap.keyStroke({ "cmd" }, "1")
		end,
	},
	{
		"g", -- ChatGPT
		"Arc",
		function()
			hs.eventtap.keyStroke({ "cmd" }, "3")
		end,
	},
}
