-- ~/.hammerspoon/init.lua
-- Idle → nudge to check Slack (no simulated input)

local IDLE_MIN = 1 -- trigger after X minutes idle

local function makeSlackActive()
	local currentApp = hs.application.frontmostApplication()
	hs.application.launchOrFocus("Slack")
	local slackApp = hs.application.find("Slack")
	if not slackApp then
		hs.alert.show("Slack not running")
		return
	end

	-- Find a window of Slack
	local slackWindow = slackApp:mainWindow()
	if not slackWindow then
		hs.alert.show("No Slack window")
		return
	end

	local workspaces = { "1", "2" }
	-- Loop through each workspace
	for _, workspace in ipairs(workspaces) do
		hs.eventtap.keyStroke({ "cmd" }, workspace)
		hs.timer.usleep(500000) -- wait 100ms
		local f = slackWindow:frame()
		local clickPos = { x = f.x + 100, y = f.y + 75 }
		hs.eventtap.leftClick(clickPos)
		hs.timer.usleep(500000) -- wait 100ms between workspaces
	end
	hs.application.launchOrFocus(currentApp:name())
end

hs.timer.doEvery(30, function()
	local idle = hs.host.idleTime()
	if idle > (IDLE_MIN * 60) then
		makeSlackActive()
	end
end)
