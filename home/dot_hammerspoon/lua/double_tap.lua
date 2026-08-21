-- Double-tap remaps: tap a key twice quickly to emit a different key.
-- e.g. double-tap q -> escape.
local remap_util = require("lua.remap_util")

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
			and remap_util.matchesExactFlags(flags, remap.sourceMods or {})
			and remap_util.frontmostAppMatches(remap)
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
