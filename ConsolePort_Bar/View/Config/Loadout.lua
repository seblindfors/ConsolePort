local _, env, db, Widgets, L = ...; db = env.db; L = db.Locale;
---------------------------------------------------------------
-- Helpers
---------------------------------------------------------------
local BASE_PATH = 'Layout/children'; -- TODO

local function PATH(name, child)
	return name..'/'..child;
end

local function ConvertName(name, path)
	local text = name or path;
	local button = text:match('/(PAD%w+)$');
	if button then
		return GetBindingText(button)
	end
	return text;
end

local function DisplaySort(t, a, b)
	local iA, iB = t[a].sort, t[b].sort;
	if iA and not iB then
		return true;
	elseif iB and not iA then
		return false;
	elseif iA and iB then
		return iA < iB;
	else
		return a < b;
	end
end

local function LoadSquareButtonPool(self, init, config)
	return CreateFramePool('Button', self, 'CPSquareButtonTemplate', FramePool_HideAndClearAnchors, false, function(self)
		self:SetSize(38, 38)
		self.owner = self:GetParent()
		Mixin(self, config)
		if init then
			init(self)
		end
		SquareIconButtonMixin.OnLoad(self)
	end)
end

---------------------------------------------------------------
local LoadoutHeader = CreateFromMixins(env.SharedConfig.Header);
---------------------------------------------------------------

function LoadoutHeader:OnClick()
	print('hello')
end

---------------------------------------------------------------
local LoadoutSetting, DP = CreateFromMixins(env.SharedConfig.Setting), 1;
---------------------------------------------------------------
local function ReleaseSetting(_, self)
	self:Hide()
	self:ClearAllPoints()
	self:SetChecked(false)
	if self.Reset then
		self:Reset()
	end
	self.children, self.owner = nil, nil;
end

local function GetEndpoint(path)
	return path:match('([^/]+)$')
end

function LoadoutSetting:OnExpandOrCollapse()
	self.Icon:SetShown(self:GetChecked())
	self:ToggleChildren(self:GetChecked())
end

function LoadoutSetting:AddChild(child)
	if not self.children then
		self.children = {};
	end
	self.children[child] = true;
	child:SetShown(self:GetChecked())
end

function LoadoutSetting:ToggleChildren(show)
	if self.children then
		for child in pairs(self.children) do
			child:SetShown(show)
		end
		self:GetParent().refreshChildren = self.children;
		self:GetParent():MarkDirty()
	end
end

function LoadoutSetting:OnHide()
	self:SetChecked(false)
	self:OnExpandOrCollapse()
end

function LoadoutSetting:OnCreate()
	env.SharedConfig.Setting.OnCreate(self)
	self:HookScript('OnHide', self.OnHide)
end

function LoadoutSetting:OnChildChanged(child, value)
	env:TriggerPathEvent(self.path, GetEndpoint(child.path), value)
end


---------------------------------------------------------------
-- Widgets
---------------------------------------------------------------
-- TODO: if these are ever used anywhere else, they should be
-- moved to a more appropriate location (aka Widgets.lua)

local ExpandableWidgets = {
	Point   = true;
	Mutable = true;
};

---------------------------------------------------------------
local Mutable, MutableBlueprint = { OnClick = nop }, {
---------------------------------------------------------------
	Input = {
		_Type  = 'Button';
		_Setup = 'CPSquareButtonTemplate';
		_Size  = {38, 38};
		_Point = {'RIGHT', 0, 0};
		_OnLoad = function(self)
			SquareIconButtonMixin.OnLoad(self)
		end;
		icon   = [[Interface\PaperDollInfoFrame\Character-Plus]];
		iconSize = 18;
		onClickHandler = function(self)
			self:GetParent():TogglePopout(true)
		end;
	};
	Popout = {
		_Type  = 'Frame';
		_Setup = 'CPSelectionPopoutTemplate';
		_Hide  = true;
		_Point = {'TOPRIGHT', -32, 0};
		_Level = 1000;
	};
};

