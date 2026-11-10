local Class = require("lib.hump.class")
local wf = require("lib.windfield.windfield")
local anim8 = require("lib.anim8.anim8")

-- Generates a soft round white texture for particles (no asset needed)
local function makeDustTexture()
	local size = 8
	local data = love.image.newImageData(size, size)
	data:mapPixel(function(x, y)
		local dx, dy = x - size / 2 + 0.5, y - size / 2 + 0.5
		local d = math.sqrt(dx * dx + dy * dy) / (size / 2)
		return 1, 1, 1, math.max(0, 1 - d)
	end)
	return love.graphics.newImage(data)
end

local Player = Class({
	init = function(self, props)
		self.x = props.x or 0
		self.y = props.y or 0
		self.w = props.w or 100
		self.h = props.h or 100
		self.ox = props.ox or (614 * 0.2 / 2)
		self.oy = props.oy or (546 / 2)
		self.r = props.r or 0
		self.scaleX = props.scaleX or 0.2
		self.scaleY = props.scaleY or 0.2
		self.images = props.images
			or {
				idle = love.graphics.newImage("assets/idle.png"),
				walk = love.graphics.newImage("assets/walk.png"),
				dead = love.graphics.newImage("assets/dead.png"),
				jump = love.graphics.newImage("assets/jump.png"),
				run = love.graphics.newImage("assets/run.png"),
			}

		self.resetToIdle = props.resetToIdle
			or function(anim, loops)
				if loops >= 1 then
					anim:gotoFrame(1)
					anim:pause()
					self.state = "idle"
				end
			end

		self.grid = props.grid or anim8.newGrid(614, 546, 614 * 15, 546)
		self.animations = props.animations
			or {
				idle = anim8.newAnimation(self.grid("1-15", 1), 0.075),
				walk = anim8.newAnimation(self.grid("1-15", 1), 0.055, self.resetToIdle),
				run = anim8.newAnimation(self.grid("1-15", 1), 0.045, self.resetToIdle),
				jump = anim8.newAnimation(self.grid("1-15", 1), 0.045, self.resetToIdle),
				dead = anim8.newAnimation(self.grid("1-15", 1), 0.045, function(anim, loops)
					if loops >= 1 then
						anim:pauseAtEnd()
					end
				end),
			}

		self.state = props.state or "idle"
		self.health = props.health or 100
		self.lockstate = props.lockstate or false
		self.world = props.world or nil

		-- prev 40x80
		self.bw = props.bw or 40
		self.bh = props.bh or 80
		self.body = self.world:newRectangleCollider(self.x, self.y, self.bw, self.bh)
		self.body:setFixedRotation(true)
		self.body:setCollisionClass("Player")
		self.body:setObject(self)

		self.feet = self.world:queryRectangleArea(self.x, self.y + self.bh, self.bw, 5)

		self.direction = props.direction or 1
		self.onGround = props.onGround or false
		-- self.debug = _G.debug.debug
		self.debug = false

		self.qx = 0
		self.qy = 0

		self.qh = 8
		self.qw = self.bw

		-- ####################
		-- Particles
		-- ####################
		local tex = makeDustTexture()
		self.moveDir = self.direction
		self.dustTimer = 0
		self.dustRate = 0
		self.airTime = 0

		-- continuous trail while running/walking
		self.dust = love.graphics.newParticleSystem(tex, 100)
		self.dust:setParticleLifetime(0.25, 0.55)
		self.dust:setEmissionRate(0)
		self.dust:setEmissionArea("uniform", 6, 2)
		self.dust:setSizes(0.6, 1.0, 0.2)
		self.dust:setSizeVariation(0.5)
		self.dust:setSpeed(15, 45)
		self.dust:setSpread(math.pi / 4)
		self.dust:setLinearAcceleration(0, -25, 0, -5)
		self.dust:setColors(0.85, 0.8, 0.7, 0.7, 0.85, 0.8, 0.7, 0)

		-- one-shot burst for jump / landing
		self.puff = love.graphics.newParticleSystem(tex, 100)
		self.puff:setParticleLifetime(0.3, 0.6)
		self.puff:setEmissionRate(0)
		self.puff:setEmissionArea("uniform", 14, 2)
		self.puff:setSizes(0.8, 1.4, 0.3)
		self.puff:setSizeVariation(0.5)
		self.puff:setSpeed(30, 90)
		self.puff:setDirection(-math.pi / 2)
		self.puff:setSpread(math.pi)
		self.puff:setLinearAcceleration(0, 0, 0, 40)
		self.puff:setColors(0.9, 0.85, 0.75, 0.8, 0.9, 0.85, 0.75, 0)

		-- ####################
		-- Signals for Player
		--#####################
		self:signals()
	end,

	signals = function(self)
		Signal.register("Ball Collision", function()
			self.health = 0

			self:dead()
			-- Gamestate.switch(Menu)
		end)
		Signal.register("Coin Collision", function()
			Signal.emit("Coin")
		end)
		Signal.register("Palindrome Collision", function()
			self.health = 0
			self:dead()
			-- self:dead()
		end)
	end,

	updateParticles = function(self, dt)
		self.dustTimer = math.max(0, self.dustTimer - dt)
		local emitting = self.dustTimer > 0 and self.onGround and self.health > 0

		local fx, fy = self.x, self.y + self.bh / 2 -- feet position
		self.dust:setEmissionRate(emitting and self.dustRate or 0)
		self.dust:setDirection(self.moveDir == 1 and math.pi or 0) -- blow backwards
		self.dust:setPosition(fx, fy)
		self.puff:setPosition(fx, fy)

		self.dust:update(dt)
		self.puff:update(dt)
	end,

	draw = function(self)
		love.graphics.setColor(1, 1, 1, 1)

		-- particles first so they sit behind the player
		love.graphics.draw(self.dust)
		love.graphics.draw(self.puff)

		if self.debug then
			Font.printf("Feet Collision" .. #self.feet, 0, 20, gw, "center", 12)
			love.graphics.setColor(color.red)
			love.graphics.rectangle("fill", self.qx, self.qy, self.bw, self.qh)
			love.graphics.setColor(1, 1, 1, 1)
		end

		if self.animations[self.state] and self.images[self.state] then
			self.animations[self.state]:draw(
				self.images[self.state],
				self.x,
				self.y,
				self.r,
				self.scaleX * self.direction,
				self.scaleY,
				self.ox + 55,
				self.oy + 10
			)
		else
			print("Player Resources not found!")
		end
	end,

	update = function(self, dt)
		if self.body ~= nil and self.world ~= nil then
			self.x = self.body:getX()
			self.y = self.body:getY()
			local queryX = self.x - (self.bw / 2)
			local queryY = self.y + (self.bh / 2)
			self.qx, self.qy = queryX, queryY
			self.feet = self.world:queryRectangleArea(queryX, queryY, self.qw, self.qh, { "Ground", "Fall" })
			if #self.feet >= 1 then
				-- !NOTE: One Player and One Ground Object
				self.onGround = true
			else
				self.onGround = false
			end

			-- landing puff
			if not self.onGround then
				self.airTime = self.airTime + dt
			else
				if self.airTime > 0.15 and self.health > 0 then
					self.puff:emit(10)
				end
				self.airTime = 0
			end

			if self.onGround and self.state == "dead" then
				self.world = nil
				self.body:destroy()
				self.body = nil
			end
		end
		if self.animations[self.state] then
			self.animations[self.state]:update(dt)
			if self.y > 400 then
				self.health = 0
				self:dead()
			end
		end

		-- runs even after the body is destroyed so leftover particles fade out
		self:updateParticles(dt)
	end,

	walk = function(self, velocity, direction)
		if self.health > 0 and self.state ~= "dead" and self.state ~= "jump" and self.onGround then
			self.direction = direction
			self.moveDir = direction
			self.dustTimer = 0.1
			self.dustRate = 12
			self.body:setLinearVelocity(velocity * direction, 0)
			if self.state ~= "walk" then
				self.animations["walk"]:resume()
				self.animations["walk"]:gotoFrame(1)
			end
			self.state = "walk"
		end
	end,

	jump = function(self, force)
		if self.health > 0 and self.onGround then
			if self.state ~= "jump" then
				Signal.emit("Jump")
				local playsLeft = 1
				Timer.every(0.95, function()
					Signal.emit("Jump")
					playsLeft = playsLeft - 1
					if playsLeft <= 0 then
						return false -- Stops the timer loop after 2 total plays
					end
				end)
			end
			self.puff:emit(14)
			self.state = "jump"
			self.animations[self.state]:resume()
			self.animations[self.state]:gotoFrame(1)
			self.body:applyLinearImpulse(0, force)
		end
	end,

	run = function(self, velocity, direction)
		if self.health > 0 and self.state ~= "dead" and self.state ~= "jump" and self.onGround then
			--self.direction = direction
			self.moveDir = direction
			self.dustTimer = 0.1
			self.dustRate = 35

			-- 2. Only reset animation on state transition
			if self.state ~= "run" then
				self.state = "run"
				self.animations[self.state]:gotoFrame(1)
				self.animations[self.state]:resume()
				Signal.emit("Running")
			end

			-- 3. Update horizontal velocity while preserving gravity/vertical movement
			local vx, vy = self.body:getLinearVelocity()
			self.body:setLinearVelocity(direction * velocity, vy)
		end
	end,

	dead = function(self)
		if self.health <= 0 then
			self.state = "dead"
			if self.state == "dead" then
				self.animations[self.state]:gotoFrame(1)
				self.animations[self.state]:resume()
			end
		end
	end,

	reset = function(self, x, y, health, world)
		if self.health <= 0 and self.state == "dead" and self.world == nil and self.body == nil then
			self.health = 100
			if world then
				self.world = world
				self.body = self.world:newRectangleCollider(x, y, self.bw, self.bh)
				self.body:setFixedRotation(true)
				self.body:setCollisionClass("Player")
				self.body:setObject(self)
				self.state = "idle"
				self.health = health
			end
		end
	end,
})

return Player
