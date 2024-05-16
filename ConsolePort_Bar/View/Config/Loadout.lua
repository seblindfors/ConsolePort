local _, env, db, Widgets = ...; db = env.db;
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
	self.children = nil;
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

--Interface\RAIDFRAME\ReadyCheck-NotReady

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
		_Point = {'TOP', '$parent', 'BOTTOM', 0, 0};
	};
};

local LoadDeleteButtonPool;
do -- Button pool for mutable delete buttons
	local function OnDeleteButtonClicked(self)
		self.parent:OnDelete(self.variableID, self:GetParent())
	end

	local function OnDeleteButtonHide(self)
		self.parent.deleteButtonPool:Release(self)
	end

	local function OnDeleteButtonInit(self)
		self:SetSize(38, 38)
		self.icon = [[Interface\RAIDFRAME\ReadyCheck-NotReady]];
		self.iconSize = 18;
		self.parent = self:GetParent()
		self.onClickHandler = OnDeleteButtonClicked;
		self:SetScript('OnHide', OnDeleteButtonHide)
		SquareIconButtonMixin.OnLoad(self)
	end

	LoadDeleteButtonPool = function(self)
		self.deleteButtonPool = self.deleteButtonPool or
			CreateFramePool('Button', self, 'CPSquareButtonTemplate', FramePool_HideAndClearAnchors, false, OnDeleteButtonInit)
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
			button.variableID = child.path;
			button:SetParent(child)
			button:SetPoint('RIGHT', child, 'RIGHT', 0, 0)
			button:Show()
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

	if self.updated then return end;
	self.updated = true;

	self:ReleaseAll()
	for name, interface in db.table.spairs(env:GetConfiguration()) do
		self:DrawTopLevel(PATH(BASE_PATH, name), interface, layoutIndex, 1)
	end
end

-- Draws a setting widget that handles a datapoint
function Loadout:DrawSetting(parent, path, datapoint, layoutIndex, depth) --print(path, 'DrawSetting', datapoint[DP]:GetType())
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
function Loadout:DrawContainer(parent, path, datapoint, layoutIndex, depth) --print(path, 'DrawContainer', datapoint[DP]:GetType())
	local widget = self:AcquireSetting(path, datapoint[DP], layoutIndex)
	widget:SetText(datapoint.name)
	widget:SetIndentation(depth)
	parent:AddChild(widget)
	self:DrawChildren(widget, path, datapoint[DP][DP], layoutIndex, depth)
	return widget;
end

-- Draws an interface instance (lacks metadata)
function Loadout:DrawInterface(parent, path, interface, layoutIndex, depth) --print(path, 'DrawInterface', interface[DP][DP]:GetType())
	local widget = self:AcquireSetting(path, interface[DP][DP], layoutIndex)
	widget:SetText(ConvertName(interface.name, path))
	widget:SetIndentation(depth)
	parent:AddChild(widget)
	self:DrawChildren(widget, path, interface[DP][DP][DP], layoutIndex, depth)
	return widget;
end

-- Draws a toplevel interface widget
function Loadout:DrawTopLevel(path, interface, layoutIndex, depth) --print(path)
	local widget = self:AcquireSetting(path, interface.props, layoutIndex)
	widget:SetText(interface.internal)
	widget:SetIndentation(depth)
	self:DrawChildren(widget, path, interface.props[DP], layoutIndex, depth)
	return widget;
end

function Loadout:DrawChildren(parent, path, children, layoutIndex, depth)
	for child, datapoint in db.table.spairs(children) do
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

env.SharedConfig.Loadout = Loadout;