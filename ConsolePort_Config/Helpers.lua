local db, _, env = ConsolePort:GetData(), ...; env.db, env.L = db, db.Locale;
---------------------------------------------------------------
-- Binding helpers
---------------------------------------------------------------
function env:GetActiveDeviceAndMap()
	-- using ID to get the buttons in WinRT API order (NOTE: zero-indexed)
	return db('Gamepad/Active'), db('Gamepad/Index/Button/ID')
end

function env:GetActiveModifiers()
	return db('Gamepad/Index/Modifier/Active')
end

function env:GetActiveModifier(button)
	return db.Gamepad:GetActiveModifier(button)
end

function env:GetHotkeyData(btnID, modID, styleMain, styleMod)
	return db.Hotkeys:GetHotkeyData(db('Gamepad/Active'), btnID, modID, styleMain, styleMod)
end

function env:GetButtonSlug(btnID, modID, split)
	return db.Hotkeys:GetButtonSlug(db('Gamepad/Active'), btnID, modID, split)
end

function env:GetTooltipPrompt(btnID, text)
	local device = db('Gamepad/Active')
	if device then
		return device:GetTooltipButtonPrompt(btnID, text)
	end
end

function env:GetTooltipPromptForClick(clickID, text)
	local device = db('Gamepad/Active')
	local btnID = db('UICursor'..clickID)
	if device and btnID then
		return device:GetTooltipButtonPrompt(btnID, text)
	end
end

function env:GetBindings()
	return db.Gamepad:GetBindings()
end

---------------------------------------------------------------
-- Scale things dynamically
---------------------------------------------------------------
local ScaleToContentMixin = {};
env.ScaleToContentMixin = ScaleToContentMixin;

function ScaleToContentMixin:SetMeasurementOrigin(top, content, width, offset)
	self.fixedWidth     = width;
	self.fixedOffset    = offset;
	self.topElement     = top;
	self.contentElement = content;
end

do -- Wrap calls to ensure no overrides
	local function GetTop(child)
		return getmetatable(child).__index.GetTop(child)
	end

	local function GetBottom(child)
		return getmetatable(child).__index.GetBottom(child)
	end

	function ScaleToContentMixin:CalcContentBoundary()
		local origT = GetTop(self.topElement) or 0
		local top, bottom = -math.huge, math.huge
		for i, child in ipairs({self.contentElement:GetChildren()}) do
			if child:IsShown() then
				local childTop, childBottom = GetTop(child), GetBottom(child)
				if childBottom then
					bottom = childBottom < bottom and childBottom or bottom;
				end
				if childTop then
					top = childTop > top and childTop or top;
				end
			end
		end
		local height = abs(origT - bottom) + self.fixedOffset;
		return height, height - abs(origT - top);
	end
end

function ScaleToContentMixin:SetRawHeight(height)
	getmetatable(self).__index.SetHeight(self, height)
end

function ScaleToContentMixin:SetHeight(height)
	if tonumber(height) then
		self.forbidRecursiveScale = true;
		self:SetHitRectInsets(0, 0, 0, 0)
		self:SetRawHeight(height)
		self:ScaleParent()
	else
		self.forbidRecursiveScale = false;
		self:ScaleToContent()
		self:ScaleToContent()
		-- BUG: (9.0.2.36949) Scroll child invalid rect OnShow,
		-- The rect for the scroll child is not properly drawn,
		-- resulting in -nan(ind) width/height on child widgets.
		-- Removing the second call triggers a Lua error in
		-- SharedUIPanelTemplates.lua:1229 when showing the initial
		-- 'wizard' panels that have a three-slice button on them,
		-- even though the button size is never changed manually.
	end
end

function ScaleToContentMixin:ScaleParent()
	local parent = self:GetParent()
	while parent do
		if ( parent.ScaleToContent and not parent.forbidRecursiveScale ) then
			parent:SetHeight(nil)
			break
		end
		parent = parent:GetParent()
	end
end

function ScaleToContentMixin:ScaleToContent()
	self:SetWidth(self.fixedWidth)
	local height, hitBoxOffset = self:CalcContentBoundary()
	self:SetRawHeight(height)
	self:SetHitRectInsets(0, 0, 0, hitBoxOffset)
	self:ScaleParent()
end

