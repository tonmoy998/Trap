local Class = require(UI_PATH .. ".libs.class")
local Base = require(UI_PATH .. ".widgets.base")
local Theme = require(UI_PATH .. ".themes.Themes")
local Options = require(UI_PATH .. ".options")
local clamp = require(UI_PATH .. ".libs.clamp")

local Toggle = Class({
	__includes = Base,

	init = function(self, props)
		props = props or {}

		-- 1. Initialize Base class properties
		if Base.init then
			Base.init(self, props)
		end
		self.status = true
		self.bw = self.w * 0.45
		self.bh = self.h * 0.8
		self.bx = self.x + self.w * 0.5
		self.by = self.y + self.h * 0.1
		self.bgColor = props.bgColor or color.blue
		self.fillColor = props.fillColor or color.white
		self.isHovered = false
	end,

	draw = function(self)
		if not self.enabled then
			return
		end

		love.graphics.setColor(self.bgColor)
		if self.hovered then
			-- love.graphics.setColor(rgba(120, 120, 120, 1))
		end
		love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)

		love.graphics.setColor(self.fillColor)
		love.graphics.rectangle("fill", self.bx, self.by, self.bw, self.bh)
	end,
	update = function(self)
		if not self.enabled then
			return
		end

		if self.status then
			self.bx = self.x + self.w * 0.5
			self.by = self.y + self.h * 0.1
		else
			self.bx = self.x + self.w * 0.05
			self.by = self.y + self.h * 0.1
		end

		self.hovered = self:isMouseOver(self.x, self.y, self.w, self.h)
	end,
	isMouseOver = function(self, x, y, w, h)
		local mx, my = love.mouse.getPosition()
		return mx >= x and mx <= x + w and my >= y and my <= y + h
	end,
	mousepressed = function(self, mx, my, button)
		if self.hovered then
			if button == 1 then
				self.clicked = true
				self.status = not self.status
				self.onClick()
			end
		end
	end,
	mousereleased = function(self, mx, my, button)
		if self.hovered then
			if button == 1 then
				self.clicked = false
				self.onRelease()
			end
		end
	end,
})

return Toggle
