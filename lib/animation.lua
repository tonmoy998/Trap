-- anim.lua
local Anim = {}
Anim.__index = Anim

-- Create a new animation
-- @param images: table of image paths or Image objects
-- @param frameDuration: time per frame in seconds
-- @param loop: whether animation should loop (default true)
function Anim.new(images, frameDuration, loop)
	local self = setmetatable({}, Anim)

	self.frames = {}
	self.currentFrame = 1
	self.frameDuration = frameDuration or 0.1
	self.timer = 0
	self.loop = loop == nil and true or loop
	self.playing = true
	self.finished = false

	-- Load images if they're paths
	for i, img in ipairs(images) do
		if type(img) == "string" then
			self.frames[i] = love.graphics.newImage(img)
		else
			self.frames[i] = img
		end
	end

	return self
end

-- Create animation from numbered files (e.g., "image1.png" to "image10.png")
-- @param prefix: filename prefix (e.g., "image")
-- @param startNum: starting number (e.g., 1)
-- @param endNum: ending number (e.g., 10)
-- @param extension: file extension (default ".png")
-- @param frameDuration: time per frame in seconds
-- @param loop: whether animation should loop
function Anim.fromSequence(prefix, startNum, endNum, extension, frameDuration, loop)
	extension = extension or ".png"
	local images = {}

	for i = startNum, endNum do
		table.insert(images, prefix .. i .. extension)
	end

	return Anim.new(images, frameDuration, loop)
end

-- Update the animation
function Anim:update(dt)
	if not self.playing or self.finished then
		return
	end

	self.timer = self.timer + dt

	if self.timer >= self.frameDuration then
		self.timer = self.timer - self.frameDuration
		self.currentFrame = self.currentFrame + 1

		if self.currentFrame > #self.frames then
			if self.loop then
				self.currentFrame = 1
			else
				self.currentFrame = #self.frames
				self.finished = true
				self.playing = false
			end
		end
	end
end

-- Draw the current frame
function Anim:draw(x, y, rotation, scaleX, scaleY, offsetX, offsetY)
	local frame = self.frames[self.currentFrame]
	love.graphics.draw(frame, x, y, rotation or 0, scaleX or 1, scaleY or 1, offsetX or 0, offsetY or 0)
end

-- Control functions
function Anim:play()
	self.playing = true
end

function Anim:pause()
	self.playing = false
end

function Anim:stop()
	self.playing = false
	self.currentFrame = 1
	self.timer = 0
	self.finished = false
end

function Anim:reset()
	self.currentFrame = 1
	self.timer = 0
	self.finished = false
end

function Anim:setFrame(frame)
	if frame >= 1 and frame <= #self.frames then
		self.currentFrame = frame
		self.timer = 0
	end
end

function Anim:setSpeed(frameDuration)
	self.frameDuration = frameDuration
end

function Anim:isFinished()
	return self.finished
end

function Anim:getCurrentFrame()
	return self.currentFrame
end

function Anim:getFrameCount()
	return #self.frames
end

return Anim
