local env, db = CPAPI.GetEnv(...);
---------------------------------------------------------------
local BUFF_CANCEL_ROW_INDEX = env.QMenuID();
local DEBUFF_INFO_ROW_INDEX = env.QMenuID();

if CPAPI.IsRetailVersion then
	local WRAP_AFTER, SLOT_OFFSET, ROW_HEIGHT = 10, 52, 48;
	local UNKNOWN_ICON = [[Interface\Icons\INV_Misc_QuestionMark]];
	local IsSecret, InCombatLockdown = CPAPI.IsSecret, InCombatLockdown;
	local GetAuraDataByIndex = C_UnitAuras.GetAuraDataByIndex;
	local GetDisplayCount    = C_UnitAuras.GetAuraApplicationDisplayCount;
	local GetAuraDuration    = C_UnitAuras.GetAuraDuration;

	-----------------------------------------------------------
	local Aura = {};
	-----------------------------------------------------------

	function Aura:OnLoad()
		self.cooldown:SetReverse(true)
		self.cooldown:SetHideCountdownNumbers(true)
		self.cooldown:SetDrawEdge(false)
		self:SetAttribute(CPAPI.ActionPressAndHold, true)
		self:SetAttribute(CPAPI.ActionTypeRelease..'2', 'cancelaura')
		self:SetAttribute('index', self:GetID())
		self:SetAttribute('filter', self:GetFilter())
	end

	function Aura:GetFilter()
		return self:GetParent():GetAttribute('filter');
	end

	function Aura:GetData()
		-- Accessing a secret aura throws while tainted; treat a
		-- throw and a secret return value the same.
		local ok, data = pcall(GetAuraDataByIndex, 'player', self:GetID(), self:GetFilter())
		if not ok or IsSecret(data) then
			return nil, true;
		end
		return data, false;
	end

	function Aura:Update()
		local data, secret = self:GetData()
		if secret then
			-- Cooldown keeps ticking from the last known duration object.
			if self:IsShown() then
				self:SetIcon(UNKNOWN_ICON)
				self:SetCount(nil, true, true)
			end
			return
		end
		local canToggle = not InCombatLockdown()
		if not data then
			if canToggle then self:Hide() end
			return
		end
		if canToggle then self:Show() end
		self:SetIcon(data.icon)
		self:SetCount(GetDisplayCount('player', data.auraInstanceID), true, true)
		local duration = GetAuraDuration('player', data.auraInstanceID)
		if duration then
			self.cooldown:SetCooldownFromDurationObject(duration)
		else
			CooldownFrame_Clear(self.cooldown)
		end
	end

	function Aura:OnEnter()
		GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMRIGHT')
		local data, secret = self:GetData()
		if secret then
			GameTooltip:SetText(UNKNOWN)
		elseif data then
			if not pcall(GameTooltip.SetUnitAura, GameTooltip, 'player', self:GetID(), self:GetFilter()) then
				GameTooltip:SetText(UNKNOWN)
			end
		else
			return GameTooltip:Hide()
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

	-----------------------------------------------------------
	local Row = {};
	-----------------------------------------------------------
	CPAPI.Props(Row)
		.Prop('Title')
		.Bool('Helpful', true)

	function Row:OnLoad()
		self.slots = {};
		self:RegisterUnitEvent('UNIT_AURA', 'player')
		self:HookScript('OnEvent', self.Update)
		self:HookScript('OnShow', self.Update)
	end

	function Row:CreateSlots(numSlots)
		for i = 1, numSlots do
			local slot = CreateFrame('Button', '$parentAura'..i, self, 'CPQMenuStaticAura')
			slot:SetID(i)
			slot:SetPoint('TOPLEFT', ((i - 1) % WRAP_AFTER) * SLOT_OFFSET, -floor((i - 1) / WRAP_AFTER) * SLOT_OFFSET)
			CPAPI.Specialize(slot, Aura)
			slot:SetScript('OnEnter', slot.OnEnter)
			slot:SetScript('OnLeave', slot.OnLeave)
			slot:Hide()
			self.slots[i] = slot;
		end
	end

	function Row:GetNumSlots()
		return self:IsHelpful() and db('QMenuNumBuffs') or db('QMenuNumDebuffs');
	end

	function Row:UpdateSize()
		-- A frame without explicit width resolves to a nil rect,
		-- dangling every row anchored below it.
		local numSlots = self:GetNumSlots()
		local numRows  = math.ceil(numSlots / WRAP_AFTER)
		self:SetSize(
			(math.min(numSlots, WRAP_AFTER) - 1) * SLOT_OFFSET + ROW_HEIGHT,
			ROW_HEIGHT + (numRows - 1) * SLOT_OFFSET
		);
	end

	function Row:Update()
		local numSlots = self:GetNumSlots()
		local canToggle = not InCombatLockdown()
		for i, slot in ipairs(self.slots) do
			if ( i > numSlots ) then
				if canToggle then slot:Hide() end
			else
				slot:Update()
			end
		end
	end

	-----------------------------------------------------------
	-- Initializer
	-----------------------------------------------------------
	env:RegisterSafeCallback('QMenu.Loaded', function(QMenu)
		local function CreateRow(index, filter, title, numSlots)
			local frame = CreateFrame('Frame', '$parentAuras'..index, QMenu, 'QMenuRow')
			frame:SetAttribute('filter', filter)
			CPAPI.Specialize(frame, Row)
			frame:SetHelpful(filter == 'HELPFUL')
			frame:CreateSlots(numSlots)
			frame:SetTitle(title)
			QMenu:AddFrame(frame, index)
			return frame;
		end

		local Helpful = CreateRow(BUFF_CANCEL_ROW_INDEX, 'HELPFUL', BUFFOPTIONS_LABEL, 20);
		local Harmful = CreateRow(DEBUFF_INFO_ROW_INDEX, 'HARMFUL', BUFFOPTIONS_LABEL, 10);

		function Helpful:OnVariablesChanged()
			self:SetShown(db('QMenuCollectionBuffs'))
			self:SetAttribute('paddingBottom', db('QMenuCollectionDebuffs') and 8 or 20)
			self:UpdateSize()
			self:Update()
		end

		function Harmful:OnVariablesChanged()
			self:SetShown(db('QMenuCollectionDebuffs'))
			self:SetTitle(db('QMenuCollectionBuffs') and '' or BUFFOPTIONS_LABEL)
			self:UpdateSize()
			self:Update()
		end

		db:RegisterSafeCallbacks(Helpful.OnVariablesChanged, Helpful,
			'Settings/QMenuCollectionBuffs',
			'Settings/QMenuCollectionDebuffs',
			'Settings/QMenuNumBuffs'
		);
		db:RegisterSafeCallbacks(Harmful.OnVariablesChanged, Harmful,
			'Settings/QMenuCollectionBuffs',
			'Settings/QMenuCollectionDebuffs',
			'Settings/QMenuNumDebuffs'
		);

		Helpful:OnVariablesChanged();
		Harmful:OnVariablesChanged();
	end)
	return