local LoadDeleteButtonPool;
do -- Button pool for mutable delete buttons
	local PopupName, PopupData = 'ConsolePort_Mutable_Confirm_Delete', {
		button1   = YES;
		button2   = CANCEL;
		showAlert = true;
		OnAccept = function(_, data)
			data.owner:OnDelete(data.variableID, data.target)
			ConsolePort:SetCursorNodeIfActive(data.owner)
		end;
		OnHide = function(_, data)
			data.target:UnlockHighlight()
			data.trigger:SetButtonState('NORMAL')
		end;
		OnShow = function(_, data)
			data.target:LockHighlight()
			data.trigger:SetButtonState('PUSHED')
		end;
		text = L('Are you sure you want to delete %s from %s?',
			ORANGE_FONT_COLOR:WrapTextInColorCode('%s'),
			ORANGE_FONT_COLOR:WrapTextInColorCode('%s'));
	};

	local function OnDeleteButtonClicked(self)
		local target = self:GetParent()
		CPAPI.Popup(PopupName, PopupData, target:GetText(), self.owner:GetText(), {
			variableID = self.variableID;
			owner    = self.owner;
			target   = target;
			trigger  = self;
		})
	end

	local function OnDeleteButtonHide(self)
		self.owner.deleteButtonPool:Release(self)
	end

	local function DeleteButtonSetTarget(self, path, target)
		self.variableID = path;
		self:SetParent(target)
		self:SetPoint('RIGHT', target, 'RIGHT', 0, 0)
		self:Show()
	end

	local function OnDeleteButtonInit(self)
		self.SetTarget = DeleteButtonSetTarget;
		self:SetScript('OnHide', OnDeleteButtonHide)
	end

	LoadDeleteButtonPool = function(self)
		self.deleteButtonPool = self.deleteButtonPool or
			LoadSquareButtonPool(self, OnDeleteButtonInit, {
				icon = [[Interface\RAIDFRAME\ReadyCheck-NotReady]];
				iconSize = 18;
				onClickHandler = OnDeleteButtonClicked;
			})
	end
end

function Mutable:OnLoad(...)
	Widgets.Base.OnLoad(self, ...)
	LoadDeleteButtonPool(self)
end

function Mutable:TogglePopout(show)
	if self.addButtonPool then self.addButtonPool:ReleaseAll() end;
	if self.Popout:IsShown() then return self.Popout:Hide() end;
	if not show then return end;

	if not self.addButtonPool then
		self.OnCancelClick = GenerateClosure(self.TogglePopout, self, false)
		self.addButtonPool = CreateFramePool('BUTTON', self.Popout, 'CPSelectionPopoutEntryTemplate')
		self.initialAnchor = AnchorUtil.CreateAnchor('TOPLEFT', self.Popout, 'TOPLEFT', 6, -12)
		self.layout = AnchorUtil.CreateGridLayout(GridLayoutMixin.Direction.TopLeftToBottomRightVertical, 10)
	end

	local buttons, counter, maxDetailsWidth = {}, CreateCounter(), 0;
	for key, info in db.table.spairs(self.controller:GetAvailableKeys()) do
		local button = self.addButtonPool:Acquire()
		local data = { name = GetBindingText(key), key = key, value = info };
		button:SetupEntry(data, counter(), false)
		button.OnCancelClick = self.OnCancelClick;
		maxDetailsWidth = math.max(maxDetailsWidth, button.SelectionDetails:GetWidth())
		tinsert(buttons, button)
	end
	for _, button in ipairs(buttons) do
		button.SelectionDetails:SetWidth(maxDetailsWidth)
		button:Layout()
		button:Show()
	end
	AnchorUtil.GridLayout(buttons, self.initialAnchor, self.layout)
	self.Popout:Show()
	ConsolePort:SetCursorNodeIfActive(buttons[1])
end

function Mutable:OnEntryClick(data)
	self:TogglePopout(false)
	self:OnAdd(data.key)
end

