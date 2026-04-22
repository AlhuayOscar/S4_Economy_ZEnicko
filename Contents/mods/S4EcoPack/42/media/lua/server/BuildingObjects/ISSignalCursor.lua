require "BuildingObjects/ISBuildingObject"
ISSignalCursor = ISBuildingObject:derive("ISSignalCursor")

local SIGNAL_UNDERGROUND_MIN_COMPUTER_DISTANCE = 2
local SIGNAL_COMPUTER_SPRITES = {
	["appliances_com_01_72"] = true,
	["appliances_com_01_73"] = true,
	["appliances_com_01_74"] = true,
	["appliances_com_01_75"] = true,
	["appliances_com_01_76"] = true,
	["appliances_com_01_77"] = true,
	["appliances_com_01_78"] = true,
	["appliances_com_01_79"] = true
}

local function isComputerSprite(obj)
	if not obj or not obj.getSprite then
		return false
	end
	local sprite = obj:getSprite()
	local name = nil
	if sprite then
		local ok, spriteName = pcall(function()
			return sprite:getName()
		end)
		if ok then
			name = spriteName
		end
	end
	if name then
		return SIGNAL_COMPUTER_SPRITES[name] == true
	end
	for spriteName, _ in pairs(SIGNAL_COMPUTER_SPRITES) do
		if sprite == getSprite(spriteName) then
			return true
		end
	end
	return false
end

local function hasComputerWithinDistance(square, distance)
	if not square then
		return false
	end
	local cell = getWorld() and getWorld():getCell() or getCell()
	if not cell then
		return false
	end
	local sx = square:getX()
	local sy = square:getY()
	local sz = square:getZ()
	for x = sx - distance, sx + distance do
		for y = sy - distance, sy + distance do
			local checkSquare = cell:getGridSquare(x, y, sz)
			local objects = checkSquare and checkSquare:getObjects() or nil
			if objects then
				for i = 0, objects:size() - 1 do
					if isComputerSprite(objects:get(i)) then
						return true
					end
				end
			end
		end
	end
	return false
end

local function canUseUndergroundInteriorSignal(character, square)
	if not character or not square or not square:isInARoom() then
		return false
	end
	local playerSquare = character:getSquare()
	local playerZ = playerSquare and playerSquare:getZ() or square:getZ()
	return playerZ <= -1 and square:getZ() <= -1 and
		not hasComputerWithinDistance(square, SIGNAL_UNDERGROUND_MIN_COMPUTER_DISTANCE)
end

local function canPlaceSignalAt(character, square)
	if not square or not square:TreatAsSolidFloor() then
		return false
	end
	if not square:isInARoom() then
		return true
	end
	return canUseUndergroundInteriorSignal(character, square)
end

function ISSignalCursor:new(character, itemTable)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o:init()
    o:setDragNilAfterPlace(true);
	o.character = character
	o.player = character:getPlayerNum()
	o.noNeedHammer = true
	o.skipBuildAction = true
	return o
end

function ISSignalCursor:create(x, y, z)
    self:setDragNilAfterPlace(true)
	local square = getWorld():getCell():getGridSquare(x, y, z)
	if canPlaceSignalAt(self.character, square) then
		if S4_Signal_Main.instance then
			S4_Signal_Main.instance:setVisible(true)
			S4_Signal_Main.instance.CodeX = x
			S4_Signal_Main.instance.CodeY = y
			S4_Signal_Main.instance.CodeZ = z
		end
	end
end

function ISSignalCursor:removeDrag()
	getCell():setDrag(nil, self.player)
end


function ISSignalCursor:isValid(square)
	return canPlaceSignalAt(self.character, square)
end

function ISSignalCursor:render(x, y, z, square)
	if not ISSignalCursor.floorSprite then
		ISSignalCursor.floorSprite = IsoSprite.new()
		ISSignalCursor.floorSprite:LoadFramesNoDirPageSimple('media/ui/FloorTileCursor.png')
	end

	local hc = getCore():getGoodHighlitedColor()
	if not self:isValid(square) then
		hc = getCore():getBadHighlitedColor()
	end
	ISSignalCursor.floorSprite:RenderGhostTileColor(x, y, z, hc:getR(), hc:getG(), hc:getB(), 0.8)
end




