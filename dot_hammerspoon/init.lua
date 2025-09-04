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
local url = require("lua.url")

-- URL routing logic moved to lua/url.lua
url.setDefaultBrowser(url.zen_browser)
url.installHandler()

-- Screenshot active window and send to tmux: llm -a <file>
local llmshot = require("lua.llm_screenshot")
hs.hotkey.bind({ "cmd" }, "s", function()
	llmshot.captureAndSend()
end)
