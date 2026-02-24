require "ISUI/ISPanel"

S4_ItemBoxButton = ISPanel:derive("S4_ItemBoxButton");

--************************************************************************--
--** ISPanel:initialise
--**
--************************************************************************--

function S4_ItemBoxButton:initialise()
	ISPanel.initialise(self);
end

--************************************************************************--
--** S4_ItemBoxButton:onMouseMove
--**
--************************************************************************--
function S4_ItemBoxButton:onMouseMove(dx, dy)
	self.mouseOver = self:isMouseOver();
end

--************************************************************************--
--** S4_ItemBoxButton:onMouseMoveOutside
--**
--************************************************************************--
function S4_ItemBoxButton:onMouseMoveOutside(dx, dy)
	self.mouseOver = false;
	if self.onmouseoutfunction then
		self.onmouseoutfunction(self.target, self, dx, dy);
	end
end

function S4_ItemBoxButton:setJoypadFocused(focused)
    self.joypadFocused = focused;
end

--************************************************************************--
--** S4_ItemBoxButton:onMouseUp
--**
--************************************************************************--
function S4_ItemBoxButton:onMouseUp(x, y)

    if not self:getIsVisible() then
        return;
    end
    local process = false;
    if self.pressed == true then
        process = true;
    end
    self.pressed = false;
     if self.onclick == nil then
        return;
    end
    if self.enable and (process or self.allowMouseUpProcessing) then
        getSoundManager():playUISound(self.sounds.activate)
        self.onclick(self.target, self, self.onClickArgs[1], self.onClickArgs[2], self.onClickArgs[3], self.onClickArgs[4]);
	    --print(self.title);
    end

end

function S4_ItemBoxButton:onMouseUpOutside(x, y)

    self.pressed = false;
end
--************************************************************************--
--** S4_ItemBoxButton:onMouseDown
--**
--************************************************************************--
function S4_ItemBoxButton:onMouseDown(x, y)
	if not self:getIsVisible() then
		return;
	end
    self.pressed = true;
    if self.onmousedown == nil or not self.enable then
		return;
    end
	self.onmousedown(self.target, self, x, y);
end

function S4_ItemBoxButton:onMouseDoubleClick(x, y)
	return self:onMouseDown(x, y)
end

function S4_ItemBoxButton:forceClick()
    if not self:getIsVisible() or not self.enable then
        return;
    end
    if self.repeatWhilePressedFunc then
		return self.repeatWhilePressedFunc(self.target, self)
    end
    getSoundManager():playUISound(self.sounds.activate)
    self.onclick(self.target, self, self.onClickArgs[1], self.onClickArgs[2], self.onClickArgs[3], self.onClickArgs[4]);
end

function S4_ItemBoxButton:setJoypadButton(texture)
    self.isJoypad = true;
    self.joypadTexture = texture;
end

function S4_ItemBoxButton:clearJoypadButton()
    self.isJoypad = false;
    self.joypadTexture = nil;
end

