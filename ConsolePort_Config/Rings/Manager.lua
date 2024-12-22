local _, env = ...;
local db, L, Widgets = env.db, env.L, env.Widgets;
local LoadoutTypeMetaMap = LibStub('ConsolePortActionButton').TypeMetaMap;

---------------------------------------------------------------
local DEFAULT_RING_ID = CPAPI.DefaultRingSetID;
local BUTTON_WITH_ICON_TEXT = '     %s';
local EXTRA_ACTION_ID = CPAPI.ExtraActionButtonID;
local FIXED_OFFSET = 8;
---------------------------------------------------------------
-- Helpers
---------------------------------------------------------------
local function GetRingOptions()
	local options = {};
	for key in db.table.spairs(db.Utility.Data) do
		tinsert(options, key == DEFAULT_RING_ID and DEFAULT or tostring(key))
	end
	return options;
end

local function GetRingNameSuggestion()
	local suggestion = #GetRingOptions() + 1;
	while rawget(db.Utility.Data, suggestion) do
		suggestion = suggestion + 1;
	end
	return tostring(suggestion)
end

local function GetRingDisplayName(name)
	return name and (tonumber(name) and L.FORMAT_RING_NUMERICAL:format(name) or name)
end

local function GetRingDisplayNameForIndex(index)
	return GetRingDisplayName(GetRingOptions()[index])
end

local function ProcessRingName(name)
	local purifiedName = tostring(name):gsub('[^A-Za-z0-9]', '');
	local processedName = tonumber(purifiedName) or purifiedName;
	if processedName ~= DEFAULT and not rawget(db.Utility.Data, processedName) then
		return processedName;
	end
end

local function GetSelectedRingID()
	local controller = env.Rings.Mapper.Child.RingSelect.controller;
	local index = controller:Get()
	local options = controller:GetOptions()
	local selectedOption = options and index and options[index];
	return selectedOption == DEFAULT and DEFAULT_RING_ID or tonumber(selectedOption) or selectedOption;
end

local function GetKindAndAction(info)
	return db.Utility:GetKindAndAction(info)
end

local function IsExtraActionButton(kind, action)
	return (kind == 'action' and action == EXTRA_ACTION_ID);
end

local function GetExtraActionButtonInfo()
	return db.Bindings:GetDescriptionForBinding(db.Bindings.Proxied.ExtraActionButton, true)
end

local function GetExtraActionButtonName()
	return select(3, GetExtraActionButtonInfo())
end

-- Bindings
local function TrySetBinding(button)
	if CPAPI.IsButtonValidForBinding(button) then
		local keychord = CPAPI.CreateKeyChord(button)
		local binding = db.Utility:GetBindingForSet(GetSelectedRingID())
		db.table.map(SetBinding, db.Gamepad:GetBindingKey(binding))
		if SetBinding(keychord, binding) then
			SaveBindings(GetCurrentBindingSet())
			return true;
		end
	end
end

local function RemoveBinding(ringID)
	local binding = db.Utility:GetBindingForSet(ringID)
	for i, key in ipairs({GetBindingKey(binding)}) do
		SetBinding(key, nil)
	end
	SaveBindings(GetCurrentBindingSet())
end

-- Ring add / remove
local function AddRing(rawName)
	local name = ProcessRingName(rawName)
	if name then
		db.Utility.Data[name] = {};
		db:TriggerEvent('OnRingAdded', name, db.Utility.Data[name])
		return true;
	end
end

local function RemoveRing(ringID)
	if ( ringID == DEFAULT_RING_ID ) then
		wipe(db.Utility.Data[ringID])
		db:TriggerEvent('OnRingCleared', ringID)
		return false;
	end
	if rawget(db.Utility.Data, ringID) then
		rawset(db.Utility.Data, ringID, nil)
		db:TriggerEvent('OnRingRemoved', ringID)
		RemoveBinding(ringID)
		return true;
	end
end


---------------------------------------------------------------
-- Ring selector
---------------------------------------------------------------
local RingSelectMixin = {};

function RingSelectMixin:OnLoad()
	self.Label:ClearAllPoints()
	self.Label:SetPoint('TOPLEFT', 40, 0)
	self.Label:SetWidth(0)
end

function RingSelectMixin:OnChecked(checked)
	CPIndexButtonMixin.OnChecked(self, checked)
	self.Content:SetShown(checked)
	self:SetHeight((checked and self.Content.HelpText:GetStringHeight() + 40 or 0) + 40)
