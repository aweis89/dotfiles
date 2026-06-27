-- Shared helpers for keyboard remap modules.

local M = {}

-- True only when exactly the expected modifier flags are active.
function M.matchesExactFlags(flags, expected)
	expected = expected or {}
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

-- True if the frontmost app matches the remap's appNames/bundleIDs.
-- A remap with neither defined matches all apps.
function M.frontmostAppMatches(remap)
	if not remap.appNames and not remap.bundleIDs then
		return true
	end

	local app = hs.application.frontmostApplication()
	if not app then
		return false
	end

	local appName = app:name()
	if appName and remap.appNames and remap.appNames[appName] then
		return true
	end

	local bundleID = app:bundleID()
	return bundleID and remap.bundleIDs and remap.bundleIDs[bundleID] or false
end

return M
