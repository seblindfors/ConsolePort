if not CPAPI.IsRetailVersion then return end;
local _, db = ...;
local SpellFlyout, FlyoutButtonMixin = SpellFlyout, CreateFromMixins(CPActionButton);
local Selector = Mixin(CPAPI.EventHandler(ConsolePortSpellFlyout, {
	'SPELL_FLYOUT_UPDATE'
}), CPAPI.SecureEnvironmentMixin);

---------------------------------------------------------------
-- Secure environment
---------------------------------------------------------------
Selector:SetFrameRef('flyout', SpellFlyout)
Selector:SetAttribute(CPAPI.ActionPressAndHold, true)
Selector:Run([[
	selector, flyout = self, self:GetFrameRef('flyout')
	BUTTONS = {};
]])

Selector:CreateEnvironment({
	ClearAndHide = ([[
		self:CallMethod('ClearInstantly')
		self:SetAttribute(%q, nil)
		local owner = flyout:GetParent()
		owner:Hide()
		owner:Show()
	]]):format(CPAPI.ActionTypeRelease);
})

Selector:Hook(SpellFlyout, 'OnShow', [[
	if selector::SetBindingsForTriggers() then
		selector::UpdateSize()
		selector:Show()
		selector:CallMethod('SetOverride', true)
	else
		selector:CallMethod('SetOverride', false)
		selector:Hide()
	end
]])

Selector:Hook(SpellFlyout, 'OnHide', [[
	wipe(BUTTONS)
	control:ClearBindings()
	control:Hide()
	control:CallMethod('ReleaseAll')
	self:SetAlpha(1)
]])

Selector:Wrap('PreClick', ([[
	self::UpdateSize()

	local index = self::GetIndex()
	local button = index and BUTTONS[index];
	if button then
		self:SetAttribute(%q, 'macro')
		self:SetAttribute('macrotext', '/click '..button:GetName())
		self:CallMethod('SetOverride', false)
	else
		self::ClearAndHide()
	end
]]):format(CPAPI.ActionTypeRelease, CPAPI.ActionTypeRelease))

---------------------------------------------------------------
-- Events
---------------------------------------------------------------
function Selector:SPELL_FLYOUT_UPDATE()
	for button in self:EnumerateActive() do
		button:Update()
	end
end

