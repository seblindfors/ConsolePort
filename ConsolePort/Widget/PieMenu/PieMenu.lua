CPPieMenuMixin = CreateFromMixins(CPFocusPoolMixin);

function CPPieMenuMixin:OnPreLoad()
	CPFocusPoolMixin.OnPreLoad(self)
	self.VertexColor = C_ClassColor.GetClassColor(select(2, UnitClass('player')))
	self.VertexValid = CreateColor(1, .81, 0, 1)
end

function CPPieMenuMixin:CreateFramePool(template, mixin, resetterFunc)
	CPFocusPoolMixin.CreateFramePool(self, 'CheckButton', template, mixin, resetterFunc)
end

function CPPieMenuMixin:OnPostHide()
	CPFocusPoolMixin.OnPostHide(self)
	self.Arrow:SetAlpha(0)
	self.BG:SetVertexColor(1, 1, 1, 0)
end

function CPPieMenuMixin:SetFocusByIndex(index)
	local newObj, oldObj = CPFocusPoolMixin.SetFocusByIndex(self, index)
	if ( oldObj ) then
		oldObj:OnClear()
	end
	if ( newObj ) then
		newObj:OnFocus(oldObj)
	end
	return newObj
end

function CPPieMenuMixin:ReflectStickPosition(x, y, len, isValid)
	local color = isValid and self.VertexValid or self.VertexColor;
	self.Arrow:SetVertexColor(color:GetRGBA())

	local r, g, b = CPAPI.InvertColor(self.VertexColor:GetRGBA())
	self.BG:SetGradientAlpha(self:GetMixGradient(r * len, g * len, b * len, len))
	self.Arrow:SetAlpha(len + len/1.5)

	local rotation = self:GetRotation(x, y)
	self.BG:SetRotation(rotation)
	self.Arrow:SetRotation(rotation)
end

function CPPieMenuMixin:GetMixGradient(...)
	return CPAPI.GetMixColorGradient('VERTICAL', ...)
end

function CPPieMenuMixin:GetFadeGradient(...)
	return 'VERTICAL', 1, 1, 1, 0, ...;
end

function CPPieMenuMixin:GetRotation(x, y)
	return -math.atan2(x, y)
end