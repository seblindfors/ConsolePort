local env, db, _, L = CPAPI.GetEnv(...);
---------------------------------------------------------------
-- Action placer: pick a slot for a spell, item or macro
---------------------------------------------------------------
local Placer = CreateFromMixins(CPButtonCatcherMixin, CPCombatHideMixin);
env.ActionPlacer = Placer;

local SLOT_EVENT, BINDING_EVENT = 'Placer.OnSlotClicked', 'Placer.OnBindingClicked';
local LIST_TOP, LIST_BOTTOM, LIST_PADDING, MAX_HEIGHT_RATIO = 98, 36, 24, 0.8;
local Current = {};

---------------------------------------------------------------
-- Payloads
---------------------------------------------------------------
local Payloads = {};
env.ActionPayloads = Payloads;

local function IsActionOfKind(actionID, kind, id)
	local actionKind, actionValue = GetActionInfo(actionID)
	return actionKind == kind and actionValue == id;
end

function Payloads.spell(spellID)
	local onBars = tInvert(C_ActionBar.FindSpellActionButtons(spellID) or {});
	return {
		kind     = 'spell';
		id       = spellID;
		name     = C_Spell.GetSpellName(spellID);
		icon     = C_Spell.GetSpellTexture(spellID);
		pickup   = GenerateClosure(C_Spell.PickupSpell, spellID);
		isMapped = function(actionID)
			return onBars[actionID] or IsActionOfKind(actionID, 'spell', spellID);
		end;
	};
end

function Payloads.item(itemID, bagID, slotID)
	local info = CPAPI.GetItemInfo(itemID)
	return {
		kind     = 'item';
		id       = itemID;
		name     = info.itemName;
		icon     = info.itemTexture or (C_Item and C_Item.GetItemIconByID and C_Item.GetItemIconByID(itemID));
		pickup   = bagID and GenerateClosure(C_Container.PickupContainerItem, bagID, slotID)
			or GenerateClosure(C_Item.PickupItem, itemID);
		isMapped = function(actionID)
			return IsActionOfKind(actionID, 'item', itemID);
		end;
	};
end

function Payloads.macro(macroID)
	local name, icon = GetMacroInfo(macroID)
	return {
		kind     = 'macro';
		id       = macroID;
		name     = name;
		icon     = icon;
		pickup   = GenerateClosure(PickupMacro, macroID);
		isMapped = function(actionID)
			return IsActionOfKind(actionID, 'macro', macroID);
		end;
	};
end

---------------------------------------------------------------
-- Rows
---------------------------------------------------------------
local Row = CreateFromMixins(env.Elements.ActionbarMapper);