end

function RingSelectMixin:Update()
	self:SetText(GetRingDisplayNameForIndex(self.controller:Get()))
end

function RingSelectMixin:OnShow()
	-- HACK: Dropdown gets clipped by container, so disable it while this panel is visible
	ConsolePortConfig.Container:SetClipsChildren(false)
	self:Update()
end

function RingSelectMixin:OnHide()
	-- HACK: Undo temporary clipping change
	ConsolePortConfig.Container:SetClipsChildren(true)
end

function RingSelectMixin:Get()
	return self.controller:Get()
end

function RingSelectMixin:UpdateOptions()
	local options = GetRingOptions()
	self.controller:SetRawOptions(options)
	return options;
end

function RingSelectMixin:OnRingAdded(name)
	local options = GetRingOptions()
	self.controller:SetRawOptions(options)
	for key, value in ipairs(options) do
		if tostring(name) == value then
			return self:Set(key)
		end
	end
end

function RingSelectMixin:OnRingRemoved(ringID)
	self.controller:SetRawOptions(GetRingOptions())
	self:Set(DEFAULT_RING_ID)
end

function RingSelectMixin:Construct()
	Widgets.Select(self, 'RingID', nil, db.Data.Select(1, 1):SetRawOptions(GetRingOptions()), L.SELECTED_RING_TEXT)
	self:SetDrawOutline(true)
	self.tooltipAnchor = 'ANCHOR_BOTTOM';
	self.Popout:ClearAllPoints()
	self.Popout:SetPoint('TOPRIGHT', -2, 0)
	self:SetCallback(function(value)
		self:OnValueChanged(value)
		self:Update()
		db:TriggerEvent('OnRingSelectionChanged', value)
	end)
	db:RegisterCallback('OnRingAdded', self.OnRingAdded, self)
	db:RegisterCallback('OnRingRemoved', self.OnRingRemoved, self)
	self:SetScript('OnClick', CPIndexButtonMixin.OnIndexButtonClick)
	self.disableTooltipHints = true;
end

---------------------------------------------------------------
-- Add / remove ring
---------------------------------------------------------------
local AddRingButton, RemoveRingButton = {}, {};

function AddRingButton:OnLoad()
	local normal = self:GetNormalTexture()
	local pushed = self:GetPushedTexture()

	normal:ClearAllPoints()
	pushed:ClearAllPoints()
	normal:SetPoint('LEFT', 8, 0)
	pushed:SetPoint('LEFT', 10, -2)
	normal:SetSize(20, 20)
	pushed:SetSize(20, 20)
end

function RemoveRingButton:OnLoad()
	local normal = self:GetNormalTexture()
	local pushed = self:GetPushedTexture()

	normal:ClearAllPoints()
	pushed:ClearAllPoints()
	normal:SetPoint('LEFT', 6, 0)
	pushed:SetPoint('LEFT', 8, -2)
	normal:SetSize(24, 24)
	pushed:SetSize(24, 24)

	normal:SetAtlas('common-icon-redx')
	pushed:SetAtlas('common-icon-redx')

	db:RegisterCallback('OnRingSelectionChanged', self.OnRingSelectionChanged, self)
end

function AddRingButton:OnClick()
	return CPAPI.Popup('ConsolePort_Rings_Add_Ring', {
		text = L.ADD_NEW_RING_TEXT;
		button1 = BATTLETAG_CREATE;
		button2 = CANCEL;
		hasEditBox = 1;
		maxLetters = 16;
		OnShow = function(self)
			self.editBox:SetText(GetRingNameSuggestion())
			self.editBox:SetFocus()
		end;
		OnAccept = function(self)
			local name = self.editBox:GetText()
			if not AddRing(name) then
				CPAPI.Log('Failed to add new ring with name %s, because it already exists.', name)
			end
		end;
		OnHide = function()
			self:Uncheck()
		end;
		EditBoxOnTextChanged = function(self)
			local purifiedName = ProcessRingName(self:GetText())
			if purifiedName then
				self:SetText(purifiedName)
				self:GetParent().button1:Enable();
			else
				self:GetParent().button1:Disable();
			end
		end;
		EditBoxOnEnterPressed = function(self)
			if self:GetParent().button1:IsEnabled() then
				StaticPopup_OnClick(self:GetParent(), 1)
			end
		end;
	})
end

