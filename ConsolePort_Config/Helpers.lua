local _, env = ...;
---------------------------------------------------------------
-- Scale things dynamically
---------------------------------------------------------------
local ScaleToContentMixin = {};
env.ScaleToContentMixin = ScaleToContentMixin;

function ScaleToContentMixin:SetMeasurementOrigin(top, content, width, offset)
	self.fixedWidth = width;
	self.fixedOffset = offset;
	self.topElement = top;
	self.contentElement = content;
end

function ScaleToContentMixin:CalcContentBoundary()
	local origT = self.topElement:GetTop() or 0
	local top, bottom = -math.huge, math.huge
	for i, child in ipairs({self.contentElement:GetChildren()}) do
		if child:IsShown() then
			local childTop, childBottom = child:GetTop(), child:GetBottom()
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

function ScaleToContentMixin:SetHeight(height)
	self:SetHitRectInsets(0, 0, 0, 0)
	getmetatable(self).__index.SetHeight(self, height)
end

function ScaleToContentMixin:ScaleToContent()
	self:SetWidth(self.fixedWidth)
	local height, hitBoxOffset = self:CalcContentBoundary()
	self:SetHeight(height)
	self:SetHitRectInsets(0, 0, 0, hitBoxOffset)
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

function FlexibleMixin:SetFlexibleElement(element, measure)
	self.flexElement = element;
	self.flexMeasure = measure or element;
end

function FlexibleMixin:IsElementFlexed()
	return self.isFlexed;
end

function FlexibleMixin:ToggleFlex(enabled)
	self.flexTarget = enabled and self.flexMeasure:GetWidth() or 0.01;
	self.isFlexed = enabled;
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
	self.Center:SetGradientAlpha('VERTICAL', r, g, b, 0, r, g, b, 1)
end