local db, _, env = ConsolePort:DB(), ...;
local Fader, spairs = db.Alpha.Fader, db.table.spairs;
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

	for _, slot in ipairs(C_ActionBar.FindSpellActionButtons(self:GetID()) or {}) do
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
		local spellID = select(2, GetActionInfo(CPAPI.ExtraActionButtonID))
		if spellID and spellID > 0 then
			self:AddSpell(spellID)
		end
	end
end

local HasVehicleActionBar = HasVehicleActionBar or nop;
local HasOverrideActionBar = HasOverrideActionBar or nop;
local HasTempShapeshiftActionBar = HasTempShapeshiftActionBar or nop;
function TempAbility:UPDATE_BONUS_ACTIONBAR()
	local barIndex =
		HasVehicleActionBar() and GetVehicleBarIndex() or
		HasOverrideActionBar() and GetOverrideBarIndex() or
		HasTempShapeshiftActionBar() and GetTempShapeshiftBarIndex()
	if barIndex then
		local offset = (barIndex - 1) * NUM_ACTIONBAR_BUTTONS;
		for i = offset + 1, offset + NUM_ACTIONBAR_BUTTONS do
			local spellID = select(2, GetActionInfo(i))
			if spellID and spellID > 0 then
				self:AddSpell(spellID)
			end
		end 
	end
end

TempAbility.UNIT_ENTERED_VEHICLE = TempAbility.UPDATE_BONUS_ACTIONBAR;
TempAbility.UPDATE_VEHICLE_ACTIONBAR = TempAbility.UPDATE_BONUS_ACTIONBAR;
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
TempAbility.Info, TempAbility.Shown = {}, {};

function TempAbility:OnShow()
	self.Header.HeaderOpenAnim:Stop()
	self.Header.HeaderOpenAnim:Play()
end

function TempAbility:OnHide()
	self.Header.HeaderOpenAnim:Finish()
	wipe(self.Info)
end

function TempAbility:OnDataLoaded()
	CPFocusPoolMixin.OnLoad(self)
	self:CreateFramePool('Button', 'CPUISimpleLootButtonTemplate', Ability)
	self:SetScript('OnHide', self.OnHide)
	self:SetScript('OnShow', self.OnShow)
	self:SetScript('OnUpdate', self.OnUpdate)

	self.Header:SetDurationMultiplier(.5)
	self:RegisterUnitEvent('UNIT_ENTERED_VEHICLE', 'player')
end

function TempAbility:OnUpdate(elapsed)
	if self.targetHeight then
		local height, newHeight = self:GetHeight() or 0, self.targetHeight;
		local diff = newHeight - height;
		if abs(newHeight - height) < 0.5 then
			self:SetHeight(newHeight)
			self.targetHeight = nil;
		else
			self:SetHeight(height + ( diff / 5 ) )
		end
	end
	if not next(self.Info) then
		Fader.Toggle(self, 0.1, false)
	else
		local spellID, timer = next(self.Info)
		while spellID do
			timer = timer - elapsed;
			if timer < 0 then
				self:RemoveSpell(spellID)
				spellID, timer = next(self.Info)
			else
				self.Info[spellID] = timer;
				spellID, timer = next(self.Info, spellID)
			end
		end
	end
end

function TempAbility:AdjustHeight()
	local newHeight = 0;
	for spell in self:EnumerateActive() do
		newHeight = newHeight + spell.NameFrame:GetHeight()
	end
	self.targetHeight = newHeight;
end

function TempAbility:AddSpell(spellID)
	if not self.Shown[spellID] and db('showAbilityBriefing') then
		local spell = Spell:CreateFromSpellID(spellID)
		spell:ContinueOnSpellLoad(function()
			local showTime = 0;
			for spellID, timer in pairs(self.Info) do
				showTime = showTime + timer;
			end
			self.Info[spellID] = self.Info[spellID] or Clamp(showTime, 10, showTime);
			self:UpdateItems()
		end)
	end
end

function TempAbility:RemoveSpell(spellID)
	self.Info[spellID]  = nil;
	self.Shown[spellID] = true;
	self:UpdateItems()
end

function TempAbility:UpdateItems()
	self:ReleaseAll()
	local idx, prev = 1;
	for spellID, timer in spairs(self.Info) do
		local spell, newObj = self:Acquire(spellID)
		if newObj then
			spell:OnLoad(idx)
		end

		spell:SetID(spellID)
		spell:Show()
		spell:Update()

		if prev then
			spell:SetPoint('TOPRIGHT', prev.NameFrame, 'BOTTOMLEFT', 36, -4)
		else
			spell:SetPoint('TOPLEFT', 0, -8)
		end
		prev, idx = spell, idx + 1;
	end

	local numActive = self:GetNumActive()
	self.Header.Text:SetText(numActive > 1 and ABILITIES or LEVEL_UP_ABILITY)
	self:AdjustHeight()
	Fader.Toggle(self, 0.1, true)
end

---------------------------------------------------------------
-- Add to config
---------------------------------------------------------------
ConsolePort:AddVariables({
	showAbilityBriefing = {db.Data.Bool(true);
		head = ACCESSIBILITY_LABEL;
		sort = 4;
		name = 'Show Ability Briefings';
		desc = 'Displays a briefing for newly acquired abilities.';
		note = 'Requires ConsolePort World.';
	};
})