function RemoveRingButton:OnClick()
	local ringID = GetSelectedRingID()
	return CPAPI.Popup('ConsolePort_Rings_Remove_Ring', {
		text = ringID == DEFAULT_RING_ID and L.CLEAR_RING_TEXT or L.REMOVE_RING_TEXT;
		button1 = REMOVE;
		button2 = CANCEL;
		OnAccept = function(self)
			RemoveRing(GetSelectedRingID())
		end;
		OnHide = function()
			self:Uncheck()
		end;
	})
end

function RemoveRingButton:OnRingSelectionChanged(value)
	self:SetText(BUTTON_WITH_ICON_TEXT:format(value == DEFAULT_RING_ID and RESET or REMOVE))
end

---------------------------------------------------------------
-- Binding button
---------------------------------------------------------------
local BindingButton, BindingCatcher = {}, {};

function BindingButton:OnLoad()
	db:RegisterCallback('OnRingSelectionChanged', self.UpdateBinding, self)
end

function BindingButton:OnClick(button)
	if ( button == 'RightButton' ) then
		RemoveBinding(GetSelectedRingID())
		self:UpdateBinding()
		return self:Uncheck()
	end
	self.Catch:TryCatchBinding({
		text = L.SET_RING_BINDING_TEXT;
		OnHide = function()
			self:UpdateBinding()
			self:Uncheck()
			env.Config:ResumeCatcher()
		end;
		OnShow = function()
			ConsolePort:SetCursorNode(self)
			env.Config:PauseCatcher()
		end;
	})
end

function BindingButton:OnShow()
	self:UpdateBinding()
end

function BindingButton:UpdateBinding()
	self.Slug:SetText(db.Utility:GetButtonSlugForSet(GetSelectedRingID()) or WrapTextInColorCode(NOT_BOUND, 'FF757575'))
end

function BindingCatcher:OnBindingCaught(...)
	return TrySetBinding(...)
end

---------------------------------------------------------------
-- Ring mapper
---------------------------------------------------------------
local Mapper = CreateFromMixins(env.FlexibleMixin)
local ActionMapper = CreateFromMixins(env.BindingActionMapper)
local CollectionMixin = CreateFromMixins(ActionMapper.CollectionMixin, {
	width = 360;
	rowSize = 8;
	clickActionCallback = function(self)
		local pickup = self.pickup;
		local append = self.append;
		local ringID = GetSelectedRingID()
		if pickup then
			pickup(self:GetValue())
			db.Utility:CheckCursorInfo(ringID, true)
			ClearCursor()
		elseif append then
			db.Utility:AddUniqueAction(ringID, nil, append(self:GetValue()))
			db:TriggerEvent('OnRingContentChanged', ringID)
		end
		CPIndexButtonMixin.Uncheck(self)
	end;
})

function Mapper:OnShow()
	self:SetVerticalScroll(0)
	self:OnRingSelectionChanged(GetSelectedRingID())
end

function Mapper:OnRingSelectionChanged(value)
	local bindingID = db.Utility:GetBindingForSet(GetSelectedRingID())
	if bindingID then
		self.IconMapper:SetBinding(bindingID, true)
	end
end

function Mapper:OnLoad()
	env.OpaqueMixin.OnLoad(self)
	self:SetFlexibleElement(self, 400)
	Mixin(self.Child, env.ScaleToContentMixin)
	self.Child:SetWidth(400)
	self.Child:SetAllPoints()
	self.Child:SetMeasurementOrigin(self.Child, self.Child, 400, 40)
	CPAPI.Start(self)

	self.ActionMapper = self.Child.ActionMapper;
	self.IconMapper = self.Child.IconMapper;
	db:RegisterCallback('OnRingSelectionChanged', self.OnRingSelectionChanged, self)
end

ActionMapper.OnHide = nil;

function ActionMapper:OnShow()
	self:OnChecked(true)
end

function ActionMapper:OnLoad()
	self.CheckedThumb:ClearAllPoints()
	self.CheckedThumb:Hide()
	self.Background:Hide()
	self.Background:ClearAllPoints()
	self:SetEnabled(false)
	CPFocusPoolMixin.OnLoad(self)
	self:SetMeasurementOrigin(self, self.Content, self:GetWidth(), 0)
	self:CreateFramePool('IndexButton',
		'CPIndexButtonBindingActionBarTemplate', CollectionMixin, nil, self.Content)
end

