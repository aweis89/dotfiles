local status, hyperModeAppMappings = pcall(require, "keyboard.hyper-apps")

if not status then
  hyperModeAppMappings = require("keyboard.hyper-apps-defaults")
end

for _, mapping in ipairs(hyperModeAppMappings) do
  local key = mapping[1]
  local app = mapping[2]
  local postOpen = mapping[3]
  hs.hotkey.bind({ "shift", "ctrl", "alt", "cmd" }, key, function()
    hs.application.open(app)
    if type(postOpen) == "function" then
      postOpen()
    end
  end)
end
