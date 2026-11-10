local Class = require(UI_PATH .. ".libs.class")

local Flex = Class({
	init = function(self, props)
		props = props or {}

		self.x = props.x or 0
		self.y = props.y or 0
		self.w = props.w or 100
		self.h = props.h or 100

		self.children = {}

		self.gap = props.gap or 0
		self.direction = props.direction or "row"
	end,

	add = function(self, child)
		table.insert(self.children, child)
	end,

	update = function(self, dt)
		if self.direction ~= "row" then
			return
		end

		if self.debug then
			print("Updating Child Positions")
		end

		local x = self.x
		local y = self.y
		local rowHeight = 0

		for _, child in ipairs(self.children) do
			-- Wrap to next row if child doesn't fit
			if x + child.w > self.x + self.w then
				x = self.x
				y = y + rowHeight + self.gap
				rowHeight = 0
			end

			-- Position child
			child.x = x
			child.y = y
			--[[  COMPONENT BUTTON ]]
			if child.t then
				child.t.x = x
				child.t.y = y
			end

			-- Move cursor horizontally
			x = x + child.w + self.gap

			-- Keep track of tallest child in current row
			rowHeight = math.max(rowHeight, child.h)
		end
	end,
})

return Flex
