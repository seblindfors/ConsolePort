if CPAPI.IsRetailVersion then return end;
---------------------------------------------------------------
-- Target frame auras (Classic)
---------------------------------------------------------------
local Ring, Container, Aura = ConsolePortTargetRing, {}, {};
local GetAuraDataByIndex = C_UnitAuras.GetAuraDataByIndex;
local DEBUFF_BORDER = [[Interface\Buttons\UI-Debuff-Overlays]];

function Aura:OnLoad(size)
	self:SetSize(size, size)
	self.Icon = self:CreateTexture(nil, 'ARTWORK')
	self.Icon:SetAllPoints()
	self.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	self.Cooldown = CreateFrame('Cooldown', nil, self, 'CooldownFrameTemplate')
	self.Cooldown:SetAllPoints()
	self.Cooldown:SetReverse(true)
	self.Cooldown:SetDrawEdge(false)
	self.Cooldown:SetHideCountdownNumbers(true)
	self.Count = self.Cooldown:CreateFontString(nil, 'OVERLAY', 'NumberFontNormalSmall')
	self.Count:SetPoint('BOTTOMRIGHT', 2, 0)
	self.Border = self:CreateTexture(nil, 'OVERLAY')
	self.Border:SetPoint('TOPLEFT', -1, 1)
	self.Border:SetPoint('BOTTOMRIGHT', 1, -1)
	self.Border:SetTexture(DEBUFF_BORDER)
	self.Border:SetTexCoord(0.296875, 0.5703125, 0, 0.515625)
end

function Aura:SetData(data, isHarmful)
	self.Icon:SetTexture(data.icon)
	self.Count:SetText(data.applications > 1 and data.applications or '')
	if ( data.duration > 0 ) then
		CooldownFrame_Set(self.Cooldown, data.expirationTime - data.duration, data.duration, true)
	else
		CooldownFrame_Clear(self.Cooldown)
	end
	self.Border:SetShown(isHarmful)
	if isHarmful then
		local color = DebuffTypeColor[data.dispelName or 'none'] or DebuffTypeColor.none;
		self.Border:SetVertexColor(color.r, color.g, color.b)
	end
	self:Show()
end

function Container:OnLoad(filter, size, gap, max)
	self.filter, self.size, self.gap, self.max = filter, size, gap, max;
	self.isHarmful = filter == 'HARMFUL';
	self.buttons = {};
	self:SetSize(1, size)
	self:SetScript('OnEvent', self.Update)
end

function Container:AnchorButton(button, index)
	local offset = (index - 1) * (self.size + self.gap);
	button:ClearAllPoints()
	if self.mirrored then
		button:SetPoint('RIGHT', -offset, 0)
	else
		button:SetPoint('LEFT', offset, 0)
	end
end

function Container:GetButton(index)
	local button = self.buttons[index];
	if not button then
		button = Mixin(CreateFrame('Frame', nil, self), Aura)
		button:OnLoad(self.size)
		self:AnchorButton(button, index)
		self.buttons[index] = button;
	end
	return button;
end

function Container:SetMirrored(mirrored)
	self.mirrored = mirrored;
	for index, button in ipairs(self.buttons) do
		self:AnchorButton(button, index)
	end
end

function Container:SetUnit(unit)
	self.unit = unit;
	if self.enabled then
		self:RegisterUnitEvent('UNIT_AURA', unit)
		self:Update()
	end
end

function Container:SetEnabled(enabled)
	self.enabled = enabled;
	if ( enabled and self.unit ) then
		self:RegisterUnitEvent('UNIT_AURA', self.unit)
		self:Update()
	else
		self:UnregisterAllEvents()
	end
end

function Container:Update()
	local shown = 0;
	for i = 1, self.max do
		local data = GetAuraDataByIndex(self.unit, i, self.filter)
		if not data then break end;
		shown = shown + 1;
		self:GetButton(shown):SetData(data, self.isHarmful)
	end
	for i = shown + 1, #self.buttons do
		self.buttons[i]:Hide()
	end
	self:SetWidth(math.max(shown * (self.size + self.gap) - self.gap, 1))
end

function Ring.CreateAuraContainer(parent, filter, size, gap, max)
	local container = Mixin(CreateFrame('Frame', nil, parent), Container)
	container:OnLoad(filter, size, gap, max)
	return container;
end

function Ring.SetAuraContainerMirrored(container, mirrored)
	container:SetMirrored(mirrored)
end
