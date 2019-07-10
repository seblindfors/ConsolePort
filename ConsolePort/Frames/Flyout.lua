---------------------------------------------------------------
-- Flyout.lua: Flyout frame
---------------------------------------------------------------
-- Adds custom frames to deal with multi-choice spell-casting,
-- such as portals/teleports, totems, pets, etc. 

local _, db = ...

if not SpellFlyout then return end
local Flyout, Selector, GameTooltip = SpellFlyout, ConsolePortSpellFlyout, GameTooltip
local FadeIn = db.UIFrameFadeIn

---------------------------------------------------------------
do local Buttons = {
		Up 		= 'CP_L_UP',
		Down 	= 'CP_L_DOWN',
		Left 	= 'CP_L_LEFT',
		Right 	= 'CP_L_RIGHT',
	}
	-----------------------------------------------------------
	Selector:Execute([[
		Index = 1
		DPAD = newtable()
	]])

	for name, binding in pairs(Buttons) do
		Selector:Execute(format('DPAD.%s = \'%s\'', binding, name))
	end
end
---------------------------------------------------------------

Selector.Buttons = {}
Selector:SetFrameRef('Flyout', Flyout)
Selector:Execute([[
	Visible = 0
	Spells = newtable()
	Flyout = self:GetFrameRef('Flyout')
	Selector = self
]])

Selector:SetAttribute('SelectSpell', [[
	local key = ...
	if key == 'Up' then
		self:SetAttribute('macrotext', '/click '..Spells[Index]:GetName())
	elseif key == 'Down' then
		local owner = Flyout:GetParent()
		owner:Hide()
		owner:Show()
		return
	elseif key == 'Left' then
		Index = Index > 1 and Index - 1 or Index
	elseif key == 'Right' then
		Index = Index < Visible and Index + 1 or Index
	end
	self:SetAttribute('index', Index)
]])

Selector:SetAttribute('ShowSpells', [[
	Spells = newtable(Flyout:GetChildren())
	for i, spell in pairs(Spells) do
		if spell:IsVisible() then
			Visible = i
		end
	end
	self:SetWidth(Visible * 74)
	if not Spells[Index]:IsVisible() then
		Index = 1
		self:SetAttribute('index', Index)
	end
]])

Selector:WrapScript(Flyout, 'OnShow', [[
	Selector:SetAttribute('macrotext', nil)
	Selector:Show()
	Flyout:ClearAllPoints()
	for binding, name in pairs(DPAD) do
		local key = GetBindingKey(binding)
		if key then
			Selector:SetBindingClick(true, key, Selector, name)
		end
	end
	Selector:RunAttribute('ShowSpells')

	local parentName = Flyout:GetParent():GetName()
	if parentName and parentName:match('CPB') then
		Flyout:SetScale(0.01)
		Flyout:SetAlpha(0)
	end
]])

Selector:WrapScript(Flyout, 'OnHide', [[
	Selector:ClearBindings()
	Selector:Hide()
	Flyout:SetScale(1)
	Flyout:SetAlpha(1)
]])

Selector:WrapScript(Selector, 'PreClick', [[
	self:SetAttribute('macrotext', nil)
	if (button == 'LeftButton' or button == 'RightButton') then
		local x = self:GetMousePosition()
		local width = self:GetWidth()
		local newIndex = math.floor(1 + ((x * width) / 74))
		if newIndex <= Visible and newIndex >= 1 then
			Index = newIndex
			self:SetAttribute('index', Index)
			self:SetAttribute('macrotext', '/click '..Spells[Index]:GetName())
		end
	else
		self:RunAttribute('SelectSpell', button)
	end
]])

local function ShowFlyoutTooltip(self)
	GameTooltip:SetOwner(self, 'ANCHOR_TOP', 0, 0)
	GameTooltip:SetSpellByID(self.spellID)
end

function Selector:SetSelection(index)
	for i, button in pairs(self.Buttons) do
		button:UnlockHighlight()
		FadeIn(button, 0.2, button:GetAlpha(), 1 - (abs(i - index) / #self.Buttons))
	end
	local selected = self.Buttons[index]
	if selected then
		selected:LockHighlight()
		ShowFlyoutTooltip(selected)
	end
end

function Selector:OnShow()
	db.Hint:DisplayMessage(format(db.TOOLTIP.FLYOUT, BINDING_NAME_CP_L_UP, BINDING_NAME_CP_L_DOWN), 4, -200)
	for i, spell in pairs({Flyout:GetChildren()}) do
		local button = self.Buttons[i]
		if spell:IsVisible() then
			if not button then
				button = db.Atlas.GetRoundActionButton('$parentFlyoutButton'..i, false, self, nil, nil, true)
				button:SetButtonState('DISABLED')
				button:SetID(i)
				self.Buttons[i] = button
			end
			button.icon:SetTexture(spell.icon:GetTexture())
			button.spellID = spell.spellID
			button:SetPoint('LEFT', (i-1) * 74, 0)
			button:Show()
			local time, cooldown = GetSpellCooldown(spell.spellName)
			if time and cooldown then
				button.cooldown:SetCooldown(time, cooldown)
			end
		elseif button and button:IsVisible() then
			button:Hide()
		end
	end
	self:SetSelection(self:GetAttribute('index') or 1)
end

function Selector:OnHide()
	GameTooltip:Hide()
end

function Selector:OnAttributeChanged(attribute, detail)
	if attribute == 'index' then
		self:SetSelection(detail)
	end
end

---------------------------------------------------------------
Selector:HookScript('OnShow', Selector.OnShow)
Selector:HookScript('OnHide', Selector.OnHide)
Selector:HookScript('OnAttributeChanged', Selector.OnAttributeChanged)
---------------------------------------------------------------

-- add class colors
do local red, green, blue = db.Atlas.GetCC()
	Selector.BG:SetVertexColor(red, green, blue, 0.25)
	Selector.TopLine:SetVertexColor(red, green, blue, 1)
	Selector.BottomLine:SetVertexColor(red, green, blue, 1)
end