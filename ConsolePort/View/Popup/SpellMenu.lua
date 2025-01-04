---------------------------------------------------------------
-- SpellMenu.lua: Popup menu for managing spells
---------------------------------------------------------------
local _, db, L = ...; L = db.Locale;
local SpellMenu = db:Register('SpellMenu', CPAPI.EventHandler(ConsolePortSpellMenu, {
	'PLAYER_REGEN_DISABLED';
	'UPDATE_BINDINGS';
}))
---------------------------------------------------------------
local SPELL_MENU_SIZE = 440;
local SPELL_MAP_BAR_SIZE = 660;
local SPELL_MAP_BAR_OFF = 48;
local SPELL_MAP_BAR_IDS = db.Actionbar.Pages;
---------------------------------------------------------------

function SpellMenu:SetSpell(spellID)
	self.ActionButtons:ReleaseAll()
	self.ActionBarText:ReleaseAll()
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
	self.Icon:SetTexture(self:GetSpellTexture())
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
	CPAPI.PickupSpell(self:GetSpellID())
	self:Hide()
end

function SpellMenu:AddUtilityRingCommand()
	local link = self:GetSpellLink()
	local action = {
		type  = 'spell';
		spell = self:GetSpellName();
		link  = link;
	};

	for key in db.table.spairs(db.Utility.Data) do
		local isUniqueAction, existingIndex = db.Utility:IsUniqueAction(key, action)
		if isUniqueAction then
			self:AddCommand(L('Add to %s', db.Utility:ConvertSetIDToDisplayName(key)), 'RingBind', {key, action})
		elseif existingIndex then
			self:AddCommand(L('Remove from %s', db.Utility:ConvertSetIDToDisplayName(key)), 'RingClear', {key, action})
		end
	end
end

function SpellMenu:RingBind(data)
	local setID, action = unpack(data)
	if db.Utility:SetPendingAction(setID, action) then
		db.Utility:PostPendingAction()
	end
	self:Hide()
end

function SpellMenu:RingClear(data)
	local setID, action = unpack(data)
	if db.Utility:SetPendingRemove(setID, action) then
		db.Utility:PostPendingAction()
	end
	self:Hide()
end