local function UpdatePlacerPrompts(button)
	local useMouseHints = not ConsolePort:IsCursorNode(button);
	local hints = {
		env:GetTooltipPromptForClick('LeftClick', L'Place in slot', useMouseHints);
		env:GetTooltipPromptForClick('RightClick', L'Clear Slot', useMouseHints);
	};
	if useMouseHints then
		hints[#hints + 1] = env:GetTooltipPromptForClick('LeftClick', L'Shift-click to Edit Binding', true);
		hints[#hints + 1] = env:GetTooltipPromptForClick('RightClick', L'Shift-right-click to Clear Binding', true);
	else
		hints[#hints + 1] = env:GetTooltipPromptForClick('Special', L'Edit Binding', false);
		hints[#hints + 1] = env:GetTooltipPromptForClick('Cancel', CANCEL, false);
	end
	button.tooltipHints = hints;
	return hints;
end

local function CancelPlacer()
	if Current.frame then
		Current.frame:Hide()
	end
end

function Row:OnAcquire(new)
	if new then
		Mixin(self, Row)
		self:SetScript('OnEvent', CPAPI.EventMixin.OnEvent)
		self:EnableMouse(false)
	end
	self:InitButtons()
	self.Info:SetPoint('BOTTOMRIGHT', self[1], 'BOTTOMLEFT', -4, 0)
	db:RegisterCallback('OnActionPageChanged', self.UpdateActivePage, self)
	env:RegisterCallback('OnActionSlotHighlight', self.UpdateSlotHighlight, self)
	self:RegisterEvent('ACTIONBAR_SLOT_CHANGED')
end

function Row:UpdateChildren(data)
	env.Elements.ActionbarMapper.UpdateChildren(self, data)
	local payload = Current.payload;
	for i = 1, NUM_ACTIONBAR_BUTTONS do
		local button = self[i];
		if button then
			button:SetSlotEvent(SLOT_EVENT)
			button.UpdatePrompts = UpdatePlacerPrompts;
			button.OnCancelClick = CancelPlacer;
			button.SelectedTexture:SetShown(button:IsShown() and payload and payload.isMapped(button:GetID()))
		end
	end
end

function Row:OnRelease()
	for i = 1, NUM_ACTIONBAR_BUTTONS do
		local button = self[i];
		if button then
			button.UpdatePrompts = nil;
			button.OnCancelClick = nil;
			button:SetSlotEvent('OnActionSlotEdit')
			button.SelectedTexture:Hide()
		end
	end
	env.Elements.ActionbarMapper.OnRelease(self)
end

function Row:UpdateSlotSelection()
	-- Selection follows the payload, not the config's slot editor.
end

---------------------------------------------------------------
-- Pages
---------------------------------------------------------------
local function GetGroupName(container, seen)
	local name = db.Actionbar.Names[container];
	if seen[name] then
		local first, last = db.Actionbar.Names[container[1]], db.Actionbar.Names[container[#container]];
		name = first == last and first or ('%s - %s'):format(first, last);
	end
	seen[name] = true;
	return name;
end

function Placer:IsBarLive(barID)
	for i = 1, db.Actionbar:GetBarWidth(barID) do
		local actionID = db.Actionbar:GetSlotID(barID, i)
		if GetActionInfo(actionID) or db.Gamepad:GetBindingKey(db('Actionbar/Action/'..actionID)) then
			return true;
		end
	end
	return false;
end

function Placer:IsGroupVisible(container)
	if not container() then return false end;
	if not CPAPI.IsCamelotVersion or db.Actionbar:IsGamepadBar(container[1]) then
		return true;
	end
	for _, barID in ipairs(container) do
		if self:IsBarLive(barID) then
			return true;
		end
	end
	return false;
end

function Placer:GetPagedBar()
	return db.Actionbar.Gamepad and db.Actionbar:GetGamepadPagedBar() or 1;
end

function Placer:FindPageForBar(barID)
	for index, container in ipairs(db.Actionbar.Pages) do
		if tContains(container, barID) then
			return index;
		end
	end
end

function Placer:BuildTabs()
	local tabs = self.Tabs;
	tabs:RemoveAllButtons()
	tabs.buttonPool:ReleaseAll()
	tabs.nextLayoutIndex = 1;
	tabs.tabIndex = nil;

	local entries, seen = {}, {};
	wipe(self.tabPages)
	for pageIndex, container in ipairs(db.Actionbar.Pages) do
		if self:IsGroupVisible(container) then
			self.tabPages[#self.tabPages + 1] = pageIndex;
			entries[#entries + 1] = { text = GetGroupName(container, seen) };
		end
	end
	tabs:AddTabs(entries)
end

function Placer:GetTabForPage(pageIndex)
	return tIndexOf(self.tabPages, pageIndex) or 1;
end

function Placer:OnTabSelected(_, tabIndex)
	self.pageIndex = self.tabPages[tabIndex];
	self:RenderPage()
	self:FocusPage()
end

function Placer:FocusPage()
	local container = db.Actionbar.Pages[self.pageIndex];
	if not container then return end;
	local pending = self.pendingFocus;
	if ( pending and tContains(container, pending[1]) ) then
		self.pendingFocus = nil;
		return self:FocusSlot(pending[1], pending[2])
	end
	for _, barID in ipairs(container) do
		if ( self:IsBarLive(barID) or self.expanded[barID] ) then
			return self:FocusSlot(barID, 1)
		end
	end
	CPAPI.Next(function()
		local frame = self.List:GetScrollView():GetFrames()[1];
		if frame then
			ConsolePort:SetCursorNodeIfActive(frame)
		end
	end)
end

function Placer:SetPageByDelta(delta)
	if delta < 0 then
		self.Tabs:Decrement()
	else
		self.Tabs:Increment()
	end
end

function Placer:RenderPage()
	local container = db.Actionbar.Pages[self.pageIndex];
	local dataProvider = self.List:GetDataProvider()
	dataProvider:Flush()
	if not container then return end;
	local contentHeight = 0;

	for _, barID in ipairs(container) do
		local stance = db.Actionbar.Lookup.Stances[barID];
		local name   = stance and stance.name or db.Actionbar.Names[barID];
		if ( self:IsBarLive(barID) or self.expanded[barID] ) then
			contentHeight = contentHeight + Row.size.y + 2;
			dataProvider:Insert(Row:New({
				bar   = barID;
				event = BINDING_EVENT;
				field = {
					name = name;
					icon = stance and stance.iconID or false;
					info = stance or false;
				};
			}))
		else
			contentHeight = contentHeight + env.Elements.Button.size.y + 2;
			dataProvider:Insert(env.Elements.Button:New({
				text  = ('%s %s'):format(name, GRAY_FONT_COLOR:WrapTextInColorCode(('(%s)'):format(L'empty')));
				atlas = 'common-icon-forwardarrow';
				callback = function()
					self.expanded[barID] = true;
					self:RenderPage()
					self:FocusSlot(barID, 1)
				end;
			}))
		end
	end
	self:SetHeight(math.min(
		LIST_TOP + LIST_BOTTOM + LIST_PADDING + contentHeight,
		UIParent:GetHeight() * MAX_HEIGHT_RATIO))
end

function Placer:FocusSlot(barID, index)
	CPAPI.Next(function()
		local scrollView = self.List:GetScrollView()
		local dataProvider = self.List:GetDataProvider()
		local elementData = dataProvider:FindElementDataByPredicate(function(elementData)
			local data = elementData:GetData()
			return data.bar == barID;
		end, false)
		if not elementData then return end;
		pcall(scrollView.ScrollToElementData, scrollView, elementData)
		local frame = scrollView:FindFrame(elementData)
		local button = frame and frame[index];
		if button then
			ConsolePort:SetCursorNodeIfActive(button)
		end
	end)
end

---------------------------------------------------------------
-- Initial focus
---------------------------------------------------------------
function Placer:GetFocusTarget(payload)
	local keyChord = Current.keyChord;
	local function IsEligible(actionID)
		if not keyChord then return true end;
		return not db.Gamepad:GetBindingKey(db('Actionbar/Action/'..actionID));
	end
	local pagedBar = self:GetPagedBar()
	local freeOnPaged, freeAnywhere;
	for _, container in ipairs(db.Actionbar.Pages) do
		if self:IsGroupVisible(container) then
			for _, barID in ipairs(container) do
				for i = 1, db.Actionbar:GetBarWidth(barID) do
					local actionID = db.Actionbar:GetSlotID(barID, i)
					if payload.isMapped(actionID) then
						return barID, i;
					end
					if ( not GetActionInfo(actionID) and IsEligible(actionID) ) then
						if ( barID == pagedBar and not freeOnPaged ) then
							freeOnPaged = { barID, i };
						elseif not freeAnywhere then
							freeAnywhere = { barID, i };
						end
					end
				end
			end
		end
	end
	local target = freeOnPaged or freeAnywhere;
	if target then
		return target[1], target[2];
	end
	return pagedBar, 1;
end

---------------------------------------------------------------
-- Placement
---------------------------------------------------------------
function Placer:SetPayload(payload, keyChord)
	Current.payload, Current.keyChord, Current.frame = payload, keyChord, self;
	wipe(self.expanded)

	self.Portrait.Icon:SetTexture(payload.icon)
	self.Name:SetText(payload.name)
	local slug = keyChord and db.Hotkeys:GetActiveButtonSlug(keyChord[2], keyChord[1]);
	self.Desc:SetText(slug and L('Select a slot to bind %s and place this action.', slug) or L'Select a slot to place this action.')

	local barID, index = self:GetFocusTarget(payload)
	self.expanded[barID] = true;
	self.pendingFocus = { barID, index };
	self:BuildTabs()
	self:Show()
	self.Tabs:SelectAtIndex(self:GetTabForPage(self:FindPageForBar(barID)))
end

function Placer:OnSlotClicked(actionID, bindingID)
	local payload = Current.payload;
	if not payload then return end;
	self.placing = true;
	ClearCursor()
	payload.pickup()
	PlaceAction(actionID)

	if ( bindingID and Current.keyChord ) then
		CPAPI.SetBinding(table.concat(Current.keyChord), bindingID, true)
		Current.keyChord = nil;
	end

	local kind, _, _, cursorSpellID = GetCursorInfo()
	ClearCursor()
	self.placing = nil;
	if ( kind == 'spell' and cursorSpellID and not payload.isMapped(actionID) ) then
		return self:SetPayload(Payloads.spell(cursorSpellID))
	end
	if ( bindingID and not db.Gamepad:GetBindingKey(bindingID) ) then
		return self:CatchBinding(bindingID, L.SLOT_NO_BINDING:format(payload.name, env:GetBindingName(bindingID)))
	end
	self:Hide()
end

function Placer:OnBindingClicked(bindingID, isClearEvent, readonly, element)
	if readonly then return end;
	if isClearEvent then
		return env:ClearBindingsForID(bindingID, true)
	end
	self:CatchBinding(bindingID, nil, element)
end

function Placer:CatchBinding(bindingID, text, element)
	local catcher = self.Catcher;
	catcher:TryCatchBinding({
		text = text or catcher:GetPromptText();
		OnShow = function()
			self:PauseCatcher()
			if element then ConsolePort:SetCursorNodeIfActive(element) end;
			CPAPI.Next(function(tooltip)
				tooltip:Hide()
				GameTooltip_HideShoppingTooltips(tooltip)
			end, GameTooltip)
		end;
		OnHide = function()
			self:ResumeCatcher()
			if element then ConsolePort:SetCursorNodeIfActive(element) end;
		end;
	}, BLUE_FONT_COLOR:WrapTextInColorCode(env:GetBindingName(bindingID)), nil, {
		bindingID = bindingID;
	})
end

---------------------------------------------------------------
-- Hints and lifecycle
---------------------------------------------------------------
function Placer:SetHints()
	local handle = db.UIHandle;
	local leftClick, rightClick, specialClick, cancelClick =
		db('UICursorLeftClick'), db('UICursorRightClick'), db('UICursorSpecial'), db('UICursorCancel');
	handle:SetHintFocus(self, IsGamePadFreelookEnabled())
	if leftClick then
		handle:AddHint(leftClick, L'Place in slot')
	end
	if rightClick then
		handle:AddHint(rightClick, L'Clear slot or binding')
	end
	if specialClick and not Current.keyChord then
		handle:AddHint(specialClick, L'Set binding')
	end
	if cancelClick then
		handle:AddHint(cancelClick, CANCEL)
	end
end

function Placer:ClearHints()
	local handle = db.UIHandle;
	if handle:IsHintFocus(self) then
		handle:HideHintBar()
	end
	handle:ClearHintsForFrame(self)
end

function Placer:OnShow()
	CPCombatHideMixin.OnShow(self)
	self:ReleaseClosures()
	self:CatchButton('PADLSHOULDER', self.SetPageByDelta, self, -1)
	self:CatchButton('PADRSHOULDER', self.SetPageByDelta, self,  1)
	self:SetHints()
end

function Placer:OnHide()
	CPCombatHideMixin.OnHide(self)
	self:ReleaseClosures()
	self:ClearHints()
	self.List:GetDataProvider():Flush()
	Current.payload, Current.keyChord = nil, nil;
end

function Placer:OnLoad()
	CPButtonCatcherMixin.OnLoad(self)
	CPCombatHideMixin.OnLoad(self)
	self:SetScript('OnGamePadButtonDown', self.OnGamePadButtonDown)
	self:HookScript('OnShow', self.OnShow)
	self:HookScript('OnHide', self.OnHide)
	self.expanded, self.tabPages = {}, {};
	self.List:InitDefault()
	self.Tabs:RegisterCallback(self.Tabs.Event.Selected, self.OnTabSelected, self)

	local BindingCatcher = env.Mixin.BindingCatcher;
	self.Catcher = CreateFrame('Button', nil, self, BindingCatcher.Template)
	self.Catcher.promptText = L.SLOT_SET_BINDING;
	CPAPI.Specialize(self.Catcher, BindingCatcher)
	self.Catcher:SetScript('OnUpdate', self.Catcher.OnUpdate)

	env:RegisterCallback(SLOT_EVENT, self.OnSlotClicked, self)
	env:RegisterCallback(BINDING_EVENT, self.OnBindingClicked, self)
	tinsert(UISpecialFrames, self:GetName())
end

---------------------------------------------------------------
-- Entry point
---------------------------------------------------------------
-- @param kind     : payload kind, 'spell', 'item' or 'macro'
-- @param keyChord : optional { modifier, button } to bind to the chosen slot
-- @param ...      : payload arguments, see Payloads
function env:ShowActionPlacer(kind, keyChord, ...)
	if InCombatLockdown() then return end;
	local builder = Payloads[kind];
	if not builder then return end;
	if not self.Placer then
		self.Placer = Mixin(CreateFrame('Frame', 'ConsolePortActionPlacer', UIParent, 'CPActionPlacer'), Placer)
		self.Placer:OnLoad()
	end
	self.Placer:SetPayload(builder(...), keyChord)
	return self.Placer;
end
