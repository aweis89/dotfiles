-- Generate EmmyLua annotations for Hammerspoon + Spoons (PR #240).
-- Tip: add the annotations path to your editor's Lua workspace library, e.g.:
-- Lua.workspace.library = os.getenv("HOME") .. "/.hammerspoon/Spoons/EmmyLua.spoon/annotations"
hs.loadSpoon("EmmyLua")

-- Hide dock icon so canvases can appear over fullscreen windows (macOS Sierra+).
hs.dockicon.hide()

-- Hyper key shared across modules.
HYPER = { "alt" }

require("lua.apps")
require("lua.windows")
require("lua.theme")
require("lua.url")
require("lua.slack")
require("lua.alt_command")
require("lua.app_remaps")
require("lua.double_tap")
require("lua.arrows")
require("lua.reload_watcher")

-- Screenshot active window and send to tmux: llm -a <file>
hs.hotkey.bind({ "cmd", "shift" }, "s", function()
	local llmshot = require("lua.llm_screenshot")
	llmshot.captureAndSend()
end)
