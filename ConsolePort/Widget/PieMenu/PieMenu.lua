CPPieMenuMixin = CreateFromMixins(CPFocusPoolMixin, CPGradientMixin);
local Clamp, atan2 = Clamp, math.atan2;

function CPPieMenuMixin:OnPreLoad()
	CPFocusPoolMixin.OnLoad(self)
	CPGradientMixin.OnLoad(self)
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
	local color = isValid and self.VertexColor or self.VertexValid;
	self.Arrow:SetVertexColor(color:GetRGBA())

	local r, g, b = self.VertexColor:GetRGBA()
	CPAPI.SetGradient(self.BG, self:GetMixGradient(r * len, g * len, b * len, len))
	self.Arrow:SetAlpha(Clamp(len + len/1.5, 0, 1))

	local rotation = self:GetRotation(x, y)
	self.BG:SetRotation(rotation)
	self.Arrow:SetRotation(rotation)
	return rotation;
end

function CPPieMenuMixin:GetRotation(x, y)
	return -atan2(x, y)
end