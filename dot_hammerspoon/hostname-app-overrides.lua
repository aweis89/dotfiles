-- Hostname-specific app overrides
-- This file contains overrides for specific hostnames
-- Only specify the apps that differ from the default configuration

return {
	-- Override configurations for specific hostnames
	["ACV2MK4DXH0"] = {
		-- Only specify the apps that should be different from default
		["c"] = "Microsoft Outlook", -- Calendar: Microsoft Outlook instead of calendar
	},

	-- Add more hostname overrides here as needed
	-- ["ANOTHER-HOSTNAME"] = {
	--     ["t"] = "Terminal",     -- Terminal: Terminal instead of Ghostty
	--     ["a"] = "Claude",       -- AI: Claude instead of ChatGPT
	-- },
}
