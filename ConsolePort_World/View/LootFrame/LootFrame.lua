local env, db = CPAPI.GetEnv(...)
local UIHandle, Input, FadeIn = db.UIHandle, db.Input, db.Alpha.FadeIn;
local LootFrame = Mixin(CPAPI.EventHandler(ConsolePortLootFrame, {
	'LOOT_OPENED';
	'LOOT_CLOSED';
	'LOOT_READY';
	'LOOT_SLOT_CLEARED';
	'LOOT_SLOT_CHANGED';
	'OPEN_MASTER_LOOT_LIST';
	'UPDATE_MASTER_LOOT_LIST';
	'PLAYER_REGEN_DISABLED';
}), CPFocusPoolMixin, CPPropagationMixin)

---------------------------------------------------------------
-- Events
---------------------------------------------------------------
function LootFrame:LOOT_SLOT_CLEARED(slot)
	if self:IsShown() then
		self:UpdateItems(false, slot)
	end
end

function LootFrame:LOOT_SLOT_CHANGED()
	if self:IsShown() then
		self:UpdateItems(false)
	end
end

LootFrame.LOOT_READY = LootFrame.LOOT_SLOT_CHANGED;

function LootFrame:LOOT_OPENED(autoLoot, isFromItem)
	if autoLoot then
		self:LootAllItems()
	end
	if isFromItem then
		PlaySound(SOUNDKIT.UI_CONTAINER_ITEM_OPEN)
	end
	if self:UpdateItems(true) then
		self:Show()
	else
		CloseLoot()
	end
end

function LootFrame:LOOT_CLOSED()
	self:Hide()
end

function LootFrame:OPEN_MASTER_LOOT_LIST()
	MasterLooterFrame_Show(self.focusIndex)
end

function LootFrame:UPDATE_MASTER_LOOT_LIST()
	MasterLooterFrame_UpdatePlayers()
end

function LootFrame:PLAYER_REGEN_DISABLED()
	self:SetPropagation(false)
end

---------------------------------------------------------------
-- Script handlers
---------------------------------------------------------------
function LootFrame:OnLoad()
	CPFocusPoolMixin.OnLoad(self)
	self:CreateFramePool('Button', 'CPWorldButtonTemplate', env.LootButtonMixin)
	self:SetScript('OnGamePadButtonDown', self.OnGamePadButtonDown)

	self.Header.Text:SetText(LOOT)
	self.Header:SetDurationMultiplier(.5)
end

function LootFrame:OnShow()
	self.Header.HeaderOpenAnim:Stop()
	self.Header.HeaderOpenAnim:Play()

	if InCombatLockdown() then
		-- Keep the loot controls until this panel closes, even after combat ends.
		self.openedInCombat = true;
		ConsolePort:SetCursorObstructor(self, true)
		self:SetHints()
	elseif ConsolePort:IsCursorActive() then
		ConsolePort:AddInterfaceCursorFrame(self)
		ConsolePort:SetCursorNode(self:GetFocusWidget())
	else
		self:SetHints()
	end
end

function LootFrame:OnHide()
	self:ReleaseAll()
	self.Header.HeaderOpenAnim:Finish()
	self:ClearHints()
	ConsolePort:RemoveInterfaceCursorFrame(self)
	if self.openedInCombat then
		self.openedInCombat = nil;
		ConsolePort:SetCursorObstructor(self, false)
	end
end

function LootFrame:OnDataLoaded()
	if ( db('useCustomLootFrame') and not CPAPI.IsNativeNavigationActive() ) then
		CPAPI.DisableFrame(_G.LootFrame, true)
		CPAPI.RegisterFrameForEvents(self, self.Events)
	else
		self:Hide()
		CPAPI.EnableFrame(_G.LootFrame, self.Events)
		self:UnregisterAllEvents()
	end
	return CPAPI.KeepMeForLater;
end

