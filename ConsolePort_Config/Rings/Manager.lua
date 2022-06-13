local _, env = ...;
local db, L, Widgets = env.db, env.L, env.Widgets;
local LoadoutTypeMetaMap = LibStub('CPActionButton').TypeMetaMap;

---------------------------------------------------------------
local DEFAULT_RING_ID = 1;
local DEFAULT_RING_BINDING = 'LeftButton';

local BUTTON_WITH_ICON_TEXT = '     %s';

local SELECTED_RING_TEXT = L[[This is your currently selected ring set.
When you press and hold your selected key binding, all your selected abilities will appear in a ring on the screen.

Tilt your radial stick in the direction of the ability or item you want to use, then release the key binding to commit.]]
local ADD_NEW_RING_TEXT = L[[|cFFFFFF00Create New Ring|r
Please choose a name for your new ring:]]
local REMOVE_RING_TEXT = L[[|cFFFFFF00Remove Ring|r
Are you sure you want to remove the current ring?]]
local CLEAR_RING_TEXT = L[[|cFFFFFF00Clear Utility Ring|r
Are you sure you want to clear your utility ring?]]
local SET_BINDING_TEXT = L[[ 
|cFFFFFF00Set Binding|r

Press a button combination to select a new binding for this ring.

]]

local EXTRA_ACTION_ID = ExtraActionButton1 and ExtraActionButton1.action or 169;
local GET_SPELLID_IDX = 7;
---------------------------------------------------------------
-- Helpers
---------------------------------------------------------------
local function GetRingOptions()
	local options = {};
	for key in pairs(db.Utility.Data) do
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
	return name and (tonumber(name) and ('Ring |cFF00FFFF%s|r'):format(name) or name)
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
	local controller = env.Rings.Control.RingSelect.controller;
	local index = controller:Get()
	local options = controller:GetOptions()
	local selectedOption = options and index and options[index];
	return selectedOption == DEFAULT and 1 or tonumber(selectedOption) or selectedOption;
end

local function GetKindAndAction(info)
	return db.Utility:GetKindAndAction(info)
end

local function IsExtraActionButton(kind, action)
	return (kind == 'action' and action == EXTRA_ACTION_ID);
end

-- Bindings
local function TrySetBinding(button)
	if CPAPI.IsButtonValidForBinding(button) then
		local keychord = CPAPI.CreateKeyChord(button)
		local binding = db.Utility:GetBindingForSet(GetSelectedRingID())
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
	Widgets.Select(self, 'RingID', nil, db.Data.Select(1, 1):SetRawOptions(GetRingOptions()), SELECTED_RING_TEXT)
	self:SetDrawOutline(true)
	self.controller:SetCallback(function(value)
		self:OnValueChanged(value)
		self:Update()
		db:TriggerEvent('OnRingSelectionChanged', value)
	end)
	db:RegisterCallback('OnRingAdded', self.OnRingAdded, self)
	db:RegisterCallback('OnRingRemoved', self.OnRingRemoved, self)
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
		text = ADD_NEW_RING_TEXT;
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
		text = ringID == DEFAULT_RING_ID and CLEAR_RING_TEXT or REMOVE_RING_TEXT;
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
local BindingButton = {};

function BindingButton:OnLoad()
	db:RegisterCallback('OnRingSelectionChanged', self.UpdateBinding, self)
end

function BindingButton:OnClick(button)
	if ( button == 'RightButton' ) then
		RemoveBinding(GetSelectedRingID())
		self:UpdateBinding()
		return self:Uncheck()
	end
	CPAPI.Popup('ConsolePort_Rings_Change_Binding', {
		text = SET_BINDING_TEXT;
		OnHide = function()
			self:UpdateBinding()
			self:Uncheck()
		end;
		OnShow = function()
			db.Cursor:SetCurrentNode(self)
		end;
	}, nil, nil, nil, self.Catch)
end

function BindingButton:OnShow()
	self:UpdateBinding()
end

