local M = {}

function M.updateKittyTheme()
    local kittyDir = os.getenv("HOME") .. "/.config/kitty"
    local themeFile = kittyDir .. "/theme.conf"
    local darkTheme = kittyDir .. "/themes/my-theme-dark.conf"
    local lightTheme = kittyDir .. "/themes/my-theme-light.conf"
    
    -- Check system theme
    local isDark = hs.osascript.applescript([[
        tell application "System Events"
            tell appearance preferences
                return dark mode
            end tell
        end tell
    ]])
    
    -- Determine target theme
    local targetTheme = isDark and darkTheme or lightTheme
    
    -- Remove existing symlink if it exists
    os.execute("rm -f '" .. themeFile .. "'")
    
    -- Create new symlink
    os.execute("ln -s '" .. targetTheme .. "' '" .. themeFile .. "'")
    
    -- Send SIGUSR1 to all kitty processes
    local output = hs.execute("ps -x | grep '/Applications/kitty.app/Contents/MacOS/kitty' | grep -v grep | awk '{ print $1 }'")
    for pid in string.gmatch(output, "%d+") do
        os.execute("kill -SIGUSR1 " .. pid)
    end
end

return M
