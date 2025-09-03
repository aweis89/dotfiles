-- llm_screenshot.lua
-- Capture the focused window to a PNG and send `llm -a <path>` to tmux.

local M = {}

local log = hs.logger.new("llm_screenshot", "debug")

-- Directory to save screenshots (created if missing)
M.screenshotDir = os.getenv("HOME") .. "/tmp/hs-llm"

-- Optional tmux target, e.g. "main:1.0". If nil, uses tmux's current client.
-- You can override from init.lua: require('llm_screenshot').tmuxTarget = "session:window.pane"
M.tmuxTarget = nil

-- Mandatory tmux session to use when no pane target provided.
-- Assumes this session already exists.
M.tmuxSession = "default"

-- Name for created window when sending without an explicit pane target.
M.tmuxWindowName = "llm-shot"

-- If true, switch the client to the new window after creating it.
M.focusNewWindow = false

-- Command to run after the initial llm attachment to keep the session interactive
M.postCommand = "llm chat --continue"

-- Model and system prompt for the initial llm call
M.model = "gpt-5"
M.systemPrompt = table.concat({
	"You are assisting in a software engineering interview.",
	"Briefly summarize the problem.",
	"Then list the key insights the solution relies on.",
	"If code is required, implement it in Go (Golang).",
}, " ")

local function ensureDir(path)
	-- Use mkdir -p for simplicity and reliability
	local ok = os.execute(string.format("mkdir -p %q", path))
	if ok then
		log.d("Ensured dir exists: " .. path)
	else
		log.e("Failed to ensure dir: " .. path)
	end
end

local function findTmux()
	-- Prefer Homebrew path, but fall back to tmux in PATH
	local candidates = {
		"/opt/homebrew/bin/tmux",
		"/usr/local/bin/tmux",
		"tmux",
	}
	for _, p in ipairs(candidates) do
		-- hs.fs.attributes returns nil if not found for absolute paths; for "tmux" allow it to proceed
		if p == "tmux" then
			return p
		end
		local attr = hs.fs.attributes(p)
		if attr and attr.mode == "file" then
			return p
		end
	end
	return "tmux"
end

local function quoteArg(a)
	-- Do not quote tmux key names like C-m/Enter; quote everything else
	if a == "C-m" or a == "Enter" then
		return a
	end
	return '"' .. tostring(a):gsub('"', '\\"') .. '"'
end

local function argsToString(bin, args)
	local parts = { quoteArg(bin) }
	for _, a in ipairs(args) do
		table.insert(parts, quoteArg(a))
	end
	return table.concat(parts, " ")
end

local function escapeForDoubleQuotes(s)
	return (tostring(s):gsub('"', '\\"'))
end

local function runTmux(args)
	local tmux = findTmux()
	local cmdStr = argsToString(tmux, args)
	log.i("Running: " .. cmdStr)
	-- Use hs.execute for synchronous execution and output capture
	local out, success, typ, rc = hs.execute(cmdStr .. " 2>&1")
	log.i(string.format("exit success=%s type=%s rc=%s", tostring(success), tostring(typ), tostring(rc)))
	if out and #out > 0 then
		log.i("output: " .. out)
	end
	return success, out
end

local function requireSession(session)
	-- Require existing session; do not create it
	local ok = runTmux({ "has-session", "-t", session })
	return ok == true
end

local function sendToTmux(typed)
	-- Always: run in a new window inside an existing session
	if not M.tmuxSession or M.tmuxSession == "" then
		local msg = "tmuxSession must be set"
		log.e(msg)
		hs.alert.show(msg)
		return
	end
	if not requireSession(M.tmuxSession) then
		local msg = "tmux session not found: " .. M.tmuxSession .. " (start tmux first)"
		log.e(msg)
		hs.alert.show(msg)
		return
	end

	local prompt = M.prompt or "describe this image"
	local postCmd = M.postCommand or "llm chat --continue"
	local model = M.model or "gpt-5"
	local sys = M.systemPrompt
		or "You are assisting in a software engineering interview. Briefly summarize the problem. Then list the key insights the solution relies on. If code is required, implement it in Go (Golang)."
	-- Pipe the first llm command through rich for markdown; do not pipe chat continuation
	local firstCmd = string.format(
		'%s --model %s --system "%s" "%s" | rich - --markdown --force-terminal',
		typed,
		model,
		escapeForDoubleQuotes(sys),
		escapeForDoubleQuotes(prompt)
	)
	local fullCmd = string.format("%s; %s", firstCmd, postCmd)
	log.i("new-window command: " .. fullCmd)
	local ok = runTmux({ "new-window", "-t", M.tmuxSession, "-n", M.tmuxWindowName, fullCmd })
	if not ok then
		hs.alert.show("tmux new-window failed (see Console)")
	end
end

function M.captureAndSend()
	local win = hs.window.focusedWindow()
	if not win then
		hs.alert.show("No focused window")
		return
	end

	local img = win:snapshot()
	if not img then
		hs.alert.show("Snapshot failed")
		return
	end

	ensureDir(M.screenshotDir)

	local appName = ""
	local app = win:application()
	if app and app:name() then
		appName = app:name():gsub("%s+", "-")
	end

	local filename = string.format("%s-%s.png", os.date("%Y%m%d-%H%M%S"), appName)
	local path = string.format("%s/%s", M.screenshotDir, filename)

	local ok = img:saveToFile(path)
	if not ok then
		hs.alert.show("Failed to save screenshot")
		return
	end

	local typed = string.format('llm -a "%s"', escapeForDoubleQuotes(path))
	log.i("Prepared send-keys literal: " .. typed)
	sendToTmux(typed)
end

return M
