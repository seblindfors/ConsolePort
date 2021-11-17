if not CPAPI.IsRetailVersion then return end;
local _, db = ...;
local Selector, Fade, FlyoutButtonMixin = CPAPI.EventHandler(ConsolePortSpellFlyout, {'SPELL_FLYOUT_UPDATE'}), db('Alpha/Fader'), {}

Selector:SetFrameRef('flyout', SpellFlyout)
Selector:Execute('this = self; that = self:GetFrameRef("flyout"); BUTTONS = newtable()')
Selector:SetAttribute('ClearAndHide', [[
	self:CallMethod('ClearInstantly')
	self:SetAttribute('type', nil)
	local owner = that:GetParent()
	owner:Hide()
	owner:Show()
]])
Selector:WrapScript(SpellFlyout, 'OnShow', [[
	if this:RunAttribute('SetBindingsForTriggers') then
		this:Show()
		self:SetAlpha(0)
	else
		self:SetAlpha(1)
		this:Hide()
	end
]])

Selector:WrapScript(SpellFlyout, 'OnHide', [[
	wipe(BUTTONS)
	this:ClearBindings()
	this:Hide()
	this:CallMethod('ReleaseAll')
	self:SetAlpha(1)
]])

Selector:WrapScript(Selector, 'PreClick', [[
	local index = self:RunAttribute('GetIndex')
	local button = index and BUTTONS[index]
	if button then
		self:SetAttribute('type', 'macro')
		self:SetAttribute('macrotext', '/click '..button:GetName())
	else
		self:RunAttribute('ClearAndHide')
	end
]])

function Selector:SPELL_FLYOUT_UPDATE(...)
--	print(GetTime(), ...)
end

function Selector:OnDataLoaded(...)
	self:CreateFramePool('CPButtonTemplate', FlyoutButtonMixin, function(pool, self)
		self:Hide()
		self:ClearAllPoints()
		if self.OnClear then
			self:OnClear()
		end
	end)
	local sticks = db.Radial:GetStickStruct(db('radialPrimaryStick'))
	db.Radial:Register(self, 'SpellFlyout', {
		sticks = sticks;
		target = {sticks[1]};
		sizer  = [[
			wipe(BUTTONS)
			for i, child in ipairs(newtable(that:GetChildren())) do
				if child:IsVisible() then
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
	local button = self:Acquire(i)
	local p, x, y = self:GetPointForIndex(i, size)
	button:RegisterForDrag('LeftButton')
	button:SetScript('OnDragStart', FlyoutButtonMixin.OnDragStart)
	button:SetPoint(p, x, self.axisInversion * y)
	button:Show()
	return button
end

function FlyoutButtonMixin:OnFocus(newFocus)
	self:SetChecked(true)
	if newFocus then
		local button = self:GetParent().buttonTrigger;
		if button then
			local device = db('Gamepad/Active')
			button = device and device:GetTooltipButtonPrompt(button, USE, 64)
		end
		self:StartFlash()
		GameTooltip_SetDefaultAnchor(GameTooltip, self)
		GameTooltip:SetSpellByID(self.spellID)
		if button then
			GameTooltip:AddLine(button)
		end
		GameTooltip:Show()
	end
end

function FlyoutButtonMixin:OnClear()
	self:SetChecked(false)
	self:StopFlash()
	if GameTooltip:IsOwned(self) then
		GameTooltip:Hide()
	end
end

function FlyoutButtonMixin:UpdateState(i, name)
	local proxy = _G[name]
	if not proxy or not proxy:IsVisible() then return false end
	self.offSpec = proxy.offSpec;
	self.spellID = proxy.spellID;
	self.spellName = proxy.spellName;
	self:SetIcon(proxy.icon:GetTexture())
	return true
end

function FlyoutButtonMixin:Update(offSpec, spellID, spellName, overrideSpellID)
	self.offSpec = offSpec;
	self.spellID = spellID;
	self.spellName = spellName;
	self:SetIcon(GetSpellTexture(overrideSpellID))
end

function FlyoutButtonMixin:OnDragStart()
	if (self.spellID) and not InCombatLockdown() then
		PickupSpell(self.spellID);
	end
end

-- signature: (self, flyoutID, parent, direction, distance, isActionBar, specID, showFullTooltip, reason)
hooksecurefunc(SpellFlyout, 'Toggle', function(flyout, flyoutID, _, _, _, isActionBar, specID)
	local self = Selector; self:ReleaseAll();
	if not flyout:IsShown() then return end

	local active, offSpec, _, _, numSlots, isKnown = {}, specID and (specID ~= 0), GetFlyoutInfo(flyoutID)
	for i=1, numSlots do
		local spellID, overrideSpellID, isKnown, spellName, slotSpecID = GetFlyoutSlotInfo(flyoutID, i)
		local visible = true

		-- ignore Call Pet spells if there isn't a pet in that slot
		local petIndex, petName = GetCallPetSpellInfo(spellID)
		if (isActionBar and petIndex and (not petName or petName == '')) then
			visible = false
		end

		-- show buttons
		if ( ((not offSpec or slotSpecID == 0) and visible and isKnown) or (offSpec and slotSpecID == specID) ) then
			active[#active+1] = {
				overrideSpellID = overrideSpellID;
				desaturated = offSpec;
				offSpec = offSpec;
				spellID = spellID;
				spellName = spellName;
			}
			-- TODO: all this
			-- SpellFlyoutButton_UpdateCooldown(button);
			-- SpellFlyoutButton_UpdateState(button);
			-- SpellFlyoutButton_UpdateUsable(button);
			-- SpellFlyoutButton_UpdateCount(button);
			-- SpellFlyoutButton_UpdateGlyphState(button, reason);
		end
	end
	for i, data in ipairs(active) do
		local button = self:AddButton(i, #active)
		button:SetIcon(GetSpellTexture(data.overrideSpellID))
		button:GetNormalTexture():SetDesaturated(data.offSpec)
		button.offSpec = data.offSpec;
		button.spellID = data.spellID;
		button.spellName = data.spellName;
		button:SetEnabledState(not data.offSpec)
		button:SetDescription(data.spellName)
	end
end)