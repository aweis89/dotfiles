-- URL routing and browser/container handling

local browser_config = require("lua.browser_config")
local M = {}

-- App names/paths
M.chromium_browser = browser_config.CHROMIUM_BROWSER
local chromium_bin = "/Applications/Chromium.app/Contents/MacOS/Chromium"
local chromium_local_state = os.getenv("HOME") .. "/Library/Application Support/Chromium/Local State"
local chromium_profile_rules = browser_config.CHROMIUM_PROFILE_RULES or {}

local function shellQuote(value)
	return "'" .. tostring(value):gsub("'", "'\\''") .. "'"
end

-- Build a display-name -> profile-directory map from Chromium Local State
local function loadChromiumProfileMap()
	local f = io.open(chromium_local_state, "r")
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
			map[string.lower(meta.name)] = dir
		end
	end
	return map
end

-- Cache the profile map so we don't read every time
local chromiumProfilesByName = loadChromiumProfileMap()

local function getChromiumProfileDir(displayName)
	-- fall back to Default if not mapped or missing
	return (displayName and chromiumProfilesByName[string.lower(displayName)]) or "Default"
end

local function getChromiumProfileForURL(url)
	local lowerURL = string.lower(url)
	for _, rule in ipairs(chromium_profile_rules) do
		if rule.pattern and rule.profile and string.match(lowerURL, string.lower(rule.pattern)) then
			return rule.profile
		end
	end
end

-- Public API: open a URL with a browser, applying container/profile routing
function M.openURLWith(url, browser)
	-- check if it's a zoom url
	if string.find(url, "zoom.us/j/", 1, true) then
		local zoom_command = string.format('/usr/bin/open -a "zoom.us" "%s"', url)
		hs.execute(zoom_command)
		return
	end

	local chromiumProfile = getChromiumProfileForURL(url)
	if chromiumProfile then
		local profileDir = getChromiumProfileDir(chromiumProfile)
		local command = string.format(
			"%s --profile-directory=%s %s >/dev/null 2>&1 &",
			shellQuote(chromium_bin),
			shellQuote(profileDir),
			shellQuote(url)
		)
		hs.execute(command)
		return
	end

	-- Fallback: open with the browser directly
	local command = string.format("/usr/bin/open -a %s %s", shellQuote(browser), shellQuote(url))
	hs.execute(command)
end

-- Default browser for handler
M.defaultBrowser = browser_config.default_browser

function M.setDefaultBrowser(browser)
	M.defaultBrowser = browser or M.chromium_browser
end

-- Install Hammerspoon URL callback that routes via openURLWith
hs.urlevent.httpCallback = function(scheme, host, params, fullURL)
	M.openURLWith(fullURL, M.defaultBrowser)
end
