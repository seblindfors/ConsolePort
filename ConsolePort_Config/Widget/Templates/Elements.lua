local env, db, Elements, L = CPAPI.GetEnv(...); Elements = env.Elements;
---------------------------------------------------------------

local function InitializeSetting(self, ...)
	Mixin(self, ...)
	self:HookScript('OnEnter', self.LockHighlight)
	self:HookScript('OnLeave', self.UnlockHighlight)
end

Elements.InitializeSetting = InitializeSetting;

---------------------------------------------------------------
local Header = CPAPI.CreateElement('CPHeader', 304, 40);
---------------------------------------------------------------
Elements.Header = Header;

function Header:OnClick()
	self:OnButtonStateChanged()
	self:Synchronize(self:GetElementData(), self:GetChecked())
end

function Header:Init(elementData)
	local data = elementData:GetData()
	self.Text:SetText(data.text)
	self:SetSize(self.size:GetXY())
	self:Synchronize(elementData)
end

function Header:Synchronize(elementData, newstate)
	local data = elementData:GetData()
	local collapsed;
	if ( newstate == nil ) then
		collapsed = data.collapsed;
	else
		collapsed = newstate;
	end
	self:SetChecked(collapsed)
	data.collapsed = collapsed;
	elementData:SetCollapsed(collapsed)
end

function Header:OnAcquire(new)
	if new then
		Mixin(self, Header)
		self:SetScript('OnClick', Header.OnClick)
	end
end

function Header:OnRelease()
	self:SetChecked(false)
end

function Header:Data(text, collapsed)
	return { text = text, collapsed = collapsed };
end

---------------------------------------------------------------
local Subcat = CPAPI.CreateElement('CPCategoryListButtonTemplate', 304, 34);
---------------------------------------------------------------
Elements.Subcat = Subcat;

function Subcat:Init(elementData)
	local data = elementData:GetData()
	self.Text:SetText(data.text)
	self:SetChecked(data.checked)
end

function Subcat:OnAcquire(new)
	if new then
		Mixin(self, Subcat)
		self:SetScript('OnClick', Subcat.OnClick)
	end
end

function Subcat:OnRelease()
	self:SetChecked(false)
end

function Subcat:OnClick()
	local data = self:GetElementData():GetData()
	env:TriggerEvent('Settings.OnSubcatClicked', data.text, data.childData)
end

function Subcat:Data(text, checked, childData)
	return { text = text, checked = checked, childData = childData };
end

---------------------------------------------------------------
local Divider = CPAPI.CreateElement('CPScrollDivider', 0, 10)
---------------------------------------------------------------
Elements.Divider = Divider;

function Divider:Data(extent)
	return { extent = extent };
end

---------------------------------------------------------------
local Title = CPAPI.CreateElement('CPPopupHeaderTemplate', 300, 36)
---------------------------------------------------------------
Elements.Title = Title;

function Title:Init(elementData)
	local data = elementData:GetData()
	self.Text:SetText(data.text)
end

function Title:OnAcquire(new)
	if new then
		Mixin(self, Title)
		self.Text:ClearAllPoints()
		self.Text:SetPoint('LEFT', 38, 0)
	end
end

function Title:Data(dpOrText)
	local text = type(dpOrText) == 'string' and dpOrText or dpOrText.text;
	return { text = text };
end

---------------------------------------------------------------
local Results = CPAPI.CreateElement('SettingsListSectionHeaderTemplate', 292, 45);
---------------------------------------------------------------
Elements.Results = Results;

function Results:Init(elementData)
	local info = elementData:GetData()
	self.Title:SetText(info.text)
	self.Title:SetPoint('TOPRIGHT', -7, -16)
	self:SetSize(Results.size:GetXY())
end

function Results:Data(text)
	return { text = text };
end

---------------------------------------------------------------
local Search = CPAPI.CreateElement('SearchBoxTemplate', 260, 24);
---------------------------------------------------------------
Elements.Search = Search; Search.indent = 6;

