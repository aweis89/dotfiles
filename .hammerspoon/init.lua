require("keyboard")
local reload_theme_path = "~/tmp/theme-reload"

-- Function to open URL in specified browser
function openURLInArc(url, browser)
  -- Use 'open' command to specifically launch URL in Arc
  local command = string.format('/usr/bin/open -a "%s" "%s"', browser, url)
  hs.execute(command)
end

-- force browser focus when opening links
-- fixes issues with slack where the link is opened, but focus doesn't change
-- requires hammerspoon to be the default browser
hs.urlevent.httpCallback = function(scheme, host, params, fullURL)
  openURLInArc(fullURL, "Arc")
end

-- Set up theme sync for system theme changes
local function syncTheme()
  os.execute("~/.config/kitty/sync-theme " .. "catppuccin")
  os.execute("/opt/homebrew/bin/tmux source-file ~/.config/tmux/tmux.conf")
  os.execute("touch " .. reload_theme_path)
end

-- Watch for system theme changes
local themeWatcher = hs.distributednotifications.new(function(name, object, userInfo)
  syncTheme()
end, "AppleInterfaceThemeChangedNotification")
themeWatcher:start()

-- Watch for system wake/unlock events
local caffeinateWatcher = hs.caffeinate.watcher.new(function(eventType)
  if eventType == hs.caffeinate.watcher.systemDidWake or
      eventType == hs.caffeinate.watcher.screensDidUnlock or
      eventType == hs.caffeinate.watcher.screensDidWake then
    syncTheme()
  end
end)
caffeinateWatcher:start()

-- hs.loadSpoon("ControlEscape"):start()