---------------------------------------------------------------
-- Dynamic self-releasing pools
---------------------------------------------------------------
local DynamicMixin = CreateFromMixins(CPFocusPoolMixin);
env.DynamicMixin = DynamicMixin;

function DynamicMixin:OnHide()
	self:ReleaseAll()
end

function DynamicMixin:GetWidgetByID(id, name)
	for regID, widget in pairs(self.Registry) do
		if ( widget:GetID() == id or name == regID ) then
			return widget;
		end
	end
end

---------------------------------------------------------------
-- Horizontal container collapse/expand
---------------------------------------------------------------
local Flexer, FlexibleMixin = CreateFrame('Frame'), {};
env.FlexibleMixin = FlexibleMixin; Flexer.Frames = {};

function Flexer:OnUpdate(elapsed)
	for frame in pairs(self.Frames) do
		local parent, target = frame.flexElement, frame.flexTarget;
		local current = parent:GetWidth()
		if abs(current - target) < 2 then
			parent:SetWidth(target)
			self:RemoveFrame(frame)
		else
			local delta = current > target and -1 or 1;
			parent:SetWidth(current + (delta * abs(current - target) / 4))
		end
	end
end

function Flexer:RemoveFrame(frame)
	self.Frames[frame] = nil;
	if not next(self.Frames) then
		self:SetScript('OnUpdate', nil)
	end
end

function Flexer:AddFrame(frame)
	self.Frames[frame] = true;
	self:SetScript('OnUpdate', self.OnUpdate)
end

function FlexibleMixin:SetFlexibleElement(element, measure, fixedWidth)
	self.flexElement = element;
	self.flexMeasure = fixedWidth or measure or element;
end

function FlexibleMixin:IsElementFlexed()
	return self.isFlexed;
end

function FlexibleMixin:ToggleFlex(enabled)
	local measure = self.flexMeasure;
	local isMeasureWidget = C_Widget.IsFrameWidget(measure)
	self.flexTarget = 
		not enabled and 0.01
		or isMeasureWidget and measure:GetWidth()
		or measure;
	self.isFlexed = enabled;
	self.flexElement:SetAttribute('nodeignore', not enabled)
	if isMeasureWidget then
		measure:SetAttribute('nodeignore', not enabled)
	end
	Flexer:AddFrame(self)
end


---------------------------------------------------------------
-- Opaque background
---------------------------------------------------------------
local OpaqueMixin = {};
env.OpaqueMixin = OpaqueMixin;

function OpaqueMixin:OnLoad()
	local r, g, b = CPAPI.GetWebColor(CPAPI.GetClassFile()):GetRGB()
	self:SetBackdropBorderColor(0.25, 0.25, 0.25, 1)
	CPAPI.SetGradient(self.Center, 'VERTICAL', r, g, b, 0, r, g, b, 1)
end


---------------------------------------------------------------
-- Header template (XML mixin)
---------------------------------------------------------------
CPConfigHeaderMixin = {};

function CPConfigHeaderMixin:OnLoad()
	self.LineTopLeft:SetStartPoint('TOPLEFT', 0, 0);
	self.LineTopLeft:SetEndPoint('TOP', 0, 0);
	self.LineTopRight:SetStartPoint('TOP', 0, 0);
	self.LineTopRight:SetEndPoint('TOPRIGHT', 0, 0);
	self.LineBottomLeft:SetStartPoint('BOTTOMLEFT', 0, 7);
	self.LineBottomLeft:SetEndPoint('BOTTOM', 0, 7);
	self.LineBottomRight:SetStartPoint('BOTTOM', 0, 7);
	self.LineBottomRight:SetEndPoint('BOTTOMRIGHT', 0, 7);

	CPAPI.SetGradient(self.LineTopLeft, 'HORIZONTAL', 1, 1, 1, 0, 1, 1, 1, 1);
	CPAPI.SetGradient(self.LineBottomLeft, 'HORIZONTAL', 1, 1, 1, 0, 1, 1, 1, 1);
	CPAPI.SetGradient(self.LineTopRight, 'HORIZONTAL', 1, 1, 1, 1, 1, 1, 1, 0);
	CPAPI.SetGradient(self.LineBottomRight, 'HORIZONTAL', 1, 1, 1, 1, 1, 1, 1, 0);
end

function CPConfigHeaderMixin:SetText(...)
	self.Text:SetText(...)
end