function Search:Init(elementData)
	local data = elementData:GetData()
	if data.dispatch then
		self:SetText(data.initText)
	end
end

function Search:OnAcquire(new)
	if new then
		CPAPI.Specialize(self, env.Search, Search)
	end
end

function Search:OnDispatch(text)
	local data = self:GetElementData():GetData()
	data.callback(text)
end

function Search:Data(setup)
	return {
		initText = setup.text or '';
		callback = setup.callback or nop;
		dispatch = setup.dispatch;
	};
end

---------------------------------------------------------------
local Button = CPAPI.CreateElement('CPPopupButtonTemplate', 300, 32)
---------------------------------------------------------------
Elements.Button = Button;

function Button:Init(elementData)
	local data = elementData:GetData()
	self.Text:SetText(data.text)
	self.Icon:SetTexCoord(0, 1, 0, 1)
	self.Icon:SetAtlas(data.atlas)
end

function Button:OnClick()
	local data = self:GetElementData():GetData()
	if data.callback then
		return data.callback()
	end
end

function Button:OnAcquire(new)
	if new then
		CPAPI.Specialize(self, Button)
		self.Icon:SetPoint('LEFT', 16, 0)
		self.Text:SetPoint('LEFT', self.Icon, 'RIGHT', 8, 0)
	end
end

function Button:OnEnter()
	self:LockHighlight()
	local data = self:GetElementData():GetData()
	if data.onenter then
		data.onenter(self)
	end
end

function Button:OnLeave()
	self:UnlockHighlight()
	local data = self:GetElementData():GetData()
	if data.onleave then
		data.onleave(self)
	end
end

function Button:Data(setup)
	return {
		text     = setup.text or BACK;
		callback = setup.callback or nop;
		atlas    = setup.atlas;
		onenter  = setup.onEnter;
		onleave  = setup.onLeave;
	};
end

---------------------------------------------------------------
local Back = CreateFromMixins(Button);
---------------------------------------------------------------
Elements.Back = Back;

function Back:Data(setup)
	local data = Button.Data(self, setup)
	data.atlas = 'common-icon-undo';
	return data;
end

---------------------------------------------------------------
local Setting = CPAPI.CreateElement('CPSetting', 0, 40)
---------------------------------------------------------------
Elements.Setting = Setting;

function Setting:Init(elementData)
	local data = elementData:GetData()
	xpcall(self.Mount, geterrorhandler(), self, {
		name  = data.field.name;
		varID = data.varID;
		field = data.field;
		owner = ConsolePortConfig;
		registry = data.db;
		newObj = true;
	})
end

function Setting:OnChecked(checked)
	-- nop
end

function Setting:Check()
	self:SetChecked(true)
	self:OnChecked(true)
end

function Setting:Uncheck()
	self:SetChecked(false)
	self:OnChecked(false)
end

function Setting:OnAcquire(new)
	if new then
		InitializeSetting(self, env.Setting, Setting)
	end
	db:RegisterCallback('OnDependencyChanged', self.OnDependencyChanged, self)
end

function Setting:OnRelease()
	self:Reset()
	db:UnregisterCallback('OnDependencyChanged', self)
end

function Setting:OnDependencyChanged()
	local isShown = not self.metaData.hide;
	local newExtent = isShown and self.size.y or 0;
	self:GetElementData():GetData().extent = newExtent;
	self:SetHeight(newExtent)
	self:SetShown(isShown)
end

function Setting:Data(datapoint)
	return {
		varID = datapoint.varID;
		field = datapoint.field;
		type  = datapoint.field[1]:GetType();
		db    = datapoint.registry or db;
	};
end

---------------------------------------------------------------
local Cvar = CreateFromMixins(Setting);
---------------------------------------------------------------
Elements.Cvar = Cvar;

