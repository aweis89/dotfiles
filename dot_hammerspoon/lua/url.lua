-- URL routing and browser/container handling

local M = {}

-- Map URL patterns to Edge/Zen containers (display names for Edge)
local container_map = {
	["calendly"] = "cl",
	["workday"] = "wd",
}

-- App names/paths
M.zen_browser = "Zen Browser"
M.edge_browser = "Microsoft Edge"
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

-- Public API: open a URL with a browser, applying container/profile routing
function M.openURLWith(url, browser)
	-- First, decide if this URL maps to a "container"/profile by display name
	local container = nil
	for pattern, container_name in pairs(container_map) do
		if string.find(url, pattern) then
			container = container_name
			break
		end
	end

	-- Branch: Microsoft Edge with profile directories
	if browser == M.edge_browser then
		local profileDir = getEdgeProfileDir(container) -- "Profile 2", "Profile 3", or "Default"
		local command = string.format('"%s" --profile-directory="%s" "%s"', edge_bin, profileDir, url)
		hs.execute(command)
		return
	end

	-- Branch: Zen with ext+container scheme
	-- if browser == M.zen_browser and container then
	-- 	local containerURL = string.format("ext+container:name=%s&url=%s", container, url)
	-- 	local command = string.format('/usr/bin/open -a "%s" "%s"', browser, containerURL)
	-- 	hs.execute(command)
	-- 	return
	-- end

	-- Fallback: open with the browser directly
	local command = string.format('/usr/bin/open -a "%s" "%s"', browser, url)
	hs.execute(command)
end

-- Default browser for handler
M.defaultBrowser = M.zen_browser

function M.setDefaultBrowser(browser)
	M.defaultBrowser = browser or M.zen_browser
end

-- Install Hammerspoon URL callback that routes via openURLWith
hs.urlevent.httpCallback = function(scheme, host, params, fullURL)
	M.openURLWith(fullURL, M.defaultBrowser)
	-- copy url to clipboard for convenience
	hs.pasteboard.setContents(fullURL)
end
