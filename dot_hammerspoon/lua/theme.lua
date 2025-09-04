-- Theme synchronization and system event watchers

local M = {}

local reload_theme_path = "~/tmp/theme-reload"

-- Sync theme across apps and notify dependents
local function syncTheme()
  os.execute("~/.config/kitty/sync-theme " .. "tokyonight")
  os.execute("/opt/homebrew/bin/tmux source-file ~/.config/tmux/tmux.conf")
  os.execute("touch " .. reload_theme_path)
end

-- Public function in case others want to trigger it
function M.sync()
  syncTheme()
end

-- Watch for system theme changes (Dark/Light mode)
_G.themeWatcher = hs.distributednotifications.new(function(name, object, userInfo)
  local ok, err = pcall(function()
    syncTheme()
  end)
  -- keep the original debug output
  print(name)
  if not ok then
    print("Error in theme watcher: " .. tostring(err))
  end
end, "AppleInterfaceThemeChangedNotification")
_G.themeWatcher:start()

-- Watch for system wake/unlock events
_G.caffeinateWatcher = hs.caffeinate.watcher.new(function(eventType)
  if
    eventType == hs.caffeinate.watcher.systemDidWake
    or eventType == hs.caffeinate.watcher.screensDidUnlock
    or eventType == hs.caffeinate.watcher.screensDidWake
  then
    syncTheme()
  end
end)
_G.caffeinateWatcher:start()

return M