-- TODO: (?) OnAdd, OnDelete are hardcoded
-- This is some convoluted shit, but it works for now.
function Mutable:OnAdd(key)
	self.controller:Add(key)
	local datapoint = self.controller[DP][key];
	local rawData =  datapoint:Get()
	env(PATH(self.variableID, key), rawData)
	env:TriggerPathEvent(self.variableID, 'OnAdd', PATH(self.variableID, key))

	local function DetermineLayoutOffset(count, tbl)
		for _, v in pairs(tbl) do
			if type(v) == 'table' then
				DetermineLayoutOffset(count, v)
			else
				count()
			end
		end
		return count()
	end

	local loadout = self:GetParent()
	local offset = DetermineLayoutOffset(CreateCounter(), rawData)
	loadout:NudgeLayoutIndex(self.layoutIndex + 1, offset)
	local widget = loadout:DrawChild(self, self.variableID, key, datapoint, CreateCounter(self.layoutIndex), self.indentation)
	self:ToggleDeleteButtons()
	ConsolePort:SetCursorNodeIfActive(widget:IsShown() and widget or self)
end

function Mutable:OnDelete(path, owner)
	env(path, nil)
	self.controller:Remove(GetEndpoint(path))
	env:TriggerPathEvent(self.variableID, 'OnDelete', path)
	self.children[owner] = nil;
	owner:Hide()
end

function Mutable:OnClick()
	self:TogglePopout(false)
	self:ToggleDeleteButtons()
end

function Mutable:ToggleDeleteButtons()
	self.deleteButtonPool:ReleaseAll()
	if self:GetChecked() and self.children then
		for child in pairs(self.children) do
			local button = self.deleteButtonPool:Acquire()
			button:SetTarget(child.path, child)
		end
	end
end

Mutable.OnPopoutShown, Mutable.OnEntryMouseEnter, Mutable.OnEntryMouseLeave = nop, nop, nop;

---------------------------------------------------------------
local Point, PointBlueprint = { OnClick = nop }, {
---------------------------------------------------------------
	Input = {
		_Type  = 'Button';
		_Setup = 'CPSquareButtonTemplate';
		_Size  = {38, 38};
		_Point = {'RIGHT', 0, 0};
		_OnLoad = function(self)
			SquareIconButtonMixin.OnLoad(self)
		end;
		icon   = [[Interface\CURSOR\UI-Cursor-Move]];
		iconSize = 20;
		onClickHandler = function(self)
			self:GetParent():OnMoverClicked()
		end;
	};
};

function Point:OnLoad(...)
	Widgets.Base.OnLoad(self, ...)
end

function Point:GetCallback()
	if not self.callback then
		self.callback = GenerateClosure(self.OnMoveCompleted, self)
	end
	return self.callback;
end

function Point:OnMoverClicked()
	-- OnMoveStart: data table (point, x, y) -> OnMoveCompleted: point, _, _, x, y
	-- TODO: (?) hardcoded for action bar env
	self.registry:TriggerPathEvent(self.variableID, 'OnMoveStart', self:GetCallback())
end

function Point:OnMoveCompleted(point, _, _, x, y)
	self.registry(self.variableID..'/point', point)
	self.registry(self.variableID..'/x', math.floor(x)) -- get rid of rounding errors
	self.registry(self.variableID..'/y', math.floor(y))
end

---------------------------------------------------------------
local Loadout = CreateFromMixins(env.SharedConfig.HeaderOwner, FramePoolCollectionMixin);
---------------------------------------------------------------

local function IsConfigurableType(datapoint)
	return not not Widgets[datapoint[DP]:GetType()];
end

local function IsInterface(datapoint)
	return datapoint.IsType and datapoint:IsType('Interface');
end

function Loadout:AcquireSetting(path, field, layoutIndex)
	local pool = self:GetOrCreatePool('CheckButton', self, 'CPPopupButtonTemplate', ReleaseSetting, false, field:GetType())
	local widget, newObj = pool:Acquire()
	if newObj then
		Mixin(widget, LoadoutSetting)
		widget:OnCreate()
	end
	-- HACK: this anchor is useless, but widgets may need a rect to draw correctly
	widget:SetPoint('TOP', 0, 0)
	widget.layoutIndex = layoutIndex()
	widget.registry = env;
	widget.path = path;
	widget:Show()
	return widget;
