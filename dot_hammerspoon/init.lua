-- Generate EmmyLua annotations for Hammerspoon + Spoons (PR #240)
-- If the Spoon is installed, loading it will auto-generate/update
-- annotations under an `annotations` directory.
-- Tip: add the annotations path to your editor's Lua workspace library, e.g.:
-- Lua.workspace.library = {
--   os.getenv("HOME") .. "/.hammerspoon/Spoons/EmmyLua.spoon/annotations"
-- }
hs.loadSpoon("EmmyLua")

-- Hide dock icon to allow canvases to appear over fullscreen windows
-- Required since macOS Sierra for fullscreen overlay support
hs.dockicon.hide()

-- Define hyper key globally for reuse across modules
-- hyper = { "shift", "ctrl", "alt", "cmd" }
HYPER = { "alt" }

require("lua.apps")
require("lua.windows")
require("lua.theme")
require("lua.url")
require("lua.slack")
require("lua.keyboard_canvas")

-- Screenshot active window and send to tmux: llm -a <file>
hs.hotkey.bind({ "cmd", "shift" }, "s", function()
	local llmshot = require("lua.llm_screenshot")
	llmshot.captureAndSend()
end)

if ALT_COMMAND_TAP then
	ALT_COMMAND_TAP:stop()
	ALT_COMMAND_TAP = nil
end

local function bindAltCommandKey(key)
	local targetApp = nil
	hs.hotkey.bind(
		{ "alt" },
		key,
		function()
			targetApp = hs.application.frontmostApplication()
		end,
		function()
			hs.eventtap.keyStroke({ "cmd" }, key, 0, targetApp or hs.application.frontmostApplication())
			targetApp = nil
		end
	)
end

for _, key in ipairs({ "c", "v", "x" }) do
	bindAltCommandKey(key)
end

local APP_SPECIFIC_REMAPS = {
	{
		sourceMods = { ctrl = true },
		sourceKey = "f",
		targetMods = { "cmd" },
		targetKey = "f",
	},
	{
		appNames = {
			Chromium = true,
		},
		bundleIDs = {
			["org.chromium.Chromium"] = true,
		},
		sourceMods = { ctrl = true },
		sourceKey = "l",
		targetMods = { "cmd" },
		targetKey = "l",
	},
	{
		appNames = {
			Chromium = true,
		},
		bundleIDs = {
			["org.chromium.Chromium"] = true,
		},
		sourceMods = { ctrl = true },
		sourceKey = "t",
		targetMods = { "cmd" },
		targetKey = "t",
	},
	{
		appNames = {
			Chromium = true,
		},
		bundleIDs = {
			["org.chromium.Chromium"] = true,
		},
		sourceMods = { ctrl = true },
		sourceKey = "s",
		targetMods = { "cmd", "alt" },
		targetKey = "n",
	},
	{
		appNames = {
			Chromium = true,
		},
		bundleIDs = {
			["org.chromium.Chromium"] = true,
		},
		sourceMods = { ctrl = true },
		sourceKey = "x",
		targetMods = { "cmd" },
		targetKey = "w",
	},
}

local function matchesExactFlags(flags, expected)
	for flag, enabled in pairs(expected) do
		if flags[flag] ~= enabled then
			return false
		end
	end

	for _, flag in ipairs({ "cmd", "ctrl", "alt", "shift", "fn" }) do
		if not expected[flag] and flags[flag] then
			return false
		end
	end

	return true
end

local function frontmostAppMatches(remap)
	if not remap.appNames and not remap.bundleIDs then
		return true
	end

	local app = hs.application.frontmostApplication()
	if not app then
		return false
	end

	local appName = app:name()
	if appName and remap.appNames[appName] then
		return true
	end

	local bundleID = app:bundleID()
	return bundleID and remap.bundleIDs[bundleID] or false
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
			and matchesExactFlags(flags, remap.sourceMods)
			and frontmostAppMatches(remap)
		then
			hs.eventtap.keyStroke(remap.targetMods, remap.targetKey, 0)
			return true
		end
	end

	return false
end)
_G.appSpecificRemapTap:start()

local EMMY_ANNOTATIONS_DIR = hs.configdir .. "/Spoons/EmmyLua.spoon/annotations/"

local function shouldReloadForPath(path)
	if not path or path == "" then
		return false
	end

	if path:sub(1, #EMMY_ANNOTATIONS_DIR) == EMMY_ANNOTATIONS_DIR then
		return false
	end

	return path:sub(1, #hs.configdir) == hs.configdir
end

if _G.configReloadWatcher then
	_G.configReloadWatcher:stop()
	_G.configReloadWatcher = nil
end

_G.configReloadWatcher = hs.pathwatcher.new(hs.configdir, function(paths)
	for _, path in ipairs(paths) do
		if shouldReloadForPath(path) then
			if _G.configReloadTimer then
				_G.configReloadTimer:stop()
			end

			_G.configReloadTimer = hs.timer.doAfter(0.3, function()
				hs.reload()
			end)
			return
		end
	end
end)
_G.configReloadWatcher:start()

for sourceKey, arrowKey in pairs({
	j = "down",
	k = "up",
}) do
	hs.hotkey.bind({ "ctrl" }, sourceKey, function()
		hs.eventtap.keyStroke({}, arrowKey, 0)
	end, nil, function()
		hs.eventtap.keyStroke({}, arrowKey, 0)
	end)
end
