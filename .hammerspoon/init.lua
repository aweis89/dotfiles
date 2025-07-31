require("keyboard")
local reload_theme_path = "~/tmp/theme-reload"
local zen_browser = "Zen Browser"

-- Container mapping for URLs
local container_map = {
	["quizlet"] = "qz",
	["calendly"] = "cl",
	["meet%.google%.com"] = "qz",
}

-- Function to open URL in specified browser
function openURLWith(url, browser)
	if browser ~= zen_browser then
		local command = string.format('/usr/bin/open -a "%s" "%s"', browser, url)
		hs.execute(command)
		return
	end

	local container = nil

	-- Check URL against container mapping
	for pattern, container_name in pairs(container_map) do
		if string.find(url, pattern) then
			container = container_name
			break
		end
	end

	-- Use container format only if mapping found
	if container then
		local containerURL = string.format("ext+container:name=%s&url=%s", container, url)
		local command = string.format('/usr/bin/open -a "%s" "%s"', browser, containerURL)
		hs.execute(command)
	else
		local command = string.format('/usr/bin/open -a "%s" "%s"', browser, url)
		hs.execute(command)
	end
end

-- force browser focus when opening links
-- fixes issues with slack where the link is opened, but focus doesn't change
-- requires hammerspoon to be the default browser
hs.urlevent.httpCallback = function(scheme, host, params, fullURL)
	-- openURLWith(fullURL, "arc")
	openURLWith(fullURL, zen_browser)
	-- copy url to clipboard
	hs.pasteboard.setContents(fullURL)
end

-- Set up theme sync for system theme changes
local function syncTheme()
	os.execute("~/.config/kitty/sync-theme " .. "tokyonight")
	os.execute("/opt/homebrew/bin/tmux source-file ~/.config/tmux/tmux.conf")
	os.execute("touch " .. reload_theme_path)
end

-- Watch for system theme changes
_G.themeWatcher = hs.distributednotifications.new(function(name, object, userInfo)
	local status, err = pcall(function()
		syncTheme()
	end)
	print(name)
	if not status then
		print("Error in theme watcher: " .. tostring(err))
	end
end, "AppleInterfaceThemeChangedNotification")
_G.themeWatcher:start()

-- Watch for system wake/unlock events
local caffeinateWatcher = hs.caffeinate.watcher.new(function(eventType)
	if
		eventType == hs.caffeinate.watcher.systemDidWake
		or eventType == hs.caffeinate.watcher.screensDidUnlock
		or eventType == hs.caffeinate.watcher.screensDidWake
	then
		syncTheme()
	end
end)
caffeinateWatcher:start()

-- hs.loadSpoon("ControlEscape"):start()
