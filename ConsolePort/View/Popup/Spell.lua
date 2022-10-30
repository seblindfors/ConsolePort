---------------------------------------------------------------
-- Spell.lua: Popup menu for managing spells
---------------------------------------------------------------
local _, db, L = ...; L = db.Locale;
local SpellMenu = db:Register('SpellMenu', CPAPI.EventHandler(ConsolePortSpellMenu, {
	'PLAYER_REGEN_DISABLED';
}))
---------------------------------------------------------------
local SPELL_MENU_SIZE = 440;
local SPELL_MAP_BAR_SIZE = 600;
local SPELL_MAP_BAR_IDS = {1, 6, 5, 3, 4, 13, 14, 15, 7, 8, 9, 10, 2};
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
	local link = self:GetLink()
	local action = {
		type  = 'spell';
		spell = self:GetSpellID();
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
	local actionButtonsWithSpellID, firstWidget, targetWidget = tInvert(C_ActionBar.FindSpellActionButtons(self:GetSpellID()) or {})
	for barPos, barID in ipairs(SPELL_MAP_BAR_IDS) do
		local text = self.ActionBarText:Acquire()
		text:SetText(SPELL_MAP_BAR_NAMES[barID] or ('%s %d'):format(L'Bar', barPos))
		text:SetPoint('TOPLEFT', 16, -((barPos + 1) * 40) - 12)
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
			widget:SetPoint('TOPLEFT', i * 40 + 40, -((barPos + 1) * 40))
			widget:Update()
			widget:Show()
		end
	end
	self:SetHeight(#SPELL_MAP_BAR_IDS * 40 + 100)
	if targetWidget or firstWidget then
		ConsolePortCursor:SetCurrentNode(targetWidget or firstWidget)
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
-- API
---------------------------------------------------------------
function SpellMenu:GetLink()
	return GetSpellLink(self:GetSpellID())
end

---------------------------------------------------------------
-- Handlers and init
---------------------------------------------------------------
function SpellMenu:OnHide()
	self:ReturnCursor()
	self.ActionButtons:ReleaseAll()
end

function SpellMenu:PLAYER_REGEN_DISABLED()
	self:Hide()
end

---------------------------------------------------------------
SpellMenu:SetScript('OnHide', SpellMenu.OnHide)
Mixin(SpellMenu, CPIndexPoolMixin):OnLoad()
SpellMenu:CreateFramePool('Button', 'CPPopupButtonTemplate', db.PopupMenuButton)
SpellMenu.ActionButtons = CreateFramePool('IndexButton', SpellMenu, 'CPIndexButtonBindingActionButtonTemplate')
SpellMenu.ActionBarText = CreateFontStringPool(SpellMenu, 'ARTWORK', nil, 'CPSmallFont')
db.Stack:AddFrame(SpellMenu)