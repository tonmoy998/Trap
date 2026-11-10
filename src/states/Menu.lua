local Menu = {}
local Camera = require("lib.hump.camera")

function Menu:init()
	self.font = love.graphics.newFont("assets/text.ttf", 20)
	self.playbtn = UI.Button({
		x = 496,
		y = 290,
		w = 127,
		h = 42,
		img = love.graphics.newImage("assets/img/play.png"),
		onClick = function()
			Gamestate.switch(Level1)
		end,
	})

	self.arrowdown =
		UI.Img({ x = 105 + 10, y = 70, w = 25, h = 25, img = love.graphics.newImage("assets/img/arrowdown.png") })

	self.level1 = UI.Button({
		x = 105,
		bg = rgba(1, 1, 1, 0),
		y = 105,
		w = 48,
		h = 48,
		img = love.graphics.newImage("assets/img/level1.png"),
		onClick = function()
			Signal.emit("Click")
			Signal.emit("Level1 Reset")
			Gamestate.switch(Level1)
		end,
	})
	local baseY = self.arrowdown.y

	Timer.script(function(wait)
		while true do
			Timer.tween(0.6, self.arrowdown, { y = baseY - 10 }, "in-out-sine")
			wait(0.6)
			Timer.tween(0.6, self.arrowdown, { y = baseY + 10 }, "in-out-sine")
			wait(0.6)
		end
	end)
	self.camera = Camera.new(0, 0)
	self.zoom = math.min(sw / gw, sh / gh)
	self.camera:zoomTo(self.zoom)
	self.camera:lookAt(gw / 2, gh / 2)
	self.text = "Load"
end

function Menu:enter(previous)
	-- Called every time you switch TO this state
end

function Menu:draw()
	self.camera:attach()
	love.graphics.rectangle("fill", 0, 0, gw, gh)
	-- Inside UI.Text or UI.Button draw method:
	love.graphics.setFont(self.font)
	-- Always round (math.floor) text draw coordinates!
	love.graphics.setColor(color.red)
	self.level1:draw()
	self.arrowdown:draw()
	self.camera:detach()
	FPS(TITLE_MD, TITLE_MD)
end

function Menu:keypressed(key) end

function Menu:update(dt)
	self.level1:update(dt)

	-- level1 lives in world space, so fix its hover state (update() used screen coords)
	local wx, wy = self.camera:mousePosition()
	self.level1.hovered = self.level1:isHovered(wx, wy)
end

function Menu:mousepressed(mx, my, button)
	local wx, wy = self.camera:worldCoords(mx, my)
	self.level1:mousepressed(wx, wy, button) -- world space (drawn inside camera)
end

function Menu:mousereleased(mx, my, button)
	local wx, wy = self.camera:worldCoords(mx, my)
	self.level1:mousereleased(wx, wy, button)
end
return Menu
