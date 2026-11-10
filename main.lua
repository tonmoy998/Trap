_G.love = require("love")
_G.UI = require("UI")
_G.debug = require("src.globals.settings")
require("lib.TESound.tesound")
sounds = require("src.sounds")

-- Libraries
Gamestate = require("lib.hump.gamestate")
Menu = require("src.states.Menu")
Level1 = require("src.states.Level1")
Timer = require("lib.hump.timer")
Font = require("lib.Font")
Signal = require("lib.hump.signal")

-- physics
wf = require("lib.windfield.windfield")
camera = require("lib.hump.camera")
anim8 = require("lib.anim8.anim8")

-- Game Libraries
FPS = require("src.globals.FPS")

sw, sh = love.graphics.getDimensions()
gw, gh = 640, 360
TITLE_SM = love.graphics.newFont("assets/text.ttf", 10)
TITLE_MD = love.graphics.newFont("assets/title.ttf", 15)
TITLE_BG = love.graphics.newFont("assets/title.ttf", 18)
TITLE_LG = love.graphics.newFont("assets/title.ttf", 28)

function love.load()
	sounds.load()
	love.graphics.setDefaultFilter("nearest", "nearest")
	Gamestate.registerEvents()
	Gamestate.switch(Menu)
end

function love.draw() end

function love.update(dt)
	Timer.update(dt)
end

function love.mousepressed(x, y, button) end

function love.mousereleased(x, y, button) end

function love.resize(w, h) end
function love.keypressed(key)
	if key == "m" then
		Gamestate.switch(Menu)
	elseif key == "l" then
		Gamestate.switch(Level1)
	elseif key == "c" then
		-- Signal.emit("Completed")
		Signal.emit("Jump")
	end
end
