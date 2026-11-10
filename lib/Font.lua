-- fonts.lua
local Fonts = { cache = {} }

-- Assuming 'gw' (game width), 'gh' (game height), 'sw' (screen width) are globally accessible,
-- or you can pass/calculate your scale factor based on your push setup.
local function getScale()
	-- If using push, choose either width or height scale depending on how it handles scaling
	return sw / gw -- or hook into your push scale variables directly
end

function Fonts.get(size)
	local s = getScale()
	local finalSize = math.max(1, math.floor(size * s + 0.5))
	local key = size .. "@" .. finalSize

	if not Fonts.cache[key] then
		Fonts.cache[key] = love.graphics.newFont(finalSize)
	end
	return Fonts.cache[key]
end

function Fonts.printf(text, x, y, limit, align, size)
	love.graphics.setFont(Fonts.get(size or 12))

	-- If push/love.graphics.scale is already active,
	-- pass coordinates and limits natively in virtual resolution units.
	love.graphics.printf(text, x, y, limit, align)
end

return Fonts