function Cvar:Init(elementData)
	local data = elementData:GetData()
	xpcall(self.Mount, geterrorhandler(), self, {
		name       = data.field.name;
		varID      = data.varID;
		field      = data.field;
		owner      = ConsolePortConfig;
		registry   = db;
		newObj     = true;
		callbackID = data.varID;
		callbackFn = function(value)
			self:SetRaw(self.variableID, value, self.variableID)
			self:OnValueChanged(value)
			db:TriggerEvent(self.variableID, value)
		end;
	})
end

function Cvar:OnAcquire(new)
	if new then
		InitializeSetting(self, env.Setting, Cvar)
	end
	db:RegisterCallback('OnDependencyChanged', self.OnDependencyChanged, self)
end

function Cvar:Get()
	local controller = self.controller;
	if controller:IsType('Bool') then
		return self:GetRawBool(self.variableID)
	elseif controller:IsType('Number') or controller:IsType('Range') then
		return tonumber(self:GetRaw(self.variableID))
	end
	return self:GetRaw(self.variableID)
end

function Cvar:SetRaw(...)
	return SetCVar(...)
end

function Cvar:GetRaw(...)
	return GetCVar(...)
end

function Cvar:GetRawBool(...)
	return GetCVarBool(...)
end

function Cvar:Data(datapoint)
	return {
		varID = datapoint.varID;
		field = datapoint.field;
		type  = 'Cvar'..datapoint.field[1]:GetType();
	};
end

---------------------------------------------------------------
local Mapper = CreateFromMixins(Cvar);
---------------------------------------------------------------
Elements.Mapper = Mapper;

function Mapper:OnAcquire(new)
	if new then
		InitializeSetting(self, env.Setting, Mapper)
	end
	db:RegisterCallback('OnDependencyChanged', self.OnDependencyChanged, self)
	db:RegisterCallback('OnMapperConfigLoaded', self.OnMapperValueChanged, self)
	db:RegisterCallback('OnMapperDeviceChanged', self.OnMapperValueChanged, self)
end

function Mapper:OnRelease()
	self:Reset()
	db:UnregisterCallback('OnDependencyChanged', self)
	db:UnregisterCallback('OnMapperConfigLoaded', self)
	db:UnregisterCallback('OnMapperDeviceChanged', self)
end

function Mapper:OnMapperValueChanged()
	self:OnValueChanged(self:GetRaw())
end

function Mapper:SetRaw(_, ...)
	return db.Mapper:SetValue(self.variableID, ...)
end

function Mapper:GetRaw(...)
	return db.Mapper:GetValue(self.variableID, self.controller:Get())
end

function Mapper:GetRawBool(...)
	return db.Mapper:GetValue(self.variableID, self.controller:Get())
end

function Mapper:Data(datapoint)
	return {
		varID = datapoint.varID;
		field = datapoint.field;
		type  = 'Mapper'..datapoint.field[1]:GetType();
	};
end

---------------------------------------------------------------
local Binding = CPAPI.CreateElement('CPBinding', 0, 32)
---------------------------------------------------------------
Elements.Binding = Binding;

local BindingIcon = {
	UpdateTooltip = env.Settings.Base.UpdateTooltip;
	OnEnter = env.Settings.Base.OnEnter;
	OnLeave = env.Settings.Base.OnLeave;
	GetText = CPAPI.Static(EMBLEM_SYMBOL);
	useDefaultTooltipAnchor = true;
}; Elements.BindingIcon = BindingIcon;

function BindingIcon:OnIconChanged(result, saveResult)
	self.NormalTexture:SetAlpha(not result and 0.25 or 1)
	self.NormalTexture:SetTexture(result or CPAPI.GetAsset([[Textures\Button\EmptyIcon]]))
	if saveResult then
		db.Bindings:SetIcon(self:GetParent():GetElementData():GetData().bindingID, result)
	end
end

function BindingIcon:OnClick(button)
	local isClearEvent = button == 'RightButton';
	env:TriggerEvent('OnBindingIconClicked',
		self:GetParent():GetElementData():GetData().bindingID,
		isClearEvent,
		self,
		self.OnIconChanged
	);
end

