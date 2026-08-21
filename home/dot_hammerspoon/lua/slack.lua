-- Keep Slack presence "active" by nudging it while the machine sits idle.
--
-- NOTE: the repeating timer MUST be retained in a long-lived reference
-- (_G.slackKeepActiveTimer). A timer created as `hs.timer.doEvery(...)` with the
-- return value discarded gets garbage-collected and silently stops firing.

local log = hs.logger.new("slack", "info")

local IDLE_MIN = 5 -- nudge Slack after this many minutes idle
local CHECK_INTERVAL = 30 -- seconds between idle checks
local WORKSPACES = { "1", "2" }

local function screenIsUsable()
	-- Clicking is pointless when the session is locked or the display is asleep.
	local props = hs.caffeinate.sessionProperties() or {}
	if props.CGSSessionScreenIsLocked == true or props.CGSSessionScreenIsLocked == 1 then
		return false, "screen locked"
	end
	if hs.screen.mainScreen() == nil then
		return false, "no screen"
	end
	return true
end

local function makeSlackActive()
	local ok, why = screenIsUsable()
	if not ok then
		log.f("skipping nudge: %s", why)
		return
	end

	local slackApp = hs.application.find("Slack")
	if not slackApp then
		log.w("Slack not running")
		return
	end

	local previousApp = hs.application.frontmostApplication()
	slackApp:activate()

	local slackWindow = slackApp:mainWindow()
	if not slackWindow then
		log.w("no Slack window")
		if previousApp then
			previousApp:activate()
		end
		return
	end

	for _, workspace in ipairs(WORKSPACES) do
		hs.eventtap.keyStroke({ "cmd" }, workspace, 0, slackApp)
		hs.timer.usleep(500000)

		local f = slackWindow:frame()
		hs.eventtap.leftClick({ x = f.x + 100, y = f.y + 75 })
		hs.timer.usleep(500000)
	end

	if previousApp and previousApp:bundleID() ~= slackApp:bundleID() then
		previousApp:activate()
	end
	log.f("nudged Slack (%d workspaces)", #WORKSPACES)
end

if _G.slackKeepActiveTimer then
	_G.slackKeepActiveTimer:stop()
	_G.slackKeepActiveTimer = nil
end

_G.slackKeepActiveTimer = hs.timer.new(CHECK_INTERVAL, function()
	if hs.host.idleTime() > (IDLE_MIN * 60) then
		makeSlackActive()
	end
end)
_G.slackKeepActiveTimer:start()

-- Exposed for manual testing: hs -c 'slackNudgeNow()'
_G.slackNudgeNow = makeSlackActive
