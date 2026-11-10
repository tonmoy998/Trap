local Class = require(UI_PATH .. ".libs.class")
local Base = require(UI_PATH .. ".widgets.base")
local Theme = require(UI_PATH .. ".themes.Themes")
local Options = require(UI_PATH .. ".options")

local Rect = Class({
	__includes = Base,

	init = function(self, props)
		props = props or {}

		self.bgColor = props.bgColor or color.blue
		self.border = props.border or false
		self.lineWidth = props.lineWidth or 1
		self.borderColor = props.borderColor or color.red
		-- 1. Initialize Base class properties
		if Base.init then
			Base.init(self, props)
		end
	end,
	draw = function(self)
		if not self.enabled then
			return
		end
		-- Draw background
		love.graphics.setColor(self.bgColor)
		love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)

		-- draw border
		if self.border then
			love.graphics.setColor(color.magenta)
			love.graphics.setLineWidth(self.lineWidth)

			love.graphics.rectangle("line", self.x, self.y, self.w, self.h)
			love.graphics.setColor(1, 1, 1, 1)
			love.graphics.setLineWidth(1)
		end
	end,
})

return Rect