function BindingButton:UpdateBinding()
	self.Slug:SetText(db.Utility:GetButtonSlugForSet(GetSelectedRingID()) or WrapTextInColorCode(NOT_BOUND, 'FF757575'))
end

---------------------------------------------------------------
-- Ring mapper
---------------------------------------------------------------
local Mapper = CreateFromMixins(env.FlexibleMixin)
local ActionMapper = CreateFromMixins(env.BindingActionMapper)
local CollectionMixin = CreateFromMixins(ActionMapper.CollectionMixin, {
	clickActionCallback = function(self)
		local pickup = self.pickup;
		if pickup then
			pickup(self:GetValue())
			db.Utility:CheckCursorInfo(GetSelectedRingID(), true)
			ClearCursor()
		end
		CPIndexButtonMixin.Uncheck(self)
	end;
})

function Mapper:OnShow()
	self:SetVerticalScroll(0)
end

function Mapper:OnLoad()
	env.OpaqueMixin.OnLoad(self)
	self:SetFlexibleElement(self, 360)
	Mixin(self.Child, env.ScaleToContentMixin)
	self.Child:SetWidth(360)
	self.Child:SetAllPoints()
	self.Child:SetMeasurementOrigin(self.Child, self.Child, 360, 40)
	CPAPI.Start(self)

	self.ActionMapper = self.Child.ActionMapper;
end

ActionMapper.OnHide = nil;

function ActionMapper:OnShow()
	self:OnChecked(true)
end

function ActionMapper:OnLoad()
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
			Spell:CreateFromSpellID((select(GET_SPELLID_IDX, GetSpellInfo(id)))):ContinueOnSpellLoad(function()
				self:UpdateProps()
			end)
		end;
	};
})


function LoadoutButton:OnLoad()
	self.ignoreUtilityRing = true;
	self:SetWidth(self:GetParent():GetWidth() - 16)
	self:SetScript('OnShow', self.OnShow)
	self:HookScript('OnEnter', self.OnEnter)
	self:HookScript('OnLeave', self.OnLeave)
end

function LoadoutButton:OnShow()
	db.Alpha.FadeIn(self, 0.1, self:GetAlpha(), 1)
end

function LoadoutButton:OnEnter()
	GameTooltip:SetOwner(self, 'ANCHOR_TOP')
	if self:SetTooltip() then
		self.UpdateTooltip = self.OnEnter;
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
	if not text then
		if IsExtraActionButton(self._state_type, self._state_action) then
			text = BINDING_NAME_EXTRAACTIONBUTTON1:gsub('%d', ''):trim()
		end
	end
	return text;
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
		self:SetText(LFG_LIST_LOADING)
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
	self.Child:SetMeasurementOrigin(self.Child, self.Child, 625, 0)
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
			widget:SetPoint('TOP', prev, 'BOTTOM', 0, -4)
		else
			widget:SetPoint('TOP', 0, -8)
		end
		prev = widget;
	end
	self.Child:SetHeight(nil)
end

---------------------------------------------------------------
-- Rings manager
---------------------------------------------------------------
local RingsManager = {};

