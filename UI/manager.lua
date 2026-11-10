local Class = require(UI_PATH .. ".libs.class")
local Options = require(UI_PATH .. ".options")

local Manager = Class({})

function Manager:init(props)
	props = props or {}
	self.debug = Options.debug
	self.activeLayer = props.activeLayer or "root"

	-- NOTE: List of layers: { {name = "root", status = true, children = {}}, ... }
	self.layers = {}
	self.needToReRender = true
	self.topElement = nil

	-- Automatically add the default/root layer on initialization
	self:addLayer(self.activeLayer, true)
end

-- Helper method to find a layer by its name within the array
function Manager:_findLayer(layerName)
	for _, layerTable in ipairs(self.layers) do
		if layerTable.name == layerName then
			return layerTable
		end
	end
	return nil
end

function Manager:addLayer(layerName, status)
	-- Prevent duplicate layers
	if self:_findLayer(layerName) then
		return
	end

	-- If this new layer is being set to active (true), deactivate all other layers
	if status then
		for _, layer in ipairs(self.layers) do
			layer.status = false
		end
	end

	table.insert(self.layers, {
		name = layerName,
		status = not not status, -- Force boolean
		children = {},
	})
end

function Manager:setActiveLayer(layerName)
	for _, layer in ipairs(self.layers) do
		if layer.name == layerName then
			layer.status = true -- Explicitly turn it on
			if self.debug then
				print("Layer " .. layerName .. " is active now")
			end
		else
			layer.status = false -- Turn everything else off
		end
	end
end

function Manager:addChild(layerName, child)
	local layerTable = self:_findLayer(layerName)

	if layerTable then
		table.insert(layerTable.children, child)
		self.needToReRender = true
	else
		error("Layer '" .. tostring(layerName) .. "' does not exist. Add it using addLayer first.")
	end
end

function Manager:draw()
	self:render()

	for _, layer in ipairs(self.layers) do
		if layer.status then
			for _, child in ipairs(layer.children) do
				if type(child) == "table" and child.draw then
					child:draw()
				end
			end
		end
	end
end

function Manager:render()
	if self.needToReRender then
		-- Perform structural sorting or UI alignment modifications here
		for _, layer in ipairs(self.layers) do
			table.sort(layer.children, function(a, b)
				local aZ = a.z or 1
				local bZ = b.z or 1
				return aZ < bZ
			end)
		end
		self.needToReRender = false
	end
end

function Manager:update(dt)
	-- 1. Get the mouse position exactly ONCE per frame
	local mx, my = love.mouse.getPosition()

	local topElement = nil
	local topZ = -math.huge
	local topLayerIndex = -1

	-- PASS 1: Find the absolute top-most element under the mouse across ALL layers
	for layerIdx, layer in ipairs(self.layers) do
		if layer.status then
			for _, child in ipairs(layer.children) do
				if type(child) == "table" and child.isMouseOver and child:isMouseOver(mx, my) then
					local currentZ = child.z or child.zIndex or 0

					-- An element wins if it belongs to a higher layer index,
					-- OR if it's on the same layer but has a higher z-index.
					if layerIdx > topLayerIndex or (layerIdx == topLayerIndex and currentZ > topZ) then
						-- Respect focus system: only allow if no focus lock, or if this IS the focused element
						if self.focusedElement == nil or self.focusedElement == child then
							self.topElement = child
							-- topElement = child
							topZ = currentZ
							topLayerIndex = layerIdx
						end
					end
				end
			end
		end
	end

	-- PASS 2: Apply hover states and run regular update cycles
	for _, layer in ipairs(self.layers) do
		if layer.status then
			for _, child in ipairs(layer.children) do
				if type(child) == "table" then
					-- Only the single absolute winner gets set to true. Everything else becomes false.
					if child == self.topElement then
						child.hovered = true
					else
						child.hovered = false
					end

					-- Run standard component update logic (for timers, animations, etc.)
					if child.update then
						child:update(dt)
					end
				end
			end
		end
	end
end
function Manager:mousepressed(mx, my, button)
	for _, layer in ipairs(self.layers) do
		if layer.status then
			for _, child in ipairs(layer.children) do
				if type(child) == "table" and child.mousepressed then
					if child:mousepressed(mx, my, button) then
						return true
					end
				end
			end
		end
	end
	return false
end
function Manager:mousereleased(mx, my, button)
	for _, layer in ipairs(self.layers) do
		if layer.status then
			for _, child in ipairs(layer.children) do
				if type(child) == "table" and child.mousereleased then
					if child:mousereleased(mx, my, button) then
						return true
					end
				end
			end
		end
	end

	return false
end

return Manager
