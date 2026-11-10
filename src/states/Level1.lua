local Level1 = {}
local love = require("love")
local Player = require("src.Player")
local Ball = require("src.objects.Ball")
local Flag = require("src.objects.Flag")
local Ground = require("src.objects.Ground")
local MapLoader = require("lib.Maploader")
local anim8 = require("lib.anim8.anim8")
local Coin = require("src.objects.Coin")
local Win = require("src.objects.Win")
local Palidrome = require("src.objects.Palindrome")
-- local gamera = require("lib.gamera.gamera")
local camera = require("lib.hump.camera")
local clamp = require("lib.lume").clamp
local flux = require("UI.libs.flux")

function Level1:init()
	Signal.register("Level1 Reset", function()
		Level1:reset()
	end)
	self.debug = debug.debug
	self.zoom = math.min(sw / gw, sh / gh)
	self.timer1 = Timer.new()
	self.title = "Level 1"
	self.prompt = "Press SPACE or ENTER to Start"

	self.world = wf.newWorld(0, 350, true)
	self.world:setQueryDebugDrawing(true)
	self.world:addCollisionClass("Ground")
	self.world:addCollisionClass("Player")
	self.world:addCollisionClass("Palindrome")
	-- self.world:addCollisionClass("Ball")
	self.world:addCollisionClass("Fall")
	self.world:addCollisionClass("Coin", { ignores = { "Player", "Palindrome" } })
	self.world:addCollisionClass("Ball", { ignores = { "Coin" } })

	-- Ground becomes static windfield colliders; Fall1/End come back as
	-- plain rects; Ball1..Ball4 come back as spawn points.
	self.map = MapLoader.load("maps/level1.json", self.world)
	self.coinObjects = MapLoader.getObjects("Coins")
	self.ballObjects = MapLoader.getObjects("Balls")
	self.fallObjects = MapLoader.getObjects("Falls")
	self.endPoints = MapLoader.getObjects("End")
	self.groundObjects = MapLoader.getObjects("Ground")

	self.flagPos = self.endPoints[1]
	-- print(#self.fallObjects)
	-- self.layers = MapLoader.getLayers()
	-- print(#self.layers)
	-- print(#self.coinObjects)
	-- self.layers = MapLoader.getLayers()
	-- local layerNames = {}
	-- for _, layer in ipairs(self.layers) do
	-- 	table.insert(layerNames, layer.name)
	-- end
	--
	-- self.objects = MapLoader.getObjects("Ground")
	-- for _, o in ipairs(self.objects) do
	-- end

	-- 1. Create the grid first so it can be safely referenced

	self.pstate = "idle"
	-- 2. Pass grid and animations safely into the Player constructor
	self.player = Player({
		-- x = 1220,
		x = 40,
		y = 100,
		w = 122,
		h = 109,
		state = "idle",
		world = self.world,
	})

	-- Spawn one Ball per Ball1..Ball4 object layer instead of hardcoding

	-- self.cam = gamera.new(0, 0, 640, 360)
	self.camera = camera.new(0, 0)
	self.camera:zoomTo(self.zoom)

	-- self.ball1 = Ball(self.world, 200, 20)
	-- self.ball2 = Ball(self.world, 370, 80)
	-- self.ball3 = Ball(self.world, 540, 120)

	-- self.camera:lookAt(0, 30)
	self.coins = {}
	for _, obj in ipairs(self.coinObjects) do
		local coin = Coin({ x = obj.x, y = obj.y + 15, radius = 10, world = self.world })
		table.insert(self.coins, coin)
	end

	self.balls = {}
	for _, obj in ipairs(self.ballObjects) do
		local ball = Ball({ x = obj.x, y = obj.y, radius = 30, world = self.world })
		table.insert(self.coins, ball)
	end

	self.falls = {}
	for _, obj in ipairs(self.fallObjects) do
		local fall = Ground({
			x = obj.x,
			y = obj.y,
			ox = -obj.width / 2,
			oy = -obj.height / 2,
			w = obj.width,
			h = obj.height,
			name = "Fall",
			world = self.world,
		})
		table.insert(self.falls, fall)
	end

	self.flag = Flag({ x = 1180, y = self.flagPos.y - 70, scaleX = 3, scaleY = 3 })
	self.win = Win({
		x = 640 + 25,
		y = 340 + 20,
		scale = 0.75,
		text = "Level Completed!!",
		textColor = { 1, 0.8, 0.1 }, -- Gold
		glowColor = { 0.9, 0.2, 0.1, 0.7 }, -- Reddish Orange Glow
	})
	-- self.win = Win({ x = 100, y = 0, scaleX = 1.4, scaleY = 1.4 })
	self.grounds = {}
	for _, g in ipairs(self.groundObjects) do
		local ground = Ground({ x = g.x, y = g.y, w = g.width, h = g.height, world = self.world, name = "Ground" })
		ground.body:setFriction(2.5)
		table.insert(self.grounds, ground)
	end

	self.palindrome = Palidrome({
		x = 350,
		y = -10,
		world = self.world,
		l = 245,
		force = 2300,
	})
	self.worldWidth = 1330
	Signal.emit("Level 1")
	self.completed = false
	self.playSound = true

	self.text = UI.Text({
		x = sw / 2,
		y = sh / 2,
		text = "Level 1",
		font = love.graphics.newFont("assets/title.ttf", 35 * self.zoom),
		w = 200 * self.zoom,
	})
	self.text.x = sw / 2 - (self.text.font:getWidth(self.text.text)) / 2
	self.text.y = sh / 2 - (self.text.font:getHeight()) / 2 - 50
	self:blinkText()
	Timer.after(4, function()
		self.text.text = ""
	end)
end

function Level1:blinkText()
	local duration = 1.5 -- Seconds for a single fade (in or out)

	local function fadeOut()
		flux.to(self.text, duration, { alpha = 0 }):ease("sinein"):oncomplete(fadeIn)
	end

	function fadeIn()
		flux.to(self.text, duration, { alpha = 1 }):ease("sineout"):oncomplete(fadeOut)
	end

	-- Start the loop
	fadeOut()
end

function Level1:enter(previous)
	-- Called every time you switch TO this state
end

-- Fall1/End aren't physics bodies, so they're checked with a plain AABB
-- overlap test against the player each frame.
local function overlaps(px, py, pw, ph, zone)
	return px < zone.x + zone.width and px + pw > zone.x and py < zone.y + zone.height and py + ph > zone.y
end

function Level1:update(dt)
	flux.update(dt)
	if self.completed and self.playSound then
		Signal.emit("Completed")
		self.playSound = false
	end
	if self.player.x >= self.flag.x then
		self.completed = true
	end
	self.world:update(dt)
	self.timer1:update(dt)
	self.win:update(dt)

	-- local cameraX = math.max(640 / 2, math.min(self.player.x, self.worldWidth - 640 / 2))
	local cameraX = clamp(self.player.x, gw / 2, self.worldWidth - gw / 2)

	self.camera:lookAt(cameraX, gh / 2)

	self.player:update(dt)
	if love.keyboard.isDown("space") then
		self.player:jump(-240)
	end
	if love.keyboard.isDown("d") then
		self.player:run(140, 1)
		self.player.direction = 1
	elseif love.keyboard.isDown("a") then
		self.player.direction = -1
		self.player:run(140, -1)
	elseif love.keyboard.isDown("lshift") then
		--self.player:run(140)
	end

	local px, py = self.player.x, self.player.y
	local pw, ph = self.player.w, self.player.h

	-- self.ball1:update(dt)
	-- self.ball2:update(dt)
	-- self.ball3:update(dt)
	--	self.coin:update(dt)
	for _, c in ipairs(self.coins) do
		c:update(dt)
	end

	for _, b in ipairs(self.balls) do
		b:update(dt)
	end

	for _, f in ipairs(self.falls) do
		if f.body:enter("Player") then
			f.fall = true
		end
		if f.fall then
			if f.y <= 550 then
				f.body:setPosition(f.x, f.y + (dt * 120))
			else
				f.fall = false
			end
		end
		f:update(dt)
		self.palindrome:update(dt)
	end

	if self.player.y >= 400 then
		self.player.health = 0
		Level1:reset()
	end
	if self.player.health <= 0 then
		Level1:reset()
	end
	if self.player.health <= 0 then
		self.player:reset(40, 10, 100, self.world)
	end

	self.flag:update(dt)
end

-- Player's bounding box entered a Fall1 gap. Wire up a respawn/death here.
function Level1:onFall() end

-- Player's bounding box reached the End zone. Wire up a level transition here.
function Level1:onLevelComplete() end

function Level1:draw()
	self.camera:attach()
	love.graphics.clear(0.1, 0.1, 0.15)

	-- self.camera:attach()
	-- push:start()
	if self.debug then
		self.world:draw()
		if self.player.onGround then
			Font.printf("On Ground", 0, 20, gw, "center", 24)
		else
			Font.printf("Not in Ground", 0, 20, gw, "center", 24)
		end
	end
	self.flag:draw()

	-- self.ball1:draw()
	-- self.ball2:draw()
	-- self.ball3:draw()
	-- self.coin:draw()
	love.graphics.setColor(1, 1, 1)

	-- push:finish()
	for _, c in ipairs(self.coins) do
		c:draw()
	end

	for _, b in ipairs(self.balls) do
		b:draw()
	end

	for _, f in ipairs(self.falls) do
		f:draw()
	end

	for _, g in ipairs(self.grounds) do
		g:draw()
	end

	self.player:draw()

	self.palindrome:draw()
	self.camera:detach()
	-- push:finish()
	--
	-- Font.printf(self.title, 10, 0, 500, "center", 24 * self.zoom)
	self.text:draw()
	FPS(TITLE_MD, TITLE_MD)
	Font.printf("X" .. math.floor(self.player.x), 50, 50, gw, "center", 24)
	-- Font.printf("Player X:" .. math.floor(self.player.x) .. "x Y:" .. math.floor(self.player.y), 0, 50, gw, "left", 24)

	-- love.graphics.print(self.player.state, 30, 30)
	-- love.graphics.print(self.player.health, 80, 70)

	if self.player.x >= self.flag.x then
		self.win:draw()
	end
end
--
-- function Level1:draw()
-- 	self.cam:draw(self.drawByCamera)
-- 	FPS(TITLE_MD, TITLE_MD)
-- end

function Level1:keypressed(key)
	if key == "r" then
		Level1:reset()
		self.player:reset(40, 0, 100, self.world)
	end
end

function Level1:reset()
	self.playSound = true
	self.completed = false
	self.palindrome:destroy()
	self.palindrome:reset()
	for _, c in ipairs(self.coins) do
		c:destroy()
	end
	for _, obj in ipairs(self.coinObjects) do
		local coin = Coin({ x = obj.x, y = obj.y + 15, radius = 10, world = self.world })
		table.insert(self.coins, coin)
	end

	for _, b in ipairs(self.balls) do
		b:destroy()
	end
	for _, obj in ipairs(self.ballObjects) do
		local ball = Ball({ x = obj.x, y = obj.y, radius = 30, world = self.world })
		table.insert(self.coins, ball)
	end

	for _, f in ipairs(self.falls) do
		f:destroy()
	end
	for _, obj in ipairs(self.fallObjects) do
		local fall = Ground({
			x = obj.x,
			y = obj.y,
			ox = -obj.width / 2,
			oy = -obj.height / 2,
			w = obj.width,
			h = obj.height,
			name = "Fall",
			world = self.world,
		})
		table.insert(self.falls, fall)
	end
	if self.player.body ~= nil then
		self.player.body:setPosition(10, 269)
	else
		self.player:reset(40, 10, 100, self.world)
	end
end

return Level1
