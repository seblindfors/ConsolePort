local _, L = ...
local Header = {}
local r, g, b = L.db.Atlas.GetNormalizedCC()
L.Header = Header

function Header:OnLoad()
	self:SetNormalTexture(self.NormalTexture)
	self:SetPushedTexture(self.PushedTexture)

	self.PushedTexture:SetVertexColor(r, g, b)

	self:SetSize(180, 55)
end