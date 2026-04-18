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
}

local CHROMIUM_FAMILY_APP_NAMES = {
	Chromium = true,
	["Google Chrome"] = true,
	Thorium = true,
}

local CHROMIUM_FAMILY_BUNDLE_IDS = {
	["org.chromium.Chromium"] = true,
	["com.google.Chrome"] = true,
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

local DEFAULT_DOUBLE_TAP_INTERVAL = 0.25

local function createDoubleTapRemap(sourceKey, targetKey, opts)
	opts = opts or {}
	return {
		appNames = opts.appNames,
		bundleIDs = opts.bundleIDs,
		sourceMods = opts.sourceMods or {},
		sourceKey = sourceKey,
		interval = opts.interval or DEFAULT_DOUBLE_TAP_INTERVAL,
		targetMods = opts.targetMods or {},
		targetKey = targetKey,
	}
end

local function sourceKeyProducesText(remap)
	if type(remap.sourceKey) ~= "string" or #remap.sourceKey ~= 1 then
		return false
	end

	local mods = remap.sourceMods or {}
	return not mods.cmd and not mods.ctrl and not mods.alt and not mods.fn
end

local DOUBLE_TAP_REMAPS = {
	createDoubleTapRemap("q", "escape"),
}

local doubleTapSyntheticKeyActive = false

local function clearDoubleTapRemapState(activeRemap)
	for _, remap in ipairs(DOUBLE_TAP_REMAPS) do
		if remap ~= activeRemap then
			remap.lastTriggeredAt = nil
		end
	end
end

local function executeDoubleTapRemap(remap)
	doubleTapSyntheticKeyActive = true
	if sourceKeyProducesText(remap) then
		hs.eventtap.keyStroke({}, "delete", 0)
	end
	hs.eventtap.keyStroke(remap.targetMods or {}, remap.targetKey, 0)
	hs.timer.doAfter(0.05, function()
		doubleTapSyntheticKeyActive = false
	end)
end

if _G.doubleTapRemapTap then
	_G.doubleTapRemapTap:stop()
	_G.doubleTapRemapTap = nil
end

_G.doubleTapRemapTap = hs.eventtap.new({
	hs.eventtap.event.types.flagsChanged,
	hs.eventtap.event.types.keyDown,
}, function(event)
	if doubleTapSyntheticKeyActive then
		return false
	end

	local eventType = event:getType()
	if eventType == hs.eventtap.event.types.flagsChanged then
		clearDoubleTapRemapState()
		return false
	end

	local keyCode = event:getKeyCode()
	local flags = event:getFlags()
	local matchedRemap = nil

	for _, remap in ipairs(DOUBLE_TAP_REMAPS) do
		if keyCode == hs.keycodes.map[remap.sourceKey]
			and matchesExactFlags(flags, remap.sourceMods or {})
			and frontmostAppMatches(remap)
		then
			matchedRemap = remap
			break
		end
	end

	if not matchedRemap then
		clearDoubleTapRemapState()
		return false
	end

	local now = hs.timer.secondsSinceEpoch()
	local interval = matchedRemap.interval or DEFAULT_DOUBLE_TAP_INTERVAL
	if matchedRemap.lastTriggeredAt and (now - matchedRemap.lastTriggeredAt) <= interval then
		clearDoubleTapRemapState()
		executeDoubleTapRemap(matchedRemap)
		return true
	end

	clearDoubleTapRemapState(matchedRemap)
	matchedRemap.lastTriggeredAt = now
	return false
end)
_G.doubleTapRemapTap:start()

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