---------------------------------------------------------------
-- Loadout
---------------------------------------------------------------
local Loadout = CreateFromMixins(CPFocusPoolMixin)
local LoadoutButton = CreateFromMixins(CPSmoothButtonMixin, {
	AsyncMap = {
		item = function(self, id)
			local constructor = tonumber(id) and Item.CreateFromItemID or Item.CreateFromItemLink;
			constructor(Item, id):ContinueOnItemLoad(function()
				self:UpdateProps()
			end)
		end;
		spell = function(self, id)
			local spellID = CPAPI.GetSpellInfo(id).spellID;
			if spellID then
				Spell:CreateFromSpellID(spellID):ContinueOnSpellLoad(function()
					self:UpdateProps()
				end)
			end
		end;
	};
})


function LoadoutButton:OnLoad()
	self.ignoreUtilityRing = true;
	self.MasqueSkinned = true;
	self:SetWidth(self:GetParent():GetWidth() - 16)
	self.Label:SetWidth(self:GetWidth() - 100)
	self:SetScript('OnShow', self.OnShow)
	self:HookScript('OnEnter', self.OnEnter)
	self:HookScript('OnLeave', self.OnLeave)
	self:SetAttribute('nohooks', true)
end

function LoadoutButton:OnShow()
	db.Alpha.FadeIn(self, 0.1, self:GetAlpha(), 1)
end

function LoadoutButton:OnEnter()
	GameTooltip:SetOwner(self, 'ANCHOR_TOP')
	if self:SetTooltip() then
		self.UpdateTooltip = self.OnEnter;
	elseif self:IsExtraActionButton() then
		local desc, _, name = GetExtraActionButtonInfo()
		GameTooltip:SetOwner(self, 'ANCHOR_TOP')
		GameTooltip:SetText(name, WHITE_FONT_COLOR:GetRGB())
		GameTooltip:AddLine(desc)
		GameTooltip:Show()
	else
		self.UpdateTooltip = nil;
	end
end

function LoadoutButton:OnLeave()
	if GameTooltip:IsOwned(self) then
		GameTooltip:Hide()
	end
end

function LoadoutButton:OnDeltaChanged(delta)
	local id = self:GetID()
	local data = tremove(self.set, id)
	tinsert(self.set, id + delta, data)
	db:TriggerEvent('OnRingContentChanged', self.setID)
	db.Utility:RefreshAll()
end

function LoadoutButton:Remove()
	db.Utility:RemoveAction(self.setID, self:GetID())
	db:TriggerEvent('OnRingContentChanged', self.setID)
end

function LoadoutButton:GetDisplayText()
	local text = self:GetActionText()
	if ( not text or text == '' ) then
		if self:IsExtraActionButton() then
			text = GetExtraActionButtonName()
		elseif ( self._state_type == 'item' ) then
			text = (CPAPI.GetItemInfo(self._state_action).itemName)
		elseif ( self._state_type == 'spell' ) then
			text = (CPAPI.GetSpellInfo(self._state_action).name)
		end
	end
	return text;
end

function LoadoutButton:IsExtraActionButton()
	return IsExtraActionButton(self._state_type, self._state_action)
end