function SpellMenu:MapActionBar(keyChord)
	self:SetDisplaySpell(self:GetSpellID())
	self:DisplayBindingsForSpellID(nil)

	local keyChordSlug = keyChord and db.Hotkeys:GetActiveButtonSlug(keyChord[2], keyChord[1])
	local description;
	if keyChordSlug then
		self.keyChord = keyChord;
		description = L('Select a slot to bind %s and place this spell.', keyChordSlug);
		self:DisplayBindingsForPending(keyChordSlug)
	else
		description = L'Select a slot to place this spell.';
		keyChord = nil;
	end

	self:SetWidth(SPELL_MAP_BAR_SIZE)
	self:SetDescription(description)
	self:ReleaseAll()
	self:FixHeight()
	self:Show()

	self.ActionButtons:ReleaseAll()

	local drawnBars, actionButtonsWithSpellID = 0, tInvert(C_ActionBar.FindSpellActionButtons(self:GetSpellID()) or {})
	local currentPage = db.Pager:GetCurrentPage()
	local targetSlot, freeSlot, pageSlot;

	local function GetPrioritySlot(target, candidate, actionID, targetKey, predicate)
		if target then return target end;
		if predicate then
			if targetKey then
				local binding = db('Actionbar/Action/'..actionID)
				if not db.Gamepad:GetBindingKey(binding) then
					return candidate;
				end
			else
				return candidate;
			end
		end
	end

	for _, data in ipairs(SPELL_MAP_BAR_IDS) do
		local shouldDrawBars = data();
		if shouldDrawBars then
			for _, barID in ipairs(data) do
				drawnBars = drawnBars + 1;

				local text = self.ActionBarText:Acquire()
				local name = db('Actionbar/Names/'..barID)

				local isCurrentPage = barID == currentPage;
				local isPagedMain   = ( barID == 1 and currentPage ~= 1 );
				local overrideColor = isPagedMain and GRAY_FONT_COLOR or isCurrentPage and GREEN_FONT_COLOR;

				text:SetText(overrideColor and overrideColor:WrapTextInColorCode(name) or name)
				text:SetWidth(50)
				text:SetJustifyH('LEFT')
				text:Show()

				for i=1, NUM_ACTIONBAR_BUTTONS do
					local actionID = (barID - 1) * NUM_ACTIONBAR_BUTTONS + i;
					local isFreeSlot = not GetActionInfo(actionID);
					local widget, newObj = self.ActionButtons:Acquire()
					if newObj then
						widget:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
						widget:SetDrawOutline(true)
						db.table.mixin(widget, db.PopupMenuMapActionButton)
					end

					pageSlot = GetPrioritySlot(pageSlot, widget, actionID, keyChord, isFreeSlot and isCurrentPage)
					freeSlot = GetPrioritySlot(freeSlot, widget, actionID, keyChord, isFreeSlot)

					if not targetSlot and actionButtonsWithSpellID[actionID] then
						targetSlot = widget;
					end

					widget:SetID(actionID)
					widget:SetSize(44, 44)
					widget:SetPoint('TOPLEFT', (i-1) * SPELL_MAP_BAR_OFF + 64, -((drawnBars + 1) * SPELL_MAP_BAR_OFF - 24))
					widget:Update()
					widget:Show()
					if ( i == 1 ) then
						text:SetPoint('LEFT', widget, 'LEFT', -50, 0)
					end
				end
			end
		end
	end
	self:SetTargetHeight(drawnBars * SPELL_MAP_BAR_OFF + 80 + self.bottomPadding + (keyChordSlug and 16 or 0))
	if targetSlot or freeSlot or pageSlot then
		ConsolePort:SetCursorNodeIfActive(targetSlot or pageSlot or freeSlot)
	end

	local handle = db.UIHandle;
	local leftClick, rightClick, specialClick, cancelClick =
		db('UICursorLeftClick'), db('UICursorRightClick'), db('UICursorSpecial'), db('UICursorCancel')

	handle:SetHintFocus(self, IsGamePadFreelookEnabled())
	if leftClick then
		handle:AddHint(leftClick, L'Place in slot')
	end
	if rightClick then
		handle:AddHint(rightClick, keyChord and L'Cancel and clear cursor' or L'Clear slot or binding')
	end
	if specialClick and not keyChord then
		handle:AddHint(specialClick, L'Set binding')
	end
	if cancelClick then
		handle:AddHint(cancelClick, CANCEL)
	end
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

---------------------------------------------------------------
-- Catcher
---------------------------------------------------------------
SpellMenu.CatchBinding = CreateFrame('Button', nil, SpellMenu,
	(CPAPI.IsRetailVersion and 'SharedButtonLargeTemplate' or 'UIPanelButtonTemplate') .. ',CPPopupBindingCatchButtonTemplate')

local NO_BINDING_TEXT, SET_BINDING_TEXT = [[
|cFFFFFF00Set Binding|r

%s in %s, does not have a binding assigned to it.

Press a button combination to select a new binding for this slot.

]], [[
|cFFFFFF00Set Binding|r

Press a button combination to select a new binding for %s.

]]

function SpellMenu.CatchBinding:OnBindingCaught(button)
	local bindingID = self.bindingID;
	if not bindingID then return end;

	if CPAPI.IsButtonValidForBinding(button) then
		local keychord = CPAPI.CreateKeyChord(button)
		if not db('bindingOverlapEnable') then
			db.table.map(SetBinding, db.Gamepad:GetBindingKey(bindingID))
		end
		if SetBinding(keychord, bindingID) then
			SaveBindings(GetCurrentBindingSet())
			return true;
		end
	end
end

function SpellMenu:CatchBindingForSlot(slot, bindingID, text)
	self.CatchBinding.bindingID = bindingID;
	self.CatchBinding:TryCatchBinding({
		text = text;
		OnShow = function()
			ConsolePort:SetCursorNodeIfActive(slot)
		end;
	})
end

function SpellMenu:ReportNoBinding(slot, bindingID)
	self:CatchBindingForSlot(slot, bindingID, NO_BINDING_TEXT:format(self:GetSpellLink(), _G['BINDING_NAME_'..bindingID] or bindingID))
end

function SpellMenu:ReportSetBinding(slot, bindingID, actionID)
	self:CatchBindingForSlot(slot, bindingID, SET_BINDING_TEXT:format(_G['BINDING_NAME_'..bindingID] or bindingID))
