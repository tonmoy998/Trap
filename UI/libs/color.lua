function rgba(r, g, b, a)
	r = r or 255
	g = g or 255
	b = b or 255
	a = a or 1
	return { r / 255, g / 255, b / 255, a }
end

function vec4(r, g, b, a)
	return { r or 1, g or 1, b or 1, a or 1 }
end

function hex(value, a)
	local hexVal = string.sub(value, 2)
	hexVal = string.upper(hexVal)
	if #hexVal == 3 then
		local f = hexVal:sub(1, 1)
		local s = hexVal:sub(2, 2)
		local t = hexVal:sub(3, 3)
		hexVal = f .. f .. s .. s .. t .. t
	end

	local val = {}
	local hexDigits = "0123456789ABCDEF"
	for i = 1, #hexVal do
		local char = hexVal:sub(i, i)
		val[i] = hexDigits:find(char) - 1
	end

	local r = val[1] * 16 + val[2]
	local g = val[3] * 16 + val[4]
	local b = val[5] * 16 + val[6]
	a = a or 1

	return { r / 255, g / 255, b / 255, a }
end

-- NEW: Parse rgba string to table
function parseRGBA(rgbaString)
	-- Match "rgba(r, g, b, a)" pattern
	local r, g, b, a = rgbaString:match("rgba%((%d+),%s*(%d+),%s*(%d+),%s*([%d%.]+)%)")

	if r and g and b and a then
		return {
			tonumber(r) / 255,
			tonumber(g) / 255,
			tonumber(b) / 255,
			tonumber(a),
		}
	end

	-- Fallback to white if parsing fails
	print("Warning: Failed to parse color string: " .. rgbaString)
	return { 1, 1, 1, 1 }
end

-- Basic colors
color = {
	white = rgba(255, 255, 255),
	black = rgba(0, 0, 0),
	red = rgba(255, 0, 0),
	green = rgba(0, 255, 0),
	blue = rgba(0, 0, 255),
	cyan = rgba(0, 255, 255),
	magenta = rgba(255, 0, 255),
	yellow = rgba(230, 230, 0),
	orange = rgba(255, 165, 0),
	pink = rgba(255, 192, 203),
	purple = rgba(128, 0, 128),
	brown = rgba(139, 69, 19),
	gray = rgba(128, 128, 128),
	lightgray = rgba(211, 211, 211),
	darkgray = rgba(64, 64, 64),
}
