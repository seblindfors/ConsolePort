local _, db = ...
----------------------------------
-- Hint mixin
----------------------------------
ConsolePortHintMixin = {}

function ConsolePortHintMixin:OnLoad()
	self.bar = self:GetParent()
	self.Text:SetShadowOffset(2, -2)
end

function ConsolePortHintMixin:OnShow()
	self.isActive = true
	db.UIFrameFadeIn(self, 0.2, 0, 1)
end

function ConsolePortHintMixin:OnHide()
	self.isActive = false
	self:SetData(nil, nil)
end

function ConsolePortHintMixin:UpdateParentWidth()
	if self.bar then
		self.bar:Update()
	end
end

function ConsolePortHintMixin:Enable()
	self.Icon:SetVertexColor(1, 1, 1)
	self.Text:SetVertexColor(1, 1, 1)
end

function ConsolePortHintMixin:Disable()
	self.Icon:SetVertexColor(0.5, 0.5, 0.5)
	self.Text:SetVertexColor(0.5, 0.5, 0.5)
end

function ConsolePortHintMixin:GetText()
	return self.Text:GetText()
end

function ConsolePortHintMixin:SetData(icon, text)
	self.Icon:SetTexture(db.TEXTURE[icon])
	self.Text:SetText(text)
	self:SetWidth(self.Text:GetStringWidth() + 64)
	self:UpdateParentWidth()
end

----------------------------------
-- HintBar mixin
----------------------------------
ConsolePortHintBarMixin = {}

function ConsolePortHintBarMixin:OnLoad()
	self.Hints = {}
	self:SetParent(UIParent)
	self:SetIgnoreParentAlpha(true)
end

function ConsolePortHintBarMixin:AdjustWidth(newWidth)
	self:SetScript('OnUpdate', function(self)
		local width = self:GetWidth()
		local diff = newWidth - width
		if abs(newWidth - width) < 1 then
			self:SetWidth(newWidth)
			self:SetScript('OnUpdate', nil)
		else
			self:SetWidth(width + ( diff / 4 ) )
		end
	end)
end

function ConsolePortHintBarMixin:Update()
	local width, previousHint = 0
	for _, hint in pairs(self.Hints) do
		if previousHint then
			hint:SetPoint('LEFT', previousHint.Text, 'RIGHT', 16, 0)
		else
			hint:SetPoint('LEFT', self, 'LEFT', 0, 0)
		end
		if hint:IsVisible() then
			width = width + hint:GetWidth()
			previousHint = hint
		end
	end
	self:AdjustWidth(width)
end

function ConsolePortHintBarMixin:Reset()
	local hints = self.Hints
	for key in ConsolePort:IterateUIControlKeys() do
		local hint = hints[key]
		if hint then
			hint:Hide()
		end
	end
end

function ConsolePortHintBarMixin:GetHintFromPool(key, showBar)
	local hints = self.Hints
	local hint = hints[key]
	if not hint then
		hint = CreateFrame('Frame', '$parentHint'..key, self, 'CPUIHintTemplate')
		hint:SetID(key)
		self.Hints[key] = hint
	end
	hint:Show()
	if showBar then
		self:Show()
	end
	return hint
end

function ConsolePortHintBarMixin:GetActiveHintForKey(key)
	local hint = self.Hints[key]
	return hint and hint.isActive and hint
end

function ConsolePortHintBarMixin:AddHint(key, text)
	local binding = ConsolePort:GetUIControlBinding(key)
	if binding then
		local hint = self:GetHintFromPool(key)
		hint:SetData(binding, text)
		hint:Enable()
		return hint
	end
end