-- Credit for this implementation goes to @arbelt and @jasoncodes 🙇⚡️😻
--
--   https://gist.github.com/arbelt/b91e1f38a0880afb316dd5b5732759f1
--   https://github.com/jasoncodes/dotfiles/blob/ac9f3ac/hammerspoon/control_escape.lua

sendTap = false
lastMods = {}

holdKeyTimer = hs.timer.delayed.new(0.15, function()
	sendTap = false
end)

holdTap = function(hold, tap)
	return function(evt)
		local newMods = evt:getFlags()
		if lastMods[hold] == newMods[hold] then
			return false
		end
		if not lastMods[hold] then
			lastMods = newMods
			sendTap = true
			holdKeyTimer:start()
		else
			if sendTap then
				keyUpDown({}, tap)
			end
			lastMods = newMods
			holdKeyTimer:stop()
		end
		return false
	end
end

ctrlTap = hs.eventtap.new({ hs.eventtap.event.types.flagsChanged }, holdTap("ctrl", "escape"))
ctrlTap:start()

otherHandler = function(evt)
	sendTap = false
	return false
end

otherTap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, otherHandler)
otherTap:start()
