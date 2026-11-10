local Class = require(UI_PATH .. ".libs.class")
local Base = require(UI_PATH .. ".widgets.base")
local Theme = require(UI_PATH .. ".themes.Themes")
local Options = require(UI_PATH .. ".options")

local Img = Class({
	__includes = Base,

	init = function(self, props)
		props = props or {}

		-- 1. Initialize the Base widget class properties if Base has an init method
		if Base.init then
			Base.init(self, props)
		end
		self.img = props.img or nil
		self.r = props.r or 0
		self.scaleX = self.w / self.img:getWidth() or 1
		self.scaeleY = self.h / self.img:getHeight() or 1
	end,
	draw = function(self)
		if not self.enabled then
			return
		end
		if self.img then
			love.graphics.draw(self.img, self.x, self.y, self.r, self.scaleX, self.scaleY)
		end
	end,
})
return Img
