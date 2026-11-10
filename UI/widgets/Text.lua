local Class = require(UI_PATH .. ".libs.class")
local Base = require(UI_PATH .. ".widgets.base")
local Font = require(UI_PATH .. ".libs.fontmetrics")
local getWidth = require("push").getWidth
local getHeight = require("push").getHeight
local getLines = require("UI.libs.fontmetrics").getLines

local Text = Class({
	__includes = Base,
	init = function(self, props)
		Base.init(self, props)
		props = props or {}
		self.text = props.text
		self.lineHeight = props.lh or props.lineHeight or 20
		self.border = props.border ~= false
		self.font = props.font or love.graphics.getFont()
		self.align = props.align or "left"
		self.border = props.border or false
		self.borderColor = props.borderColor or self.theme.blue
		self.opacity = props.opacity or 1
		self.name = "text"

		if self.debug then
			print("Text added." .. "ID :" .. self.id)
		end
	end,
	draw = function(self)
		if not self.enabled then
			return
		end
		if self.debug then
			-- print("Text is drawing. POS" .. self.x .. "X" .. self.y)
		end

		if self.text then
			local color = self.color
			local default = love.graphics.getFont()
			love.graphics.setFont(self.font)
			love.graphics.setColor(color[1], color[2], color[3], self.alpha)
			Font.print({
				x = self.x,
				y = self.y,
				w = self.w,
				h = self.h,
				text = self.text,
				lineHeight = self.lineHeight,
				font = self.font,
				align = self.align,
			})
			love.graphics.setFont(default)
		end
		if self.border then
			local bc = self.borderColor
			love.graphics.setColor(bc[1], bc[2], bc[3], bc[4], self.alpha)
			self.h = Font.getLines(self.w, self.text, self.font) * self.lineHeight
			love.graphics.rectangle("line", self.x, self.y, self.w, self.h)
			love.graphics.setLineWidth(1)
			love.graphics.setColor(1, 1, 1)
		end
	end,

	-- update = function(self, dt)
	-- 	if not self.enabled then
	-- 		return
	-- 	end
	-- end,
	getWidth = function(self)
		Font.getWidth(self.text, self.font)
	end,

	getHeight = function(self)
		return Font.getHeight(self.font)
	end,
})

return Text
