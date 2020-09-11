---------------------------------------------------------------
-- Trackable widget pool
---------------------------------------------------------------
CPFocusPoolMixin = {};

function CPFocusPoolMixin:OnLoad()
	self.Registry = {};
end

function CPFocusPoolMixin:OnPostHide()
	self.focusIndex = nil;
end

function CPFocusPoolMixin:CreateFramePool(type, template, mixin, resetterFunc)
	assert(not self.FramePool, 'Frame pool already exists.')
	self.FramePool = CreateFramePool(type, self, template, resetterFunc)
	self.FramePoolMixin = mixin;
	return self.FramePool;
end

function CPFocusPoolMixin:Acquire(index)
	local widget, newObj = self.FramePool:Acquire()
	if newObj then
		Mixin(widget, self.FramePoolMixin)
	end
	self.Registry[index] = widget;
	return widget, newObj;
end

function CPFocusPoolMixin:GetNumActive()
	return self.FramePool:GetNumActive()
end

function CPFocusPoolMixin:ReleaseAll()
	self.FramePool:ReleaseAll()
end

function CPFocusPoolMixin:SetFocusByIndex(index)
	local old = self.focusIndex ~= index and self.focusIndex;
	self.focusIndex = index;

	local oldObj = old and self.Registry[old];
	local newObj = self.Registry[index];
	return newObj, oldObj;
end

function CPFocusPoolMixin:SetFocusByWidget(widget)
	return self:SetFocusByIndex(tIndexOf(self.Registry, widget))
end


---------------------------------------------------------------
-- Gradient mixin
---------------------------------------------------------------
CPGradientMixin = {};

function CPGradientMixin:OnLoad()
	self.VertexColor  = C_ClassColor.GetClassColor(CPAPI.GetClassFile())
	self.VertexValid  = CreateColor(1, .81, 0, 1)
	self.VertexOrient = 'VERTICAL';
end

function CPGradientMixin:SetGradientDirection(direction)
	assert(direction == 'VERTICAL' or direction == 'HORIZONTAL', 'Valid: VERTICAL, HORIZONTAL')
	self.VertexOrient = direction;
end

function CPGradientMixin:GetClassColor()
	return self.VertexColor:GetRGB()
end

function CPGradientMixin:GetValidColor()
	return self.VertexColor:GetRGB()
end

function CPGradientMixin:GetMixGradient(...)
	return CPAPI.GetReverseMixColorGradient(self.VertexOrient, ...)
end

function CPGradientMixin:GetReverseMixGradient(...)
	return CPAPI.GetMixColorGradient(self.VertexOrient, ...)
end

function CPGradientMixin:GetFadeGradient(...)
	return self.VertexOrient, 1, 1, 1, 0, ...;
end


---------------------------------------------------------------
-- Frame background
---------------------------------------------------------------
CPBackgroundMixin = CreateFromMixins(BackdropTemplateMixin);

function CPBackgroundMixin:OnLoad()
	local r, g, b = CPAPI.GetWebColor(CPAPI.GetClassFile()):GetRGB()
	self:HookScript('OnSizeChanged', self.OnBackdropSizeChanged)
	self.Background = self:CreateTexture(nil, 'BACKGROUND', nil, 2)
	self.Rollover   = self:CreateTexture(nil, 'BACKGROUND', nil, 3)
	self.Rollover:SetAllPoints(self.Background)
	self.Rollover:SetTexture(CPAPI.GetAsset([[Textures\Frame\Backdrop_Vertex_White]]))
	self.Rollover:SetGradientAlpha('VERTICAL', r, g, b, 1, r, g, b, 0)
	self:SetOriginTop(true)
	self:CreateBackground(2048, 2048, 2048, 2048, CPAPI.GetAsset([[Art\Background\%s]]):format(CPAPI.GetClassFile()))
end

function CPBackgroundMixin:GetBGOffset(point, size)
	return ((point / 2) / size)
end

function CPBackgroundMixin:GetBGFraction(point, size)
	return (point / size)
end

function CPBackgroundMixin:SetBackgroundDimensions(w, h, x, y)
	assert(self.Background, 'Frame is missing background.')
	self.Background.maxWidth = w;
	self.Background.maxHeight = h;
	self.Background.sizeX = x;
	self.Background.sizeY = y;
end

function CPBackgroundMixin:SetOriginTop(enabled)
	self.originTop = enabled;
end

