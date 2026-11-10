local Class = require("lib.hump.class")

local Ball = Class({})

function Ball:init(props)
	self.x = props.x or 100
	self.y = props.y or 100
	self.radius = props.radius or 30
	self.startY = props.y or 100
	self.targetBounceHeight = props.targetBounceHeight or 50 -- Max vertical travel distance
	self.force = props.force or -2500

	self.world = props.world or nil
	self.body = self.world:newCircleCollider(self.x, self.y, self.radius)
	self.body:setFriction(0) -- Prevent energy loss from surface friction
	self.body:setLinearDamping(0) -- Prevent air resistance slowdown

	self.body:setObject(self)
	self.onGrond = props.onGrond or false
end

function Ball:update(dt)
	if self.body ~= nil then
		if self.body:enter("Ground") then
			self.onGrond = true
			self:bounce(self.force)
		elseif self.body:enter("Player") then
			Signal.emit("Ball Collision")
		end
	end
end

function Ball:bounce(force)
	if self.onGrond then
		Signal.emit("Ball")
		self.body:applyLinearImpulse(0, force)
		self.onGrond = false
	end
end

function Ball:draw()
	if self.body ~= nil then
		local x = self.body:getX()
		local y = self.body:getY()

		-- Draw ball outline and fill
		love.graphics.setColor(0.9, 0.3, 0.3)
		love.graphics.circle("fill", x, y, self.radius)

		love.graphics.setColor(1, 1, 1)
	end

	--	love.graphics.circle("line", x, y, self.radius)
end

function Ball:reset(x, y)
	if self.body == nil then
		self.body = self.world:newCircleCollider(x, y, self.radius)
		-- self.collider:setRestitution(1.0) -- Perfectly elastic collision (no energy loss)
		self.body:setFriction(0) -- Prevent energy loss from surface friction
		self.body:setLinearDamping(0) -- Prevent air resistance slowdown
	end
end

function Ball:destroy()
	if self.world ~= nil and self.body ~= nil then
		self.body:destroy()
		self.body = nil
	end
end

return Ball
