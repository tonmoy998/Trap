local Class = require("lib.hump.class")
local Timer = require("lib.hump.timer")
local Palindrome = Class({
	init = function(self, props)
		self.x = props.x or 100
		self.y = props.y or 100
		self.w = props.w or 10
		self.h = props.h or 10
		self.l = props.l or 20
		self.radius = props.radius or 30
		self.world = props.world or nil
		self.ox = props.ox or 0
		self.oy = props.oy or 0
		self.name = props.name or "Palindrome"
		self.bg = props.bg or color.red

		self.head = props.head or self.world:newRectangleCollider(self.x, self.y, self.w, self.h)
		self.head:setType("static")
		self.bob = props.bob or self.world:newCircleCollider(self.x, self.y + self.l + (self.radius / 2), self.radius)
		self.bob:setCollisionClass(self.name)
		self.bob:setFriction(0)
		self.bob:setLinearDamping(0) -- Prevent air resistance slowdown

		self.forceApplied = false
		self.bobX, self.bobY = self.bob:getPosition()
		self.lineWidth = props.lineWidth or 2
		self.lineColor = props.lineColor or color.black

		-- Anchor 1: Center of the head (self.x, self.y)
		-- Anchor 2: Center of the bob (self.x, self.y + self.l + self.radius / 2)
		self.joint = props.joint
			or self.world:addJoint(
				"DistanceJoint",
				self.head,
				self.bob,
				self.x,
				self.y,
				self.x,
				self.y + self.l + (self.radius / 2)
			)
		self.direction = props.direction or 1
		self.force = props.force or 500
	end,

	draw = function(self)
		if self.bob ~= nil and self.head ~= nil then
			-- DRAW ROPE
			love.graphics.setLineWidth(self.lineWidth)
			love.graphics.setColor(self.lineColor)
			love.graphics.line(self.head:getX(), self.head:getY(), self.bobX, self.bobY)
			love.graphics.setColor(1, 1, 1, 1)

			-- Draw BOB
			love.graphics.setColor(self.bg)
			love.graphics.circle("fill", self.bobX, self.bobY, self.radius)
			love.graphics.setColor(1, 1, 1, 1)
		end
	end,
	update = function(self, dt)
		-- !NOTE: Palindrome Update function occursing player ground bug
		-- !BUG : Starts There
		-- !BUG: Palindrome BOB Position is doing the bug
		-- if self.bob ~= nil and self.head ~= nil and self.joint ~= nil then
		-- 	local vx, vy = self.bob:getLinearVelocity()
		-- 	if vx == 0 and vy == 0 and not self.forceApplied then
		-- 		self.bob:applyLinearImpulse(self.force, self.force)
		-- 		self.forceApplied = true
		-- 	end
		-- 	self.bobX, self.bobY = self.bob:getPosition()
		--

		-- !BUG : Ends there
		-- 	-- if self.bob:enter("Player") then
		-- 	-- 	Signal.emit("Palindrome Collision")
		-- 	-- end
		-- end

		-- if love.keyboard.isDown("x") then
		-- 	self:destroy()
		-- elseif love.keyboard.isDown("c") then
		-- 	self:reset()
		-- end

		if self.bob ~= nil and self.head ~= nil then
			self.bobX, self.bobY = self.bob:getPosition()

			local vx, vy = self.bob:getLinearVelocity()
			if vx == 0 and vy == 0 and not self.forceApplied then
				self.bob:applyLinearImpulse(self.force, self.force)
				self.forceApplied = true
			end
			if self.bob:enter("Player") then
				Signal.emit("Palindrome Collision")
			end
		end
	end,

	destroy = function(self)
		if self.joint ~= nil then
			self.world:removeJoint(self.joint)
			self.joint = nil
		end
		if self.bob ~= nil then
			self.bob:destroy()
			self.bob = nil
		end
		if self.head ~= nil then
			self.head:destroy()
			self.head = nil
		end
	end,

	reset = function(self)
		self.forceApplied = false
		if self.bob == nil and self.head == nil and self.joint == nil then
			self.head = self.world:newRectangleCollider(self.x, self.y, self.w, self.h)
			self.head:setType("static")
			self.bob = self.world:newCircleCollider(self.x, self.y + self.l + (self.radius / 2), self.radius)
			self.bob:setCollisionClass(self.name)
			self.bob:setFriction(0)
			self.bob:setLinearDamping(0) -- Prevent air resistance slowdown

			self.joint = self.world:addJoint(
				"DistanceJoint",
				self.head,
				self.bob,
				self.x,
				self.y,
				self.x,
				self.y + self.l + (self.radius / 2)
			)
			self.bob:applyLinearImpulse(self.force, self.force)
			self.forceApplied = true
		end
	end,
})

return Palindrome
