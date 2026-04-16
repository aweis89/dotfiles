local M = {}

M.EDGE_BROWSER = "Microsoft Edge"
M.CHROME_BROWSER = "Google Chrome"
M.CHROMIUM_BROWSER = "Chromium"

M.CHROMIUM_PROFILE_RULES = {
	{ pattern = "calendly", profile = "calendly" },
	{ pattern = "evisort", profile = "workday" },
	{ pattern = "workday", profile = "workday" },
}

M.default_browser = M.CHROMIUM_BROWSER

return M
