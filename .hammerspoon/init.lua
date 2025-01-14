require("keyboard")

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

local themeWatcher = hs.distributednotifications.new(function(name, object, userInfo)
  os.execute("~/.config/kitty/sync-theme")
  os.execute("/opt/homebrew/bin/tmux source-file ~/.config/tmux/tmux.conf")
end, "AppleInterfaceThemeChangedNotification")
themeWatcher:start()

-- hs.loadSpoon("ControlEscape"):start()