end

function SpellMenu:ReportSetBindingToKeyChord(bindingID)
	if self.keyChord then
		local keyChord = table.concat(self.keyChord)
		SetBinding(keyChord, bindingID)
		SaveBindings(GetCurrentBindingSet())
		self.keyChord = nil;
	end
end

function SpellMenu:ReportClearBinding(bindingID)
	if bindingID then
		db.table.map(SetBinding, db.Gamepad:GetBindingKey(bindingID))
		SaveBindings(GetCurrentBindingSet())
	end
end

function SpellMenu:HasPendingKeyChord()
	return not not self.keyChord;
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

function SpellMenu:DisplayBindingsForPending(slug)
	local header = self.BindingHeader;
	header.Text:SetText(GRAY_FONT_COLOR:WrapTextInColorCode(slug))
	header:ClearAllPoints()
	header:SetPoint('BOTTOM', 0, 20)
	header:Show()
end

---------------------------------------------------------------
-- API
---------------------------------------------------------------
SpellMenu.GetSpellLink = SpellMenu.GetSpellLink or function(self)
	return (CPAPI.GetSpellLink(self:GetSpellID()));
end

SpellMenu.GetSpellName = SpellMenu.GetSpellName or function(self)
	return (CPAPI.GetSpellName(self:GetSpellID()));
end

SpellMenu.GetSpellTexture = SpellMenu.GetSpellTexture or function(self)
	return (CPAPI.GetSpellTexture(self:GetSpellID()));
end

function SpellMenu:GetSpellSubtext()
	return (CPAPI.GetSpellSubtext(self:GetSpellID()));
end

---------------------------------------------------------------
-- Handlers and init
---------------------------------------------------------------
function SpellMenu:OnHide()
	self.ActionButtons:ReleaseAll()
	self.BindingHeader:Hide()
	self.keyChord = nil;

	local handle = db.UIHandle;
	if handle:IsHintFocus(self) then
		handle:HideHintBar()
	end
	handle:ClearHintsForFrame(self)
end

function SpellMenu:OnCursorChanged(isDefault, cursorType, oldCursorType)
	if not db('bindingShowSpellMenuGrid') then return end;
	if ConsolePortConfig and ConsolePortConfig:IsShown() then return end;

	if ( isDefault and oldCursorType == Enum.UICursorType.Spell ) then
		return self:Hide()
	elseif ( cursorType == Enum.UICursorType.Spell ) then
		local _, _, _, spellID = GetCursorInfo()
		self:SetSpell(spellID)
		self:MapActionBar()
	end
end

function SpellMenu:OnSlotRequest(modID, btnID, kind, value, subType, spellID)
	if ( kind == 'spell') then
		self:SetSpell(spellID)
		self:MapActionBar({ modID, btnID })
	end
end

function SpellMenu:PLAYER_REGEN_DISABLED()
	self:Hide()
end

function SpellMenu:UPDATE_BINDINGS()
	for widget in self.ActionButtons:EnumerateActive() do
		widget:UpdateBinding()
	end
end

---------------------------------------------------------------
SpellMenu:HookScript('OnHide', SpellMenu.OnHide)
SpellMenu:SetAttribute('nodepass', true)
SpellMenu:CreateFramePool('Button', 'CPPopupButtonTemplate', db.PopupMenuButton)
SpellMenu.ActionButtons = CreateFramePool('IndexButton', SpellMenu, 'CPIndexButtonBindingActionButtonTemplate')
SpellMenu.ActionBarText = CreateFontStringPool(SpellMenu, 'ARTWORK', nil, 'CPSmallFont')
---------------------------------------------------------------
GameMenuFrame:HookScript('OnShow', GenerateClosure(SpellMenu.Hide, SpellMenu))
---------------------------------------------------------------
db:RegisterCallback('OnCursorChanged', SpellMenu.OnCursorChanged, SpellMenu)
db:RegisterCallback('OnSlotRequest', SpellMenu.OnSlotRequest, SpellMenu)
db:RegisterCallback('PlayerSpellsFrame.OpenFrame', SpellMenu.SetBackgroundAlpha, SpellMenu, 0.95)
db:RegisterCallback('PlayerSpellsFrame.CloseFrame', SpellMenu.SetBackgroundAlpha, SpellMenu, 0.75)