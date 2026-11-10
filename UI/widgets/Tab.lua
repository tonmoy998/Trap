local Class = require(UI_PATH .. ".libs.class")
local Base = require(UI_PATH .. ".widgets.base")
local Theme = require(UI_PATH .. ".themes.Themes")
local Options = require(UI_PATH .. ".options")

local Tab = Class({
	__includes = Base,

	init = function(self, props)
		props = props or {}

		-- 1. Initialize Base class properties
		if Base.init then
			Base.init(self, props)
		end
		if self.debug then
			print("Tab added" .. self.id)
		end
		self.headinds = props.headinds or function() end
		self.active = props.active or 1
		self.total = props.total or 2
		self.one = props.one or function() end
		self.two = props.two or function() end
	end,
	draw = function(self)
		if not self.enabled then
			return
		end
		if self.active == 1 then
			self.one()
		elseif self.active == 2 then
			self.two()
		else
			self.one()
		end
	end,
	update = function(self)
		if not self.enabled then
			return
		end
	end,
	isMouseOver = function(self, mx, my)
		return mx >= self.x and mx <= self.x + self.w and my >= self.y and my <= self.y + self.h
	end,

	mousepressed = function(self, mx, my, button)
		if not self.enabled then
			return
		end

		if button == 1 and self.hovered then
			self.clicked = true
			if self.onClick then
				self:onClick()
			end
		end
	end,

	mousereleased = function(self, mx, my, button)
		if not self.enabled then
			return
		end

		if button == 1 then
			if self.clicked then
				self.clicked = false
				if self.hovered then
					self:onRelease()
				end
			end
		end
	end,
})

return Tab
