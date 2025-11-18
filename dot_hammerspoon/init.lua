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

-- Toggle keyboard layout canvas
hs.hotkey.bind({ "cmd" }, "k", function()
	local keyboard = require("lua.keyboard_canvas")
	local imagePath = "/Users/aaron.weisberg/p/Adv360-Pro-ZMK/keymap-2col.png"
	keyboard.toggle(imagePath)
end)
