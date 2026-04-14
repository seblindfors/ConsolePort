if CPAPI.IsRetailVersion then return end;
local env, db = CPAPI.GetEnv(...);
---------------------------------------------------------------
local LOOT_ROW_INDEX  = env.QMenuID();
---------------------------------------------------------------
local NUM_LOOT_FRAMES = NUM_GROUP_LOOT_FRAMES or 4;
local ROLL_PASS       = 0;
local ROLL_NEED       = 1;
local ROLL_GREED      = 2;
local ROLL_DISENCHANT = 3;

---------------------------------------------------------------
local LootSlot = Mixin({}, CPActionButtonMixin);
---------------------------------------------------------------

function LootSlot:OnLoad()
	self:RegisterForClicks('AnyDown')
	self:SetSize(48, 48)

	env.QMenu:Hook(self, 'PostClick', [[
		self:::PostClick(button)
	]])
end

function LootSlot:Init()
	self:SetScript('OnEnter', self.OnEnter)
	self:SetScript('OnLeave', self.OnLeave)
	if self.cooldown then
		self.cooldown:SetAllPoints(self)
		self.cooldown:SetSwipeColor(NORMAL_FONT_COLOR:GetRGBA())
		self.cooldown:SetUsingParentLevel(false)
		self.cooldown:SetHideCountdownNumbers(true)
	end
	self:Update()
	self.Init = nop;
end

function LootSlot:SetRoll(rollID, rollTime)
	self.rollID       = rollID;
	self.rollStart    = GetTime();
	self.rollDuration = rollTime / 1000;
	self.rolled       = nil;
	self:Update()
end

function LootSlot:RecoverRoll(rollID)
	local remaining = GetLootRollTimeLeft(rollID);
	if ( not remaining or remaining <= 0 ) then return end;
	remaining = remaining / 1000;
	local duration = C_Loot and C_Loot.GetLootRollDuration and C_Loot.GetLootRollDuration(rollID);
	self.rollID       = rollID;
	self.rollDuration = duration and duration / 1000 or remaining;
	self.rollStart    = GetTime() - self.rollDuration + remaining;
	self.rolled       = nil;
	self:Update()
end

function LootSlot:ClearRoll()
	self.rollID       = nil;
	self.rollStart    = nil;
	self.rollDuration = nil;
	self.rolled       = nil;
	self:Update()
end

function LootSlot:IsActive()
	return self.rollID and not self.rolled;
end

function LootSlot:Update()
	local isTooltipOwner = CPAPI.Scrub(GameTooltip:IsOwned(self));

	if not self.rollID then
		self:SetIcon(nil)
		if self.icon then
			self.icon:SetDesaturated(true)
		end
		self:SetAlpha(0.25)
		CooldownFrame_Clear(self.cooldown)
		if isTooltipOwner then
			GameTooltip:Hide()
		end
		local parent = self:GetParent();
		if parent.RefreshActiveRolls then
			parent:RefreshActiveRolls()
		end
		return;
	end

	local texture, name, count, quality, _, canNeed, canGreed, canDisenchant = GetLootRollItemInfo(self.rollID);
	if not name then
		return self:ClearRoll()
	end

	self:SetAlpha(1)
	self:SetIcon(texture)
	if self.icon then
		self.icon:SetDesaturated(self.rolled and true or false)
	end
	self.canNeed       = canNeed;
	self.canGreed      = canGreed;
	self.canDisenchant = canDisenchant;

	if self.rolled then
		CooldownFrame_Clear(self.cooldown)
	else
		local color = ITEM_QUALITY_COLORS[quality];
		if color then
			self.cooldown:SetSwipeColor(color.r, color.g, color.b, 1)
		end
		CooldownFrame_Set(self.cooldown, self.rollStart, self.rollDuration, true)
	end

	if isTooltipOwner then
		self:OnEnter()
	end
end

function LootSlot:PostClick(button)
	if not self.rollID or self.rolled then return end;

	local rollType;
	if ( button == 'LeftButton' and self.canGreed ) then
		rollType = ROLL_GREED;
	elseif ( button == 'RightButton' and self.canNeed ) then
		rollType = ROLL_NEED;
	elseif button == 'MiddleButton' then
		rollType = self.canDisenchant and ROLL_DISENCHANT or ROLL_PASS;
	end

	if rollType then
		RollOnLoot(self.rollID, rollType)
		self.rolled = true;
		self:Update()
	end
end

function LootSlot:OnEnter()
	GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMRIGHT')
	if self.rollID then
		GameTooltip:SetLootRollItem(self.rollID)
		GameTooltip_ShowCompareItem(GameTooltip)
		if ( not self.rolled ) then
			local lines = {};
			if self.canGreed then
				local text = env:GetTooltipPromptForClick('LeftButton', GREED)
				if text then tinsert(lines, text) end
			end
			if self.canNeed then
				local text = env:GetTooltipPromptForClick('RightButton', NEED)
				if text then tinsert(lines, text) end
			end
			do local label = self.canDisenchant and DISENCHANT or PASS;
				local text = env:GetTooltipPromptForClick('MiddleButton', label)
				if text then tinsert(lines, text) end
			end
			if #lines > 0 then
				for _, line in ipairs(lines) do
					GameTooltip:AddLine(line, 1, 1, 1)
				end
				GameTooltip:Show()
			end
		end
	end
	self:LockHighlight()
end

function LootSlot:OnLeave()
	GameTooltip:Hide()
	self:UnlockHighlight()
end

function LootSlot:OnHide()
	if CPAPI.Scrub(GameTooltip:IsOwned(self)) then
		GameTooltip:Hide()
	end