--************************************************************************--
--** S4_ItemBoxButton:render
--**
--************************************************************************--
function S4_ItemBoxButton:prerender()
	if self.displayBackground and not self.isJoypad then
		-- Checking self:isMouseOver() in case the button is becoming visible again.
		self.fade:setFadeIn((self.mouseOver and self:isMouseOver()) and self.enable or self.joypadFocused or false)
		self.fade:update()
		local f = self.fade:fraction()
		local fill = self.backgroundColorMouseOver
		if self.pressed then
			self.backgroundColorPressed = self.backgroundColorPressed or {}
			self.backgroundColorPressed.r = self.backgroundColorMouseOver.r * 0.5
			self.backgroundColorPressed.g = self.backgroundColorMouseOver.g * 0.5
			self.backgroundColorPressed.b = self.backgroundColorMouseOver.b * 0.5
			self.backgroundColorPressed.a = self.backgroundColorMouseOver.a
			fill = self.backgroundColorPressed
		end
		self:drawRect(0, 0, self.width, self.height,
			fill.a * f + self.backgroundColor.a * (1 - f),
			fill.r * f + self.backgroundColor.r * (1 - f),
			fill.g * f + self.backgroundColor.g * (1 - f),
			fill.b * f + self.backgroundColor.b * (1 - f));
		if self.textureBackground then
			self:drawTextureScaled(self.textureBackground, 0, 0, self.width, self.height, 1-f, 1, 1, 1);
		end
        self:drawRectBorder(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);
    end
	if self.joypadFocused then
		self:drawRectBorder(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);
	end
	if self.displayBackground and self.blinkBG and not self.mouseOver then
		if not self.blinkBGAlpha then
			self.blinkBGAlpha = 1
			self.blinkBGAlphaIncrease = false
		end
		if not self.blinkBGAlphaIncrease then
			self.blinkBGAlpha = self.blinkBGAlpha - 0.1 * (UIManager.getMillisSinceLastRender() / 33.3)
			if self.blinkBGAlpha < 0 then
				self.blinkBGAlpha = 0;
				self.blinkBGAlphaIncrease = true
			end
		else
			self.blinkBGAlpha = self.blinkBGAlpha + 0.1 * (UIManager.getMillisSinceLastRender() / 33.3)
			if self.blinkBGAlpha > 1 then
				self.blinkBGAlpha = 1
				self.blinkBGAlphaIncrease = false
			end
		end
		local f = self.blinkBGAlpha
		self:drawRect(0, 0, self.width, self.height,
			self.backgroundColorMouseOver.a * f + self.backgroundColor.a * (1 - f),
			self.backgroundColorMouseOver.r * f + self.backgroundColor.r * (1 - f),
			self.backgroundColorMouseOver.g * f + self.backgroundColor.g * (1 - f),
			self.backgroundColorMouseOver.b * f + self.backgroundColor.b * (1 - f));
		if self.textureBackground then
			self:drawTextureScaled(self.textureBackground, 0, 0, self.width, self.height, f, 1, 1, 1);
		end
	end
	self:updateTooltip()
end

function S4_ItemBoxButton:setImage(image)
	self.image = image;
end

function S4_ItemBoxButton:forceImageSize(width, height)
    self.forcedWidthImage = width;
    self.forcedHeightImage = height;
end

function S4_ItemBoxButton:setOverlayText(text)
	self.overlayText = text;
end

function S4_ItemBoxButton:render()
	if self.ItemImg then
		if not self.ImgSize then self.ImgSize = (S4_UI.FH_L * 3) - S4_UI.FH_S end
		if self.ItemName then
			if self.Authority or self.SoldOut then
				self:drawTextureScaledAspect(self.ItemImg, (self.width / 2) - (self.ImgSize / 2), 10, self.ImgSize, self.ImgSize, 0.5, 1, 1, 1)
				local FixName = S4_UI.TextLimitOne(self.ItemName, self.width - 10, UIFont.Small)
				local NameX = (self.width / 2) - (getTextManager():MeasureStringX(UIFont.Small, FixName) / 2)
				local NameY = 15 + self.ImgSize
				self:drawText(FixName, NameX, NameY, 0.3, 0.3, 0.3, 1, UIFont.Small)
				if self.SoldOut then
					self:drawText("Sold Out", 10, 10, 0.9, 0, 0, 1, UIFont.Small)
				end
			else
				self:drawTextureScaledAspect(self.ItemImg, (self.width / 2) - (self.ImgSize / 2), 10, self.ImgSize, self.ImgSize, 1, 1, 1, 1)
				local FixName = S4_UI.TextLimitOne(self.ItemName, self.width - 10, UIFont.Small)
				local NameX = (self.width / 2) - (getTextManager():MeasureStringX(UIFont.Small, FixName) / 2)
				local NameY = 15 + self.ImgSize
				self:drawText(FixName, NameX, NameY, 0.8, 0.8, 0.8, 1, UIFont.Small)
			end
			-- Demand Indicator
			if self.item and self.item.DemandFaction then
				local label = "DEMAND"
				local labelW = getTextManager():MeasureStringX(UIFont.Small, label)
				self:drawText(label, self.width - labelW - 5, 5, 1, 1, 0, 1, UIFont.Small)
			end
		end
	end
end

function S4_ItemBoxButton:setFont(font)
	self.font = font;
end

function S4_ItemBoxButton:getTitle()
	return self.title;
end

function S4_ItemBoxButton:setTitle(title)
	self.title = title;
end

