---------------------------------------------------------------
-- UnitMenu.lua: Unit menu popup
---------------------------------------------------------------
local _, db = ...;
local UnitIsOtherPlayersBattlePet = UnitIsOtherPlayersBattlePet or nop;
local UnitMenu = db:Register('UnitMenu', CPAPI.EventHandler(Mixin(ConsolePortUnitMenu, UnitPopupManager, {
	LayoutFrames = {};
	ButtonFrames = {};
	ReplaceMixins = {};
	UnitTypeMenuConversion = {
		arena    = 'ARENAENEMY';
		arenapet = 'ARENAENEMY';
		boss     = 'BOSS';
		focus    = 'FOCUS';
		party    = 'PARTY';
	};
	UnitMenuTypePredicates = {
		function(unit) return UnitIsUnit(unit, 'player')               and 'SELF' end;
		function(unit) return UnitIsUnit(unit, 'vehicle')              and 'VEHICLE' end;
		function(unit) return UnitIsUnit(unit, 'pet')                  and 'PET' end;
		function(unit) return UnitIsOtherPlayersBattlePet(unit)        and 'OTHERBATTLEPET' end;
		function(unit) return UnitIsOtherPlayersPet(unit)              and 'OTHERPET' end;
		function(unit) return UnitIsPlayer(unit) and UnitInRaid(unit)  and 'RAID_PLAYER' end;
		function(unit) return UnitIsPlayer(unit) and UnitInParty(unit) and 'PARTY' end;
		function(unit) return UnitIsPlayer(unit)                       and 'PLAYER' end;
		function(unit) return UnitIsUnit(unit, 'target')               and 'TARGET' end;
	};
	Events = {
		'PLAYER_DIFFICULTY_CHANGED';
		'PLAYER_LOOT_SPEC_UPDATED';
		'PLAYER_TARGET_CHANGED';
		'RAID_TARGET_UPDATE';
	};
	ReplaceIcons = {};
	index = 1;
})))

---------------------------------------------------------------
-- Main
---------------------------------------------------------------
function UnitMenu:SetUnit(unit, isSecure)
	if not unit then return self:Hide() end;
	self.contextData = self:CreateInitialContextData(unit, isSecure);
	if not self.contextData then return self:Hide() end;
	local contextData = self.contextData;

	self:AddAdditionalContextData(contextData);
	self:ModifyAppearance(contextData);

	local menu = self:GetMenu(contextData.which);
	if not menu then return self:Hide() end;

	local entries = menu:AssembleMenuEntries(contextData);
	tinsert(entries, self.Emotes)

	self:RenderEntries(entries, contextData)
	self:Show()

	if isSecure then
		self:SetFocusByIndex(1)
	end

	return true;
end

---------------------------------------------------------------
-- Context data
---------------------------------------------------------------
function UnitMenu:CreateInitialContextData(unit, isSecure)
	---@see SecureTemplates.lua:SECURE_ACTIONS.togglemenu
	if not unit then return end;
	unit = unit:lower();

	local unitType = unit:match('^([a-z]+)[0-9]+$') or unit;
	local which = self.UnitTypeMenuConversion[unitType];

	if not which then
		for _, predicate in ipairs(self.UnitMenuTypePredicates) do
			which = predicate(unit);
			if which then break end;
		end
	end

	if not which then return end;
	return { unit = unit, which = which, isSecure = isSecure };
end

function UnitMenu:AddAdditionalContextData(contextData)
	---@see UnitPopupShared.lua:UnitPopupManager:OpenMenu
	contextData.name, contextData.server = UnitNameUnmodified(contextData.unit);
	contextData.playerLocation = UnitPopupSharedUtil.TryCreatePlayerLocation(contextData);
	contextData.accountInfo = UnitPopupSharedUtil.GetBNetAccountInfo(contextData);
	contextData.isMobile = UnitPopupSharedUtil.GetIsMobile(contextData);
end

