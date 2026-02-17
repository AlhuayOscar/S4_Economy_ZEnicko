require "BuildingObjects/ISBuildingObject"
ISSignalCursor = ISBuildingObject:derive("ISSignalCursor")

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
	if not square:isInARoom() then
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
	return square:TreatAsSolidFloor()
end

function ISSignalCursor:render(x, y, z, square)
	if not ISSignalCursor.floorSprite then
		ISSignalCursor.floorSprite = IsoSprite.new()
		ISSignalCursor.floorSprite:LoadFramesNoDirPageSimple('media/ui/FloorTileCursor.png')
	end

	local hc = getCore():getGoodHighlitedColor()
	if not self:isValid(square) or square:isInARoom() then
		hc = getCore():getBadHighlitedColor()
	end
	ISSignalCursor.floorSprite:RenderGhostTileColor(x, y, z, hc:getR(), hc:getG(), hc:getB(), 0.8)
end




