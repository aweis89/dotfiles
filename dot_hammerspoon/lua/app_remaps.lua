-- App-specific key remaps via eventtap.
-- Remaps ctrl+f/l/t/a/s/x to cmd equivalents in Chromium-family browsers.
local remap_util = require("lua.remap_util")

local CHROMIUM_FAMILY_APP_NAMES = {
	Chromium = true,
	["Google Chrome"] = true,
	Thorium = true,
}

local CHROMIUM_FAMILY_BUNDLE_IDS = {
	["org.chromium.Chromium"] = true,
	["com.google.Chrome"] = true,
}

local APP_SPECIFIC_REMAPS = {
	{
		sourceMods = { ctrl = true },
		sourceKey = "f",
		targetMods = { "cmd" },
		targetKey = "f",
	},
}

for _, remap in ipairs({
	{
		sourceMods = { ctrl = true },
		sourceKey = "l",
		targetMods = { "cmd" },
		targetKey = "l",
	},
	{
		sourceMods = { ctrl = true },
		sourceKey = "t",
		targetMods = { "cmd" },
		targetKey = "t",
	},
	{
		sourceMods = { ctrl = true },
		sourceKey = "a",
		targetMods = { "cmd", "shift" },
		targetKey = "a",
	},
	{
		sourceMods = { ctrl = true },
		sourceKey = "s",
		targetMods = { "cmd", "alt" },
		targetKey = "n",
	},
	{
		sourceMods = { ctrl = true },
		sourceKey = "x",
		targetMods = { "cmd" },
		targetKey = "w",
	},
}) do
	remap.appNames = CHROMIUM_FAMILY_APP_NAMES
	remap.bundleIDs = CHROMIUM_FAMILY_BUNDLE_IDS
	table.insert(APP_SPECIFIC_REMAPS, remap)
end

if _G.appSpecificRemapTap then
	_G.appSpecificRemapTap:stop()
	_G.appSpecificRemapTap = nil
end

_G.appSpecificRemapTap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
	local keyCode = event:getKeyCode()
	local flags = event:getFlags()

	for _, remap in ipairs(APP_SPECIFIC_REMAPS) do
		if keyCode == hs.keycodes.map[remap.sourceKey]
			and remap_util.matchesExactFlags(flags, remap.sourceMods)
			and remap_util.frontmostAppMatches(remap)
		then
			hs.eventtap.keyStroke(remap.targetMods, remap.targetKey, 0)
			return true
		end
	end

	return false
end)
_G.appSpecificRemapTap:start()
