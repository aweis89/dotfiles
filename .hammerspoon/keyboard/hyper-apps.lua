-- Default keybindings for launching apps in Hyper Mode
--
-- To launch _your_ most commonly-used apps via Hyper Mode, create a copy of
-- this file, save it as `hyper-apps.lua`, and edit the table below to configure
-- your preferred shortcuts.
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
		"Arc",
		function()
			hs.eventtap.keyStroke({ "cmd" }, "2")
		end,
	},
	{
		"s",
		"Arc",
		function()
			hs.eventtap.keyStroke({ "cmd" }, "1")
		end,
	},
	{
		"g",
		"Arc",
		function()
			hs.eventtap.keyStroke({ "cmd" }, "3")
		end,
	},
}
