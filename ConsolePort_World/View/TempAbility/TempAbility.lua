local env, db = CPAPI.GetEnv(...);
local Fader = db.Alpha.Fader;
local TempAbility = Mixin(CPAPI.EventHandler(ConsolePortTempAbilityFrame, {
	'ACTIONBAR_SLOT_CHANGED';
	'SPELLS_CHANGED';
	'UPDATE_BONUS_ACTIONBAR';
	CPAPI.IsRetailVersion and 'UPDATE_OVERRIDE_ACTIONBAR';
	CPAPI.IsRetailVersion and 'UPDATE_VEHICLE_ACTIONBAR';
	CPAPI.IsRetailVersion and 'UPDATE_EXTRA_ACTIONBAR';
}), CPFocusPoolMixin)

---------------------------------------------------------------
-- Shown ability mixin
---------------------------------------------------------------
local Ability = {};

local function CreateTooltip(self)
	TempAbility.TooltipCount = (TempAbility.TooltipCount or 0) + 1;
	return CreateFrame('GameTooltip', 'ConsolePortTempAbilityTooltip'..TempAbility.TooltipCount, self, 'GameTooltipTemplate')
end

function Ability:Update()
	self:SetIcon(CPAPI.GetSpellTexture(self:GetID()))

	self.tooltip:SetOwner(self, 'ANCHOR_BOTTOMRIGHT', 0, 50)
	self.tooltip:SetSpellByID(self:GetID())
	self.tooltip.NineSlice:Hide()

	for _, slot in ipairs(C_ActionBar.FindSpellActionButtons(self:GetID()) or { self.actionID }) do
		local binding = db.Actionbar.Action[slot];
		local slug = binding and db.Hotkeys:GetButtonSlugForBinding(binding)
		if slug then
			self.tooltip:AddDoubleLine(KEY_BINDING, slug, 1, 1, 1)
		end
	end

	if self.tooltip:IsOwned(self) then
		self.tooltip:Show()
		self:SetScript('OnUpdate', self.OnUpdate)
	end
end

function Ability:OnLoad()
	CPAPI.Start(self)
	self.tooltip = CreateTooltip(self)
	self.QuestTexture:Hide()
	self:RegisterForDrag('LeftButton')
	self:OnHide()
end

function Ability:OnDragStart()
	self:GetParent():StartMoving()
end

function Ability:OnDragStop()
	self:GetParent():StopMovingOrSizing()
end

function Ability:OnClick()
	self:GetParent():RemoveSpell(self:GetID())
end

function Ability:OnHide()
	self:SetScript('OnUpdate', nil)
end

function Ability:OnUpdate()
	local width, height = (self.tooltip:GetWidth() or 330) + 50, (self.tooltip:GetHeight() or 50)
	self.NameFrame:SetSize(Clamp(width, 330, width), Clamp(height, 50, height))
end

---------------------------------------------------------------
-- Events
---------------------------------------------------------------
function TempAbility:UPDATE_EXTRA_ACTIONBAR()
	if HasExtraActionBar() then
		local actionID = CPAPI.ExtraActionButtonID;
		local spellID  = select(2, GetActionInfo(actionID))
		if spellID and spellID > 0 then
			self:AddSpell(spellID, actionID)
		end
	end
end

do -- Vehicle and override bars
	local HasVehicleActionBar        = HasVehicleActionBar or nop;
	local HasOverrideActionBar       = HasOverrideActionBar or nop;
	local HasTempShapeshiftActionBar = HasTempShapeshiftActionBar or nop;

	function TempAbility:UPDATE_BONUS_ACTIONBAR()
		local barIndex =
			HasVehicleActionBar()        and GetVehicleBarIndex() or
			HasOverrideActionBar()       and GetOverrideBarIndex() or
			HasTempShapeshiftActionBar() and GetTempShapeshiftBarIndex()
		if barIndex then
			local offset = (barIndex - 1) * NUM_ACTIONBAR_BUTTONS;
			for i = offset + 1, offset + NUM_ACTIONBAR_BUTTONS do
				local spellID = select(2, GetActionInfo(i))
				if spellID and spellID > 0 then
					self:AddSpell(spellID, i)
				end
			end
		end
	end
end

TempAbility.UNIT_ENTERED_VEHICLE      = TempAbility.UPDATE_BONUS_ACTIONBAR;
TempAbility.UPDATE_VEHICLE_ACTIONBAR  = TempAbility.UPDATE_BONUS_ACTIONBAR;
TempAbility.UPDATE_OVERRIDE_ACTIONBAR = TempAbility.UPDATE_BONUS_ACTIONBAR;

