local Class = require("lib.hump.class")
local Ground = Class({
	init = function(self, props)
		self.x = props.x or 100
		self.y = props.y or 100
		self.w = props.w or 100
		self.h = props.h or 100
		self.world = props.world or nil
		self.ox = props.ox or 0
		self.oy = props.oy or 0
		self.name = props.name or "Ground"
		self.rotation = props.rotation or true
		self.bg = props.bg or color.gray
		if self.world then
			self.body = self.world:newRectangleCollider(self.x, self.y, self.w, self.h)
			self.body:setType("static")
			self.body:setFixedRotation(self.rotation)
			self.body:setCollisionClass(self.name)
		end
	end,

	draw = function(self)
		if self.body then
			love.graphics.setColor(self.bg)
			love.graphics.rectangle("fill", self.x + self.ox, self.y + self.oy, self.w, self.h)
			love.graphics.setColor(1, 1, 1, 1)
		end
	end,

	update = function(self, dt)
		if self.body then
			self.x, self.y = self.body:getPosition()
		end
	end,

	destroy = function(self)
		if self.world ~= nil and self.collider ~= nil then
			self.body:destroy()
			self.body = nil
		end
	end,
})

return Ground
