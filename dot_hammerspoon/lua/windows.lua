-- Use MiroWindowsManager Spoon for window management
-- Replaces the custom modal window layout with direct Hyper+Arrow bindings.

hs.window.animationDuration = 0

-- Load the spoon
hs.loadSpoon("MiroWindowsManager")

-- Optional: customize cycle sizes or grid
-- spoon.MiroWindowsManager.sizes = { 2, 3, 3/2 }
-- spoon.MiroWindowsManager.GRID = { w = 24, h = 24 }

-- Bind hjkl and fullscreen via the Spoon (no arrows)
spoon.MiroWindowsManager:bindHotkeys({
	up = { HYPER, "k" },
	right = { HYPER, "l" },
	down = { HYPER, "j" },
	left = { HYPER, "h" },
	fullscreen = { HYPER, "return" },
})

-- No extra aliases; hjkl are primary bindings

-- Keep a simple next-screen binding to replace the old mapping
hs.hotkey.bind(HYPER, "n", function()
	local win = hs.window.focusedWindow()
	if not win then
		return
	end
	local currentScreen = win:screen()
	local allScreens = hs.screen.allScreens()
	local idx = hs.fnutils.indexOf(allScreens, currentScreen) or 0
	local nextIdx = idx + 1
	if allScreens[nextIdx] then
		win:moveToScreen(allScreens[nextIdx])
	else
		win:moveToScreen(allScreens[1])
	end
end)

-- Optional: also allow Hyper+Space to maximize via Hammerspoon directly
hs.hotkey.bind(HYPER, "space", function()
	local win = hs.window.focusedWindow()
	if win then
		win:maximize()
	end
end)
