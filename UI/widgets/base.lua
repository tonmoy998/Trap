local Class = require(UI_PATH .. ".libs.class")
local Options = require(UI_PATH .. ".options")
local Theme = require(UI_PATH .. ".themes.Themes")

local Base = Class({
	init = function(self, props)
		self.name = props.name or "Base"
		self.x = props.x or 100
		self.ox = props.ox or 0
		self.oy = props.oy or 0
		self.y = props.y or 100
		self.lx = props.lx or 100
		self.ly = props.ly or 100
		self.w = props.w or 100
		self.h = props.h or 100
		self.border = props.border or false

		-- Theme
		self.theme = Theme[Options.theme]

		-- children
		self.children = {}
		self.parent = nil
		self.container = props.container or "root"

		-- Fill type
		self.backgroundImage = props.backgroundImage or nil
		self.bg = props.bg or nil
		self.type = props.type or "fill"
		self.color = props.color or self.theme.fg

		-- Border
		self.borderColor = props.borderColor or nil
		self.borderWidth = props.borderWidth or 1

		-- font
		self.font = props.font or love.graphics.getFont()

		-- Active Status
		-- Explicitly fallback to true if not provided in props or Base
		self.enabled = props.enabled ~= false and (self.enabled or true)
		self.visible = props.visible ~= false and (self.visible or true)
		self.alpha = props.alpha or 1

		-- Events
		self.hovered = false
		self.clicked = false
		self.hoverColor = props.hoverColor or nil
		self.clickedColor = props.clickedColor or nil
		self.onClick = props.onClick or function() end
		self.debug = Options.debug
		self.id = tostring(self):sub(8) -- unique ID

		--
		self.onRelease = props.onRelease or function() end

		-- drawing order
		self.z = props.z or 1

		-- specify element
		self.element = props.element or nil
	end,
})

return Base
