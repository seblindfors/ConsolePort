---------------------------------------------------------------
-- Spell.lua: Popup menu for managing spells
---------------------------------------------------------------
local _, db, L = ...; L = db.Locale;
local SpellMenu = db:Register('SpellMenu', CPAPI.EventHandler(ConsolePortSpellMenu, {
	'PLAYER_REGEN_DISABLED';
	'UPDATE_BINDINGS';
}))
---------------------------------------------------------------
local SPELL_MENU_SIZE = 440;
local SPELL_MAP_BAR_SIZE = 600;
local SPELL_MAP_BAR_IDS = db.Actionbar.Pages;
local SPELL_MAP_BAR_NAMES = {
	[2] = L'Page 2';
	[7] = L'Stance 1';
	[8] = L'Stance 2';
	[9] = L'Stance 3';
	[10] = L'Stance 4';
}
---------------------------------------------------------------
local SpellMapButtonPool;

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
	self.Icon:SetTexture(self:GetSpellTexture())
	self.Name:SetText(self:GetSpellName())
end

function SpellMenu:FixHeight()
	local lastItem = self:GetObjectByIndex(self:GetNumActive())
	if lastItem then
		local height = self:GetHeight() or 0
		local bottom = self:GetBottom() or 0
		local anchor = lastItem:GetBottom() or 0
		self:SetHeight(height + bottom - anchor + 16)
	end
end

function SpellMenu:RedirectCursor()
	self.returnToNode = self.returnToNode or ConsolePortCursor:GetCurrentNode()
	ConsolePortCursor:SetCurrentNode(self:GetObjectByIndex(1))
end

function SpellMenu:ReturnCursor()
	if self.returnToNode then
		ConsolePortCursor:SetCurrentNode(self.returnToNode)
		self.returnToNode = nil
	end
end

---------------------------------------------------------------
-- Add spell commands
---------------------------------------------------------------
function SpellMenu:SetCommands()
	self:ReleaseAll()

	self:AddCommand(L'Place on action bar', 'MapActionBar')
	self:AddUtilityRingCommand()
	self:AddCommand(L'Pick up', 'Pickup')
end

---------------------------------------------------------------
-- Commands
---------------------------------------------------------------
function SpellMenu:Pickup()
	PickupSpell(self:GetSpellID())
	self:Hide()
end

function SpellMenu:AddUtilityRingCommand()
	local link = self:GetSpellLink()
	local action = {
		type  = 'spell';
		spell = self:GetSpellName();
		link  = link;
	};

	if db.Utility:SetPendingAction(1, action) then
		self:AddCommand(L'Add to Utility Ring', 'RingBind')
	else
		local _, existingIndex = db.Utility:IsUniqueAction(1, action)
		if existingIndex then
			db.Utility:SetPendingRemove(1, action)
			self:AddCommand(L'Remove from Utility Ring', 'RingClear')
		end
	end
end

function SpellMenu:RingBind()
	if db.Utility:HasPendingAction() then
		db.Utility:PostPendingAction()
	end
	self:Hide()
end

SpellMenu.RingClear = SpellMenu.RingBind;

function SpellMenu:MapActionBar()
	self:SetDisplaySpell(self:GetSpellID())
	self:SetWidth(SPELL_MAP_BAR_SIZE)
	self:SetDescription(L'Select a slot to place this spell.')
	self:ReleaseAll()
	self:FixHeight()
	self:Show()

	self.ActionButtons:ReleaseAll()
	local drawnBars, actionButtonsWithSpellID, firstWidget, targetWidget = 0, tInvert(C_ActionBar.FindSpellActionButtons(self:GetSpellID()) or {})
	for _, data in ipairs(SPELL_MAP_BAR_IDS) do
		local shouldDrawBars = data();
		if shouldDrawBars then
			for barPos, barID in ipairs(data) do
				drawnBars = drawnBars + 1;

				local text = self.ActionBarText:Acquire()
				text:SetText(db('Actionbar/Names/'..barID))
				text:SetPoint('TOPLEFT', 16, -((drawnBars + 1) * 40) - 12)
				text:Show()
				for i=1, NUM_ACTIONBAR_BUTTONS do
					local actionID = (barID - 1) * NUM_ACTIONBAR_BUTTONS + i;
					local widget, newObj = self.ActionButtons:Acquire()
					if newObj then
						widget:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
						widget:SetDrawOutline(true)
						db.table.mixin(widget, db.PopupMenuMapActionButton)
					end
					if not firstWidget and not GetActionInfo(actionID) then
						firstWidget = widget;
					end
					if not targetWidget and actionButtonsWithSpellID[actionID] then
						targetWidget = widget;
					end
					widget:SetID(actionID)
					widget:SetPoint('TOPLEFT', i * 40 + 40, -((drawnBars + 1) * 40))
					widget:Update()
					widget:Show()
				end
			end
		end
	end
	self:SetHeight(drawnBars * 40 + 100)
	if targetWidget or firstWidget then
		ConsolePortCursor:SetCurrentNode(targetWidget or firstWidget)
	end

	local handle = db.UIHandle;
	local leftClick, rightClick, specialClick =
		db('UICursorLeftClick'), db('UICursorRightClick'), db('UICursorSpecial')

	handle:SetHintFocus(self)
	if leftClick then
		handle:AddHint(leftClick, L'Place in slot')
	end
	if rightClick then
		handle:AddHint(rightClick, L'Clear slot or binding')
	end
	if specialClick then
		handle:AddHint(specialClick, L'Set binding')
	end
