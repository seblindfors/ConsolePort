local _, env = ...;
---------------------------------------------------------------
local CommonWidget = setmetatable({}, GetFrameMetatable());
env.CommonWidgetMixin = CommonWidget;
---------------------------------------------------------------
local CommonHandlers = {
	height = CommonWidget.SetHeight;
	level  = CommonWidget.SetFrameLevel;
	point  = CommonWidget.ClearAllPoints;
	scale  = CommonWidget.SetScale;
	strata = CommonWidget.SetFrameStrata;
	width  = CommonWidget.SetWidth;
};

function CommonWidget:SetCommonProps(props)
	for key, handler in pairs(CommonHandlers) do
		if ( props[key] ~= nil ) then
			handler(self, props[key]);
		end
	end
	if props.pos then
		local info = props.pos;
		self:ClearAllPoints()
		self:SetAttribute('offsetscale', info.offsetscale)
		self:SetPoint(info.point, UIParent, info.relPoint or info.point, info.x, info.y)
		if info.strata then
			self:SetFrameStrata(info.strata)
		end
		if info.level then
			self:SetFrameLevel(info.level)
		end
	end
	self.props = props;
end

---------------------------------------------------------------
local DynamicWidget = {};
env.DynamicWidgetMixin = DynamicWidget;
---------------------------------------------------------------
local NESTING_LEVEL = 1; -- How deep to register callbacks

function DynamicWidget:SetDynamicCallbacks(props, level)
	env:RegisterCallback(tostring(props), self.OnPropsChanged, self);
	if level == 0 then return end;
	for _, datapoint in pairs(props) do
		if type(datapoint) == 'table' then
			self:SetDynamicCallbacks(datapoint, level - 1)
		end
	end
end

function DynamicWidget:ClearDynamicCallbacks(props, level)
	env:UnregisterCallback(tostring(props), self);
	if level == 0 then return end;
	for _, datapoint in pairs(props) do
		if type(datapoint) == 'table' then
			self:ClearDynamicCallbacks(datapoint, level - 1)
		end
	end
end

function DynamicWidget:SetDynamicProps(props)
	if self.props then
		self:ClearDynamicCallbacks(self.props, self:GetPropNestingLevel())
		self.props = nil;
	end
	if self.SetCommonProps then
		self:SetCommonProps(props)
	end
	self.props = props;
	self:SetDynamicCallbacks(props, self:GetPropNestingLevel())
end

function DynamicWidget:OnPropsChanged(key, value)
	-- Implement in child
	CPAPI.Log('Config changed '..tostring(key)..' to '..tostring(value)..' but it was not handled.');
end

function DynamicWidget:GetPropNestingLevel()
	return NESTING_LEVEL;
end

---------------------------------------------------------------
local MovableWidget = {OnPropsUpdated = DynamicWidget.OnPropsChanged};
env.MovableWidgetMixin = MovableWidget;
---------------------------------------------------------------

function MovableWidget:OnPropsChanged(key, ...)
	if ( key == 'OnMoveStart' ) then
		return env:TriggerEvent('OnMoveFrame', self:GetMoveTarget(), ..., self:GetSnapSize())
	end
	if ( key == 'OnHighlight' ) then
		return env:TriggerEvent('OnHighlightFrame', self:GetMoveTarget(), ...)
	end
	return self:OnPropsUpdated(key, ...);
end

function MovableWidget:GetMoveTarget()
	return self; -- Implement in child
end

function MovableWidget:GetSnapSize()
	return self.snapToPixels or 1; -- Implement in child
end

---------------------------------------------------------------
local AnimatedWidgetMixin = { FadeIn = env.db.Alpha.FadeIn };
env.AnimatedWidgetMixin = AnimatedWidgetMixin;
---------------------------------------------------------------

local Clamp, tonumber = Clamp, tonumber;
function AnimatedWidgetMixin:OnAttributeChanged(attribute, value)
	if ( attribute == 'alpha' ) then
		local time = (self.props.transition or 50) * 0.001;
		local target = (tonumber(value) or 100) * 0.01;
		self:FadeIn(time, self:GetAlpha(), Clamp(target, 0, 1))
	elseif ( attribute == 'scale' ) then
		local scale = (tonumber(value) or 100) * 0.01;
		if self.useOffsetScale then
			local relScale = 1 / scale;
			local point, relFrame, relPoint = self:GetPoint()
			getmetatable(self).__index.SetPoint(self,
				point, relFrame, relPoint,
				self.x * relScale, self.y * relScale
			);
		end
		self:SetScale(scale)
	elseif ( attribute == 'offsetscale' ) then
		self.useOffsetScale = value;
	end
end

function AnimatedWidgetMixin:OnDriverChanged()
	local driver = self.props.opacity;
	if driver then
		RegisterAttributeDriver(self, 'alpha', env.ConvertDriver(driver))
	end

	driver = self.props.rescale;
	if driver then
		RegisterAttributeDriver(self, 'scale', env.ConvertDriver(driver))
	end
end

function AnimatedWidgetMixin:SetPoint(point, relFrame, relPoint, x, y)
	self.x, self.y = x, y;
	getmetatable(self).__index.SetPoint(self, point, relFrame, relPoint, x, y)
end

---------------------------------------------------------------
env.ConfigurableWidgetMixin = CreateFromMixins(
	CommonWidget,
	DynamicWidget,
	MovableWidget
);
---------------------------------------------------------------