function Binding:OnClick(button)
	local data = self:GetElementData():GetData()
	local isClearEvent = button == 'RightButton';
	env:TriggerEvent(data.event,
		data.bindingID,  -- the bindingID to be set or cleared
		isClearEvent,    -- if the binding is to be cleared
		data.readonly(), -- if the binding is readonly
		self             -- the element that was clicked
	);
end

function Binding:Init(elementData)
	local data = elementData:GetData()
	self:SetText(data.name)
	self.Slug:SetBinding(data.bindingID)
	self.Icon.tooltipText = ('%s | %s'):format(data.list, data.name)
	self.Icon:OnIconChanged(db.Bindings:GetIcon(data.bindingID), false)
end

function Binding:OnAcquire(new)
	if new then
		InitializeSetting(self, Binding)
		self:SetScript('OnClick', self.OnClick)
		self:HookScript('OnEnter', self.UpdateInfo)

		CPAPI.Specialize(self.Icon, BindingIcon)

		local base = env.Settings.Base;
		self:HookScript('OnEnter', base.OnEnter)
		self:HookScript('OnLeave', base.OnLeave)
		self.UpdateTooltip = base.UpdateTooltip;
	end
end

function Binding:UpdateInfo()
	local data = self:GetElementData():GetData()

	local desc, image  = db.Bindings:GetDescriptionForBinding(data.bindingID, true)
	local readOnlyText = data.readonly();
	local isPairMode   = data.pair;
	local disableHints = not not readOnlyText;

	local lines = { data.list };
	if desc then
		tinsert(lines, desc);
	end
	if readOnlyText then
		tinsert(lines, RED_FONT_COLOR:WrapTextInColorCode(readOnlyText:trim()));
	end

	self.tooltipText = table.concat(lines, '\n\n');
	self.tooltipImage = image;
	self.disableTooltipHints = disableHints;

	local useMouseHints = not ConsolePort:IsCursorNode(self);
	if disableHints then
		self.tooltipHints = nil;
	elseif isPairMode then self.tooltipHints = {
		env:GetTooltipPromptForClick('LeftClick', CHOOSE, useMouseHints),
	} else self.tooltipHints = {
		env:GetTooltipPromptForClick('LeftClick', EDIT, useMouseHints),
		env:GetTooltipPromptForClick('RightClick', REMOVE, useMouseHints),
	} end
end

function Binding:Data(datapoint)
	return {
		name      = datapoint.field.name;
		list      = datapoint.field.list;
		bindingID = datapoint.binding;
		readonly  = datapoint.readonly or nop;
		event     = datapoint.event or 'OnBindingClicked';
		pair      = datapoint.pair;
	};
end

---------------------------------------------------------------
local LoadoutEntry = CPAPI.CreateElement('CPCardLoadoutTemplate', 292, 48);
---------------------------------------------------------------
Elements.LoadoutEntry = LoadoutEntry;
-- Needs to be implemented:
--  OnSelected, ShouldBeChecked, OnLeaveEntry, OnFocusEntry

function LoadoutEntry.UnpackID(id)
	if type(id) == 'table' then
		return unpack(id)
	end
	return id;
end

function LoadoutEntry:OnAcquire(new)
	if new then
		CPAPI.Specialize(self, LoadoutEntry)
		self:OnLoad()
		self:RegisterForDrag('LeftButton')
		self:SetScript('OnDragStop', self.OnDragStop)
		self:SetAttribute('nohooks', true)
		self.InnerContent.SelectedHighlight:SetPoint('TOPLEFT', 50, -20)
	end
end

function LoadoutEntry:Init(elementData)
	local info = elementData:GetData()
	local id, funcs = info.id, info.funcs;
	local texture = funcs.texture(self.UnpackID(id))
	self.Name:SetText(funcs.title(self.UnpackID(id)))
	self.Icon:SetTexture(texture)
	self:SetChecked(self:ShouldBeChecked(info))
end

