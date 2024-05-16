local _, env, db, config, L = ...; db = env.db; L = db.Locale;
---------------------------------------------------------------
local Setting = {};
---------------------------------------------------------------

function Setting:OnCreate()
	CPAPI.SetAtlas(self:GetNormalTexture(), 'perks-list-hover', false, true)
	CPAPI.SetAtlas(self:GetHighlightTexture(), 'perks-list-active', false, false)
	self:HookScript('OnEnter', self.LockHighlight)
	self:HookScript('OnLeave', self.UnlockHighlight)
	self:HookScript('OnClick', self.OnExpandOrCollapse)
	self:SetIndentation(1)
	self:SetSize(540, 40)
	self:GetNormalTexture():SetPoint('BOTTOMRIGHT', 8, 0)
	CPAPI.SetAtlas(self.Icon, 'Waypoint-MapPin-Minimap-Tracked')
	self.Icon:Hide()
end

function Setting:SetIndentation(level)
	self.Text:SetPoint('LEFT', 32 + ((level - 1) * 8), 0)
	self.Icon:SetPoint('LEFT', 8 + ((level - 1) * 8), 0)
	self.indentation = level;
end

function Setting:OnChecked(checked)
	self.Icon:SetShown(checked)
end

function Setting:OnExpandOrCollapse()
	self.Icon:SetShown(self:GetChecked())
end

function Setting:Check()
	self:SetChecked(true)
	self:OnChecked(true)
end

function Setting:Uncheck()
	self:SetChecked(false)
	self:OnChecked(false)
end

---------------------------------------------------------------
local Header = {};
---------------------------------------------------------------

function Header:OnAcquire(parent)
	self:SetParent(parent)
	self:SetWidth(540)
	self:SetScript('OnClick', self.OnClick)
end

---------------------------------------------------------------
local SettingsHeader = CreateFromMixins(Header);
---------------------------------------------------------------

function SettingsHeader:OnClick()
	local parent = self:GetParent()
	parent.HiddenGroups[self.groupID] = not parent.HiddenGroups[self.groupID];
	parent:ReleaseAll()
	parent:OnShow()
end

---------------------------------------------------------------
local HeaderOwner = {};
---------------------------------------------------------------

function HeaderOwner:OnLoad(headerMixin)
	self.headerMixin = headerMixin;
end

function HeaderOwner:CreateHeader(name, groupID)
	local header, newObj = self.headerPool:Acquire()
	if newObj then
		header.Text:SetTextColor(WHITE_FONT_COLOR:GetRGBA())
	end
	header.groupID = groupID or name;
	header.Text:SetText(L(name))
	Mixin(header, self.headerMixin)
	header:OnAcquire(self)
	header:Show()
	return header;
end

---------------------------------------------------------------
local Settings = Mixin({
---------------------------------------------------------------
	HiddenGroups = {};
	DisplaySort = function(fields, a, b)
		local iA, iB = fields[a].field.sort, fields[b].field.sort;
		if iA and not iB then
			return true;
		elseif iB and not iA then
			return false;
		elseif iA and iB then
			return iA < iB;
		else
			return a < b;
		end
	end;
}, CPIndexPoolMixin, HeaderOwner);

function Settings:OnLoad(inputHandler, headerPool)
	CPIndexPoolMixin.OnLoad(self)
	HeaderOwner.OnLoad(self, SettingsHeader)
	self.owner = inputHandler;
	self.headerPool = headerPool;
	self:CreateFramePool('CheckButton', 'CPPopupButtonTemplate', Setting, nil, self)
	env:RegisterCallback('OnDependencyChanged', self.OnShow, self)
	self:OnShow()
	CPAPI.Start(self)
end

function Settings:DrawGroup(group, set, layoutIndex)
	for name, data in db.table.spairs(set, Settings.DisplaySort) do
		local widget, newObj = self:TryAcquireRegistered(group..':'..name)
		if newObj then
			widget:OnCreate()
		end
		widget:Construct(name, data.varID, data.field, newObj, env, nil, self.owner)
		widget.layoutIndex = layoutIndex()
		widget:Show()
	end
end

