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
