local Class = require(UI_PATH .. ".libs.class")
local Base = require(UI_PATH .. ".widgets.base")
local Button = require(UI_PATH .. ".widgets.Button")
local Text = require(UI_PATH .. ".widgets.Text")

-- Component Button
local CButton = Class({
	__includes = Base,
	init = function(self, props)
		Base.init(self, props)
		props = props or {}
		self.text = props.text or nil
		self.img = props.img or nil
		self.align = props.align or "center"
		self.onClick = props.onClick or function()
			print("Component Button")
		end
		self.onRelease = props.onRelease or function() end
		self.button = Button({
			x = self.x,
			y = self.y,
			w = self.w,
			h = self.h,
			bg = self.bg,
			onClick = self.onClick,
			onRelease = self.onRelease,
		})
		self.t = Text({
			x = self.x,
			y = self.y,
			w = self.w,
			h = self.h,
			lineHeight = self.lineHeight,
			font = self.font,
			align = self.align,
			color = self.color,
			text = self.text,
			border = self.border,
		})
		self.img = props.img or nil
		self.r = props.r or 0
		if self.img then
			self.scaleX = self.w / self.img:getWidth() or 1
			self.scaleY = self.h / self.img:getHeight() or 1
		end
	end,
	draw = function(self)
		if not self.img then
			self.button:draw()
		end
		if self.img then
			love.graphics.draw(self.img, self.x, self.y, self.r, self.scaleX, self.scaleY)
			-- love.graphics.draw(self.img, self.x, self.y, self.r, 1, 1)
		end
		if self.text then
			self.t:draw()
		end
	end,
	update = function(self, dt)
		self.button:update(dt)
	end,
	isHovered = function(self, mx, my)
		if self.button.isHovered then
			self.button:isHovered(mx, my)
		end
	end,
	mousepressed = function(self, mx, my, button)
		self.button:mousepressed(mx, my, button)
	end,
	mousereleased = function(self, mx, my, button)
		self.button:mousereleased(mx, my, button)
	end,
})

return CButton