function CPBackgroundMixin:OnAspectRatioChanged()
	local maxWidth, maxHeight = self.Background.maxWidth, self.Background.maxHeight;
	local sizeX, sizeY = self.Background.sizeX, self.Background.sizeY;
	local width, height = self:GetSize()

	local maxCoordX, maxCoordY, centerCoordX, centerCoordY = 
		self:GetBGFraction(maxWidth, sizeX),
		self:GetBGFraction(maxHeight, sizeY),
		self:GetBGOffset(maxWidth, sizeX),
		self:GetBGOffset(maxHeight, sizeY);

	local top, bottom, left, right = 0, 1, 0, 1;
	if width > height then
		local newHeight = self:GetBGFraction(height, width) * maxWidth;
		if self.originTop then
			top, left, right = 0, 0, maxCoordX;
			bottom = self:GetBGFraction(newHeight, sizeY)
		else
			local offset = self:GetBGOffset(newHeight, sizeY)
			left, right = 0, maxCoordX;
			top = centerCoordY - offset;
			bottom = centerCoordY + offset;
		end
	end
	if height > width or (top < 0 or bottom < 0) then
		local newWidth = self:GetBGFraction(width, height) * maxHeight;
		local offset = self:GetBGOffset(newWidth, sizeX)
		top, bottom = 0, maxCoordY;
		left = centerCoordX - offset;
		right = centerCoordX + offset;
	end
	self.Background:SetTexCoord(left, right, top, bottom)
end

function CPBackgroundMixin:SetBackgroundInsets(enabled, value)
	self.Background:ClearAllPoints()
	if enabled then
		local inset = value or 8;
		self.Background:SetPoint('TOPLEFT', inset, -inset)
		self.Background:SetPoint('BOTTOMRIGHT', -inset, inset)
	else
		self.Background:SetAllPoints()
	end
end

function CPBackgroundMixin:CreateBackground(w, h, x, y, texture)
	self.Background:SetTexture(texture)
	self:SetBackgroundDimensions(w, h, x, y)
	self:OnAspectRatioChanged()
	self:HookScript('OnShow', self.OnAspectRatioChanged)
	self:HookScript('OnSizeChanged', self.OnAspectRatioChanged)
end

---------------------------------------------------------------
-- Ambience mixin
---------------------------------------------------------------
CPAmbienceMixin = {
	soundKitOnShow = SOUNDKIT.UI_ADVENTURES_ADVENTURER_LEVEL_UP;
	soundVars = {
		Sound_EnableSFX = false;
		Sound_EnableMusic = false;
		Sound_EnableDialog = false;
		Sound_EnableAmbience = false;
	};
	soundKits = {
		WARRIOR     = SOUNDKIT.AMB_GLUESCREEN_BATTLE_FOR_AZEROTH;
		HUNTER      = SOUNDKIT.AMB_GLUESCREEN_NIGHTELF;
		MAGE        = SOUNDKIT.AMB_GLUESCREEN_VOIDELF;
		ROGUE       = SOUNDKIT.AMB_GLUESCREEN_DARKIRONDWARF;
		PRIEST      = SOUNDKIT.AMB_GLUESCREEN_DWARF;
		WARLOCK     = SOUNDKIT.AMB_GLUESCREEN_LEGION;
		PALADIN     = SOUNDKIT.AMB_GLUESCREEN_LIGHTFORGEDDRAENEI;
		DRUID       = SOUNDKIT.AMB_GLUESCREEN_WARLORDS_OF_DRAENOR;
		SHAMAN      = SOUNDKIT.AMB_GLUESCREEN_DRAENEI;
		MONK        = SOUNDKIT.AMB_GLUESCREEN_PANDAREN;
		DEMONHUNTER = SOUNDKIT.AMB_GLUESCREEN_DEMONHUNTER;
		DEATHKNIGHT = SOUNDKIT.AMB_GLUESCREEN_DEATHKNIGHT;
	};
}

function CPAmbienceMixin:OnLoad()
	self:HookScript('OnShow', self.PlayAmbience)
	self:HookScript('OnHide', self.StopAmbience)
end

function CPAmbienceMixin:PlayAmbience()
	PlaySound(self.soundKitOnShow, 'Master', true)
	local playFileID = self.soundKits[CPAPI.GetClassFile()]
	if playFileID then
		local willPlay, handle = PlaySound(playFileID, 'Master', true)
		if willPlay then
			self.isPlayingAmbience = handle;
			for var in pairs(self.soundVars) do
				self.soundVars[var] = GetCVarBool(var)
				SetCVar(var, 0)
			end
		end
	end
end

function CPAmbienceMixin:StopAmbience()
	if self.isPlayingAmbience then
		StopSound(self.isPlayingAmbience, 1000)
		self.isPlayingAmbience = nil;
		for var, val in pairs(self.soundVars) do
			SetCVar(var, val)
		end
	end
end