-- Keyboard layout canvas display
local M = {}

-- Canvas instance
local canvas = nil
local isVisible = false

-- Create and configure the canvas
function M.createCanvas(imagePath)
	if canvas then
		canvas:delete()
	end

	-- Get screen dimensions
	local screen = hs.screen.mainScreen()
	local screenFrame = screen:frame()

	-- Canvas dimensions (adjust as needed)
	local canvasWidth = screenFrame.w * 0.95
	local canvasHeight = screenFrame.h * 0.95
	local canvasX = (screenFrame.w - canvasWidth) / 2
	local canvasY = (screenFrame.h - canvasHeight) / 2

	-- Create canvas
	canvas = hs.canvas.new({
		x = canvasX,
		y = canvasY,
		w = canvasWidth,
		h = canvasHeight,
	})

	-- Add semi-transparent background
	canvas[1] = {
		type = "rectangle",
		action = "fill",
		fillColor = { red = 0, green = 0, blue = 0, alpha = 0.8 },
		roundedRectRadii = { xRadius = 10, yRadius = 10 },
	}

	-- Add image
	canvas[2] = {
		type = "image",
		image = hs.image.imageFromPath(imagePath),
		imageScaling = "scaleProportionally",
		imageAlignment = "center",
		frame = {
			x = "5%",
			y = "5%",
			w = "95%",
			h = "95%",
		},
	}

	-- Set canvas properties to show over fullscreen windows
	-- Requires hs.dockicon.hide() to be called in init.lua
	canvas:behavior(hs.canvas.windowBehaviors.canJoinAllSpaces)
	canvas:level(hs.canvas.windowLevels.screenSaver)
	-- Make canvas clickthrough so it doesn't interfere with the app below
	canvas:clickActivating(false)

	return canvas
end

-- Toggle canvas visibility
function M.toggle(imagePath)
	if not canvas then
		M.createCanvas(imagePath)
	end

	if canvas then
		if isVisible then
			canvas:hide()
			isVisible = false
		else
			canvas:show()
			isVisible = true
		end
	end
end

-- Show canvas
function M.show(imagePath)
	if not canvas then
		M.createCanvas(imagePath)
	end
	if canvas then
		canvas:show()
		isVisible = true
	end
end

-- Hide canvas
function M.hide()
	if canvas then
		canvas:hide()
		isVisible = false
	end
end

-- Cleanup
function M.cleanup()
	if canvas then
		canvas:delete()
		canvas = nil
		isVisible = false
	end
end

return M
