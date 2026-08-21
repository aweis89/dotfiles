-- Auto-reload Hammerspoon config when files under hs.configdir change
-- (excluding generated EmmyLua annotations).
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
