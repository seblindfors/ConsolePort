local env = CPAPI.GetEnv(...); env.Mixin = {};

---------------------------------------------------------------
local ScrollBoxHelper = {};
---------------------------------------------------------------
env.Mixin.ScrollBoxHelper = ScrollBoxHelper;

function ScrollBoxHelper:FindFirstOfType(type, scrollView)
	return (scrollView or self:GetScrollView()):FindElementDataByPredicate(function(elementData)
		return elementData:GetData().xml == type.xml;
	end)
end

function ScrollBoxHelper:FindFirstFrameOfType(type, scrollView)
	scrollView = scrollView or self:GetScrollView()
	local elementData = self:FindFirstOfType(type, scrollView)
	if not elementData then return end;
	return scrollView:FindFrame(elementData)
end

---------------------------------------------------------------
local Background = CreateFromMixins(BackdropTemplateMixin);
---------------------------------------------------------------
env.Mixin.Background = Background;

function Background:OnLoad()
	local r, g, b = CPAPI.GetWebColor(CPAPI.GetClassFile()):GetRGB()
	self:HookScript('OnSizeChanged', self.OnBackdropSizeChanged)
	self.Background = self:CreateTexture(nil, 'BACKGROUND', nil, 2)
	self.Rollover   = self:CreateTexture(nil, 'BACKGROUND', nil, 3)
	self.Rollover:SetAllPoints(self.Background)
	self.Rollover:SetTexture(CPAPI.GetAsset([[Textures\Frame\Backdrop_Vertex_White]]))
	CPAPI.SetGradient(self.Rollover, 'VERTICAL',
		{r = r*0.5, g = g*0.5, b = b*0.5, a = 1},
		{r = r*0.5, g = g*0.5, b = b*0.5, a = 0}
	)
	self:SetOriginTop(true)
	self:CreateBackground(2048, 2048, 2048, 2048, CPAPI.GetAsset([[Art\Background\%s]]):format(CPAPI.GetClassFile()))
end

function Background:GetBGOffset(point, size)
	return ((point / 2) / size)
end

function Background:GetBGFraction(point, size)
	return (point / size)
end

function Background:SetBackgroundDimensions(w, h, x, y)
	assert(self.Background, 'Frame is missing background.')
	self.Background.maxWidth = w;
	self.Background.maxHeight = h;
	self.Background.sizeX = x;
	self.Background.sizeY = y;
end

function Background:SetOriginTop(enabled)
	self.originTop = enabled;
end

function Background:OnAspectRatioChanged()
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

function Background:SetBackgroundInsets(tlX, tlY, brX, brY)
	self.Background:ClearAllPoints()
	if tlX then
		tlX = tonumber(tlX) or 8;
		tlY = tonumber(tlY) or -tlX;
		brX = tonumber(brX) or -tlX;
		brY = tonumber(brY) or  tlX;
		self.Background:SetPoint('TOPLEFT', tlX, tlY)
		self.Background:SetPoint('BOTTOMRIGHT', brX, brY)
	else
		self.Background:SetAllPoints()
	end
end

function Background:CreateBackground(w, h, x, y, texture)
	self.Background:SetTexture(texture)
	self:SetBackgroundDimensions(w, h, x, y)
	self:OnAspectRatioChanged()
	self:HookScript('OnShow', self.OnAspectRatioChanged)
	self:HookScript('OnSizeChanged', self.OnAspectRatioChanged)
end

function Background:SetBackgroundVertexColor(...)
	self.Background:SetVertexColor(...)
end

function Background:SetBackgroundAlpha(alpha)
	self.Background:SetAlpha(alpha)
	self.Rollover:SetAlpha(alpha)
end

function Background:AddBackgroundMaskTexture(mask)
	self.Background:AddMaskTexture(mask)
	self.Rollover:AddMaskTexture(mask)
end

---------------------------------------------------------------
local UpdateStateTimer = {};
---------------------------------------------------------------
env.Mixin.UpdateStateTimer = UpdateStateTimer;

function UpdateStateTimer:SetUpdateStateTimer(timer)
	self:CancelUpdateStateTimer()
	self.updateStateTimer = C_Timer.NewTimer(self.updateStateDuration, timer)
end

function UpdateStateTimer:CancelUpdateStateTimer()
	if self.updateStateTimer then
		self.updateStateTimer:Cancel()
		self.updateStateTimer = nil;
	end
end

function UpdateStateTimer:SetUpdateStateDuration(duration)
    self.updateStateDuration = duration or 0;
end

---------------------------------------------------------------
local BindingCatcher = CreateFromMixins(CPPopupBindingCatchButtonMixin)
---------------------------------------------------------------
env.Mixin.BindingCatcher = BindingCatcher;

function BindingCatcher:OnBindingCaught(button, data)
	if not CPAPI.IsButtonValidForBinding(button) then return end;

	local bindingID = data.bindingID;
	local keyChord  = CPAPI.CreateKeyChord(button)

	return env:SetBinding(keyChord, bindingID)
end

function BindingCatcher:ClearBindingsForID(bindingID)
	env:ClearBindingsForID(bindingID, true)
end