local Class = require(UI_PATH .. ".libs.class")
local Base = require(UI_PATH .. ".widgets.base")
local Theme = require(UI_PATH .. ".themes.Themes")
local Options = require(UI_PATH .. ".options")
local clamp = require(UI_PATH .. ".libs.clamp") -- assumes clamp(value, min, max)

local Slider = Class({
	__includes = Base,

	init = function(self, props)
		props = props or {}

		-- 1. Initialize Base class properties
		if Base.init then
			Base.init(self, props)
		end

		-- value (0..1) is the single source of truth
		self.value = clamp(props.value or 0.5, 0, 1)

		self.bgColor = props.bgColor or rgba(104, 104, 104, 1)
		self.fillColor = props.fillColor or color.blue
		self.barColor = props.barColor or rgba(255, 255, 255, 1)
		self.barHoverColor = props.barHoverColor or rgba(220, 120, 220, 1)

		self.bw = props.bw or 20
		self.bh = props.bh or 40

		self.barHovered = false
		self.barDragging = false
	end,

	-- Bar position is always derived from value, so it stays correct
	-- even if the layout moves or resizes the slider.
	getBarRect = function(self)
		local bx = self.x + self.w * self.value - self.bw / 2
		local by = self.y + (self.h - self.bh) / 2
		return bx, by, self.bw, self.bh
	end,

	draw = function(self)
		if not self.enabled then
			return
		end

		-- background
		love.graphics.setColor(self.bgColor)
		love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)

		-- fill
		love.graphics.setColor(self.fillColor)
		love.graphics.rectangle("fill", self.x, self.y, self.w * self.value, self.h)

		-- bar (pick the color locally instead of mutating state in draw)
		if self.barHovered or self.barDragging then
			love.graphics.setColor(self.barHoverColor)
		else
			love.graphics.setColor(self.barColor)
		end
		love.graphics.rectangle("fill", self:getBarRect())
	end,

	update = function(self, dt)
		if not self.enabled then
			return
		end

		self.barHovered = self:isMouseOver(self:getBarRect())

		if self.barDragging and self.w > 0 then
			local mx = love.mouse.getX()
			self.value = clamp((mx - self.x) / self.w, 0, 1)
		end
	end,

	isMouseOver = function(self, x, y, w, h)
		local mx, my = love.mouse.getPosition()
		return mx >= x and mx <= x + w and my >= y and my <= y + h
	end,

	mousepressed = function(self, mx, my, button)
		if self.barHovered and button == 1 then
			self.barDragging = true
		end
	end,

	mousereleased = function(self, mx, my, button)
		if self.barDragging and button == 1 then
			self.barDragging = false
		end
	end,
})

return Slider
