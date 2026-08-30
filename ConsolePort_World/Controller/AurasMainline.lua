local env, db = CPAPI.GetEnv(...);
---------------------------------------------------------------
local BUFF_CANCEL_ROW_INDEX = env.QMenuID();
local DEBUFF_INFO_ROW_INDEX = env.QMenuID();

local WRAP_AFTER, SLOT_OFFSET, ROW_HEIGHT, MAX_SLOTS = 10, 52, 48, 40;
local UNKNOWN_ICON = [[Interface\Icons\INV_Misc_QuestionMark]];
local IsSecret, InCombatLockdown = CPAPI.IsSecret, InCombatLockdown;
local GetAuraDataByIndex = C_UnitAuras.GetAuraDataByIndex;
local GetDisplayCount    = C_UnitAuras.GetAuraApplicationDisplayCount;
local GetAuraDuration    = C_UnitAuras.GetAuraDuration;

---------------------------------------------------------------
local Aura = {};
---------------------------------------------------------------

function Aura:OnLoad()
	local color = self:GetParent():IsHelpful() and NORMAL_FONT_COLOR or RED_FONT_COLOR;
	self.cooldown:SetReverse(true)
	self.cooldown:SetHideCountdownNumbers(true)
	self.cooldown:SetDrawEdge(false)
	self.cooldown:SetSwipeColor(color:GetRGBA())
	self:SetAttribute(CPAPI.ActionPressAndHold, true)
	self:SetAttribute(CPAPI.ActionTypeRelease..'2', 'cancelaura')
	self:SetAttribute('index', self:GetID())
	self:SetAttribute('filter', self:GetFilter())
end

function Aura:GetFilter()
	return self:GetParent():GetAttribute('filter');
end

function Aura:GetData()
	-- Accessing a secret aura throws while tainted; the data can also
	-- come back as a plain table with secret fields, which the aura
	-- instance APIs then refuse as arguments.
	local ok, data = pcall(GetAuraDataByIndex, 'player', self:GetID(), self:GetFilter())
	if not ok or IsSecret(data) then
		return nil, true;
	end
	return data, data and IsSecret(data.auraInstanceID);
end

function Aura:Update()
	local data, secret = self:GetData()
	if secret then
		self:Show()
		if not ( data and pcall(self.SetIcon, self, data.icon) ) then
			self:SetIcon(UNKNOWN_ICON)
		end
		self:SetCount(nil, true, true)
		CooldownFrame_Clear(self.cooldown)
		return
	end
	if not data then
		return self:Hide()
	end
	self:Show()
	self:SetIcon(data.icon)
	self:SetCount(GetDisplayCount('player', data.auraInstanceID), true, true)
	local duration = GetAuraDuration('player', data.auraInstanceID)
	if duration then
		self.cooldown:SetCooldownFromDurationObject(duration)
	else
		CooldownFrame_Clear(self.cooldown)
	end
	if GameTooltip:IsOwned(self) then
		self:OnEnter()
	end
end

function Aura:OnHide()
	if GameTooltip:IsOwned(self) then
		GameTooltip:Hide()
	end
end

function Aura:OnEnter()
	GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMRIGHT')
	local data, secret = self:GetData()
	if not ( data or secret ) then
		return GameTooltip:Hide()
	end
	if not pcall(GameTooltip.SetUnitAura, GameTooltip, 'player', self:GetID(), self:GetFilter()) then
		GameTooltip:SetText(UNKNOWN)
	end
	if self:GetParent():IsHelpful() then
		local text = env:GetTooltipPromptForClick('RightButton', CANCEL)
		if text then
			GameTooltip:AddLine(text, 1, 1, 1)
		end
	end
	GameTooltip:Show()
	self:LockHighlight()
end

function Aura:OnLeave()
	GameTooltip:Hide()
	self:UnlockHighlight()
end

---------------------------------------------------------------
local Row = {};
---------------------------------------------------------------
CPAPI.Props(Row)
	.Prop('Title')
	.Bool('Helpful', true)
	.Bool('Enabled', true)

function Row:OnLoad()
	self.slots = {};
	self:RegisterUnitEvent('UNIT_AURA', 'player')
	self:RegisterEvent('PLAYER_REGEN_ENABLED')
	self:HookScript('OnEvent', self.Update)
	self:HookScript('OnShow', self.Update)
end