function LoadoutEntry:ShowTooltip(tooltipFunc, ...)
	local tooltip = GameTooltip;
	tooltip:SetOwner(self, 'ANCHOR_BOTTOMRIGHT', 0, self.size.y)
	NineSliceUtil.ApplyLayoutByName(
		tooltip.NineSlice,
		'CharacterCreateDropdown',
		tooltip.NineSlice:GetFrameLayoutTextureKit()
	);

	tooltipFunc(tooltip, ...)
	RunNextFrame(function()
		tooltip:SetHeight(tooltip:GetHeight() + 24)
		tooltip:SetSize(
			math.max(tooltip:GetWidth(), 90),
			math.max(tooltip:GetHeight(), 70)
		);
	end)
	return tooltip;
end

function LoadoutEntry:OnEnter()
	local info = self:GetElementData():GetData()
	CPCardSmallMixin.OnEnter(self)
	self:ShowTooltip(info.funcs.tooltip, self.UnpackID(info.id))
	self:OnFocusEntry(info)
end

function LoadoutEntry:OnLeave()
	CPCardSmallMixin.OnLeave(self)
	if GameTooltip:IsOwned(self) then
		GameTooltip:Hide()
	end
	-- This may have been released already, check if element data exists.
	self:OnLeaveEntry(self.GetElementData and self:GetElementData():GetData())
end

function LoadoutEntry:OnClick(button)
	if ( button == 'RightButton' ) then
		return self:CollapseToParent()
	end
	self:OnSelected(self:GetElementData():GetData())
end

function LoadoutEntry:OnDragStart()
	local info = self:GetElementData():GetData()
	info.funcs.pickup(self.UnpackID(info.id))
end

function LoadoutEntry:OnDragStop()
	CPCardSmallMixin.OnMouseUp(self)
end

function LoadoutEntry:OnButtonStateChanged()
	CPCardSmallMixin.OnButtonStateChanged(self)
	self.Border:SetAtlas(self:GetChecked()
		and 'glues-characterselect-icon-notify-bg-hover'
		or 'glues-characterselect-icon-notify-bg')
end

function LoadoutEntry:CollapseToParent()
	self:SetChecked(false)

	local parentElementData = self:GetElementData().parent;
	local scrollBox = self:GetParent():GetParent();
	scrollBox:ScrollToElementData(parentElementData, ScrollBoxConstants.AlignCenter, 0, true)

	local scrollView = scrollBox:GetParent():GetScrollView()
	local header = scrollView:FindFrame(parentElementData);
	if header then
		header:Click()
		ConsolePort:SetCursorNodeIfActive(header)
	end
end

function LoadoutEntry:OnRelease()
	self:SetChecked(false)
end

function LoadoutEntry:Data(id, funcs)
	return { id = id, funcs = funcs };
end

---------------------------------------------------------------
local ActionbarMapper = CPAPI.CreateElement('CPActionBarMapper', 300, 60)
local ActionbarMapperButtonPool;
---------------------------------------------------------------
Elements.ActionbarMapper = ActionbarMapper;

local function GetActionButtonBinding(button)
	local actionID = button:GetID()
	return db('Actionbar/Action/'..actionID), actionID;
end

local function ActionButtonInit(button)
	button:SetScale(1.2)
	button.Slug:SetScale(0.75)
end

local function GetActionbarMapperButton(owner)
	if not ActionbarMapperButtonPool then
		ActionbarMapperButtonPool = CreateFramePool('CheckButton', owner, 'CPActionConfigButton')
	end
	local button, new = ActionbarMapperButtonPool:Acquire()
	button.GetBinding = GetActionButtonBinding;
	button:SetParent(owner)
	button:SetFrameLevel(owner:GetFrameLevel() + 1)
	button.SelectedTexture:Hide()
	return button, new;
end

local function ReleaseActionbarMapperButton(button)
	if ActionbarMapperButtonPool then
		ActionbarMapperButtonPool:Release(button)
	end
end

local function IsMainActionBar(value)
	if type(value) == 'number' then
		return value == 1;
	end
	if C_Widget.IsFrameWidget(value) then
		return value:GetElementData():GetData().bar == 1;
	end
	if type(value) == 'table' then
		return value.bar == 1;
	end
