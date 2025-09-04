-- Generate EmmyLua annotations for Hammerspoon + Spoons (PR #240)
-- If the Spoon is installed, loading it will auto-generate/update
-- annotations under an `annotations` directory.
-- Tip: add the annotations path to your editor's Lua workspace library, e.g.:
-- Lua.workspace.library = {
--   os.getenv("HOME") .. "/.hammerspoon/Spoons/EmmyLua.spoon/annotations"
-- }
hs.loadSpoon("EmmyLua")

require("lua.apps")
require("lua.windows")
require("lua.theme")
require("lua.url")

-- Screenshot active window and send to tmux: llm -a <file>
hs.hotkey.bind({ "cmd" }, "s", function()
	local llmshot = require("lua.llm_screenshot")
	llmshot.captureAndSend()
end)