function Row:EnsureSlots(numSlots)
	for i = #self.slots + 1, numSlots do
		local slot = CreateFrame('Button', '$parentAura'..i, self, 'CPQMenuStaticAura')
		slot:SetID(i)
		slot:SetPoint('TOPLEFT', ((i - 1) % WRAP_AFTER) * SLOT_OFFSET, -floor((i - 1) / WRAP_AFTER) * SLOT_OFFSET)
		CPAPI.Specialize(slot, Aura)
		slot:SetScript('OnEnter', slot.OnEnter)
		slot:SetScript('OnLeave', slot.OnLeave)
		slot:HookScript('OnHide', slot.OnHide)
		slot:Hide()
		self.slots[i] = slot;
	end
end

function Row:GetNumAuras()
	local filter, count = self:GetAttribute('filter'), 0;
	for i = 1, MAX_SLOTS do
		local ok, data = pcall(GetAuraDataByIndex, 'player', i, filter)
		if ( ok and not data ) then break end;
		count = i;
	end
	return count;
end

function Row:UpdateSize(numSlots)
	-- A frame without explicit width resolves to a nil rect,
	-- dangling every row anchored below it.
	local numRows = math.max(1, math.ceil(numSlots / WRAP_AFTER))
	local numCols = Clamp(numSlots, 1, WRAP_AFTER)
	self:SetSize(
		(numCols - 1) * SLOT_OFFSET + ROW_HEIGHT,
		ROW_HEIGHT + (numRows - 1) * SLOT_OFFSET
	);
end

function Row:Update()
	if InCombatLockdown() then return end;
	local numAuras = self:GetNumAuras()
	self:EnsureSlots(numAuras)
	for i, slot in ipairs(self.slots) do
		if ( i > numAuras ) then
			slot:Hide()
		else
			slot:Update()
		end
	end
	self:UpdateSize(numAuras)
	self:SetAttribute('numAuras', numAuras)
	self:SetShown(self:IsEnabled() and numAuras > 0)
	self:GetParent():Run([[ self::UpdateLayout() ]])
end

function Row:UpdateState(enabled)
	self:SetEnabled(enabled)
	if enabled then
		RegisterStateDriver(self, 'visible', '[combat] nil; true')
		self:SetAttribute('_onstate-visible', [[
			if newstate and (self:GetAttribute('numAuras') or 0) > 0 then
				self:Show()
			else
				self:Hide()
			end
			self:GetParent():RunAttribute('UpdateLayout')
		]])
	else
		UnregisterStateDriver(self, 'visible')
		self:Hide()
	end
end

---------------------------------------------------------------
-- Initializer
---------------------------------------------------------------
env:RegisterSafeCallback('QMenu.Loaded', function(QMenu)
	local function CreateRow(index, filter, title)
		local frame = CreateFrame('Frame', '$parentAuras'..index, QMenu, 'QMenuRow, SecureHandlerStateTemplate')
		frame:SetAttribute('filter', filter)
		CPAPI.Specialize(frame, Row)
		frame:SetHelpful(filter == 'HELPFUL')
		frame:SetTitle(title)
		QMenu:AddFrame(frame, index)
		return frame;
	end

	local Helpful = CreateRow(BUFF_CANCEL_ROW_INDEX, 'HELPFUL', BUFFOPTIONS_LABEL);
	local Harmful = CreateRow(DEBUFF_INFO_ROW_INDEX, 'HARMFUL', BUFFOPTIONS_LABEL);

	local function UpdateDecorations()
		if InCombatLockdown() then return end;
		Helpful:SetAttribute('paddingBottom', Harmful:IsShown() and 8 or 20)
		Harmful:SetTitle(Helpful:IsShown() and '' or BUFFOPTIONS_LABEL)
	end

	for _, row in ipairs({ Helpful, Harmful }) do
		row:HookScript('OnShow', UpdateDecorations)
		row:HookScript('OnHide', UpdateDecorations)
	end

	function Helpful:OnVariablesChanged()
		self:UpdateState(db('QMenuCollectionBuffs'))
		self:Update()
	end

	function Harmful:OnVariablesChanged()
		self:UpdateState(db('QMenuCollectionDebuffs'))
		self:Update()
	end

	db:RegisterSafeCallbacks(Helpful.OnVariablesChanged, Helpful,
		'Settings/QMenuCollectionBuffs',
		'Settings/QMenuCollectionDebuffs'
	);
	db:RegisterSafeCallbacks(Harmful.OnVariablesChanged, Harmful,
		'Settings/QMenuCollectionBuffs',
		'Settings/QMenuCollectionDebuffs'
	);

	Helpful:OnVariablesChanged();
	Harmful:OnVariablesChanged();
	UpdateDecorations();
end)
