local M = {}

-- Helper to find the correct Zen Browser app name
-- Tries to launch both "Zen Browser" and "Zen" to see which one exists
local function findZenBrowser()
	-- Try "Zen Browser" first (newer naming)
	local result = hs.execute("open -a 'Zen Browser' --background 2>/dev/null")
	if result then
		return "Zen Browser"
	end
	
	-- Fall back to "Zen" (older naming)
	local result2 = hs.execute("open -a 'Zen' --background 2>/dev/null")
	if result2 then
		return "Zen"
	end
	
	-- Default to "Zen Browser" if we can't determine
	return "Zen Browser"
end

M.ZEN_BROWSER = findZenBrowser()
M.EDGE_BROWSER = "Microsoft Edge"

M.default_browser = M.ZEN_BROWSER

return M
