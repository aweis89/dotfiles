-- Default keybindings for launching apps in Hyper Mode
hs.application.enableSpotlightForNameSearches(true)

return {
	{ "m", "Music" }, -- "M" for "Music"
	-- { "b", "Arc" }, -- "B" for "Browser"
	{ "b", "Zen Browser" }, -- "B" for "Browser"
	{ "f", "Finder" }, -- "F" for "Finder"
	{ "s", "Slack" }, -- "S" for "Slack"
	-- { "t", "Neovide" }, -- "T" for "Terminal"
	-- { "t", "Kitty" }, -- "T" for "Terminal"
	{ "t", "Ghostty" }, -- "T" for "Terminal"
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
