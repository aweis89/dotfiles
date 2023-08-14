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
		-- "Slack",
		"Arc",
		function()
			hs.eventtap.keyStroke({ "cmd" }, "2")
		end,
	},
	{
		"s",
		-- "Slack",
		"Arc",
		function()
			hs.eventtap.keyStroke({ "cmd" }, "1")
		end,
	},
}
