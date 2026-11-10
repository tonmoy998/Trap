local function printFPS(font, default)
	local fps = love.timer.getFPS()
	love.graphics.setColor(0, 1, 0, 1) -- Green text
	love.graphics.setFont(font)
	love.graphics.print("FPS: " .. tostring(fps), 10, 10)
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setFont(default)
end

return printFPS
