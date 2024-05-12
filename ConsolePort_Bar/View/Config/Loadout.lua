local _, env, db, Widgets = ...; db = env.db;
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

function LoadoutSetting:OnExpandOrCollapse()
	self.Icon:SetShown(self:GetChecked())
	self:ToggleChildren(self:GetChecked())
end

function LoadoutSetting:AddChild(child)
	if not self.children then
		self.children = {};
	end
	tinsert(self.children, child)
	child:SetShown(self:GetChecked())
end

function LoadoutSetting:ToggleChildren(show)
	if self.children then
		for _, child in pairs(self.children) do
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
	env:TriggerEvent(tostring(env(self.path)), child.path:match('([^/]+)$'), value)
end


---------------------------------------------------------------
-- Widgets
---------------------------------------------------------------
-- TODO: if these are ever used anywhere else, they should be
-- moved to a more appropriate location (aka Widgets.lua)

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

function Point:OnMoverClicked()
	env:TriggerEvent(tostring(env(self.variableID)), 'OnMoveStart', GenerateClosure(self.OnMoveCompleted, self))
end

function Point:OnMoveCompleted(point, _, _, x, y)
	env(self.variableID..'/point', point)
	env(self.variableID..'/x', math.floor(x))
	env(self.variableID..'/y', math.floor(y))
end

---------------------------------------------------------------
local Loadout = CreateFromMixins(env.SharedConfig.HeaderOwner, FramePoolCollectionMixin);
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

function Loadout:OnLoad(inputHandler, headerPool)
	local sharedConfig = env.SharedConfig;
	sharedConfig.HeaderOwner.OnLoad(self, LoadoutHeader)
	FramePoolCollectionMixin.OnLoad(self)
	Widgets = sharedConfig.Env.Widgets;

	Mixin(Widgets.CreateWidget('Point', Widgets.Base, PointBlueprint), Point)

	Mixin(LoadoutSetting, sharedConfig.Env.SettingMixin)

	self.owner = inputHandler;
	self.headerPool = headerPool;
	CPAPI.Start(self)
end

function Loadout:OnShow()
	self:MarkDirty()
	self:ReleaseAll()
	self.headerPool:ReleaseAll()

	configuration = env:GetConfiguration()
	local layoutIndex = CreateCounter()
	local configHeader = self:CreateHeader('Loadout')
	configHeader.layoutIndex = layoutIndex()
	for name, interface in db.table.spairs(configuration) do
		self:DrawTopLevel(PATH(BASE_PATH, name), interface, layoutIndex, 1)
	end
end

function Loadout:DrawSetting(parent, path, datapoint, layoutIndex, depth)
	local widget = self:AcquireSetting(path, datapoint[DP], layoutIndex)
	widget:SetIndentation(depth)
	widget:Construct(datapoint.name, path, datapoint, true, env, path, self.owner)
	parent:RegisterCallback(path, widget.OnChildChanged, widget)
	parent:AddChild(widget)
	if datapoint[DP]:IsType('Point') then
		self:DrawChildren(widget, path, datapoint[DP][DP], layoutIndex, depth)
	end
end

function Loadout:DrawContainer(parent, path, datapoint, layoutIndex, depth)
	local widget = self:AcquireSetting(path, datapoint[DP], layoutIndex)
	widget:SetText(datapoint.name)
	widget:SetIndentation(depth)
	parent:AddChild(widget)
	self:DrawChildren(widget, path, datapoint[DP][DP], layoutIndex, depth)
end

function Loadout:DrawInterface(parent, path, interface, layoutIndex, depth)
	local widget = self:AcquireSetting(path, interface[DP][DP], layoutIndex)
	widget:SetText(ConvertName(interface.name, path))
	widget:SetIndentation(depth)
	parent:AddChild(widget)
	self:DrawChildren(widget, path, interface[DP][DP][DP], layoutIndex, depth)
end

function Loadout:DrawTopLevel(path, interface, layoutIndex, depth)
	local widget = self:AcquireSetting(path, interface.props, layoutIndex)
	widget:SetText(interface.internal)
	widget:SetIndentation(depth)
	self:DrawChildren(widget, path, interface.props[DP], layoutIndex, depth)
end

function Loadout:DrawChildren(parent, name, children, layoutIndex, depth)
	for child, datapoint in db.table.spairs(children) do
		if ( not datapoint.hide ) then -- TODO: handle mutable children
			if IsInterface(datapoint) then
				self:DrawInterface(parent, PATH(name, child), datapoint, layoutIndex, depth + 1)
			elseif IsConfigurableType(datapoint) then
				self:DrawSetting(parent, PATH(name, child), datapoint, layoutIndex, depth + 1)
			else
				self:DrawContainer(parent, PATH(name, child), datapoint, layoutIndex, depth + 1)
			end
		end
	end
end

function Loadout:OnCleaned()
	if self.refreshChildren then
		for _, child in pairs(self.refreshChildren) do
			if child:IsShown() and child.OnShow then
				child:OnShow()
			end
		end
		self.refreshChildren = nil;
	end
end

env.SharedConfig.Loadout = Loadout;