function UnitMenu:CreateEntries(root, entry, contextData, parent)
	if not entry:CanShow(contextData) then return end;

	if ( entry:IsTitle() or entry:IsDivider() ) then
		return self:CreateTitle(entry)
	else
		local child = entry:CreateMenuDescription(root, contextData)
		local entries = entry:GetEntries()

		if child then
			child.refreshOnClick = true;
			child.IsEnabled = GenerateClosure(UnitPopupSharedUtil.IsEnabled, contextData, entry)
			self:CustomizeEntry(child, entry, contextData)
		end

		if entries then
			child.refreshOnClick = false;
			child.onClickHandler = function()
				self.BackButton:Acquire(parent, entries, self.index)

				local header = CreateFromMixins(UnitPopupSubsectionTitleMixin)
				header.GetText = GenerateClosure(entry.GetText, entry)
				tinsert(entries, 2, header)

				self:RenderEntries(entries, contextData)
				if contextData.isSecure then
					self:SetFocusByIndex(1)
				end
			end;
		end
	end
end

---------------------------------------------------------------
-- Appearance
---------------------------------------------------------------
UnitMenu.Tooltip = ConsolePortPopupMenuTooltip;

function UnitMenu:SetTooltip(contextData, color)
	local tooltip = self.Tooltip;
	tooltip:SetParent(self)
	tooltip:SetOwner(self, 'ANCHOR_NONE')
	tooltip:SetUnit(contextData.unit)
	tooltip:ClearAllPoints()
	tooltip:SetPoint('TOPLEFT', self.tooltipOffsetX, -16 - self.Desc:GetHeight())
	local statusBar = tooltip:GetStatusBar()
	statusBar:SetColor(color)
	statusBar:SetOffset(self.Desc:GetHeight())
	db.Alpha.FadeIn(self.Tooltip, 0.25, 0, 1)
end

function UnitMenu:GetTitleColor(unit)
	if UnitIsPlayer(unit) then
		local class = select(2, UnitClass(unit));
		if class then
			return RAID_CLASS_COLORS[class];
		end
	else
		local reaction = UnitReaction(unit, 'player');
		if reaction then
			return FACTION_BAR_COLORS[reaction];
		end
	end
	return NORMAL_FONT_COLOR;
end

function UnitMenu:ModifyAppearance(contextData)
	if contextData.isSecure then
		ConsolePort:RemoveInterfaceCursorFrame(self)
	else
		ConsolePort:AddInterfaceCursorFrame(self)
	end
	self.CloseButton:SetShown(not contextData.isSecure)

	local color = self:GetTitleColor(contextData.unit);
	SetPortraitTexture(self.Icon, contextData.unit)
	self.Name:SetText(contextData.name)
	self.Name:SetTextColor(color:GetRGB())
	self.Desc:SetText(contextData.server)
	self:SetTooltip(contextData, color)
end

function UnitMenu:CustomizeEntry(widget, entry, contextData)
	local data = self.ReplaceIcons[entry];
	if data then
		local atlas, isNative, keepSize = unpack(data)
		local object = widget:AttachTexture()
		if isNative then
			object:SetTexCoord(0, 1, 0, 1)
			object:SetAtlas(atlas, keepSize)
		else
			CPAPI.SetAtlas(object, atlas)
		end
	end
end

---------------------------------------------------------------
-- Scripts
---------------------------------------------------------------
function UnitMenu:OnHide()
	self:UnregisterAllEvents()
	self:ResetAll()
	if self.updateTicker then
		self.updateTicker:Cancel()
		self.updateTicker = nil;
	end
	self.contextData = nil;
	self.BackButton:Reset()
	self.SecureProxy:SetAttribute('clickbutton', nil)
end

function UnitMenu:OnShow()
	CPAPI.RegisterFrameForEvents(self, self.Events)
	self.updateTicker = C_Timer.NewTicker(0.1, function()
		if not self.contextData.isSecure and not UnitExists(self.contextData.unit) then
			return self:Hide()
		end
		self:UpdateAll()
	end)
end

---------------------------------------------------------------
-- Content
---------------------------------------------------------------
UnitMenu.FixHeight = nop;

function UnitMenu:ResetAll()
	self:ReleaseAll()
	self.RadioPool:ReleaseAll()
	self.FramePool:ReleaseAll()
	self.TitlePool:ReleaseAll()
	wipe(self.LayoutFrames)
	wipe(self.ButtonFrames)
	self.entries = nil;
end

function UnitMenu:UpdateAll()
	for button in self:EnumerateActive() do
		button:Update()
	end
	for button in self.RadioPool:EnumerateActive() do
		button:Update()
	end
end