function Settings:OnShow()
	self.headerPool:ReleaseAll()
	self:MarkDirty()

	local sortedGroups, layoutIndex = {}, CreateCounter();
	foreach(env.Variables, function(var, data)
		local group = data.head or MISCELLANEOUS;

		if data.hide then
			local widget = self:GetObjectByIndex(group..':'..data.name)
			return widget and widget:Hide()
		end

		if not sortedGroups[group] then
			sortedGroups[group] = {}
		end
		sortedGroups[group][data.name] = {
			varID = var;
			field = data;
		};
	end)

	for group, set in db.table.spairs(sortedGroups) do
		local header = self:CreateHeader(group)
		header.layoutIndex = layoutIndex()
		if not self.HiddenGroups[group] then
			self:DrawGroup(group, set, layoutIndex)
		end
	end
end

---------------------------------------------------------------
local SettingsContainer = { Tabs = CreateRadioButtonGroup() };
---------------------------------------------------------------

function SettingsContainer:OnLoad()
	local ToggleScrollEdge = function(scrollBar) self.BorderArt.ScrollEdge:SetShown(scrollBar:IsShown()) end;
	self.ScrollBar:HookScript('OnShow', ToggleScrollEdge)
	self.ScrollBar:HookScript('OnHide', ToggleScrollEdge)
	self.Tabs:AddButtons(self.TabButtons)
	self.Tabs:RegisterCallback(ButtonGroupBaseMixin.Event.Selected, self.OnTabSelected, self)
	self.Tabs:SelectAtIndex(1)
	self.headerPool = CreateFramePool('Button', self, 'CPPopupHeaderTemplate')
	Mixin(self.ScrollChild.Options, Settings):OnLoad(self:GetParent(), self.headerPool)
	Mixin(self.ScrollChild.Loadout, env.SharedConfig.Loadout):OnLoad(self:GetParent(), self.headerPool)
	CPAPI.Start(self)
end

function SettingsContainer:OnShow()
	db.Gamepad.SetIconToTexture(self.TabDecrementIcon, 'PADLSHOULDER', 32, {24, 24}, {18, 18})
	db.Gamepad.SetIconToTexture(self.TabIncrementIcon, 'PADRSHOULDER', 32, {24, 24}, {18, 18})
end

function SettingsContainer:OnTabSelected(button, tabIndex)
	for _, child in ipairs({self.ScrollChild:GetChildren()}) do
		child:Hide()
	end
	self.tabIndex = tabIndex;
	self.ScrollChild[button.categoryKey]:Show()
end

function SettingsContainer:CatchTabDecrement()
	self.Tabs:SelectAtIndex(self.tabIndex - 1)
end

function SettingsContainer:CatchTabIncrement()
	self.Tabs:SelectAtIndex(self.tabIndex + 1)
end

---------------------------------------------------------------
local Config = CreateFromMixins(CPButtonCatcherMixin);
---------------------------------------------------------------

function Config:OnLoad()
	CPButtonCatcherMixin.OnLoad(self)
	self:SetUserPlaced(false)
	LoadAddOn('ConsolePort_Config');
	env.SharedConfig.Env = ConsolePortConfig:GetEnvironment();
	Mixin(Setting, env.SharedConfig.Env.SettingMixin) -- borrow code from the config for the settings
	self.Name:SetText(L'Action Bar Configuration')
	self.Mover:SetTooltipInfo(L'Move', L'Click here to start moving the configuration window.')
	self.Mover:SetOnClickHandler(GenerateClosure(env.TriggerEvent, env, 'OnMoveFrame', self, nil, 10))
	Mixin(self.SettingsContainer, SettingsContainer):OnLoad()
	CPAPI.Start(self)
end

function Config:OnShow()
	self:SetDefaultClosures()
end

function Config:SetDefaultClosures()
	self:ReleaseClosures()
	self.CatchTabDecrement = self:CatchButton('PADLSHOULDER', self.SettingsContainer.CatchTabDecrement, self.SettingsContainer)
	self.CatchTabIncrement = self:CatchButton('PADRSHOULDER', self.SettingsContainer.CatchTabIncrement, self.SettingsContainer)
end

---------------------------------------------------------------
-- Factory
---------------------------------------------------------------
env:RegisterSafeCallback('OnConfigToggle', function()
	if not env.Config then
		env.Config = Mixin(CreateFrame('Frame', 'ConsolePortActionBarConfig', UIParent, 'CPActionBarConfig'), Config)
		if ( env.Config:GetNumPoints() == 0 ) then
			env.Config:SetPoint('LEFT', (UIParent:GetWidth() - env.Config:GetWidth()) * 0.25, 0)
		end
		env.Config:OnLoad()
	end
	env.Config:SetShown(not env.Config:IsShown())
end)

env.SharedConfig = {
	Setting     = Setting;
	Header      = Header;
	HeaderOwner = HeaderOwner;
};