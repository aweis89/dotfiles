-- ctrl+j / ctrl+k -> down / up arrows (repeat while held).
for sourceKey, arrowKey in pairs({
	j = "down",
	k = "up",
}) do
	hs.hotkey.bind({ "ctrl" }, sourceKey, function()
		hs.eventtap.keyStroke({}, arrowKey, 0)
	end, nil, function()
		hs.eventtap.keyStroke({}, arrowKey, 0)
	end)
end