end

---------------------------------------------------------------
local Aura = { getData = C_UnitAuras.GetAuraDataByIndex };
---------------------------------------------------------------
local SetTimer, ClearTimer = CooldownFrame_Set, CooldownFrame_Clear;

function Aura:OnLoad()
	self.cooldown:SetReverse(true)
	if self.cooldown.SetUseAuraDisplayTime then
		self.cooldown:SetUseAuraDisplayTime(true)
	end
	if CPAPI.IsRetailVersion then
		self.cooldown:SetHideCountdownNumbers(true)
		self.cooldown:SetDrawEdge(false)
	end
end

function Aura:GetFilter()
	return self:GetAttribute('filter');
end

function Aura:GetUnit()
	return self:GetParent():GetAttribute('unit');
end

function Aura:GetArguments(unit)
	return unit or self:GetUnit(), self:GetID(), self:GetFilter();
end

function Aura:GetData(unit)
	return self.getData(self:GetArguments(unit));
end

if C_UnitAuras and C_UnitAuras.GetAuraApplicationDisplayCount then
	function Aura:GetCount(data)
		return C_UnitAuras.GetAuraApplicationDisplayCount(self:GetUnit(), data.auraInstanceID)
	end
else
	function Aura:GetCount(data)
		return data and data.applications or '';
	end
end

if CPAPI.IsRetailVersion then
	function Aura:GetColor()
		return self.isHelpful and NORMAL_FONT_COLOR
		    or self.isHarmful and RED_FONT_COLOR
		    or BLUE_FONT_COLOR;
	end

	function Aura:SetCooldown(data)
		local duration = C_UnitAuras.GetAuraDuration(self:GetUnit(), data.auraInstanceID)
		self.cooldown:SetSwipeColor(self:GetColor(data):GetRGBA())
		if duration then
			self.cooldown:SetCooldownFromDurationObject(duration)
		else
			ClearTimer(self.cooldown)
		end
	end