end

function ActionbarMapper:Init(elementData)
	local data = elementData:GetData()
	self:SetMinMaxRange(data)
	self:UpdateInfo(data)
	self:UpdateActivePage(db.Pager:GetCurrentPage())
	self:UpdateChildren(data)
end

function ActionbarMapper:SetMinMaxRange(data)
	self.rangeMin = (data.bar - 1) * NUM_ACTIONBAR_BUTTONS + 1;
	self.rangeMax = self.rangeMin + NUM_ACTIONBAR_BUTTONS - 1;
end

function ActionbarMapper:UpdateActivePage(activePage)
	local data = self:GetElementData():GetData()
	self.isActivePage = activePage == data.bar;
	self.InnerContent.Highlight:SetShown(self.isActivePage)
end

function ActionbarMapper:UpdateChildren(data)
	local pair    = data.pair;
	local event   = data.event;
	local offset  = pair and 44 or 46;
	local padding = pair and 8 or 10;
	for i = 1, NUM_ACTIONBAR_BUTTONS do
		local button = self[i];
		if button then
			button:SetID(((data.bar - 1) * NUM_ACTIONBAR_BUTTONS) + i)
			button:SetPoint('RIGHT', -((NUM_ACTIONBAR_BUTTONS - i) * offset) - padding, 0)
			button:SetOnClickEvent(event)
			button:SetPairMode(pair)
			button:SetEditMode(false)
			button:SetPairText(nil)
		end
	end
end

function ActionbarMapper:GetButtonForActionID(actionID)
	if actionID < self.rangeMin or actionID > self.rangeMax then
		return nil;
	end
	for i = 1, NUM_ACTIONBAR_BUTTONS do
		local button = self[i];
		if ( button and button:GetID() == actionID ) then
			return button;
		end
	end
	return nil;
end

function ActionbarMapper:UpdateSlotHighlight(actionID, highlight)
	local button = self:GetButtonForActionID(actionID)
	if not button then return end;
	if highlight then
		button:LockHighlight()
	else
		button:UnlockHighlight()
	end
end

function ActionbarMapper:UpdateSlotSelection(actionID)
	for i = 1, NUM_ACTIONBAR_BUTTONS do
		local button = self[i];
		if button then
			button.SelectedTexture:SetShown(button:GetID() == actionID)
		end
	end
end