function UnitMenu:Layout()
	local height = 0;
	local lastFrame = self:GetLastFrame()
	if lastFrame:IsTitle() then
		-- Remove the last frame if it's a title,
		-- since nothing interesting is going to be below it.
		lastFrame:Hide()
		self.LayoutFrames[#self.LayoutFrames] = nil;
	end
	for i, frame in ipairs(self.LayoutFrames) do
		frame:ClearAllPoints()
		if i == 1 then
			frame:SetAttribute('nodepriority', 1)
			frame:SetPoint('TOPLEFT', self.Tooltip, 'BOTTOMLEFT', -self.tooltipOffsetX, -24)
		else
			frame:SetAttribute('nodepriority', nil)
			frame:SetPoint('TOP', self.LayoutFrames[i-1], 'BOTTOM', 0, 0)
		end
		height = height + frame:GetHeight() + 8;
	end
	self:SetTargetHeight(self:GetTop() - self.LayoutFrames[#self.LayoutFrames]:GetBottom() + self.bottomPadding)
end

function UnitMenu:GetLayoutIndex()
	return #self.LayoutFrames + 1;
end

function UnitMenu:GetLastFrame()
	return self.LayoutFrames[#self.LayoutFrames];
end

function UnitMenu:RenderEntries(entries, contextData)
	self:ResetAll()
	for _, entry in ipairs(entries) do
		self:CreateEntries(self, self:GetMixin(entry), contextData, entries);
	end
	self.entries = entries;
	self:Layout()
	if contextData.isSecure then
		self:SetFocusByIndex(self.index)
	end
end

function UnitMenu:Refresh()
	if self.entries then
		self:RenderEntries(self.entries, self.contextData)
	end
end

---------------------------------------------------------------
-- Events
---------------------------------------------------------------
function UnitMenu:PLAYER_TARGET_CHANGED()
	if UnitIsUnit(self.contextData.unit, 'target') then
		self:SetUnit(self.contextData.unit, self.contextData.isSecure)
	end
end

function UnitMenu:RAID_TARGET_UPDATE()
	self:UpdateAll()
end

UnitMenu.PLAYER_LOOT_SPEC_UPDATED  = UnitMenu.RAID_TARGET_UPDATE;
UnitMenu.PLAYER_DIFFICULTY_CHANGED = UnitMenu.RAID_TARGET_UPDATE;

---------------------------------------------------------------
-- Commands
---------------------------------------------------------------
function UnitMenu:Execute(command)
	if self[command] then
		self[command](self)
	end
end

function UnitMenu:ExecuteButtonScript(button, script)
	if not button then return end;
	ExecuteFrameScript(button, script)
end

function UnitMenu:ExecuteClick(button)
	if not button or not button:IsEnabled() then return end;
	button:Click()
end

function UnitMenu:SetFocusByIndex(index)
	self:ExecuteButtonScript(self.ButtonFrames[self.index], 'OnLeave')
	self.index = index < 1 and #self.ButtonFrames or index > #self.ButtonFrames and 1 or index;

	local button = self.ButtonFrames[self.index];
	self:ExecuteButtonScript(button, 'OnEnter')
	self.SecureProxy:SetAttribute('clickbutton', button)
end

function UnitMenu:ACCEPT()
	-- Only use this approach in combat.
	if not InCombatLockdown() then return end;
	self:ExecuteClick(self.ButtonFrames[self.index])
end

function UnitMenu:CANCEL()
	if ( self.entries[1] == self.BackButton ) then
		self:ExecuteClick(self.ButtonFrames[1])
	elseif not InCombatLockdown() then
		db.UnitMenuSecure:SetUnit(nil)
	end
end

function UnitMenu:UP()
	self:SetFocusByIndex(self.index - 1)
end

function UnitMenu:DOWN()
	self:SetFocusByIndex(self.index + 1)
end

---------------------------------------------------------------
-- Initializers
---------------------------------------------------------------
function UnitMenu:CreateButtonBase(text, onClick, pool)
	local widget, newObj = pool:Acquire(pool:GetNumActive() + 1)
	if newObj then
		widget:OnLoad()
	end
	tinsert(self.LayoutFrames, widget)
	tinsert(self.ButtonFrames, widget)
	self:ExecuteButtonScript(widget, 'OnLeave')
	widget:SetMotionScriptsWhileDisabled(true)
	widget:SetText(text)
	widget:Show()
	if ConsolePort:IsCursorNode(widget) then
		widget:OnEnter()
	end
	widget.onClickHandler = onClick;
	widget:SetAttribute(CPAPI.ActionPressAndHold, true)
	widget:SetAttribute(CPAPI.ActionTypeRelease, nil)
	widget:AttachTexture():SetTexture(nil)
	return widget;
end

function UnitMenu:CreateButton(text, onClick)
	return self:CreateButtonBase(text, onClick, self)
end

function UnitMenu:CreateRadio(text, isSelected, onClick)
	local widget = self:CreateButtonBase(text, onClick, self.RadioPool)
	widget:SetIsSelected(isSelected)
	return widget;
end

function UnitMenu:CreateCheckbox(text, isSelected, onClick)
	local widget = self:CreateButtonBase(text, onClick, self.RadioPool)
	widget:SetIsSelected(isSelected)
	return widget;
end

function UnitMenu:CreateFrame()
	local widget, newObj = self.FramePool:Acquire(self.FramePool:GetNumActive() + 1)
	if newObj then
		widget:OnLoad()
	end
	tinsert(self.LayoutFrames, widget)
	widget:Show()
	return widget;
end

function UnitMenu:CreateTitle(entry)
	local title = self:GetLastFrame()
	if not (title and title:IsTitle()) then
		title = self.TitlePool:Acquire(self:GetLayoutIndex())
		tinsert(self.LayoutFrames, title)
	end
	local isHeader = entry:IsTitle()
	title.Text:SetText(isHeader and entry:GetText() or '')
	title.Text:SetTextColor(entry:GetColor())
	title:SetHeight(isHeader and 32 or 16)
	title:Show()
	return title;
end

---------------------------------------------------------------
local UnitMenuButtonIcon = { SetPoint = nop };
---------------------------------------------------------------

function UnitMenuButtonIcon:OnLoad()
	self:SetSize(26, 26)
	self:ClearAllPoints()
	getmetatable(self).__index.SetPoint(self, 'CENTER', self:GetParent(), 'LEFT', 56, 0)
end

function UnitMenuButtonIcon:SetSize(width, height)
	getmetatable(self).__index.SetSize(self,
		Clamp(width, 20, 26),
		Clamp(height, 20, 26)
	);
end

---------------------------------------------------------------
local UnitMenuButton = CreateFromMixins(db.PopupMenuButton)
---------------------------------------------------------------
function UnitMenuButton:OnLoad()
	self:HookScript('OnClick', self.ExecuteClick)
	self:HookScript('OnHide', self.OnLeave)
	self:SetScript('OnLeave', self.OnLeave)
end

function UnitMenuButton:OnEnter()
	db.PopupMenuButton.OnEnter(self)
	self.Icon:SetIgnoreParentAlpha(true)
end

function UnitMenuButton:OnLeave()
	db.PopupMenuButton.OnLeave(self)
	self.Icon:SetIgnoreParentAlpha(false)
end

function UnitMenuButton:AddInitializer(initializer)
	self.fontString = self.Text;
	self.fontString.SetPoint = nop;
	initializer(self)
end

function UnitMenuButton:SetOnEnter(handler)
	self:SetScript('OnEnter', handler)
	self:HookScript('OnEnter', self.OnEnter)
end

function UnitMenuButton:ExecuteClick()
	if self.onClickHandler then
		self.onClickHandler(self)
	end
	if self.refreshOnClick then
		self:GetParent():Refresh()
	end
end

function UnitMenuButton:AttachTexture()
	Mixin(self.Icon, UnitMenuButtonIcon)
	UnitMenuButtonIcon.OnLoad(self.Icon)
	return self.Icon;
end

function UnitMenuButton:Update()
	local enabled = self:IsEnabled()
	self:SetEnabled(enabled)
	self:SetAlpha(enabled and 1 or 0.5)
end

function UnitMenuButton:IsEnabled()
	-- UnitPopupSharedUtil.IsEnabled(contextData, entry)
end

function UnitMenuButton:IsTitle()
	return false;
end

---------------------------------------------------------------
local UnitMenuRadio = CreateFromMixins(UnitMenuButton)
---------------------------------------------------------------
function UnitMenuRadio:OnLoad()
	UnitMenuButton.OnLoad(self)
	self.CheckedBackground = self:CreateTexture(nil, 'BACKGROUND')
	self.CheckedTexture = self:CreateTexture(nil, 'ARTWORK')

	self.CheckedBackground:SetPoint('LEFT', 16, 0)
	self.CheckedBackground:SetSize(24, 24)
	self.CheckedBackground:SetAtlas('checkbox-minimal')

	self.CheckedTexture:SetPoint('LEFT', 16, 0)
	self.CheckedTexture:SetSize(24, 24)
	self.CheckedTexture:SetAtlas('checkmark-minimal')
	self:SetCheckedTexture(self.CheckedTexture)

	self:SetScript('OnEnter', self.OnEnter)
end

function UnitMenuRadio:SetIsSelected(isSelected)
	self.IsSelected = isSelected;
	self:Update()
end

function UnitMenuRadio:Update()
	UnitMenuButton.Update(self)
	self:SetChecked(self:IsSelected())
end

---------------------------------------------------------------
local UnitMenuFrame = {};
---------------------------------------------------------------
function UnitMenuFrame:OnLoad()
	self.compositor = CreateCompositor(self)
	self:SetScript('OnHide', self.Clear)
end

function UnitMenuFrame:Clear()
	self.compositor:Clear()
end

function UnitMenuFrame:AttachTemplate(template)
	return self.compositor:AttachTemplate(self, template)
end

function UnitMenuFrame:IsTitle()
	return false;
end

function UnitMenuFrame:AddInitializer(initializer)
	self:SetSize(initializer(self))
end

---------------------------------------------------------------
local UnitMenuHeader = {};
---------------------------------------------------------------
function UnitMenuHeader:IsTitle()
	return true;
end

---------------------------------------------------------------
do -- Create pools
---------------------------------------------------------------
	local function CreatePool(...)
		local pool = CreateFromMixins(CPIndexPoolMixin)
		pool:OnLoad()
		pool:CreateFramePool(...)
		return pool;
	end
	UnitMenu.RadioPool = CreatePool('CheckButton', 'CPPopupButtonTemplate', UnitMenuRadio, nil, UnitMenu)
	UnitMenu.FramePool = CreatePool('Frame', 'CPPopupSubFrameTemplate', UnitMenuFrame, nil, UnitMenu)
	UnitMenu.TitlePool = CreatePool('Frame', 'CPPopupHeaderTemplate', UnitMenuHeader, nil, UnitMenu)
	UnitMenu:CreateFramePool('Button', 'CPPopupButtonTemplate', UnitMenuButton)
end

---------------------------------------------------------------
UnitMenu.BackButton = CreateFromMixins(UnitPopupButtonBaseMixin, {
---------------------------------------------------------------
	EntryTrace = {};
	IndexTrace = {};
})

function UnitMenu.BackButton:CreateMenuDescription(rootDescription, contextData)
	local element = rootDescription:CreateButton(BACK, function()
		self:Return(rootDescription, contextData)
	end)
	element:AddInitializer(function(self)
		self.Icon:SetTexCoord(0, 1, 0, 1)
		self.Icon:SetAtlas('common-icon-undo')
	end)
end

function UnitMenu.BackButton:Return(rootDescription, contextData)
	local entries, index = self:Pop()
	rootDescription:RenderEntries(entries, contextData)
	if contextData.isSecure then
		rootDescription:SetFocusByIndex(index)
	end
end

function UnitMenu.BackButton:Acquire(parent, entries, restoreIndex)
	tinsert(self.EntryTrace, parent)
	tinsert(self.IndexTrace, restoreIndex)
	tinsert(entries, 1, self)
	return self;
end

function UnitMenu.BackButton:Pop() return
	tremove(self.EntryTrace),
	tremove(self.IndexTrace);
end

function UnitMenu.BackButton:Reset()
	wipe(self.EntryTrace)
	wipe(self.IndexTrace)
end

---------------------------------------------------------------
-- Mount
---------------------------------------------------------------
UnitMenu:HookScript('OnHide', UnitMenu.OnHide)
UnitMenu:HookScript('OnShow', UnitMenu.OnShow)
UnitMenu:SetAttribute('nodepass', true)
UnitMenu.SecureProxy = CreateFrame('Button', nil, UnitMenu, 'InsecureActionButtonTemplate')
UnitMenu.SecureProxy:SetAttribute(CPAPI.ActionTypeRelease, 'click')
UnitMenu.SecureProxy:SetAttribute(CPAPI.ActionPressAndHold, true)
UnitMenu.SecureProxy:HookScript('OnClick', GenerateClosure(UnitMenu.ACCEPT, UnitMenu))

---------------------------------------------------------------
do -- Emote list
---------------------------------------------------------------
	UnitMenu.Emotes       = CreateFromMixins(UnitPopupButtonBaseMixin)
	local EmoteMenuBase   = CreateFromMixins(UnitPopupButtonBaseMixin)
	local EmoteButtonBase = CreateFromMixins(UnitPopupButtonBaseMixin)

	local MAXEMOTEINDEX = MAXEMOTEINDEX or 627;

	local function MakeEmoteText(value)
		local i = 1;
		local token = _G['EMOTE'..i..'_TOKEN'];
		while ( i < MAXEMOTEINDEX ) do
			if ( token == value ) then
				break;
			end
			i = i + 1;
			token = _G['EMOTE'..i..'_TOKEN'];
		end
		return  _G['EMOTE'..i..'_CMD1'] or value;
	end

	function EmoteMenuBase:GetEntries()
		local entries = {};
		for i = self.start, self.stop do
			local emote = self.list[i];
			tinsert(entries, CreateFromMixins(EmoteButtonBase, {
				text = MakeEmoteText(emote),
				emote = emote,
			}))
		end
		return entries;
	end

	function EmoteMenuBase:GetText()
		return ('%s [%d-%d]'):format(self.name,
			self.start,
			self.stop
		);
	end

	function EmoteButtonBase:GetText()
		return self.text;
	end

	function EmoteButtonBase:OnClick(contextData)
		DoEmote(self.emote, UnitIsPlayer(contextData.unit) and contextData.unit or nil);
	end

	function UnitMenu.Emotes:GetText()
		return EMOTE_MESSAGE;
	end

	function UnitMenu.Emotes:GetEntries()
		local entries = {};
		local function createMenus(list, name)
			local half = ceil(#list / 2)
			return {
				CreateFromMixins(EmoteMenuBase, { list = list, start = 1, stop = half, name = name }),
				CreateFromMixins(EmoteMenuBase, { list = list, start = half + 1, stop = #list, name = name })
			}
		end

		tAppendAll(entries, createMenus(EmoteList, EMOTE_MESSAGE))
		tAppendAll(entries, createMenus(TextEmoteSpeechList, VOICEMACRO_LABEL))

		return entries;
	end
end

---------------------------------------------------------------
-- Replacements
---------------------------------------------------------------
local Replace = UnitMenu.ReplaceMixins;

CPAPI.Callable(Replace, function(self, mixin, replacement)
	if not mixin then return end;
	rawset(self, mixin, CreateFromMixins(mixin, replacement))
end)

CPAPI.Proxy(Replace, function(_, mixin)
	return mixin;
end)

function UnitMenu:GetMixin(mixin)
	return self.ReplaceMixins[mixin];
end

do -- Focus handling
	local function SetOrClearFocus(description, unit)
		if unit then
			description:SetAttribute(CPAPI.ActionTypeRelease, 'focus')
			description:SetAttribute('unit', unit)
		else
			description:SetAttribute(CPAPI.ActionTypeRelease, 'macro')
			description:SetAttribute('macrotext', '/clearfocus')
		end
	end

	local function IsEnabled()
		return not InCombatLockdown()
	end

	Replace(UnitPopupSetFocusButtonMixin, {
		OnClick = nop;
		IsEnabled = IsEnabled;
		CreateMenuDescription = function(self, rootDescription, contextData)
			local replaceWithClear = UnitIsUnit(contextData.unit, 'focus') and contextData.unit ~= 'focus';
			local display = replaceWithClear and rootDescription:GetMixin(UnitPopupClearFocusButtonMixin) or self;
			local description = UnitPopupButtonBaseMixin.CreateMenuDescription(display, rootDescription, contextData)
			SetOrClearFocus(description, not replaceWithClear and contextData.unit or nil)
			return description;
		end;
	});

	Replace(UnitPopupClearFocusButtonMixin, {
		OnClick = nop;
		IsEnabled = IsEnabled;
		CreateMenuDescription = function(self, rootDescription, contextData)
			local description = UnitPopupButtonBaseMixin.CreateMenuDescription(self, rootDescription, contextData)
			SetOrClearFocus(description, nil)
			return description;
		end;
	});
end

-- Hide buttons which carry taint or don't make sense in the context.
do local hideButton = { CanShow = nop };
	Replace(UnitPopupEnterEditModeMixin, hideButton);
	Replace(UnitPopupCopyCharacterNameButtonMixin, hideButton);
end

---------------------------------------------------------------
-- Icons
---------------------------------------------------------------
local Icons = UnitMenu.ReplaceIcons;

CPAPI.Callable(Icons, function(self, mixin, icon)
	if not mixin then return end;
	mixin = UnitMenu:GetMixin(mixin)
	rawset(self, mixin, icon)
end)

Icons(UnitPopupAchievementButtonMixin,              {'poi-transmogrifier'});
Icons(UnitPopupAddBtagFriendButtonMixin,            {'Battlenet-ClientIcon-App', true});
Icons(UnitPopupAddCharacterFriendButtonMixin,       {'Battlenet-ClientIcon-WoW', true});
Icons(UnitPopupAddFriendMenuButtonMixin,            {'Battlenet-ClientIcon-App', true});
Icons(UnitPopupClearFocusButtonMixin,               {'Ping_Map_Whole_Threat'});
Icons(UnitPopupConvertToRaidButtonMixin,            {'poi-transmogrifier'});
Icons(UnitPopupDuelButtonMixin,                     {'VignetteEventElite'});
Icons(UnitPopupDungeonDifficulty1ButtonMixin,       {'GM-icon-difficulty-normal-hover', true, true});
Icons(UnitPopupDungeonDifficulty2ButtonMixin,       {'GM-icon-difficulty-heroic-hover', true, true});
Icons(UnitPopupDungeonDifficulty3ButtonMixin,       {'GM-icon-difficulty-mythic-hover', true, true});
Icons(UnitPopupDungeonDifficultyButtonMixin,        {'MagePortalAlliance'});
Icons(UnitPopupFollowButtonMixin,                   {'MiniMap-QuestArrow'});
Icons(UnitPopupInspectButtonMixin,                  {'None'});
Icons(UnitPopupInviteButtonMixin,                   {'GreenCross'});
Icons(UnitPopupLegacyRaidDifficulty1ButtonMixin,    {'MagePortalAlliance'});
Icons(UnitPopupLegacyRaidDifficulty2ButtonMixin,    {'MagePortalHorde'});
Icons(UnitPopupOptOutLootTitleMixin,                {'Banker'});
Icons(UnitPopupPartyInstanceLeaveButtonMixin,       {'poi-door-down'});
Icons(UnitPopupPartyLeaveButtonMixin,               {'XMarksTheSpot'});
Icons(UnitPopupPetBattleDuelButtonMixin,            {'WildBattlePet'});
Icons(UnitPopupPetDismissButtonMixin,               {'XMarksTheSpot'});
Icons(UnitPopupPvpFlagButtonMixin,                  {(UnitFactionGroup('player'))..'Symbol'});
Icons(UnitPopupRaidDifficulty1ButtonMixin,          {'GM-icon-difficulty-normal-hover', true, true});
Icons(UnitPopupRaidDifficulty2ButtonMixin,          {'GM-icon-difficulty-heroic-hover', true, true});
Icons(UnitPopupRaidDifficulty3ButtonMixin,          {'GM-icon-difficulty-mythic-hover', true, true});
Icons(UnitPopupRaidDifficultyButtonMixin,           {'MagePortalHorde'});
Icons(UnitPopupRaidTargetButtonMixin,               {'Ping_Map_Whole_OnMyWay'});
Icons(UnitPopupRequestInviteButtonMixin,            {'GreenCross'});
Icons(UnitPopupResetInstancesButtonMixin,           {'common-icon-undo', true});
Icons(UnitPopupSelectLootSpecializationButtonMixin, {'Banker'});
Icons(UnitPopupSelfHighlightSelectButtonMixin,      {'Ping_Map_Whole_NonThreat'});
Icons(UnitPopupSetFocusButtonMixin,                 {'Ping_Map_Whole_Threat'});
Icons(UnitPopupSuggestInviteButtonMixin,            {'GreenCross'});
Icons(UnitPopupTradeButtonMixin,                    {'Auctioneer'});
Icons(UnitPopupWhisperButtonMixin,                  {'Mailbox'});