function S4_ItemBoxButton:setOnMouseOverFunction(onmouseover)
	self.onmouseover = onmouseover;
end

function S4_ItemBoxButton:setOnMouseOutFunction(onmouseout)
	self.onmouseoutfunction = onmouseout;
end

function S4_ItemBoxButton:setDisplayBackground(background)
	self.displayBackground = background;
end

function S4_ItemBoxButton:update()
	ISUIElement.update(self)
	if self.enable and self.pressed and self.target and self.repeatWhilePressedFunc then
		if not self.pressedTime then
			self.pressedTime = getTimestampMs()
			self.repeatWhilePressedFunc(self.target, self)
		else
			local ms = getTimestampMs()
			if ms - self.pressedTime > self.repeatWhilePressedTimer then
				self.pressedTime = ms
				self.repeatWhilePressedFunc(self.target, self)
			end
		end
	else
		self.pressedTime = nil
	end
end

function S4_ItemBoxButton:updateTooltip()
	if (self:isMouseOver() or self.joypadFocused) and self.tooltip then
		local text = self.tooltip
		if not self.tooltipUI then
			self.tooltipUI = ISToolTip:new()
			self.tooltipUI:setOwner(self)
			self.tooltipUI:setVisible(false)
			self.tooltipUI:setAlwaysOnTop(true)
		end
		if not self.tooltipUI:getIsVisible() then
			if string.contains(self.tooltip, "\n") then
				self.tooltipUI.maxLineWidth = 1000 -- don't wrap the lines
			else
				self.tooltipUI.maxLineWidth = 300
			end
			self.tooltipUI:addToUIManager()
			self.tooltipUI:setVisible(true)
		end
		self.tooltipUI.description = text
		if self:isMouseOver() then
		    self.tooltipUI:setDesiredPosition(getMouseX(), self:getAbsoluteY() + self:getHeight() + 8)
		else
		    self.tooltipUI:setDesiredPosition(self:getAbsoluteX(), self:getAbsoluteY() + self:getHeight() + 8)
        end
	else
		if self.tooltipUI and self.tooltipUI:getIsVisible() then
			self.tooltipUI:setVisible(false)
			self.tooltipUI:removeFromUIManager()
		end
    end
end

function S4_ItemBoxButton:setRepeatWhilePressed(func)
	self.repeatWhilePressedFunc = func
end

function S4_ItemBoxButton:setBackgroundRGBA(r, g, b, a)
	self.backgroundColor.r = r
	self.backgroundColor.g = g
	self.backgroundColor.b = b
	self.backgroundColor.a = a
end

function S4_ItemBoxButton:setBackgroundColorMouseOverRGBA(r, g, b, a)
	self.backgroundColorMouseOver.r = r
	self.backgroundColorMouseOver.g = g
	self.backgroundColorMouseOver.b = b
	self.backgroundColorMouseOver.a = a
end

function S4_ItemBoxButton:setBorderRGBA(r, g, b, a)
	self.borderColor.r = r
	self.borderColor.g = g
	self.borderColor.b = b
	self.borderColor.a = a
end

function S4_ItemBoxButton:setTextureRGBA(r, g, b, a)
	self.textureColor.r = r
	self.textureColor.g = g
	self.textureColor.b = b
	self.textureColor.a = a
end

function S4_ItemBoxButton:enableAcceptColor()
	local GHC = getCore():getGoodHighlitedColor()
	local r, g, b = GHC:getR(), GHC:getG(), GHC:getB()
	self:setBackgroundRGBA(r, g, b, 0.25)
	self:setBackgroundColorMouseOverRGBA(r, g, b, 0.50)
	self:setBorderRGBA(r, g, b, 1)
end

function S4_ItemBoxButton:enableCancelColor()
	local BHC = getCore():getBadHighlitedColor()
	local r, g, b = BHC:getR(), BHC:getG(), BHC:getB()
	self:setBackgroundRGBA(r, g, b, 0.25)
	self:setBackgroundColorMouseOverRGBA(r, g, b, 0.50)
	self:setBorderRGBA(r, g, b, 1)
end

function S4_ItemBoxButton:toggleAcceptCancel(bEnabled)
	if bEnabled then
		self:enableAcceptColor()
	else
		self:enableCancelColor()
	end
end