function TempAbility:SPELLS_CHANGED()
	local zoneAbilities = CPAPI.GetActiveZoneAbilities()
	table.sort(zoneAbilities, function(lhs, rhs)
		return lhs.uiPriority < rhs.uiPriority;
	end)

	for i, zoneAbility in ipairs(zoneAbilities) do
		local spellID = zoneAbility.spellID;
		if not C_ActionBar.FindSpellActionButtons(spellID) then
			self:AddSpell(spellID)
		end
	end
end

---------------------------------------------------------------
-- Temporary ability briefing frame
---------------------------------------------------------------
TempAbility.activeSpells, TempAbility.alreadyShown = {}, {};

function TempAbility:OnShow()
	self.Header.HeaderOpenAnim:Stop()
	self.Header.HeaderOpenAnim:Play()
end

function TempAbility:OnHide()
	self.Header.HeaderOpenAnim:Finish()
	self:ReleaseAll()
	wipe(self.activeSpells)
end

function TempAbility:OnDataLoaded()
	CPFocusPoolMixin.OnLoad(self)
	self:CreateFramePool('Button', 'CPWorldButtonTemplate', Ability)
	self:SetScript('OnHide', self.OnHide)
	self:SetScript('OnShow', self.OnShow)
	self:SetScript('OnUpdate', self.OnUpdate)

	self.Header:SetDurationMultiplier(.5)
	self:RegisterUnitEvent('UNIT_ENTERED_VEHICLE', 'player')
	return CPAPI.BurnAfterReading;
end

function TempAbility:OnUpdate(elapsed)
	self:SetHeight(FrameDeltaLerp(self:GetTargetHeight(), self:GetHeight() or 0, 2))

	if not next(self.activeSpells) then return end;

	local count = #self.activeSpells;
	for i, activeSpell in ipairs_reverse(self.activeSpells) do
		activeSpell.showTime = activeSpell.showTime - elapsed;
		if activeSpell.showTime <= 0 then
			tremove(self.activeSpells, i)
		end
	end

	if not next(self.activeSpells) and self.fadeInfo.mode ~= 'OUT' then
		Fader.Toggle(self, 0.1, false)
	elseif ( count ~= #self.activeSpells ) then
		self:UpdateItems()
	end
end

function TempAbility:GetTargetHeight()
	local newHeight = 0;
	for spell in self:EnumerateActive() do
		newHeight = newHeight + spell.NameFrame:GetHeight()
	end
	return newHeight;
end

function TempAbility:AddSpell(spellID, actionID)
	if self.alreadyShown[spellID] or not db('showAbilityBriefing') then return end
	self.alreadyShown[spellID] = true;

	local spell = Spell:CreateFromSpellID(spellID)
	spell:ContinueOnSpellLoad(function()
		tinsert(self.activeSpells, {
			spellID  = spellID;
			actionID = actionID;
			showTime = 10 * (#self.activeSpells + 1);
		})
		self:UpdateItems()
	end)
end

function TempAbility:RemoveSpell(spellID)
	for i, activeSpell in pairs(self.activeSpells) do
		if ( activeSpell.spellID == spellID ) then
			tremove(self.activeSpells, i)
			break
		end
	end
	self:UpdateItems()
end

function TempAbility:UpdateItems()
	self:ReleaseAll()
	local prev;
	for i, activeSpell in ipairs(self.activeSpells) do
		local spell, newObj = self:Acquire(i)
		if newObj then
			spell:OnLoad(i)
		end

		spell.actionID = activeSpell.actionID;
		spell:SetID(activeSpell.spellID)
		spell:Show()
		spell:Update()

		if prev then
			spell:SetPoint('TOPRIGHT', prev.NameFrame, 'BOTTOMLEFT', 36, -4)
		else
			spell:SetPoint('TOPLEFT', 0, -8)
		end
		prev = spell;
	end

	local numActive = self:GetNumActive()
	self.Header.Text:SetText(numActive > 1 and ABILITIES or LEVEL_UP_ABILITY)
	Fader.Toggle(self, 0.1, true)
end

env:RegisterCallback('QMenu.Show', function(self, isVisible)
	if isVisible and self:IsShown() then
		self:Hide();
	end
end, TempAbility);