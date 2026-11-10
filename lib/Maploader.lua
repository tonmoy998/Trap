local json = require("lib.json")

local MapLoader = {}
MapLoader.layersByName = {}
MapLoader.allLayers = {}

function MapLoader.load(path, world)
	local raw = love.filesystem.read(path)
	assert(raw, "MapLoader: could not read map file '" .. path .. "'")
	local data = json.decode(raw)

	-- Reset and store layer references
	MapLoader.allLayers = data.layers
	MapLoader.layersByName = {}

	for _, layer in ipairs(data.layers) do
		-- Map layers by their name for easy lookup (e.g. MapLoader.getLayer("Ground"))
		MapLoader.layersByName[layer.name] = layer
	end

	local map = {
		width = data.width,
		height = data.height,
		tilewidth = data.tilewidth,
		tileheight = data.tileheight,
		grounds = {},
		fallZones = {},
		endZones = {},
		balls = {},
	}

	-- for _, layer in ipairs(data.layers) do
	-- 	if layer.type == "objectgroup" then
	-- 		if layer.name == "Ground" then
	-- 			MapLoader._buildGround(layer, world, map)
	-- 		elseif layer.name == "Fall1" or layer.class == "Fall" then
	-- 			MapLoader._buildZone(layer, map.fallZones)
	-- 		elseif layer.name == "End" then
	-- 			MapLoader._buildZone(layer, map.endZones)
	-- 		elseif layer.class == "Ball" then
	-- 			MapLoader._buildBallSpawn(layer, map.balls)
	-- 		end
	-- 	end
	-- end

	return map
end

-- Ground objects -> static rectangle colliders in the windfield world.
function MapLoader._buildGround(layer, world, map)
	for _, obj in ipairs(layer.objects or {}) do
		local collider = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
		collider:setType("static")
		if collider.setCollisionClass then
			collider:setCollisionClass("Ground")
		end
		table.insert(map.grounds, collider)
	end
end

-- Fall/End zones stay as plain rectangles
function MapLoader._buildZone(layer, bucket)
	for _, obj in ipairs(layer.objects or {}) do
		table.insert(bucket, {
			x = obj.x,
			y = obj.y,
			width = obj.width,
			height = obj.height,
		})
	end
end

-- Ball spawn point calculation
function MapLoader._buildBallSpawn(layer, bucket)
	for _, obj in ipairs(layer.objects or {}) do
		table.insert(bucket, {
			x = obj.x + (obj.width or 0) / 2,
			y = obj.y + (obj.height or 0) / 2,
		})
	end
end

-----------------------------------------------------------
-- HELPER FUNCTIONS
-----------------------------------------------------------

-- 1. Get all raw layers array
function MapLoader.getLayers()
	return MapLoader.allLayers
end

-- 2. Get a single layer by its name (e.g., MapLoader.getLayer("Ground"))
function MapLoader.getLayer(layerName)
	return MapLoader.layersByName[layerName]
end

-- 3. Get all objects belonging to a specific layer name
function MapLoader.getObjects(layerName)
	local layer = MapLoader.getLayer(layerName)
	if layer and layer.objects then
		return layer.objects
	end
	return {}
end

-- 4. Get a specific object by its 'name' property across all layers (or within a given layer)
function MapLoader.getObjectByName(objectName, layerName)
	local layersToSearch = layerName and { MapLoader.getLayer(layerName) } or MapLoader.allLayers

	for _, layer in ipairs(layersToSearch) do
		if layer and layer.objects then
			for _, obj in ipairs(layer.objects) do
				if obj.name == objectName then
					return obj
				end
			end
		end
	end
	return nil
end

return MapLoader
