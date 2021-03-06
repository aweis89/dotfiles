hs.loadSpoon("SpoonInstall")

Install = spoon.SpoonInstall

Install:andUse('EmmyLua')

hs.hotkey.bind({"ctrl"}, "space", function()
  local alacritty = hs.application.find('alacritty')
  if alacritty:isFrontmost() then
    alacritty:hide()
  else
    hs.application.launchOrFocus("Alacritty.app")
  end
end)

local screens = hs.screen.allScreens()
local hyper = {'cmd'}
local hyperShift = {'cmd', 'shift'}

if #screens == 2 then
	hs.hotkey.bind(hyper, '1', function()
		hs.application.launchOrFocus('Opera')
		hs.application.launchOrFocus('Alacritty')
		hs.application.launchOrFocus('Slack')

		local main_monitor = screens[1]:name()
		local macbook_monitor = screens[2]:name()
		local reading_layout = {
			{"Opera", nil, main_monitor, hs.layout.right50, nil, nil},
			{"Alacritty", nil, main_monitor, hs.layout.left50, nil, nil},
			{"Slack", nil, macbook_monitor, hs.layout.apply, nil, nil},
		}

		hs.layout.apply(reading_layout)
	end)
end

hs.hotkey.bind(hyperShift, 'o', function()
    hs.application.launchOrFocus('Opera')
end)

hs.hotkey.bind(hyperShift, 't', function()
    hs.application.launchOrFocus('Alacritty')
end)

hs.hotkey.bind(hyperShift, 's', function()
    hs.application.launchOrFocus('Slack')
end)
