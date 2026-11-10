local Class = require("lib.hump.class") -- Adjust path to your HUMP Class module

local YouWin = Class({
	init = function(self, props)
		props = props or {}

		-- Position & Scale Properties
		self.x = props.x or love.graphics.getWidth() / 2
		self.y = props.y or love.graphics.getHeight() / 2
		self.baseScale = props.scale or 1
		self.scale = 0
		self.rotation = props.rotation or 0

		-- Text & Styling
		self.text = props.text or "YOU WIN!"
		self.font = props.font or love.graphics.newFont(64)
		self.textColor = props.textColor or { 1, 0.84, 0 } -- Gold
		self.glowColor = props.glowColor or { 1, 0.4, 0, 0.6 } -- Orange glow

		-- Animation Timers & States
		self.timer = 0
		self.active = true
		self.pulse = 0
		self.shineOffset = -200

		-- Setup Particles
		self:initParticles()
	end,
})

function YouWin:initParticles()
	-- Create a 1x1 white pixel canvas for particles
	local pCanvas = love.graphics.newCanvas(4, 4)
	love.graphics.setCanvas(pCanvas)
	love.graphics.clear(1, 1, 1, 1)
	love.graphics.setCanvas()

	self.psystem = love.graphics.newParticleSystem(pCanvas, 100)
	self.psystem:setParticleLifetime(0.5, 1.2)
	self.psystem:setLinearAcceleration(-150, -150, 150, 150)
	self.psystem:setColors(1, 0.9, 0.2, 1, 1, 0.2, 0.1, 0) -- Fade color
	self.psystem:setSizes(1.5, 0.5)
	self.psystem:emit(50)
end

function YouWin:update(dt)
	if not self.active then
		return
	end

	self.timer = self.timer + dt
	self.psystem:update(dt)

	-- Pop-in Scale Effect (Elastic Ease-Out)
	if self.timer < 0.6 then
		local t = self.timer / 0.6
		self.scale = self.baseScale * (math.sin(t * math.pi * 0.5) + math.sin(t * math.pi * 2.5) * 0.15)
	else
		self.scale = self.baseScale
	end

	-- Floating / Bobbing Motion
	self.pulse = math.sin(self.timer * 4) * 8

	-- Text Light Sweep / Shine effect
	self.shineOffset = self.shineOffset + dt * 400
	if self.shineOffset > 400 then
		self.shineOffset = -300
	end
end

function YouWin:draw()
	if not self.active then
		return
	end

	love.graphics.push()
	love.graphics.translate(self.x, self.y + self.pulse)
	love.graphics.rotate(self.rotation)
	love.graphics.scale(self.scale, self.scale)

	-- Draw Background Particles
	love.graphics.draw(self.psystem, 0, 0)

	-- Text Dimensions
	love.graphics.setFont(self.font)
	local textWidth = self.font:getWidth(self.text)
	local textHeight = self.font:getHeight()
	local originX = textWidth / 2
	local originY = textHeight / 2

	-- 1. Outer Glow / Drop Shadow Pass
	love.graphics.setColor(self.glowColor)
	for ox = -3, 3, 3 do
		for oy = -3, 3, 3 do
			love.graphics.print(self.text, -originX + ox, -originY + oy)
		end
	end

	-- 2. Base Text Pass
	love.graphics.setColor(self.textColor)
	love.graphics.print(self.text, -originX, -originY)

	-- 3. Shiny Overlay Effect (Stencil Mask)
	love.graphics.stencil(function()
		love.graphics.print(self.text, -originX, -originY)
	end, "replace", 1)

	love.graphics.setStencilTest("greater", 0)
	love.graphics.setColor(1, 1, 1, 0.4)
	love.graphics.polygon(
		"fill",
		self.shineOffset,
		-originY - 20,
		self.shineOffset + 40,
		-originY - 20,
		self.shineOffset - 20,
		originY + 20,
		self.shineOffset - 60,
		originY + 20
	)
	love.graphics.setStencilTest()

	-- Reset Color
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.pop()
end

return YouWin