function LoadoutButton:SetData(data, set, setID)
	self.setID = setID;
	self.set   = set;
	self.data  = data;

	local kind, action = GetKindAndAction(data)
	self._state_type = kind;
	self._state_action = action;
	setmetatable(self, LoadoutTypeMetaMap[kind] or LoadoutTypeMetaMap.empty)
	self:SetAttribute('type', kind)
	self:SetAttribute(kind, action)

	self.upButton:SetEnabled(self:GetID() > 1)
	self.downButton:SetEnabled(self:GetID() < #set)
	self.removeButton:SetEnabled(not IsExtraActionButton(kind, action))

	local asyncCallback = self.AsyncMap[kind];
	if asyncCallback then
		self:CustomImage(CPAPI.GetAsset('Textures\\Button\\Loading'))
		self:SetText(('%s |c50757575(%s, %s)|r'):format(LFG_LIST_LOADING, kind, action))
		return asyncCallback(self, action)
	end
	self:UpdateProps()
end

function LoadoutButton:UpdateProps()
	self:CustomImage(self:GetTexture() or CPAPI.GetAsset('Textures\\Button\\EmptyIcon'))
	self:SetText(self:GetDisplayText())
end

function Loadout:OnLoad()
	env.OpaqueMixin.OnLoad(self)
	CPFocusPoolMixin.OnLoad(self)
	self.Child:SetWidth(self:GetWidth())
	Mixin(self.Child, env.ScaleToContentMixin)
	self.Child:SetAllPoints()
	self.Child:SetMeasurementOrigin(self.Child, self.Child, 585, 0)
	self:CreateFramePool('Button', 'CPRingLoadoutButtonTemplate', LoadoutButton, nil, self.Child)

	db:RegisterCallback('OnRingSelectionChanged', self.Reset, self)
	db:RegisterCallback('OnRingContentChanged', self.Update, self)
	db:RegisterCallback('OnRingCleared', self.Reset, self)
end

function Loadout:OnShow()
	self:Update(true)
end

function Loadout:Reset()
	self:Update(true)
	self:SetVerticalScroll(0)
end

function Loadout:Update(animate)
	self:ReleaseAll()

	local ringID = GetSelectedRingID()
	local set = rawget(db.Utility.Data, ringID)

	self.EmptyText:SetShown(not set or #set == 0)

	if not set then
		return
	end

	local prev;
	for i, data in ipairs(set) do
		local widget, newObj = self:Acquire(i)
		if newObj then
			widget:OnLoad()
		end
		widget:Show()
		widget:SetID(i)
		widget:SetData(data, set, ringID)
		if ( animate == true ) then
			widget:Animate()
		end
		if prev then
			widget:SetPoint('TOP', prev, 'BOTTOM', 0, -FIXED_OFFSET/2)
		else
			widget:SetPoint('TOP', 0, -FIXED_OFFSET)
		end
		prev = widget;
	end
	self.Child:SetHeight(nil)
end

---------------------------------------------------------------
-- Icon mapper
---------------------------------------------------------------
local IconMapper = CreateFromMixins(env.BindingIconMapper)

function IconMapper:OnLoad()
	env.BindingIconMapper.OnLoad(self)

	local inset = (FIXED_OFFSET * 2.5);
	self.Content:ClearAllPoints()
	self.Content:SetPoint('TOPLEFT', inset, -40)
	self.Content:SetPoint('BOTTOMRIGHT', -inset, 0)
end

---------------------------------------------------------------
-- Rings manager
---------------------------------------------------------------
local RingsManager = {};

function RingsManager:OnFirstShow()
	local mapper = self:CreateScrollableColumn('Mapper', {
		_Mixin = Mapper;
		_Setup = {'CPSmoothScrollTemplate', 'BackdropTemplate'};
		_Width = 400;
		_SetDelta = 40;
		_Backdrop = CPAPI.Backdrops.Opaque;
		_Points = {
			{'TOPLEFT', 0, 0};
			{'BOTTOMLEFT', 0, 0};
		};
		{
			Child = {
				_Width = 400;
				{
					HeaderSelect = {
						_Type  = 'Frame';
						_Setup = 'CPAnimatedLootHeaderTemplate';
						_Width = 380;
						_Point = {'TOP', 14, -FIXED_OFFSET};
						_Text  = L'Ring selection';
					};
					RingSelect = {
						_Type = 'IndexButton';
						_Setup = 'CPIndexButtonBindingHeaderTemplate';
						_Mixin = RingSelectMixin;
						_Width = 380;
						_Point = {'TOP', 0, -FIXED_OFFSET * 5};
						{
							HelpButton = {
								_Type = 'Button';
								_Size = {40, 40};
								_SetNormalTexture = 'Interface\\common\\help-i';
								_SetHighlightTexture = 'Interface\\common\\help-i';
								_Point = {'RIGHT', '$parent.Label', 'LEFT', 0, 0};
								_OnClick = function(self, ...)
									self:GetParent():Click()
								end;
								_OnEnter = function(self, ...)
									self:GetParent():OnEnter()
								end;
								_OnLeave = function(self, ...)
									self:GetParent():OnLeave()
								end;
							};
							Content = {
								{
									HelpText = {
										_Type = 'FontString';
										_Setup = {'ARTWORK', 'GameTooltipText'};
										_Text = L.RING_MENU_DESC;
										_Points = {
											{'TOPLEFT', FIXED_OFFSET, 0};
											{'BOTTOMRIGHT', -FIXED_OFFSET, FIXED_OFFSET};
										};
									};
								};
							};
						};
					};
					RingAdd = {
						_Type = 'IndexButton';
						_Setup = 'CPIndexButtonSimpleTemplate';
						_Point = {'TOPLEFT', '$parent.RingSelect', 'BOTTOMLEFT', 0, -FIXED_OFFSET};
						_Mixin = AddRingButton;
						_Text = BUTTON_WITH_ICON_TEXT:format(BATTLETAG_CREATE);
						_Size = {186, 40};
						_SetNormalTexture = [[Interface\PaperDollInfoFrame\Character-Plus]];
						_SetPushedTexture = [[Interface\PaperDollInfoFrame\Character-Plus]];
						_SetDrawOutline = true;
					};
					RingRemove = {
						_Type = 'IndexButton';
						_Setup = 'CPIndexButtonSimpleTemplate';
						_Point = {'TOPRIGHT', '$parent.RingSelect', 'BOTTOMRIGHT', 0, -FIXED_OFFSET};
						_Mixin = RemoveRingButton;
						_Text = BUTTON_WITH_ICON_TEXT:format(RESET);
						_Size = {186, 40};
						_SetNormalTexture = [[Interface\RAIDFRAME\ReadyCheck-NotReady]];
						_SetPushedTexture = [[Interface\RAIDFRAME\ReadyCheck-NotReady]];
						_SetDrawOutline = true;
					};
					RingBinding = {
						_Type = 'IndexButton';
						_Setup = 'CPIndexButtonBindingActionTemplate';
						_Size  = {380, 40};
						_Point = {'TOP', '$parent.RingSelect', 'BOTTOM', 0, -56};
						_SetDrawOutline = true;
						_RegisterForClicks = {'LeftButtonUp', 'RightButtonUp'};
						_Text = KEY_BINDING ..':';
						_Mixin = BindingButton;
						{
							Catch = {
								_Type = 'Button';
								_Setup = {CPAPI.IsRetailVersion and 'SharedButtonLargeTemplate' or 'UIPanelButtonTemplate', 'CPPopupBindingCatchButtonTemplate'};
								_Mixin = BindingCatcher;
							};
						};
					};
					IconMapper = {
						_Type  = 'IndexButton';
						_Setup = 'CPIndexButtonBindingHeaderTemplate';
						_Mixin = IconMapper;
						_Size  = {380, 40};
						_Text  = L'Icon:';
						_Point = {'TOP', '$parent.RingBinding', 'BOTTOM', 0, -FIXED_OFFSET};
						_Hide  = true;
						{
							CurrentIcon = {
								_Type  = 'IndexButton';
								_Setup = 'CPIndexButtonBindingActionButtonTemplate';
								_Point = {'TOPRIGHT', -4, -6};
								_Size  = {30, 30};
								_SetEnabled = false;
							};
							Content = {
								_Mixin = env.BindingIconMapper.Container;
								{
									PageSelector = {
										_Type = 'IndexButton';
										_Mixin = env.BindingIconMapper.PageSelector;
										_Height = 40;
										_Points = {
											{'TOPLEFT', 0, 0};
											{'TOPRIGHT', 0, 0};
										};
									};
								};
							};
						};
					};
					HeaderCollection = {
						_Type  = 'Frame';
						_Setup = 'CPAnimatedLootHeaderTemplate';
						_Width = 380;
						_Point = {'TOP', '$parent.IconMapper', 'BOTTOM', 12, -FIXED_OFFSET*2};
						_Text  = COLLECTIONS;
					};
					ActionMapper = {
						_Type  = 'IndexButton';
						_Setup = 'CPIndexButtonBindingHeaderTemplate';
						_Mixin = ActionMapper;
						_Size  = {380, 40};
						_Point = {'TOP', '$parent.IconMapper', 'BOTTOM', 0, -FIXED_OFFSET};
					};
				};
			};
		};
	})

	local loadout = self:CreateScrollableColumn('Loadout', {
		_Mixin = Loadout;
		_Setup = {'CPSmoothScrollTemplate', 'BackdropTemplate'};
		_SetDelta = 40;
		_Backdrop = CPAPI.Backdrops.Opaque;
		_Points = {
			{'TOPLEFT', 400, 0};
			{'BOTTOMRIGHT', 0, 0};
		};
		{
			EmptyText = {
				_Type = 'FontString';
				_Setup = {'ARTWORK', 'Fancy22Font'};
				_Point = {'CENTER', 0, 0};
				_Text  = L.RING_EMPTY_DESC;
			};
		};
	})

	self.Mapper.Child.RingSelect:Construct()
end

env.Rings = ConsolePortConfig:CreatePanel({
	name = L'Rings';
	mixin = RingsManager;
	scaleToParent = true;
	forbidRecursiveScale = true;
})