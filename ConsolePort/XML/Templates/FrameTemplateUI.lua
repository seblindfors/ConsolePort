ConsolePortFrameTemplateMixin = {}
local Frame = ConsolePortFrameTemplateMixin
local UIPath = [[Interface\AddOns\ConsolePort\%s]]

function Frame:SetIcon(texturePath)
	self.Portrait:SetMask([[Interface\Minimap\UI-Minimap-Background]])
	return self.Portrait:SetTexture(texturePath)
end

function Frame:SetUnitPortrait(unit)
	if type(unit) == 'string' then
		self.Portrait:SetMask([[Interface\Minimap\UI-Minimap-Background]])
		self:SetTitle(UnitName('npc'))
		return SetPortraitTexture(self.Portrait, unit)
	end
end

function Frame:SetTitle(title)
	self.Title:SetText(title)
end

function Frame:SetSubtitle(subtitle)

end

function Frame:HidePortrait()
	self.TopLeftCorner:SetTexture(UIPath:format([[Textures\Window\Edges\Topright]]))
	self.TopLeftCorner:SetTexCoord(1, 0, 0, 1)
	self.Title:SetPoint('TOPLEFT', 20, -18)
	self.Banner:SetPoint('TOPLEFT', 0, -10)
	self.Portrait:Hide()
end

function Frame:ShowPortrait()
	self.TopLeftCorner:SetTexture(UIPath:format([[Textures\Window\Edges\Topleft]]))
	self.TopLeftCorner:SetTexCoord(0, 1, 0, 1)
	self.Title:SetPoint('TOPLEFT', 70, -18)
	self.Banner:SetPoint('TOPLEFT', 20, -10)
	self.Portrait:Show()
end