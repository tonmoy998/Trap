local Class = require("lib.hump.class")
local Flag = Class({
	init = function(self, props)
		self.x = props.x or 100
		self.y = props.y or 100

		-- 300x60 60x60 1x5
		self.img = props.img or love.graphics.newImage("assets/gameui/flaganimation.png")
		self.grid = props.grid or anim8.newGrid(60, 60, 300, 60)
		self.animation = anim8.newAnimation(self.grid("1-5", 1), 0.2)
		self.scaleX = props.scaleX or 1
		self.scaleY = props.scaleY or 1
		self.r = props.r or 0
		self.ox = props.ox or 0
		self.oy = props.oy or 0
		self.bg = props.bg or color.red
	end,

	draw = function(self)
		if self.img and self.animation then
			love.graphics.setColor(self.bg)
			self.animation:draw(self.img, self.x, self.y, self.r, self.scaleX, self.scaleY, self.ox, self.oy)
			love.graphics.setColor(1, 1, 1, 1)
		end
	end,

	update = function(self, dt)
		if self.img and self.animation then
			self.animation:update(dt)
		end
	end,
})
return Flag
