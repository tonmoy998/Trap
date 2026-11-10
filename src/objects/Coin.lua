local Class = require("lib.hump.class")
local anim8 = require("lib.anim8.anim8")

local Coin = Class({
	init = function(self, props)
		self.x = props.x or 100
		self.y = props.y or 100
		self.img = love.graphics.newImage("assets/gameui/Coin_Gems/MonedaD.png")
		self.grid = anim8.newGrid(16, 16, 80, 16)
		self.animation = anim8.newAnimation(self.grid("1-4", 1), 0.1)
		self.ox = props.ox or 8
		self.oy = props.oy or 8
		self.scaleX = props.scaleX or 1
		self.scaleY = props.scaleY or 1
		self.world = props.world or nil
		self.radius = props.radius or 30
		if self.world then
			self.body = self.world:newCircleCollider(self.x, self.y, self.radius)
			self.body:setType("static")
			self.body:setCollisionClass("Coin")
			self.body:setObject(self)
		end
		self.r = props.r or 0
	end,
	draw = function(self)
		if self.body then
			if self.img and self.animation and self.body then
				self.animation:draw(self.img, self.x, self.y, self.r, self.scaleX, self.scaleY, self.ox, self.oy)
			end
		end
	end,

	update = function(self, dt)
		if self.body then
			if self.img and self.animation and self.body then
				self.animation:update(dt)
				if self.body:enter("Player") then
					self.body:destroy()
					self.body = nil
					Signal.emit("Coin Collision")
				end
			end
		end
	end,
	destroy = function(self)
		if self.world ~= nil and self.body ~= nil then
			self.body:destroy()
			self.body = nil
		end
	end,
})

return Coin