function RingsManager:OnFirstShow()
	LibStub('Carpenter'):BuildFrame(self, {
		Control = {
			_Type = 'Frame';
			_Setup = 'BackdropTemplate';
			_Backdrop = CPAPI.Backdrops.Opaque;
			_OnLoad = env.OpaqueMixin.OnLoad;
			_Points = {
				{'TOPLEFT', self, 'BOTTOMLEFT', 0, 60};
				{'BOTTOMRIGHT', self, 'BOTTOMRIGHT', -1, 0};
			};
			{
				RingSelect = {
					_Type = 'IndexButton';
					_Setup = 'CPIndexButtonSettingTemplate';
					_Mixin = RingSelectMixin;
					_Point = {'LEFT', 8, 0};
					_Width = 400;
				};
				RingRemove = {
					_Type = 'IndexButton';
					_Setup = 'CPIndexButtonSimpleTemplate';
					_Point = {'RIGHT', -8, 0};
					_Mixin = RemoveRingButton;
					_Text = BUTTON_WITH_ICON_TEXT:format(RESET);
					_Size = {162, 40};
					_SetNormalTexture = [[Interface\RAIDFRAME\ReadyCheck-NotReady]];
					_SetPushedTexture = [[Interface\RAIDFRAME\ReadyCheck-NotReady]];
					_SetDrawOutline = true;
				};
				RingAdd = {
					_Type = 'IndexButton';
					_Setup = 'CPIndexButtonSimpleTemplate';
					_Point = {'RIGHT', '$parent.RingRemove', 'LEFT', 0, 0};
					_Mixin = AddRingButton;
					_Text = BUTTON_WITH_ICON_TEXT:format(BATTLETAG_CREATE);
					_Size = {162, 40};
					_SetNormalTexture = [[Interface\PaperDollInfoFrame\Character-Plus]];
					_SetPushedTexture = [[Interface\PaperDollInfoFrame\Character-Plus]];
					_SetDrawOutline = true;
				};
				RingBinding = {
					_Type = 'IndexButton';
					_Setup = 'CPIndexButtonBindingActionTemplate';
					_Height = 40;
					_Points = {
						{'LEFT', '$parent.RingSelect', 'RIGHT', 8, 0};
						{'RIGHT', '$parent.RingAdd', 'LEFT', -8, 0};
					};
					_SetDrawOutline = true;
					_RegisterForClicks = {'LeftButtonUp', 'RightButtonUp'};
					_Text = KEY_BINDING ..':';
					_Mixin = BindingButton;
					{
						Catch = {
							_Type = 'Button';
							_Setup = CPAPI.IsRetailVersion and 'SharedButtonLargeTemplate' or 'UIPanelButtonTemplate';
							_Size = {260, 50};
							_Hide = true;
							_OnShow = function(self)
								env.Config:PauseCatcher()
								self:EnableGamePadButton(true)
								self.timeUntilCancel = 5;
							end;
							_OnHide = function(self)
								env.Config:ResumeCatcher()
								self:EnableGamePadButton(false)
								self.timeUntilCancel = 5;
							end;
							_OnUpdate = function(self, elapsed)
								self.timeUntilCancel = self.timeUntilCancel - elapsed;
								self:SetText(('%s (%d)'):format(CANCEL, ceil(self.timeUntilCancel)))
								if self.timeUntilCancel <= 0 then
									self.timeUntilCancel = 5;
									self:GetParent():Hide()
								end
							end;
							_OnGamePadButtonUp = function(self, ...)
								if TrySetBinding(...) then
									self:GetParent():Hide()
								end
							end;
							_OnClick = function(self) self:Hide() end;
						};
					};
				};
			}
		};
	})

	local mapper = self:CreateScrollableColumn('Mapper', {
		_Mixin = Mapper;
		_Setup = {'CPSmoothScrollTemplate', 'BackdropTemplate'};
		_Width = 360;
		_SetDelta = 40;
		_Backdrop = CPAPI.Backdrops.Opaque;
		_Points = {
			{'TOPLEFT', 0, 0};
			{'BOTTOMLEFT', 0, 60};
		};
		{
			Child = {
				_Width = 360;
				{
					ActionMapper = {
						_Type  = 'IndexButton';
						_Setup = 'CPIndexButtonBindingHeaderTemplate';
						_Mixin = ActionMapper;
						_Size  = {340, 40};
						_Text  = SPELLBOOK_ABILITIES_BUTTON;
						_Point = {'TOP', 0, -8};
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
			{'TOPLEFT', 360, 0};
			{'BOTTOMRIGHT', 0, 60};
		};
	})

	self.Control.RingSelect:Construct()
end

env.Rings = ConsolePortConfig:CreatePanel({
	name = L'Rings';
	mixin = RingsManager;
	scaleToParent = true;
	forbidRecursiveScale = true;
})