end

function SpellMenu:AddCommand(text, command, data)
	local widget, newObj = self:Acquire(self:GetNumActive() + 1)
	local anchor = self:GetObjectByIndex(self:GetNumActive() - 1)

	if newObj then
		widget:SetScript('OnClick', widget.OnClick)
	end
	
	widget:SetCommand(text, command, data)
	widget:SetPoint('TOPLEFT', anchor or self.Tooltip, 'BOTTOMLEFT', anchor and 0 or 8, anchor and 0 or -16)
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
	tooltip:SetPoint('TOPLEFT', 80, -16)
end

function SpellMenu:SetDescription(text)
	local tooltip = self.Tooltip
	tooltip:SetParent(self)
	tooltip:SetOwner(self, 'ANCHOR_NONE')
	tooltip:SetText(' ')
	tooltip:AddLine(text, 1, 1, 1)
	tooltip:Show()
	tooltip:ClearAllPoints()
	tooltip:SetPoint('TOPLEFT', 80, -16)
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
			db.Cursor:SetCurrentNode(slot)
		end;
	})
end

function SpellMenu:ReportNoBinding(slot, bindingID)
	self:CatchBindingForSlot(slot, bindingID, NO_BINDING_TEXT:format(self:GetSpellLink(), _G['BINDING_NAME_'..bindingID] or bindingID))
end

function SpellMenu:ReportSetBinding(slot, bindingID, actionID)
	self:CatchBindingForSlot(slot, bindingID, SET_BINDING_TEXT:format(_G['BINDING_NAME_'..bindingID] or bindingID))
end

function SpellMenu:ReportClearBinding(bindingID)
	if bindingID then
		db.table.map(SetBinding, db.Gamepad:GetBindingKey(bindingID))
		SaveBindings(GetCurrentBindingSet())
	end
end

---------------------------------------------------------------
-- API
---------------------------------------------------------------
SpellMenu.GetSpellLink = SpellMenu.GetSpellLink or function(self)
	return (GetSpellLink(self:GetSpellID()));
end

SpellMenu.GetSpellName = SpellMenu.GetSpellName or function(self)
	return (GetSpellName(self:GetSpellID()));
end

SpellMenu.GetSpellTexture = SpellMenu.GetSpellTexture or function(self)
	return (GetSpellTexture(self:GetSpellID()));
end

---------------------------------------------------------------
-- Handlers and init
---------------------------------------------------------------
function SpellMenu:OnHide()
	self:ReturnCursor()
	self.ActionButtons:ReleaseAll()

	local handle = db.UIHandle;
	if handle:IsHintFocus(self) then
		handle:HideHintBar()
	end
	handle:ClearHintsForFrame(self)
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
SpellMenu:SetScript('OnHide', SpellMenu.OnHide)
Mixin(SpellMenu, CPIndexPoolMixin):OnLoad()
SpellMenu:CreateFramePool('Button', 'CPPopupButtonTemplate', db.PopupMenuButton)
SpellMenu.ActionButtons = CreateFramePool('IndexButton', SpellMenu, 'CPIndexButtonBindingActionButtonTemplate')
SpellMenu.ActionBarText = CreateFontStringPool(SpellMenu, 'ARTWORK', nil, 'CPSmallFont')
db.Stack:AddFrame(SpellMenu)