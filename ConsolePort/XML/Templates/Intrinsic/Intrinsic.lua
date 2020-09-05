ConsolePortPieMenuMixin = {};

function ConsolePortPieMenuMixin:OnPreLoad()
	self.Registry = {};
	self.VertexColor = C_ClassColor.GetClassColor(select(2, UnitClass('player')))
	self.VertexValid = CreateColor(1, .81, 0, 1)
end

function ConsolePortPieMenuMixin:CreateFramePool(template, mixin, resetterFunc)
	assert(not self.FramePool, 'Frame pool already exists.')
	self.FramePool = CreateFramePool('CheckButton', self, template, resetterFunc)
	self.FramePoolMixin = mixin;
end

function ConsolePortPieMenuMixin:Acquire(index)
	local widget, newObj = self.FramePool:Acquire()
	if newObj then
		Mixin(widget, self.FramePoolMixin)
	end
	self.Registry[index] = widget;
	return widget, newObj;
end

function ConsolePortPieMenuMixin:ReleaseAll()
	self.FramePool:ReleaseAll()
end

function ConsolePortPieMenuMixin:OnPostHide()
	self.focusIndex = nil;
	self.Arrow:SetAlpha(0)
	self.BG:SetVertexColor(1, 1, 1, 0)
end

function ConsolePortPieMenuMixin:SetFocusByIndex(index)
	local old = self.focusIndex ~= index and self.focusIndex;
	self.focusIndex = index;

	local oldObj = old and self.Registry[old];
	if ( oldObj ) then
		oldObj:OnClear()
	end

	local newObj = self.Registry[index];
	if ( newObj ) then
		newObj:OnFocus(oldObj)
	end
	return newObj
end

function ConsolePortPieMenuMixin:SetFocusByWidget(widget)
	for i, obj in pairs(self.Registry) do
		if ( obj == widget ) then
			return self:SetFocusByIndex(i)
		end
	end
end

function ConsolePortPieMenuMixin:ReflectStickPosition(x, y, len, isValid)
	local color = isValid and self.VertexValid or self.VertexColor;
	self.Arrow:SetVertexColor(color:GetRGBA())

	local r, g, b = CPAPI.InvertColor(self.VertexColor:GetRGBA())
	self.BG:SetGradientAlpha(self:GetMixGradient(r * len, g * len, b * len, len))
	self.Arrow:SetAlpha(len + len/1.5)

	local rotation = self:GetRotation(x, y)
	self.BG:SetRotation(rotation)
	self.Arrow:SetRotation(rotation)
end

function ConsolePortPieMenuMixin:GetMixGradient(...)
	return CPAPI.GetMixColorGradient('VERTICAL', ...)
end

function ConsolePortPieMenuMixin:GetFadeGradient(...)
	return 'VERTICAL', 1, 1, 1, 0, ...;
end

function ConsolePortPieMenuMixin:GetRotation(x, y)
	return -math.atan2(x, y)
end