do	-- Placeholder icon function for action bars that do not have an icon.
	-- Reusing the PaperDollInfoFrame slots to give the non-iconed action bars some flavor. 
	local prefix = [[Interface\PaperDoll\UI-PaperDoll-Slot-]];
	local icons  = { 'Head', 'Trinket', 'Finger', 'Relic', 'Ammo', 'SecondaryHand', 'MainHand' };
	local function GetPlaceHolderIcon(data)
		return prefix..icons[data.bar % #icons + 1];
	end

	function ActionbarMapper:UpdateInfo(data)
		local page = data.page or data.bar;
		self.Name:SetText(data.name)
		self.Page:SetText(page ~= 0 and page or '')
		if data.icon then
			self.Icon:SetTexCoord(0, 1, 0, 1)
			self.Icon:SetTexture(data.icon)
		elseif IsMainActionBar(data.bar) then
			self.Icon:SetTexCoord(0.2, 0.8, 0.2, 0.8)
			self.Icon:SetTexture([[Interface\Common\help-i]])
		else
			self.Icon:SetTexCoord(0, 1, 0, 1)
			self.Icon:SetTexture(GetPlaceHolderIcon(data))
		end
	end
end

function ActionbarMapper:InitButtons()
	for i = 1, NUM_ACTIONBAR_BUTTONS do
		local button, newObj = GetActionbarMapperButton(self)
		if newObj then
			ActionButtonInit(button)
		end
		button:Show()
		self[i] = button;
	end
end

function ActionbarMapper:OnAcquire(new)
	if new then
		Mixin(self, ActionbarMapper)
		self:SetScript('OnEvent', CPAPI.EventMixin.OnEvent)
		self:EnableMouse(false)
	end
	self:InitButtons()
	self.Info:SetPoint('BOTTOMRIGHT', self[1], 'BOTTOMLEFT', -4, 0)
	db:RegisterCallback('OnActionPageChanged', self.UpdateActivePage, self)
	env:RegisterCallback('OnActionSlotHighlight', self.UpdateSlotHighlight, self)
	env:RegisterCallback('OnActionSlotEdit', self.UpdateSlotSelection, self)
	self:RegisterEvent('ACTIONBAR_SLOT_CHANGED')
end

function ActionbarMapper:OnRelease()
	for i = 1, NUM_ACTIONBAR_BUTTONS do
		local button = self[i];
		if button then
			button:UnlockHighlight()
			ReleaseActionbarMapperButton(button)
			self[i] = nil;
		end
	end
	db:UnregisterCallback('OnActionPageChanged', self)
	env:UnregisterCallback('OnActionSlotHighlight', self)
	self:UnregisterEvent('ACTIONBAR_SLOT_CHANGED')
end

function ActionbarMapper:OnInfoEnter()
	self.Border:SetAtlas('glues-characterselect-icon-notify-bg-hover')

	local data = self:GetElementData():GetData()
	GameTooltip_SetDefaultAnchor(GameTooltip, self)
	if data.info then -- stance bar
		GameTooltip:SetSpellByID(data.info.spellID)
		GameTooltip:AddLine('\n'..NOTE_COLON, ORANGE_FONT_COLOR:GetRGB())
		GameTooltip:AddLine(CPAPI.FormatLongText(L.ACTIONBAR_FORM_DESC, 50), WHITE_FONT_COLOR:GetRGB())
		if self.isActivePage then
			GameTooltip:AddLine('\n'..CPAPI.FormatLongText(L.ACTIONBAR_FORM_ACTIVE_DESC, 50), GREEN_FONT_COLOR:GetRGB())
		end
	elseif IsMainActionBar(data) then
		GameTooltip:SetText(BINDING_HEADER_ACTIONBAR)
		GameTooltip:AddLine(CPAPI.FormatLongText(L.ACTIONBAR_MAIN_DESC, 50), WHITE_FONT_COLOR:GetRGB())
	else
		GameTooltip:SetText(db.Actionbar.Names[data.bar] or data.bar)
		GameTooltip:AddLine(PAGE_NUMBER:format(data.bar), WHITE_FONT_COLOR:GetRGB())
		GameTooltip:AddLine('\n'..NOTE_COLON, ORANGE_FONT_COLOR:GetRGB())
		GameTooltip:AddLine(CPAPI.FormatLongText(L.ACTIONBAR_PAGE_MISMATCH_DESC, 50), WHITE_FONT_COLOR:GetRGB())
	end
	GameTooltip:Show()
end

function ActionbarMapper:OnInfoLeave()
	self.Border:SetAtlas('glues-characterselect-icon-notify-bg')
	if GameTooltip:IsOwned(self) then
		GameTooltip:Hide()
	end
end

function ActionbarMapper:ACTIONBAR_SLOT_CHANGED(actionID)
	if actionID >= self.rangeMin and actionID <= self.rangeMax then
		local button = self[actionID - self.rangeMin + 1];
		if button then
			button:Update()
		end
	end
end

function ActionbarMapper:Data(datapoint)
	return {
		bar   = datapoint.bar;
		name  = datapoint.field.name;
		icon  = datapoint.field.icon;
		info  = datapoint.field.info;
		pair  = datapoint.pair;
		event = datapoint.event or 'OnBindingClicked';
	};
end

ActionbarMapper.ActionButtonInit = ActionButtonInit;
ActionbarMapper.GetActionbarMapperButton = GetActionbarMapperButton;
ActionbarMapper.ReleaseActionbarMapperButton = ReleaseActionbarMapperButton;