else
	function Aura:GetColor(data)
		return (data and data.isHelpful) and NORMAL_FONT_COLOR
		    or (data and data.isHarmful) and RED_FONT_COLOR
		    or BLUE_FONT_COLOR;
	end

	function Aura:SetCooldown(data)
		self.cooldown:SetSwipeColor(self:GetColor(data):GetRGBA())
		if data.duration > 0 then
			self.cooldown:SetHideCountdownNumbers(data.duration > 60)
			SetTimer(self.cooldown, data.expirationTime - data.duration, data.duration, true)
		else
			ClearTimer(self.cooldown)
		end
	end
end

function Aura:Update(unit)
	local data = self:GetData(unit);
	if not data then return self:SetIcon(nil) end;

	self:SetIcon(data.icon)
	self:SetCount(self:GetCount(data), true, true)
	self:SetCooldown(data)
end

function Aura:OnEnter()
	GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMRIGHT')
	self:UpdateTooltip()
	self:LockHighlight()
end

function Aura:UpdateTooltip()
	local data = self:GetData();
	if not data then return end;
	if CPAPI.IsRetailVersion then
		GameTooltip:SetUnitAuraByAuraInstanceID(self:GetUnit(), data.auraInstanceID, self:GetFilter())
	else
		GameTooltip:SetUnitAura(self:GetArguments())
	end

	if not self.isHelpful then return end;
	local text = env:GetTooltipPromptForClick('RightButton', CANCEL)
	if text then
		GameTooltip:AddLine(text, 1, 1, 1)
		GameTooltip:Show()
	end
end

function Aura:OnLeave()
	GameTooltip:Hide()
	self:UnlockHighlight()
end

---------------------------------------------------------------
local Header = {};
---------------------------------------------------------------
CPAPI.Props(Header)
	.Prop('Title')
	.Bool('Helpful', true)

function Header:OnLoad()
	self:HookScript('OnShow', self.Update)
	self:HookScript('OnEvent', self.Update)
	self:SetAttribute('nodepass', true)
end

function Header:Update()
	local i, unit, aura = CreateCounter(0), self:GetAttribute('unit');
	repeat aura = self:GetAttribute('child'..i())
		if not aura or not aura:IsShown() then break end;
		if not aura.Update then
			CPAPI.Specialize(aura, Aura)
			aura.isHelpful = self:IsHelpful();
			aura.isHarmful = not aura.isHelpful;
		end
		aura:Update(unit)
	until false;
end

---------------------------------------------------------------
-- Initializer
---------------------------------------------------------------
env:RegisterSafeCallback('QMenu.Loaded', function(QMenu)
	local function CreateHeader(index, filter, title)
		local frame = CreateFrame('Frame', '$parentAuras'..index, QMenu, 'CPQMenuAuraHeader,SecureAuraHeaderTemplate')
		frame:SetAttribute('filter', filter)
		CPAPI.Specialize(frame, Header)
		frame:SetTitle(title);
		frame:SetHelpful(filter == 'HELPFUL');
		QMenu:AddFrame(frame, index)
		return frame;
	end

	local Helpful = CreateHeader(BUFF_CANCEL_ROW_INDEX, 'HELPFUL', BUFFOPTIONS_LABEL);
	local Harmful = CreateHeader(DEBUFF_INFO_ROW_INDEX, 'HARMFUL', BUFFOPTIONS_LABEL);

	function Helpful:OnVariablesChanged()
		self:SetShown(db('QMenuCollectionBuffs'))
		self:SetAttribute('paddingBottom', db('QMenuCollectionDebuffs') and 8 or 20);
		if not self:IsShown() then
			env.QMenu:Run([[ self::OnAurasChanged(%q, -math.huge)]], self:GetAttribute('filter'))
		end
	end

	function Harmful:OnVariablesChanged()
		self:SetShown(db('QMenuCollectionDebuffs'))
		self:SetTitle(db('QMenuCollectionBuffs') and '' or BUFFOPTIONS_LABEL)
		if not self:IsShown() then
			env.QMenu:Run([[ self::OnAurasChanged(%q, -math.huge)]], self:GetAttribute('filter'))
		end
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
end)