end

---------------------------------------------------------------
local LootRow = {
---------------------------------------------------------------
	Events = {
		'CANCEL_ALL_LOOT_ROLLS';
		'CANCEL_LOOT_ROLL';
		'CONFIRM_DISENCHANT_ROLL';
		'CONFIRM_LOOT_ROLL';
		'GROUP_ROSTER_UPDATE';
		'LOOT_BIND_CONFIRM';
		'PARTY_LOOT_METHOD_CHANGED';
		'START_LOOT_ROLL';
	};
};

-- Group Loot and Need Before Greed are the methods that involve rolls.
local RollLootMethods = C_PartyInfo and {
	[Enum.LootMethod.Group]           = true;
	[Enum.LootMethod.Needbeforegreed] = true;
} or {
	group           = true;
	needbeforegreed = true;
};

function LootRow:OnLoad()
	local xOffset = tonumber(self:GetAttribute('xOffset')) or 52;
	local point   = self:GetAttribute('point') or 'TOPLEFT';

	self.buttons = {};
	for i = 1, NUM_LOOT_FRAMES do
		local button = CreateFrame('Button', '$parentSlot'..i, self, 'CPWorldSecureButtonBaseTemplate')
		CPAPI.Specialize(button, LootSlot)
		button:SetID(i)
		if i == 1 then
			button:SetPoint(point, self, point, 0, 0)
		else
			button:SetPoint(point, self.buttons[i - 1], point, xOffset, 0)
		end
		self.buttons[i] = button;
	end

	CPAPI.RegisterFrameForEvents(self, self.Events)
	self:SetTitle(LOOT)
	self:UpdateState()
	db:RegisterSafeCallback('Settings/QMenuCollectionGroupLoot', self.UpdateState, self)
end

function LootRow:UpdateState()
	if not db('QMenuCollectionGroupLoot') then
		UnregisterStateDriver(self, 'grouploot')
		return self:Hide()
	end

	local isRollMethod = IsInGroup() and RollLootMethods[CPAPI.GetLootMethod()];
	if isRollMethod then
		local condition = '[group] true; nil';
		RegisterStateDriver(self, 'grouploot', condition)
		self:SetShown(SecureCmdOptionParse(condition) == 'true')
		self:SetAttribute('_onstate-grouploot', [[
			if newstate then
				self:Show()
			else
				self:Hide()
			end
			self:GetParent():RunAttribute('UpdateLayout')
		]])
	else
		UnregisterStateDriver(self, 'grouploot')
		self:Hide()
	end
end

function LootRow:UpdateStateSafe()
	env:RunSafe(self.UpdateState, self)
end

function LootRow:LayoutItems()
	return self.buttons;
end

function LootRow:GetAvailableSlot()
	for _, button in ipairs(self.buttons) do
		if not button.rollID then
			return button;
		end
	end
end

function LootRow:GetSlotByRollID(rollID)
	for _, button in ipairs(self.buttons) do
		if button.rollID == rollID then
			return button;
		end
	end
end

function LootRow:OnShow()
	for _, button in ipairs(self.buttons) do
		button:Init()
	end
	self:RefreshActiveRolls()
end

function LootRow:RefreshActiveRolls()
	if not GetActiveLootRollIDs then return end;
	local activeRolls = GetActiveLootRollIDs();
	for _, rollID in ipairs(activeRolls) do
		if not self:GetSlotByRollID(rollID) then
			local slot = self:GetAvailableSlot();
			if slot then
				slot:RecoverRoll(rollID)
			end
		end
	end
end

function LootRow:OnHide()
	for _, button in ipairs(self.buttons) do
		button:ClearRoll()
	end
end

function LootRow:START_LOOT_ROLL(rollID, rollTime)
	local slot = self:GetAvailableSlot();
	if slot then
		slot:SetRoll(rollID, rollTime)
	end
end

function LootRow:CANCEL_LOOT_ROLL(rollID)
	local slot = self:GetSlotByRollID(rollID);
	if slot then
		slot:ClearRoll()
	end
end

function LootRow:CANCEL_ALL_LOOT_ROLLS()
	for _, button in ipairs(self.buttons) do
		button:ClearRoll()
	end
end

function LootRow:CONFIRM_LOOT_ROLL(rollID, rollType)
	local slot = self:GetSlotByRollID(rollID);
	if ( slot and slot.rolled ) then
		ConfirmLootRoll(rollID, rollType)
		CPAPI.Next(StaticPopup_Hide, 'CONFIRM_LOOT_ROLL')
	end
end

function LootRow:LOOT_BIND_CONFIRM(lootSlot)
	if self:IsShown() then
		ConfirmLootSlot(lootSlot)
	end
end

LootRow.CONFIRM_DISENCHANT_ROLL   = LootRow.CONFIRM_LOOT_ROLL;
LootRow.PARTY_LOOT_METHOD_CHANGED = LootRow.UpdateStateSafe;
LootRow.GROUP_ROSTER_UPDATE       = LootRow.UpdateStateSafe;

---------------------------------------------------------------
-- Initializer
---------------------------------------------------------------
env:AddQMenuFactory('QMenuCollectionGroupLoot', function(QMenu)
	local header = CreateFrame('Frame', '$parentGroupLoot', QMenu, 'QMenuRow, SecureHandlerStateTemplate')
	CPAPI.Specialize(CPAPI.EventHandler(header), env.QMenuRow, LootRow)
	QMenu:AddFrame(header, LOOT_ROW_INDEX)
	header:Layout()
end)