---------------------------------------------------------------
-- Handler
---------------------------------------------------------------
function Selector:OnDataLoaded(...)
	local counter = CreateCounter();
	self:CreateObjectPool(function()
		return CreateFrame(
			'CheckButton',
			self:GetName()..'Button'..counter(),
			self, 'ActionButtonTemplate')
		end,
		function(_, self)
			self:Hide()
			self:ClearAllPoints()
			if self.OnClear then
				self:OnClear()
			end
		end, FlyoutButtonMixin)
	local sticks = db.Radial:GetStickStruct(db('radialPrimaryStick'))
	db.Radial:Register(self, 'SpellFlyout', {
		sticks = sticks;
		target = {sticks[1]};
		sizer  = [[
			wipe(BUTTONS)
			for i, child in ipairs(newtable(flyout:GetChildren())) do
				if child:IsVisible()
				and child:IsProtected()
				and child:IsObjectType('CheckButton') then
					BUTTONS[#BUTTONS+1] = child
				end
			end
			local size = #BUTTONS;
		]];
	});
	self:OnAxisInversionChanged()
end

function Selector:OnAxisInversionChanged()
	self.axisInversion = db('radialCosineDelta')
end

function Selector:OnPrimaryStickChanged()
	local sticks = db.Radial:GetStickStruct(db('radialPrimaryStick'))
	self:SetInterrupt(sticks)
	self:SetIntercept({sticks[1]})
end

db:RegisterSafeCallback('Settings/radialCosineDelta', Selector.OnAxisInversionChanged, Selector)
db:RegisterSafeCallback('Settings/radialPrimaryStick', Selector.OnPrimaryStickChanged, Selector)

---------------------------------------------------------------
-- Frontend
---------------------------------------------------------------
function Selector:OnInput(x, y, len, stick)
	self:SetFocusByIndex(self:GetIndexForPos(x, y, len, self:GetNumActive()))
	self:ReflectStickPosition(self.axisInversion * x, self.axisInversion * y, len, len > self:GetValidThreshold())
end

function Selector:OnBindingSet(btn, mod)
	if ( not mod ) then
		self.buttonTrigger = btn;
	end
end

function Selector:AddButton(i, size)
	local button, newObj = self:Acquire(i)
	local p, x, y = self:GetPointForIndex(i, size)
	if newObj then
		button:RegisterForDrag('LeftButton')
		button:SetScript('OnDragStart', FlyoutButtonMixin.OnDragStart)
		button:SetSize(64, 64)
		button.Name:Hide()
	end
	button:SetPoint(p, x, self.axisInversion * y)
	button:SetRotation(self:GetRotation(x, y))
	button:SetID(i)
	button:Show()
	return button;
end

function Selector:SetOverride(enabled)
	SpellFlyout:SetAlpha(enabled and 0 or 1)
	local owner = SpellFlyout:GetParent()
	if owner and owner.UpdateFlyout then
		owner:UpdateFlyout(false)
	end
	if not enabled and owner and owner.SetButtonState then
		owner:SetButtonState('NORMAL')
	end
end

---------------------------------------------------------------
-- Buttons
---------------------------------------------------------------
local ActionButton = LibStub('ConsolePortActionButton')

function FlyoutButtonMixin:OnFocus(newFocus)
	self:LockHighlight()
	if newFocus then
		local button = self:GetParent().buttonTrigger;
		if button then
			local device = db('Gamepad/Active')
			button = device and device:GetTooltipButtonPrompt(button, USE, 64)
		end
		GameTooltip_SetDefaultAnchor(GameTooltip, self)
		GameTooltip:SetSpellByID(self.spellID)
		if button then
			GameTooltip:AddLine(button)
		end
		GameTooltip:Show()
	end
	self:GetParent():SetActiveSliceText(self.Name:GetText())
end

function FlyoutButtonMixin:OnClear()
	self:UnlockHighlight()
	if GameTooltip:IsOwned(self) then
		GameTooltip:Hide()
	end
	self:GetParent():SetActiveSliceText(nil)
end

function FlyoutButtonMixin:OnDragStart()
	if (self.spellID) and not InCombatLockdown() then
		PickupSpell(self.spellID);
	end
end

function FlyoutButtonMixin:SetData(data)
	Mixin(self, data)
	self:Update()
end

function FlyoutButtonMixin:Update()
	if not self.spellID then return end;
	SpellFlyoutButton_UpdateCooldown(self);
	SpellFlyoutButton_UpdateCount(self);
	SpellFlyoutButton_UpdateUsable(self);
	SpellFlyoutButton_UpdateState(self);

	self.icon:SetTexture(GetSpellTexture(self.overrideSpellID))
	self:GetNormalTexture():SetDesaturated(self.offSpec)
	self.Name:SetText(self.spellName)
	self:SetEnabled(not self.offSpec)
	ActionButton.Skin.RingButton(self)
	RunNextFrame(function()
		self:GetParent():SetSliceText(self:GetID(), self.Name:GetText())
	end)
end

---------------------------------------------------------------
-- Hook
---------------------------------------------------------------

-- signature: (self, flyoutID, parent, direction, distance, isActionBar, specID, showFullTooltip, reason)
hooksecurefunc(SpellFlyout, 'Toggle', function(flyout, flyoutID, _, _, _, isActionBar, specID, _, reason)
	local self = Selector; self:ReleaseAll();
	if not flyout:IsShown() then return end

	-- BUG: Flyout sometimes clicks the wrong button
	local active, offSpec, _, _, numSlots = {}, specID and (specID ~= 0), GetFlyoutInfo(flyoutID)
	for i=1, numSlots do
		local spellID, overrideSpellID, isKnown, spellName, slotSpecID = GetFlyoutSlotInfo(flyoutID, i)
		local visible = true

		-- ignore Call Pet spells if there isn't a pet in that slot
		local petIndex, petName = GetCallPetSpellInfo(spellID)
		if (isActionBar and petIndex and (not petName or petName == '')) then
			visible = false;
		end

		-- show buttons
		if ( (not offSpec or slotSpecID == 0) and visible and isKnown )
		or ( offSpec and slotSpecID == specID ) then
			active[#active+1] = {
				overrideSpellID = overrideSpellID;
				desaturated     = offSpec;
				offSpec         = offSpec;
				spellID         = spellID;
				spellName       = spellName;
				reason          = reason;
			}
		end
	end
	for i, data in ipairs(active) do
		local button = self:AddButton(i, #active)
		button:SetData(data)
	end
	self:UpdatePieSlices(true, #active)
end)