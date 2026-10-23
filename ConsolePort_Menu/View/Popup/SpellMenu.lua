---------------------------------------------------------------
-- SpellMenu.lua: Popup menu for managing spells
---------------------------------------------------------------
local env, db, _, L = CPAPI.GetEnv(...);
local SpellMenu = db:Register('SpellMenu', CPAPI.EventHandler(ConsolePortSpellMenu, {
	'PLAYER_REGEN_DISABLED';
}))
---------------------------------------------------------------
local SPELL_MENU_SIZE = 440;
---------------------------------------------------------------

function SpellMenu:SetSpell(spellID)
	self:SetDisplaySpell(spellID)
	self:SetWidth(SPELL_MENU_SIZE)
	self:SetTooltip()
	self:SetCommands()
	self:FixHeight()
	self:Show()
	self:RedirectCursor()
end

function SpellMenu:SetDisplaySpell(spellID)
	self:SetSpellID(spellID)
	if self:IsSpellEmpty() then
		return self:Hide()
	end
	local name, subtext = self:GetSpellName(), self:GetSpellSubtext();
	local hasSubtext = subtext and subtext ~= '';
	self.Portrait.Icon:SetTexture(self:GetSpellTexture())
	self.Name:SetText(hasSubtext and ('%s: %s'):format(name, WHITE_FONT_COLOR:WrapTextInColorCode(subtext)) or name)
end

---------------------------------------------------------------
-- Add spell commands
---------------------------------------------------------------
function SpellMenu:SetCommands()
	self:ReleaseAll()
	self:DisplayBindingsForSpellID(self:GetSpellID())

	self:AddCommand(L'Place on action bar', 'MapActionBar')
	self:AddUtilityRingCommand()
	self:AddCommand(L'Pick up', 'Pickup')
end

---------------------------------------------------------------
-- Commands
---------------------------------------------------------------
function SpellMenu:Pickup()
	C_Spell.PickupSpell(self:GetSpellID())
	self:Hide()
end

function SpellMenu:AddUtilityRingCommand()
	local link = self:GetSpellLink()
	local action = {
		type  = 'spell';
		spell = self:GetSpellName();
		link  = link;
	};

	for key in db.table.spairs(ConsolePort:GetRingsData()) do
		local isUniqueAction, existingIndex = ConsolePort:IsUniqueRingAction(key, action)
		if isUniqueAction then
			self:AddCommand(L('Add to %s', db.Bindings:ConvertRingSetIDToDisplayName(key)), 'RingBind', {key, action})
		elseif existingIndex then
			self:AddCommand(L('Remove from %s', db.Bindings:ConvertRingSetIDToDisplayName(key)), 'RingClear', {key, action})
		end
	end
end

function SpellMenu:RingBind(data)
	local setID, action = unpack(data)
	if ConsolePort:SetPendingRingAction(setID, action) then
		ConsolePort:PostPendingRingAction()
	end
	self:Hide()
end

function SpellMenu:RingClear(data)
	local setID, action = unpack(data)
	if ConsolePort:SetPendingRingRemove(setID, action) then
		ConsolePort:PostPendingRingAction()
	end
	self:Hide()
end

function SpellMenu:MapActionBar(keyChord)
	local spellID = self:GetSpellID()
	self:Hide()
	env.ShowActionPlacer('spell', keyChord, spellID)
end

function SpellMenu:AddCommand(text, command, data)
	local widget, newObj = self:Acquire(self:GetNumActive() + 1)
	local anchor = self:GetObjectByIndex(self:GetNumActive() - 1)

	if newObj then
		widget:OnLoad()
	end

	widget:SetCommand(text, command, data)
	widget:SetPoint('TOPLEFT', anchor or self.Tooltip, 'BOTTOMLEFT',
		anchor and 0 or self.buttonOffsetX,
		anchor and 1 or (self.BindingHeader:IsShown() and -40 or -16))
	widget:Show()
end

---------------------------------------------------------------
-- Tooltip
---------------------------------------------------------------
SpellMenu.Tooltip = ConsolePortPopupMenuTooltip;

function SpellMenu:SetTooltip()
	local tooltip = self.Tooltip
	tooltip:SetParent(self)
	tooltip:SetOwner(self, 'ANCHOR_NONE')
	tooltip:SetSpellByID(self:GetSpellID())
	tooltip:Show()
	tooltip:ClearAllPoints()
	tooltip:SetPoint('TOPLEFT', self.tooltipOffsetX, -16)
	db.Alpha.FadeIn(self.Tooltip, 0.25, 0, 1)
