-- UI/lib/fontmetrics.lua
local FontMetrics = {}

-- fallback to current font
local function getFont(font)
	return font or love.graphics.getFont()
end

-- =========================
-- Width of text
-- =========================
function FontMetrics.getWidth(text, font)
	font = getFont(font)
	return font:getWidth(tostring(text or ""))
end

-- =========================
-- Height of text (single line)
-- =========================
function FontMetrics.getHeight(font)
	font = getFont(font)
	return font:getHeight()
end

-- =========================
-- Width + Height
-- =========================
function FontMetrics.getSize(text, font)
	font = getFont(font)
	return font:getWidth(tostring(text or "")), font:getHeight()
end

-- =========================
-- Multiline height
-- =========================
function FontMetrics.getMultilineHeight(text, font)
	font = getFont(font)
	text = tostring(text or "")

	local lines = 1
	for _ in text:gmatch("\n") do
		lines = lines + 1
	end

	return lines * font:getHeight()
end

function FontMetrics.print(props)
	local x = props.x or 100
	local y = props.y or 100
	local width = props.w or 400
	local height = props.h or 200
	local text = props.text or ""
	local font = props.font or love.graphics.getFont()
	local align = props.align or "left"
	local lineHeight = props.lineHeight or font:getHeight()

	love.graphics.setFont(font)

	local _, lines = font:getWrap(text, width)
	local numLines = #lines

	-- total height of the whole text block
	local blockHeight = numLines * lineHeight

	-- starting y so the whole block is vertically centered in the box
	local startY = y + (height - blockHeight) / 2

	for i, line in ipairs(lines) do
		local lw = font:getWidth(line)
		local lh = font:getHeight()
		local py = startY + (i - 1) * lineHeight
		local px = x

		if align == "center" then
			px = x + (width - lw) / 2
		elseif align == "right" then
			px = x + (width - lw)
		end

		love.graphics.print(line, px, py)
	end

	love.graphics.setFont(love.graphics.getFont())
end
function FontMetrics.getLines(width, text, font)
	text = text or ""
	font = font or love.graphics.getFont()
	local _, lines = font:getWrap(text, width)
	return #lines
end

return FontMetrics
