local push = {
	defaults = {
		fullscreen = false,
		resizable = false,
		pixelperfect = true,
		highdpi = true,
		canvas = true,
		stencil = true,
	},
	_canvases = {},
}

function push:setupScreen(W, H, w, h, options)
	options = options or {}
	for k, v in pairs(self.defaults) do
		if options[k] == nil then
			options[k] = v
		end
	end

	self._RWIDTH = W
	self._RHEIGHT = H
	self._SWIDTH = w
	self._SHEIGHT = h
	self._options = options

	love.graphics.setDefaultFilter("nearest", "nearest")

	if options.canvas then
		self:initCanvas()
	end

	self:calculateScale()
	love.window.setMode(self._SWIDTH, self._SHEIGHT, {
		fullscreen = options.fullscreen,
		resizable = options.resizable,
		highdpi = options.highdpi,
	})

	return self
end

function push:initCanvas()
	self._canvases = {}
	local canvas = love.graphics.newCanvas(self._RWIDTH, self._RHEIGHT)
	canvas:setFilter("nearest", "nearest")
	table.insert(self._canvases, { canvas = canvas })
end

function push:calculateScale()
	local szW, szH = love.graphics.getDimensions()
	self._SWIDTH = szW
	self._SHEIGHT = szH

	local scaleX = self._SWIDTH / self._RWIDTH
	local scaleY = self._SHEIGHT / self._RHEIGHT

	if self._options.pixelperfect then
		local scale = math.max(1, math.floor(math.min(scaleX, scaleY)))
		self._scale = { x = scale, y = scale }
	else
		local scale = math.min(scaleX, scaleY)
		self._scale = { x = scale, y = scale }
	end

	-- Integer offsets to eliminate fractional pixel blur
	self._offset = {
		x = math.floor((self._SWIDTH - (self._RWIDTH * self._scale.x)) / 2),
		y = math.floor((self._SHEIGHT - (self._RHEIGHT * self._scale.y)) / 2),
	}
end

function push:start()
	if self._options.canvas and #self._canvases > 0 then
		love.graphics.setCanvas(self._canvases[1].canvas)
		love.graphics.clear()
	else
		love.graphics.push()
		love.graphics.translate(self._offset.x, self._offset.y)
		love.graphics.scale(self._scale.x, self._scale.y)
	end
end

function push:finish()
	if self._options.canvas and #self._canvases > 0 then
		love.graphics.setCanvas()

		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.setDefaultFilter("nearest", "nearest")

		-- Render scaled canvas at integer-floored position
		love.graphics.draw(self._canvases[1].canvas, self._offset.x, self._offset.y, 0, self._scale.x, self._scale.y)
	else
		love.graphics.pop()
	end
end

function push:resize(w, h)
	self._SWIDTH = w
	self._SHEIGHT = h
	self:calculateScale()
end

function push:toGame(x, y)
	if not x or not y then
		return nil, nil
	end
	local gx = (x - self._offset.x) / self._scale.x
	local gy = (y - self._offset.y) / self._scale.y

	if gx < 0 or gx > self._RWIDTH or gy < 0 or gy > self._RHEIGHT then
		return nil, nil
	end

	return math.floor(gx), math.floor(gy)
end

function push:getWidth()
	return self._RWIDTH
end
function push:getHeight()
	return self._RHEIGHT
end

return push
