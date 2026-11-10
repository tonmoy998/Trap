local HoldButton = {}
HoldButton.__index = HoldButton

--- Creates a new Hold Button instance.
-- @param x, y The top-left position of the button
-- @param w, h The width and height of the button
-- @param holdTime Duration in seconds required to trigger
-- @param onComplete Function called when hold is completed
function HoldButton.new(x, y, w, h, holdTime, onComplete)
	local self = setmetatable({}, HoldButton)

	self.x = x
	self.y = y
	self.w = w
	self.h = h
	self.holdTime = holdTime or 1.0
	self.onComplete = onComplete or function() end

	self.text = "HOLD"
	self.progress = 0 -- Progress from 0.0 to 1.0
	self.activeTouchId = nil
	self.isTriggered = false

	-- Visual styling
	self.colorBg = { 0.2, 0.2, 0.2, 0.9 }
	self.colorProgress = { 0.2, 0.8, 0.4, 0.8 }
	self.colorText = { 1, 1, 1, 1 }
	self.colorBorder = { 0.5, 0.5, 0.5, 1 }
	self.cornerRadius = 12

	return self
end

--- Internal check to see if a touch coordinate falls within the button bounds.
function HoldButton:_contains(tx, ty)
	return tx >= self.x and tx <= self.x + self.w and ty >= self.y and ty <= self.y + self.h
end

--- Update the button state. Pass the delta time (`dt`) from love.update.
function HoldButton:update(dt)
	if self.activeTouchId then
		if not self.isTriggered then
			self.progress = self.progress + (dt / self.holdTime)

			if self.progress >= 1.0 then
				self.progress = 1.0
				self.isTriggered = true
				self:onComplete()
			end
		end
	else
		-- Smoothly drain progress back to zero when released prematurely
		if self.progress > 0 then
			self.progress = math.max(0, self.progress - (dt / (self.holdTime * 0.5)))
		end
	end
end

--- Call inside love.touchpressed
function HoldButton:touchpressed(id, x, y, dx, dy, pressure)
	if not self.activeTouchId and self:_contains(x, y) then
		self.activeTouchId = id
		self.isTriggered = false
		return true
	end
	return false
end

--- Call inside love.touchmoved
function HoldButton:touchmoved(id, x, y, dx, dy, pressure)
	if self.activeTouchId == id then
		-- Cancel hold if finger slides off the button
		if not self:_contains(x, y) then
			self.activeTouchId = nil
		end
	end
end

--- Call inside love.touchreleased
function HoldButton:touchreleased(id, x, y, dx, dy, pressure)
	if self.activeTouchId == id then
		self.activeTouchId = nil
		self.isTriggered = false
	end
end

--- Draw the button. Place this in love.draw.
function HoldButton:draw()
	-- Draw background
	love.graphics.setColor(self.colorBg)
	love.graphics.rectangle("fill", self.x, self.y, self.w, self.h, self.cornerRadius)

	-- Draw filled progress bar along the bottom of the button
	if self.progress > 0 then
		love.graphics.setColor(self.colorProgress)
		local fillWidth = self.w * self.progress

		-- Use a scissor box to constrain rounded progress fill to the button boundary
		love.graphics.setScissor(self.x, self.y, fillWidth, self.h)
		love.graphics.rectangle("fill", self.x, self.y, self.w, self.h, self.cornerRadius)
		love.graphics.setScissor()
	end

	-- Draw border
	love.graphics.setColor(self.colorBorder)
	love.graphics.rectangle("line", self.x, self.y, self.w, self.h, self.cornerRadius)

	-- Draw button text
	love.graphics.setColor(self.colorText)
	local font = love.graphics.getFont()
	local textW = font:getWidth(self.text)
	local textH = font:getHeight()
	love.graphics.print(self.text, self.x + (self.w - textW) / 2, self.y + (self.h - textH) / 2)

	-- Reset graphics color
	love.graphics.setColor(1, 1, 1, 1)
end

return HoldButton
