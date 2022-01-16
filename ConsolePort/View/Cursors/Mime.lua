CPCursorMimeMixin = {};

-- External
---------------------------------------------------------------
function CPCursorMimeMixin:OnLoad()
	self.Parent   = self:GetParent()
	self.Fonts    = CreateFontStringPool(self, 'OVERLAY')
	self.Textures = CreateTexturePool(self, 'OVERLAY')
end

function CPCursorMimeMixin:SetNode(node)
	self:MimeRegions(node:GetRegions())
	self:ClearAllPoints()
	self:SetSize(node:GetSize())
	self:SetScale(node:GetEffectiveScale() / self.Parent:GetEffectiveScale())
	self:Show()
	for i=1, node:GetNumPoints() do
		self:SetPoint(node:GetPoint(i))
	end
	self.Scale:Stop()
	self.Scale:Play()
end

function CPCursorMimeMixin:Clear()
	self.Fonts:ReleaseAll()
	self.Textures:ReleaseAll()
	self:Hide()
end

-- Internal
---------------------------------------------------------------
function CPCursorMimeMixin:SetFontString(region)
	if region:IsShown() and region:GetFont() then
		local obj = self.Fonts:Acquire()
		obj:SetFont(obj.GetFont(region))
		obj:SetText(obj.GetText(region))
		obj:SetTextColor(obj.GetTextColor(region))
		obj:SetJustifyH(obj.GetJustifyH(region))
		obj:SetJustifyV(obj.GetJustifyV(region))
		obj:SetSize(obj.GetSize(region))
		for i=1, obj.GetNumPoints(region) do
			obj:SetPoint(obj.GetPoint(region, i))
		end
		obj:Show()
	end
end

function CPCursorMimeMixin:SetTexture(region)
	if region:IsShown() then
		local obj = self.Textures:Acquire()
		if obj.GetAtlas(region) then
			obj:SetAtlas(obj.GetAtlas(region))
		else
			local texture = obj.GetTexture(region)
			-- DEPRECATED: returns File Data ID <num> in 9.0
			if (type(texture) == 'string') and texture:find('^[Cc]olor-') then
				obj:SetColorTexture(CPAPI.Hex2RGB(texture:sub(7), true))
			else
				obj:SetTexture(texture)
			end
		end
		obj:SetBlendMode(obj.GetBlendMode(region))
		obj:SetTexCoord(obj.GetTexCoord(region))
		obj:SetVertexColor(obj.GetVertexColor(region))
		obj:SetSize(obj.GetSize(region))
		for i=1, obj.GetNumPoints(region) do
			obj:SetPoint(obj.GetPoint(region, i))
		end
		obj:Show()
	end
end

function CPCursorMimeMixin:MimeRegions(region, ...)
	if region then
		if (region:GetDrawLayer() == 'HIGHLIGHT') then
			if (region:GetObjectType() == 'Texture') then
				self:SetTexture(region)
			elseif (region:GetObjectType() == 'FontString') then
				self:SetFontString(region)
			end
		end
		self:MimeRegions(...)
	end
end