end

function SpellMenu:SetDescription(text)
	local tooltip = self.Tooltip
	tooltip:SetParent(self)
	tooltip:SetOwner(self, 'ANCHOR_NONE')
	tooltip:SetText(' ')
	tooltip:AddLine(text, 1, 1, 1)
	tooltip:Show()
	tooltip:ClearAllPoints()
	tooltip:SetPoint('TOPLEFT', self.tooltipOffsetX, -16)
end

function SpellMenu:ClearTooltip()
	self.Tooltip:Hide()
end

function SpellMenu:DisplayBindingsForSpellID(spellID)
	if not spellID then return self.BindingHeader:Hide() end;
	local actionButtons = C_ActionBar.FindSpellActionButtons(spellID)
	if actionButtons then
		local slugs = {};
		for _, button in ipairs(actionButtons) do
			local binding = db('Actionbar/Action/'..button)
			local slug = binding and db.Hotkeys:GetButtonSlugForBinding(binding)
			if slug then
				slugs[#slugs + 1] = slug;
			end
		end
		if next(slugs) then
			local slug = table.concat(slugs, ' | ')
			local header = self.BindingHeader;
			header.Text:SetText(GRAY_FONT_COLOR:WrapTextInColorCode(slug))
			header:ClearAllPoints()
			header:SetPoint('TOPLEFT', self.Tooltip, 'BOTTOMLEFT', self.buttonOffsetX, -8)
			header:Show()
		end
	end
end

---------------------------------------------------------------
-- API
---------------------------------------------------------------
SpellMenu.GetSpellLink = SpellMenu.GetSpellLink or function(self)
	return (C_Spell.GetSpellLink(self:GetSpellID()));
end

SpellMenu.GetSpellName = SpellMenu.GetSpellName or function(self)
	return (C_Spell.GetSpellName(self:GetSpellID()));
end

SpellMenu.GetSpellTexture = SpellMenu.GetSpellTexture or function(self)
	return (C_Spell.GetSpellTexture(self:GetSpellID()));
end

function SpellMenu:GetSpellSubtext()
	return (C_Spell.GetSpellSubtext(self:GetSpellID()));
end

---------------------------------------------------------------
-- Handlers and init
---------------------------------------------------------------
function SpellMenu:OnHide()
	self.BindingHeader:Hide()
end

function SpellMenu:OnCursorChanged(isDefault, cursorType, oldCursorType)
	if not db('bindingShowSpellMenuGrid') then return end;
	if ConsolePortConfig and ConsolePortConfig:IsShown() then return end;

	local placer = ConsolePortActionPlacer;
	if ( isDefault and oldCursorType == Enum.UICursorType.Spell ) then
		if ( placer and placer:IsShown() and not placer.placing ) then
			placer:Hide()
		end
	elseif ( cursorType == Enum.UICursorType.Spell ) then
		local _, _, _, spellID = GetCursorInfo()
		env.ShowActionPlacer('spell', nil, spellID)
	end
end

function SpellMenu:OnSlotRequest(modID, btnID, kind, value, subType, spellID)
	if ( kind == 'spell' ) then
		env.ShowActionPlacer('spell', { modID, btnID }, spellID)
	elseif ( kind == 'item' ) then
		env.ShowActionPlacer('item', { modID, btnID }, value)
	end
end

function SpellMenu:PLAYER_REGEN_DISABLED()
	self:Hide()
end

---------------------------------------------------------------
SpellMenu:HookScript('OnHide', SpellMenu.OnHide)
SpellMenu:SetAttribute('nodepass', true)
SpellMenu:CreateFramePool('Button', 'CPPopupButtonTemplate', db.PopupMenuButton)
---------------------------------------------------------------
GameMenuFrame:HookScript('OnShow', GenerateClosure(SpellMenu.Hide, SpellMenu))
---------------------------------------------------------------
db:RegisterCallback('OnCursorChanged', SpellMenu.OnCursorChanged, SpellMenu)
db:RegisterCallback('OnSlotRequest', SpellMenu.OnSlotRequest, SpellMenu)
EventRegistry:RegisterCallback('PlayerSpellsFrame.OpenFrame', SpellMenu.SetBackgroundAlpha, SpellMenu, 0.95)
EventRegistry:RegisterCallback('PlayerSpellsFrame.CloseFrame', SpellMenu.SetBackgroundAlpha, SpellMenu, 0.75)