-- Generate EmmyLua annotations for Hammerspoon + Spoons (PR #240)
-- If the Spoon is installed, loading it will auto-generate/update
-- annotations under an `annotations` directory.
-- Tip: add the annotations path to your editor's Lua workspace library, e.g.:
-- Lua.workspace.library = {
--   os.getenv("HOME") .. "/.hammerspoon/Spoons/EmmyLua.spoon/annotations"
-- }
hs.loadSpoon("EmmyLua")

-- Define hyper key globally for reuse across modules
-- hyper = { "shift", "ctrl", "alt", "cmd" }
HYPER = { "alt" }

require("lua.apps")
require("lua.windows")
require("lua.theme")
require("lua.url")
require("lua.slack")

-- Screenshot active window and send to tmux: llm -a <file>
hs.hotkey.bind({ "cmd", "shift" }, "s", function()
	local llmshot = require("lua.llm_screenshot")
	llmshot.captureAndSend()
end)
