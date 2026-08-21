-- Bind alt+<key> to forward as cmd+<key> in the frontmost app.
-- Useful in terminals where alt is the prefix but apps expect cmd shortcuts.
local targetApp = nil

local function bindAltCommandKey(key)
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

for _, key in ipairs({ "v", "x" }) do
	bindAltCommandKey(key)
end
