require("keyboard")
local reload_theme_path = "~/tmp/theme-reload"

-- Map URL patterns to Edge/Zen containers (display names for Edge)
local container_map = {
	["quizlet"] = "qz",
	["calendly"] = "cl",
	["meet%.google%.com"] = "qz",
}

-- App names/paths
local zen_browser = "Zen Browser"
local edge_browser = "Microsoft Edge"
local edge_bin = "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge"
local edge_local_state = os.getenv("HOME") .. "/Library/Application Support/Microsoft Edge/Local State"

-- Build a display-name -> profile-directory map from Edge Local State
local function loadEdgeProfileMap()
	local f = io.open(edge_local_state, "r")
	if not f then
		return {}
	end
	local data = f:read("*a")
	f:close()
	local ok, json = pcall(hs.json.decode, data)
	if not ok or not json or not json.profile or not json.profile.info_cache then
		return {}
	end

	local map = {}
	for dir, meta in pairs(json.profile.info_cache) do
		if meta and meta.name then
			map[meta.name] = dir -- e.g., ["qz"] = "Profile 2", ["cl"] = "Profile 3", ["Personal"] = "Default"
		end
	end
	return map
end

-- Cache the profile map so we don't read every time
local edgeProfilesByName = loadEdgeProfileMap()

local function getEdgeProfileDir(displayName)
	-- fall back to Default if not mapped or missing
	return (displayName and edgeProfilesByName[displayName]) or "Default"
end

-- Function to open URL in specified browser
function openURLWith(url, browser)
	-- First, decide if this URL maps to a "container"/profile by display name
	local container = nil
	for pattern, container_name in pairs(container_map) do
		if string.find(url, pattern) then
			container = container_name
			break
		end
	end

	-- Branch: Microsoft Edge with profile directories
	if browser == edge_browser then
		local profileDir = getEdgeProfileDir(container) -- "Profile 2", "Profile 3", or "Default"
		local command = string.format('"%s" --profile-directory="%s" "%s"', edge_bin, profileDir, url)
		hs.execute(command)
		return
	end

	-- Branch: Zen with ext+container scheme
	if browser == zen_browser and container then
		local containerURL = string.format("ext+container:name=%s&url=%s", container, url)
		local command = string.format('/usr/bin/open -a "%s" "%s"', browser, containerURL)
		hs.execute(command)
		return
	end

	-- Fallback: open with the browser directly
	local command = string.format('/usr/bin/open -a "%s" "%s"', browser, url)
	hs.execute(command)
end

-- Force browser focus when opening links (Hammerspoon is default browser)
hs.urlevent.httpCallback = function(scheme, host, params, fullURL)
	-- Example: route to Edge
	-- openURLWith(fullURL, "Microsoft Edge")

	-- Your current default:
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

-- Screenshot active window and send to tmux: llm -a <file>
local llmshot = require("llm_screenshot")
-- Optional: target a specific tmux pane (e.g., "main:1.0")
-- llmshot.tmuxTarget = "main:1.0"
hs.hotkey.bind({ "ctrl" }, "s", function()
	llmshot.captureAndSend()
end)