function LootFrame:SetHints()
	UIHandle:SetHintFocus(self)
	UIHandle:AddHint('PAD1', LOOT)
	UIHandle:AddHint('PAD3', ALL)
	UIHandle:AddHint('PAD2', CLOSE)
end

function LootFrame:ClearHints()
	if UIHandle:IsHintFocus(self) then
		UIHandle:HideHintBar()
	end
	UIHandle:ClearHintsForFrame(self)
end

function LootFrame:OnCursorShow()
	if not self:IsShown() then return end;
	ConsolePort:AddInterfaceCursorFrame(self)
	self:ClearHints()
end

function LootFrame:OnCursorHide()
	if not self:IsShown() then return end;
	self:SetHints()
end

function LootFrame:OnGamePadButtonDown(button)
	if Input:IsOverrideActive(CPAPI.CreateKeyChord(button)) then
		return self:SetPropagation(true)
	end
	self:SetPropagation(false)

	if (button == 'PAD1') then
		local lootSlot = self:GetFocusWidget()
		if lootSlot then
			lootSlot:OnClick()
		end
	elseif (button == 'PAD3') then
		self:LootAllItems()
	elseif (button == 'PADDDOWN') then
		self:UpdateFocus(self.focusIndex + 1)
	elseif (button == 'PADDUP') then
		self:UpdateFocus(self.focusIndex - 1)
	elseif (self.CloseOnButton[button]) then
		self:Close()
	end
end

CPAPI.Specialize(LootFrame, {
	focusIndex = 1;
	CloseOnButton = {
		PAD2 = true;
		PADBACK = true;
		PADSYSTEM = true;
		PADSOCIAL = true;
		PADFORWARD = true;
	};
})

db:RegisterCallback('OnCursorShow', LootFrame.OnCursorShow, LootFrame)
db:RegisterCallback('OnCursorHide', LootFrame.OnCursorHide, LootFrame)
db:RegisterCallback('Settings/useCustomLootFrame', LootFrame.OnDataLoaded, LootFrame)

---------------------------------------------------------------
-- Content handling
---------------------------------------------------------------
function LootFrame:UpdateItems(fadeOnShow, clearedSlot)
	self:ReleaseAll()

	local count, prev = 1;
	for i = 1, GetNumLootItems() do
		if i ~= clearedSlot and LootSlotHasItem(i) then
			local button, newObj = self:TryAcquireRegistered(count)
			if newObj then
				button:OnLoad()
			end

			button:SetID(i)
			button:Show()
			button:Update()

			if fadeOnShow then
				FadeIn(button, 0.3, 0, 1)
			end

			if prev then
				button:SetPoint('TOPRIGHT', prev.NameFrame, 'BOTTOMLEFT', 36, -4)
			else
				button:SetPoint('TOPLEFT', 0, -8)
			end
			prev, count = button, count + 1;
		end
	end

	local numActive = self:GetNumActive()
	if ( numActive < 1 ) then
		self:Hide()
		return false;
	end

	self:AdjustHeight(numActive * 52)
	self:UpdateFocus(self.focusIndex)
	return true;
end

function LootFrame:Close()
	self:Hide()
	CloseLoot()
end

function LootFrame:UpdateFocus(index)
	self.focusIndex = Clamp(index, 1, self:GetNumActive())

	local newObj, oldObj = self:SetFocusByIndex(self.focusIndex)
	if oldObj then oldObj:OnLeave() end
	if newObj then newObj:OnEnter() end
end

function LootFrame:AdjustHeight(newHeight)
	self:SetScript('OnUpdate', function(self)
		local height = self:GetHeight() or 0;
		local diff = newHeight - height;
		if abs(newHeight - height) < 0.5 then
			self:SetHeight(newHeight)
			self:SetScript('OnUpdate', nil)
		else
			self:SetHeight(height + ( diff / 5 ) )
		end
	end)
end

function LootFrame:LootAllItems()
	for i = GetNumLootItems(), 1, -1 do
		LootSlot(i)
	end
end
