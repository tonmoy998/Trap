local love = require("love")

local Class = require(UI_PATH .. ".libs.class")
local Base = require(UI_PATH .. ".widgets.base")
local Theme = require(UI_PATH .. ".themes.Themes")
local Options = require(UI_PATH .. ".options")

local Button = Class({
	__includes = Base,

	init = function(self, props)
		props = props or {}

		if Base.init then
			Base.init(self, props)
		end

		self.name = "Button"
		self.theme = Theme[Options.theme]

		self.bg = props.bg or self.theme.blue
		self.hoverColor = props.hoverColor or self.bg
		self.clickedColor = props.clickedColor or self.bg

		self.onRelease = props.onRelease or function() end
		self.text = props.text or ""
		self.clicked = false
		self.hovered = false
		self.r = props.r or 0
		self.ox = props.ox or 0
		self.oy = props.oy or 0

		self.img = props.img or nil

		if self.debug then
			print("Button Added. ID :" .. tostring(self.id))
		end
	end,

	updateLayout = function(self)
		for _, c in ipairs(self.children) do
			c.x = self.cx + c.lx + c.ox
			c.y = self.cy + c.ly + c.oy
		end
	end,

	update = function(self, dt)
		if not self.enabled then
			return
		end

		for _, child in ipairs(self.children) do
			if child then
				child.x = self.x + child.lx
				child.y = self.y + child.ly
				if child.update then
					child:update(dt)
				end
			end
		end
	end,

	isHovered = function(self, mx, my)
		if not mx or not my then
			self.hovered = false
			return false
		end
		self.hovered = self:isMouseOver(mx, my)
		return self.hovered
	end,

	add = function(self, child)
		table.insert(self.children, child)
		child.x = self.x + child.lx
		child.y = self.y + child.ly

		if self.debug then
			print("child added :" .. child.name)
		end
	end,

	getCurrentColor = function(self)
		if self.clicked then
			return self.clickedColor
		elseif self.hovered then
			return self.hoverColor
		end
		return self.bg
	end,

	draw = function(self)
		if not self.enabled then
			return
		end

		love.graphics.setColor(self:getCurrentColor())
		love.graphics.rectangle(self.type or "fill", self.x + self.ox, self.y + self.oy, self.w, self.h)
		love.graphics.setColor(1, 1, 1, 1)

		if self.debug then
			love.graphics.print(self.text, self.x + (self.w / 2) + self.ox, self.y + self.oy + (self.h / 2))
		end

		if self.img then
			local iw, ih = self.img:getDimensions()
			love.graphics.setColor(1, 1, 1)
			love.graphics.draw(self.img, self.x + self.ox, self.y + self.oy, self.r, self.w / iw, self.h / ih)
		end

		for _, c in ipairs(self.children) do
			if c.draw and c.enabled then
				c:draw()
			end
		end
	end,

	isMouseOver = function(self, mx, my)
		if not mx or not my then
			return false
		end
		return mx >= self.x + self.ox
			and mx <= self.x + self.ox + self.w
			and my >= self.y + self.oy
			and my <= self.y + self.h + self.oy
	end,

	mousepressed = function(self, mx, my, mbutton)
		if not self.enabled then
			return
		end

		if mbutton == 1 and self.hovered then
			self.clicked = true
			if self.onClick then
				self:onClick()
			end
		end
	end,

	mousereleased = function(self, mx, my, mbutton)
		if not self.enabled then
			return
		end

		if mbutton == 1 then
			if self.clicked then
				self.clicked = false
				if self.hovered then
					self:onRelease()
				end
			end
		end
	end,
})

return Button