end

function Loadout:NudgeLayoutIndex(layoutIndex, rate)
	for object in self:EnumerateActive() do
		if object.layoutIndex >= layoutIndex then
			object.layoutIndex = object.layoutIndex + rate;
		end
	end
	self:MarkDirty()
end

function Loadout:OnLoad(inputHandler, headerPool)
	local sharedConfig = env.SharedConfig;
	sharedConfig.HeaderOwner.OnLoad(self, LoadoutHeader)
	FramePoolCollectionMixin.OnLoad(self)
	Widgets = sharedConfig.Env.Widgets;

	Mixin(Widgets.CreateWidget('Point', Widgets.Base, PointBlueprint), Point)
	Mixin(Widgets.CreateWidget('Mutable', Widgets.Base, MutableBlueprint), Mutable)

	Mixin(LoadoutSetting, sharedConfig.Env.SettingMixin)

	self.owner = inputHandler;
	self.headerPool = headerPool;

	LoadDeleteButtonPool(self)
	do -- Copy button pool
		local PopupName, PopupData = 'ConsolePort_Mutable_Confirm_Copy', {
			button1    = YES;
			button2    = CANCEL;
			showAlert  = true;
			hasEditBox = 1;
			OnAccept = function(popup, data)
				data.owner:OnCopy(data.variableID, popup.editBox:GetText())
				ConsolePort:SetCursorNodeIfActive(data.owner)
			end;
			OnHide = function(_, data)
				data.target:UnlockHighlight()
				data.trigger:SetButtonState('NORMAL')
			end;
			OnShow = function(popup, data)
				popup.button1:Disable()
				data.target:LockHighlight()
				data.trigger:SetButtonState('PUSHED')
			end;
			EditBoxOnTextChanged = function(editBox)
				local parent = editBox:GetParent()
				-- HACK: check the upvalued config table for conflicting names
				parent.button1:SetEnabled(UserEditBoxNonEmpty(editBox) and not self.config[editBox:GetText()])
			end;
			text = L('Copy %s from %s:',
				ORANGE_FONT_COLOR:WrapTextInColorCode('%s'),
				ORANGE_FONT_COLOR:WrapTextInColorCode('%s'));
		};

		local function OnCopyButtonClicked(self)
			local target = self:GetParent()
			CPAPI.Popup(PopupName, PopupData, target:GetText(), self.owner:GetText(), {
				variableID = self.variableID;
				owner    = self.owner;
				target   = target;
				trigger  = self;
			})
		end

		self.copyButtonPool = LoadSquareButtonPool(self, nil, {
			icon = [[Interface\BUTTONS\UI-GuildButton-OfficerNote-Up]];
			iconSize = 18;
			onClickHandler = OnCopyButtonClicked;
			tooltipTitle   = BLUE_FONT_COLOR:WrapTextInColorCode(L('Copy'));
			tooltipText    = L('Copy this widget to a new name.');
		})
	end

	CPAPI.Start(self)
end

function Loadout:Update()
	self.updated = false;
	self:MarkDirty()
	self:Draw()
end

function Loadout:OnShow()
	self:MarkDirty()
	self:Draw()
	env:TriggerEvent('OnLoadoutConfigShown', true)
end

function Loadout:OnHide()
	env:TriggerEvent('OnLoadoutConfigShown', false)
end

function Loadout:Draw()
	self.headerPool:ReleaseAll()

	local layoutIndex = CreateCounter()
	local configHeader = self:CreateHeader('Loadout')
	configHeader.layoutIndex = layoutIndex()

	if self.updated then return end; self.updated = true;

	self:ReleaseAll()
	self.deleteButtonPool:ReleaseAll()
	self.copyButtonPool:ReleaseAll()

	self.config = env:GetConfiguration()
	for name, interface in db.table.spairs(self.config) do
		local path = PATH(BASE_PATH, name);
		local widget = self:DrawTopLevel(path, interface, layoutIndex, 1)

		local deleteButton = self.deleteButtonPool:Acquire()
		deleteButton:SetTarget(path, widget)
		deleteButton:SetScript('OnHide', nil)

		local isUnique = env.Toplevel[interface.type];
		if not isUnique then
			local copyButton = self.copyButtonPool:Acquire()
			copyButton.variableID = path;
			copyButton:SetParent(widget)
			copyButton:SetPoint('RIGHT', widget, 'RIGHT', -32, 0)
			copyButton:Show()
		end
	end
