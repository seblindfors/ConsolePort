CPPieMenuMixin = CreateFromMixins(CPFocusPoolMixin, CPGradientMixin);

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
	self.BG:SetGradientAlpha(self:GetMixGradient(r * len, g * len, b * len, len))
	self.Arrow:SetAlpha(len + len/1.5)

	local rotation = self:GetRotation(x, y)
	self.BG:SetRotation(rotation)
	self.Arrow:SetRotation(rotation)
end

function CPPieMenuMixin:GetRotation(x, y)
	return -math.atan2(x, y)
end