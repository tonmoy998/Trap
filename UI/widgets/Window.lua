local Class = require(UI_PATH .. ".libs.class")
local Options = require(UI_PATH .. ".options")
local Base = require(UI_PATH .. ".widgets.base")
local Themes = require(UI_PATH .. ".themes.Themes")
local clamp = require(UI_PATH .. ".libs.clamp")
local Flex = require(UI_PATH .. ".layouts.Flex")

local Window = Class({
	__includes = Base,

	init = function(self, props)
		props = props or {}

		-- ========================================
		-- Initialize Base
		-- ========================================

		if Base.init then
			Base.init(self, props)
		end

		-- ========================================
		-- Content Dimensions
		-- ========================================

		self.bg = props.bg or color.black
		self.hoverColor = props.hoverColor or nil
		self.cw = props.cw or 100
		self.ch = props.ch or 100

		-- Content position
		self.cx = self.x
		self.cy = self.y
		self.updateWindow = props.updateWindow or true

		-- ========================================
		-- Theme
		-- ========================================

		self.theme = Themes[Options.theme]

		-- ========================================
		-- Horizontal Scrollbar
		-- ========================================

		self.hsb = false

		-- Scrollbar handle width
		self.hsbw = props.hsbw or 100
		self.hsbx = self.x

		-- Scrollbar height
		self.hsbh = props.hsbh or 20

		-- ========================================
		-- Vertical Scrollbar
		-- ========================================

		self.vsb = false

		-- Scrollbar handle width
		self.vsbw = props.vsbw or 20

		-- Scrollbar handle height
		self.vsbh = props.vsbh or 100

		-- Scrollbar position
		self.vsbx = self.x + self.w - self.vsbw
		self.vsby = self.y

		-- Scrollbar limits
		self.vsbMinY = self.y
		self.vsbMaxY = self.y + self.h - self.vsbh

		-- ========================================
		-- Scroll Events
		-- ========================================

		self.isVSBDragging = false
		self.isVSBOver = false

		self.isHSBDragging = false
		self.isHSBOver = false

		-- ========================================
		-- Viewport
		-- ========================================

		self.vx = self.x
		self.vy = self.y

		self.vw = self.w - self.vsbw
		self.vh = self.h - self.hsbh

		-- ========================================
		-- Scroll Calculations
		-- ========================================

		self.vsbprogress = 0

		-- Maximum amount content can scroll
		self.cyrange = math.max(0, self.ch - self.vh)

		-- Horizontal scrollbar
		self.hsby = self.vy + self.vh
		self.hsbMaxX = self.vx + self.w - self.hsbw
		self.cxrange = math.max(self.x, self.cw - self.vw)
		self.hsbMinX = self.x

		-- Layout
		self.layout = props.layout or "flex"
		self.gap = props.gap or 0
		self.direction = props.direction or "row"
		if self.layout == "flex" then
			self.flex = Flex({ x = self.x, y = self.y, w = self.w, h = self.h, direction = "row", gap = self.gap })
		else
			self.flex = nil
		end

		if self.debug then
			print("Window Added. ID: " .. self.id)
		end
	end,

	add = function(self, child)
		if self.debug then
			print(child.name .. " Added")
		end
		table.insert(self.children, child)

		-- Calculate the rightmost and bottommost edge required by the child
		local requiredContentWidth = child.lx + child.w
		local requiredContentHeight = child.ly + child.h

		-- Expand content dimensions independently using math.max
		self.cw = math.max(self.cw, requiredContentWidth)
		self.ch = math.max(self.ch, requiredContentHeight)

		if self.layout == "flex" then
			self.flex:add(child)
			print("child Added to Flex Layout")
		end
	end,
	isHovered = function(self, mx, my)
		return self:isMouseOver(mx, my, self.w, self.h)
	end,
	updateLayout = function(self)
		for _, c in ipairs(self.children) do
			c.x = self.cx + c.lx
			c.y = self.cy + c.ly
		end
	end,

	update = function(self, dt)
		if not self.enabled then
			return
		end

		if self.updateWindow then
			self:updateLayout()
		end

		-- Fix Children events for scrolling
		for _, c in ipairs(self.children) do
			if (c.x + c.w) < self.vx then
				c.enabled = false
			elseif (c.y + c.h) < self.vy then
				c.enabled = false
			else
				c.enabled = true
			end
		end

		local mx, my = love.mouse.getPosition()
		-- ========================================
		-- Update Scrollbar Requirements
		-- ========================================

		self.hsb = self.w < self.cw
		self.vsb = self.h < self.ch

		-- ========================================
		-- Update Viewport
		-- ========================================

		self.vx = self.x
		self.vy = self.y

		self.vw = self.w

		if self.vsb then
			self.vw = self.vw - self.vsbw
		end

		self.vh = self.h

		if self.hsb then
			self.vh = self.vh - self.hsbh
		end

		-- ========================================
		-- Update Vertical Scrollbar Position
		-- ========================================

		self.vsbx = self.x + self.w - self.vsbw

		self.vsbMinY = self.y

		self.vsbMaxY = self.y + self.h - self.vsbh

		-- ========================================
		-- Drag Vertical Scrollbar
		-- ========================================

		if self.isVSBDragging then
			-- Center scrollbar handle on mouse
			self.vsby = my - self.vsbh / 2
			-- Prevent scrollbar from leaving track
			self.vsby = clamp(self.vsby, self.vsbMinY, self.vsbMaxY)
		end

		if self.isHSBDragging then
			self.hsbx = mx - (self.hsbw / 2)
			self.hsbx = clamp(self.hsbx, self.hsbMinX, self.hsbMaxX)
		end
		-- ========================================
		-- Calculate Content Position From Scrollbar
		-- ========================================

		if self.vsb then
			-- Total scrollbar movement range
			local scrollRange = self.vsbMaxY - self.vsbMinY

			-- Total content movement range
			self.cyrange = math.max(0, self.ch - self.vh)

			if scrollRange > 0 then
				-- 0 = scrollbar at top
				-- 1 = scrollbar at bottom
				self.vsbprogress = (self.vsby - self.vsbMinY) / scrollRange
			else
				self.vsbprogress = 0
			end

			-- Move content upward as scrollbar moves downward
			self.cy = self.y - (self.cyrange * self.vsbprogress)
		else
			-- Reset content position when scrolling isn't needed
			self.vsbprogress = 0
			self.cy = self.y
			self.vsby = self.vsbMinY
		end

		if self.hsb then
			local scrollRange = self.hsbMaxX - self.hsbMinX
			local contentRange = self.cw - self.vw

			self.hsbprogress = (self.hsbx - self.hsbMinX) / scrollRange
			self.cx = self.x - (contentRange * self.hsbprogress)
		end

		-- ========================================
		-- Check Mouse Over Vertical Scrollbar
		-- ========================================

		self.isVSBOver = self:isMouseOver(self.vsbx, self.vsby, self.vsbw, self.vsbh)
		self.isHSBOver = self:isMouseOver(self.hsbx, self.hsby, self.hsbw, self.hsbh)
		-- self.isHovered = self:isMouseOver(self.x, self.y, self.w, self.h)
		self:isHovered(mx, my)
		if self.isHovered then
			self.hovered = true
		else
			self.hovered = false
		end

		-- ========================================
		-- Update Children
		-- ========================================

		for _, c in ipairs(self.children) do
			-- Children
			if c.enabled and c.update then
				c:update(dt)
			end
			-- For button compoenent
			if c.button then
				c.button:update(dt)
			end
			if self.isHovered then
				if c.isHovered then
					c:isHovered(mx, my)
				end
			else
				c.hovered = false
			end

			-- component
		end
		if self.flex then
			if self.debug then
				-- print("Flex Updating")
			end
			self.flex:update(dt)
		end
	end,

	close = function(self)
		for _, c in ipairs(self.children) do
			c.enabled = false
			if c.button then
				c.button.enabled = false
			end
		end

		self.enabled = false
	end,

	destroy = function(self)
		for _, c in ipairs(self.children) do
			c.enabled = false
			if c.button then
				c.button.enabled = false
			end
			c = {}
		end
		self.enabled = false
		self = {}
	end,

	draw = function(self)
		if not self.enabled then
			return
		end

		-- ========================================
		-- Draw Window Background
		-- ========================================

		if self.bg then
			love.graphics.setColor(self.bg)
		elseif self.isHovered then
			if self.hoverColor then
				love.graphics.setColor(self.hoverColor)
			end
		else
			love.graphics.setColor(self.bg)
		end

		love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)

		love.graphics.setColor(1, 1, 1, 1)

		-- ========================================
		-- Draw Viewport
		-- ========================================

		if self.debug then
			love.graphics.setColor(self.theme.red)

			love.graphics.rectangle("line", self.vx, self.vy, self.vw, self.vh)

			love.graphics.setColor(1, 1, 1, 1)
		end

		-- ========================================
		-- Draw Content
		-- ========================================
		if self.debug then
			-- love.graphics.setColor(self.theme.cyan)
			-- love.graphics.rectangle("fill", self.cx, self.cy, self.cw, self.ch)
			-- love.graphics.setColor(1, 1, 1, 1)
		end

		love.graphics.setScissor(self.vx, self.vy, self.vw, self.vh)

		if self.debug then
			-- if self.isHovered then
			-- 	love.graphics.setColor(self.theme.cyan)
			-- else
			-- 	love.graphics.setColor(self.theme.red)
			-- end
			-- love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
			-- love.graphics.rectangle("fill", self.cx, self.cy, self.cw, self.ch)
			-- love.graphics.setColor(1, 1, 1, 1)
			--
			-- love.graphics.print("top", self.cx, self.cy)
			-- love.graphics.print("Bottom", self.cx, self.cy + self.ch - 20)
			-- love.graphics.print("left", self.cx, self.vy + self.vw / 2 - 10)
			-- love.graphics.print("Right", self.cx + self.cw - 20, self.vy + self.vw / 2 - 10)
		end

		for _, c in ipairs(self.children) do
			if c.draw and c.enabled then
				-- The important part:
				-- Children need to use cy/cx
				-- for scrolling to be visible.
				c:draw()
			end
		end

		love.graphics.setScissor()

		-- ========================================
		-- Draw Horizontal Scrollbar
		-- ========================================

		if self.hsb then
			-- if self.isHSBDragging then
			-- 	love.graphics.setColor(self.theme.purple)
			-- else
			-- 	love.graphics.setColor(self.theme.purple)
			-- end

			love.graphics.setColor(self.theme.purple)
			love.graphics.rectangle("fill", self.hsbx, self.hsby, self.hsbw, self.hsbh)
			love.graphics.setColor(1, 1, 1, 1)
		end

		-- ========================================
		-- Draw Vertical Scrollbar
		-- ========================================

		if self.vsb then
			love.graphics.setColor(self.theme.purple)
			love.graphics.rectangle("fill", self.vsbx, self.vsby, self.vsbw, self.vsbh)
			love.graphics.setColor(1, 1, 1, 1)
		end
	end,

	-- ========================================
	-- AABB Collision Check
	-- ========================================

	isMouseOver = function(self, x, y, w, h, mx, my)
		if mx == nil or my == nil then
			mx, my = love.mouse.getPosition()
		end
		return mx >= x and mx <= x + w and my >= y and my <= y + h
	end,

	-- ========================================
	-- Mouse Pressed
	-- ========================================

	mousepressed = function(self, x, y, button)
		if not self.enabled then
			return
		end

		if self.isHovered then
			for _, c in ipairs(self.children) do
				if c.mousepressed and c.enabled then
					c:mousepressed(x, y, button)
				end
			end
		end

		-- Only left mouse button
		if button == 1 then
			if self.isVSBOver then
				self.isVSBDragging = true
			end
			if self.isHSBOver then
				self.isHSBDragging = true
			end
		end
	end,

	-- ========================================
	-- Mouse Released
	-- ========================================

	mousereleased = function(self, x, y, button)
		if not self.enabled then
			return
		end

		if self.isHovered then
			for _, c in ipairs(self.children) do
				if c.mousereleased and c.enabled then
					c:mousereleased(x, y, button)
				end
			end
		end

		if button == 1 then
			self.isVSBDragging = false
			self.isHSBDragging = false
		end
	end,
})

return Window