function S4_ItemBoxButton:setEnable(bEnabled)
	self.enable = bEnabled;
	if not self.borderColorEnabled then
		self.borderColorEnabled = { r = self.borderColor.r, g = self.borderColor.g, b = self.borderColor.b, a = self.borderColor.a }
		self.backgroundColorEnabled = { r = self.backgroundColor.r, g = self.backgroundColor.g, b = self.backgroundColor.b, a = self.backgroundColor.a }
	end
	if bEnabled then
		self:setTextureRGBA(1, 1, 1, 1)
		self:setBorderRGBA(
			self.borderColorEnabled.r,
			self.borderColorEnabled.g,
			self.borderColorEnabled.b,
			self.borderColorEnabled.a)
		self:setBackgroundRGBA(
			self.backgroundColorEnabled.r,
			self.backgroundColorEnabled.g,
			self.backgroundColorEnabled.b,
			self.backgroundColorEnabled.a)
	else
		self:setTextureRGBA(0.3, 0.3, 0.3, 1.0)
		self:setBorderRGBA(0.7, 0.1, 0.1, 0.7)
		self:setBackgroundRGBA(0, 0, 0, 1)
	end
end

function S4_ItemBoxButton:isEnabled()
	return self.enable;
end

function S4_ItemBoxButton:setTooltip(tooltip)
    self.tooltip = tooltip;
end

function S4_ItemBoxButton:setWidthToTitle(minWidth, isJoypad)
	local width = getTextManager():MeasureStringX(self.font, self.title) + 10
	if isJoypad or self.iconTexture then
		width = width + 5 + self.joypadTextureWH
	end
	width = math.max(width, minWidth or 0)
	if width ~= self.width then
		self.originalWidth = width;
		self:setWidth(width)
	end
end

function S4_ItemBoxButton:setOnClick(func, arg1, arg2, arg3, arg4)
	self.onclick = func
	self.onClickArgs = { arg1, arg2, arg3, arg3 }
end

function S4_ItemBoxButton:setSound(which, soundName)
	self.sounds[which] = soundName
end

function S4_ItemBoxButton:calculateLayout(_preferredWidth, _preferredHeight)
    local width = math.max(self.originalWidth or 0, _preferredWidth or 0);
    local height = math.max(self.originalHeight or 0, _preferredHeight or 0);


    self:setWidth(width);
    self:setHeight(height);
end

--************************************************************************--
--** S4_ItemBoxButton:new
--**
--************************************************************************--
function S4_ItemBoxButton:new (x, y, width, height, title, clicktarget, onclick, onmousedown, allowMouseUpProcessing)

	local o = {}
	--o.data = {}
	o = ISPanel:new(x, y, width, height);
	setmetatable(o, self)
    self.__index = self
	o.x = x;
	o.y = y;
	o.font = UIFont.Small;
	o.borderColor = {r=0.7, g=0.7, b=0.7, a=1};
	o.backgroundColor = {r=0, g=0, b=0, a=1.0};
	o.backgroundColorMouseOver = {r=0.3, g=0.3, b=0.3, a=1.0};
    o.textureColor = {r=1.0, g=1.0, b=1.0, a=1.0};
    o.textColor = {r=1.0, g=1.0, b=1.0, a=1.0};
    if width < (getTextManager():MeasureStringX(UIFont.Small, title) + 10) then
        width = getTextManager():MeasureStringX(UIFont.Small, title) + 10;
    end
    o.width = width;
    o.height = height;
	o.anchorLeft = true;
	o.anchorRight = false;
	o.anchorTop = true;
	o.anchorBottom = false;
	o.mouseOver = false;
	o.displayBackground = true;
	o.title = title;
	o.onclick = onclick;
	o.onClickArgs = {}
	o.target = clicktarget;
	o.onmousedown = onmousedown;
	o.enable = true;
    o.tooltip = nil;
    o.isButton = true;
    o.allowMouseUpProcessing = allowMouseUpProcessing;
    o.yoffset = 0;
    o.fade = UITransition.new()
    o.joypadTextureWH = 32
	o.repeatWhilePressedTimer = 500;
    o.sounds = {}
    o.sounds.activate = "UIActivateButton"
	o.originalWidth = width;
	o.originalHeight = height;
	o.textureBackground = nil;
   return o
end