end

-- Draws a setting widget that handles a datapoint
function Loadout:DrawSetting(parent, path, datapoint, layoutIndex, depth)
	local widget = self:AcquireSetting(path, datapoint[DP], layoutIndex)
	widget:SetIndentation(depth)
	widget:Construct(datapoint.name, path, datapoint, true, env, path, self.owner)
	parent:RegisterCallback(path, widget.OnChildChanged, widget)
	parent:AddChild(widget)
	if ExpandableWidgets[datapoint[DP]:GetType()] then
		self:DrawChildren(widget, path, datapoint[DP][DP], layoutIndex, depth)
	end
	return widget;
end

-- Draws a container widget that has no inherent handling of a datapoint (such as a table of settings)
function Loadout:DrawContainer(parent, path, datapoint, layoutIndex, depth)
	local widget = self:AcquireSetting(path, datapoint[DP], layoutIndex)
	widget:SetText(datapoint.name)
	widget:SetIndentation(depth)
	parent:AddChild(widget)
	self:DrawChildren(widget, path, datapoint[DP][DP], layoutIndex, depth)
	return widget;
end

-- Draws an interface instance (lacks metadata)
function Loadout:DrawInterface(parent, path, interface, layoutIndex, depth)
	local widget = self:AcquireSetting(path, interface[DP][DP], layoutIndex)
	widget:SetText(ConvertName(interface.name, path))
	widget:SetIndentation(depth)
	parent:AddChild(widget)
	self:DrawChildren(widget, path, interface[DP][DP][DP], layoutIndex, depth)
	return widget;
end

function Loadout:DrawChildren(parent, path, children, layoutIndex, depth)
	for child, datapoint in db.table.spairs(children, DisplaySort) do
		self:DrawChild(parent, path, child, datapoint, layoutIndex, depth)
	end
end

function Loadout:DrawChild(parent, path, child, datapoint, layoutIndex, depth)
	if datapoint.hide then return end;
	if IsInterface(datapoint) then
		return self:DrawInterface(parent, PATH(path, child), datapoint, layoutIndex, depth + 1)
	elseif IsConfigurableType(datapoint) then
		return self:DrawSetting(parent, PATH(path, child), datapoint, layoutIndex, depth + 1)
	else
		return self:DrawContainer(parent, PATH(path, child), datapoint, layoutIndex, depth + 1)
	end
end

-- Draws a toplevel interface widget provided by env:GetConfiguration()
function Loadout:DrawTopLevel(path, interface, layoutIndex, depth)
	local widget = self:AcquireSetting(path, interface.props, layoutIndex)
	widget:SetText(interface.internal)
	widget:SetIndentation(depth)
	widget.owner = interface.widget;
	self:DrawChildren(widget, path, interface.props[DP], layoutIndex, depth)
	return widget;
end

function Loadout:OnCleaned()
	if self.refreshChildren then
		for child in pairs(self.refreshChildren) do
			if child:IsShown() and child.OnShow then
				child:OnShow()
			end
		end
		self.refreshChildren = nil;
	end
end

function Loadout:GetText()
	return db.Locale 'your current loadout';
end

function Loadout:OnDelete(path, widget)
	local owner = widget.owner;
	env:Release(owner)
	self:ReleaseAll()
	env(path, nil)
	self:Update()
end

function Loadout:OnCopy(path, name)
	local newPath = path:gsub(GetEndpoint(path), name);
	local newObj = CopyTable(env(path))
	env(newPath, newObj)
	env.Manager:OnPropsChanged()
	self:Update()
end

env.SharedConfig.Loadout = Loadout;