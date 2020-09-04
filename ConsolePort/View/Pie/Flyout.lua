-- TODO: CLEAN
-- TODO: handle spellflyout updates
local _, db = ...;
local Flyout, Selector, FlyoutButtonMixin = SpellFlyout, CPAPI.EventHandler(ConsolePortSpellFlyout, {'SPELL_FLYOUT_UPDATE'}), {}

Selector:SetFrameRef('flyout', Flyout)
Selector.Arrow = Selector:CreateTexture(nil, 'ARTWORK')
Selector.Arrow:SetTexture([[Interface\AddOns\ConsolePort\Assets\UtilityRunes.blp]])
Selector.Arrow:SetPoint('CENTER', 0, 0)
Selector.Arrow:SetSize(450, 450)
Selector.Arrow.Color = C_ClassColor.GetClassColor(select(2, UnitClass('player')))
Selector.Arrow.Valid = CreateColor(1, 1, 1, 1)

Selector:Execute('this = self; that = self:GetFrameRef("flyout"); BUTTONS = newtable()')
Selector:WrapScript(Flyout, 'OnShow', [[
	wipe(BUTTONS)
	this:CallMethod('Release')
	local children = newtable(self:GetChildren())
	for i, child in ipairs(children) do
		if child:IsVisible() then
			BUTTONS[#BUTTONS+1] = child
		end
	end

	this:SetAttribute('size', #BUTTONS)
	for i, child in ipairs(BUTTONS) do
		this:CallMethod('AddButton', i, child:GetName())
	end

	self:SetAlpha(0.25)
	this:Show()

	local mods = newtable(this:RunAttribute('GetModifiersHeld'))
	local btns = newtable(this:RunAttribute('GetButtonsHeld'))
	table.sort(mods)
	mods[#mods+1] = table.concat(mods)

	for _, button in ipairs(btns) do
		this:SetBindingClick(true, button, this, 'LeftButton')
		for _, modifier in ipairs(mods) do
			this:SetBindingClick(true, (modifier..button):upper(), this, 'LeftButton')
			print(modifier..button)
		end
	end
]])

Selector:WrapScript(Flyout, 'OnHide', [[
	wipe(BUTTONS)
	this:ClearBindings()
	this:Hide()
	this:CallMethod('Release')
	self:SetAlpha(1)
]])

Selector:WrapScript(Selector, 'PreClick', [[
	print(button,down)
	local index = self:RunAttribute('GetIndex')
	local button = index and BUTTONS[index]
	if button then
		self:SetAttribute('type', 'macro')
		self:SetAttribute('macrotext', '/click '..button:GetName())
	else
		self:CallMethod('ClearInstantly')
		self:SetAttribute('type', nil)
		local owner = that:GetParent()
		owner:Hide()
		owner:Show()
	end
]])

function Selector:SPELL_FLYOUT_UPDATE(...)
	print(GetTime(), ...)
end

function Selector:OnDataLoaded(...)
	self.pool = CreateFramePool('CheckButton', self, 'CPButtonTemplate')
	local sticks = db('radialPrimaryStick')
	db('Radial'):Register(self, 'SpellFlyout', {
		sticks = sticks;
		target = {sticks[1]};
	});

	self.OnInput = function(self, x, y, len, stick)
		local index, button = self:GetIndexForPos(x, y, len)
		local oldIdx = self:SetIndex(index)
		for i=1, self.size do
			button = self[i]
			if button and i == index then
				button:OnFocus(oldIdx)
			elseif button and i == oldIdx then
				button:OnClear()
			end
		end
		self:UpdateArrow(x, y, len)
	end;
end

function Selector:UpdateArrow(x, y, len)
	if len > 0.5 then
		self.Arrow:SetVertexColor(self.Arrow.Valid:GetRGBA())
	else
		self.Arrow:SetVertexColor(self.Arrow.Color:GetRGBA())
	end
	self.Arrow:SetRotation(self:GetRotation(x, y))
	self.Arrow:SetAlpha(len^2)
end

function Selector:SetIndex(index)
	local oldIdx = self.index
	self.index = index
	if oldIdx ~= index then
		return oldIdx
	end
end

function Selector:Release()
	self.pool:ReleaseAll()
	self.size = 0;
	self.index = nil;
--	self.Arrow:SetAlpha(0)
end

function Selector:AddButton(i, name)
	local button, newObj = self.pool:Acquire()
	if newObj then
		Mixin(button, FlyoutButtonMixin)
	end
	button:SetPoint(self:GetPointForIndex(i))
	button:StopFlash()
	button:SetChecked(false)
	button:Show()
	button:UpdateState(i, name)
	self[i] = button
	self.size = self.size + 1
end

function FlyoutButtonMixin:OnFocus(newFocus)
	self:SetChecked(true)
	if newFocus then
		local x = select(4, self:GetPoint())
		self:StartFlash()
		GameTooltip_SetDefaultAnchor(GameTooltip, self)
		GameTooltip:SetSpellByID(self.spellID)
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
--	local spellID, overrideSpellID, isKnown, spellName, slotSpecID = GetFlyoutSlotInfo(flyoutID, i)
	local proxy = _G[name]
	if not proxy then return end
	self.offSpec = proxy.offSpec;
	self.spellID = proxy.spellID;
	self.spellName = proxy.spellName;
	self:SetIcon(proxy.icon:GetTexture())
end