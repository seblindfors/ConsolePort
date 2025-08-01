local _, env, db, L = ...; db = env.db; L = db.Locale;
---------------------------------------------------------------
local Setting, ROW_WIDTH = {}, 542;
---------------------------------------------------------------

function Setting:OnCreate()
	CPAPI.SetAtlas(self:GetNormalTexture(), 'perks-list-hover', false, true)
	CPAPI.SetAtlas(self:GetHighlightTexture(), 'perks-list-active', false, false)
	self:HookScript('OnEnter', self.LockHighlight)
	self:HookScript('OnLeave', self.UnlockHighlight)
	self:HookScript('OnClick', self.OnExpandOrCollapse)
	self:SetIndentation(1)
	self:SetSize(ROW_WIDTH, 40)
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
local Header = {
---------------------------------------------------------------
	OnClick = nop;
	OnEnter = UIButtonMixin.OnEnter;
	OnLeave = UIButtonMixin.OnLeave;
	SetTooltipInfo   = UIButtonMixin.SetTooltipInfo;
	SetTooltipAnchor = UIButtonMixin.SetTooltipAnchor;
};

function Header:OnAcquire(parent)
	self:SetParent(parent)
	self:SetWidth(ROW_WIDTH)
	self:SetIndentation(0)
	self:SetScript('OnHide', self.OnHide)
	self:SetScript('OnClick', self.OnClick)
	self:SetScript('OnEnter', self.OnEnter)
	self:SetScript('OnLeave', self.OnLeave)
end

function Header:SetIndentation(px)
	if not px or px == math.huge then px = 0 end;
	self.Text:SetPoint('CENTER', px * 0.5, 0)
	self.BarTexture:SetPoint('LEFT',  px > 0 and  px or 0, 0)
	self.BarTexture:SetPoint('RIGHT', px < 0 and  px or 0, 0)
	self.indentation = px;
end

function Header:Release()
	self:SetTooltipInfo(nil)
	self:SetTooltipAnchor(nil)
end

Header.OnHide = Header.Release;

---------------------------------------------------------------
local SettingsHeader = CreateFromMixins(Header);
---------------------------------------------------------------

function SettingsHeader:OnClick()
	local parent = self:GetParent()
	parent.hiddenGroups[self.groupID] = not parent.hiddenGroups[self.groupID];
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
	local header = self.headerPool:Acquire()
	header.groupID = groupID or name;
	header.Text:SetText(L(name))
	Mixin(header, self.headerMixin)
	header:OnAcquire(self)
	header:Show()
	return header;
end

function HeaderOwner:ReleaseHeaders()
	self.headerPool:ReleaseAll()
end

---------------------------------------------------------------
local Settings = Mixin({
---------------------------------------------------------------
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
	self.hiddenGroups = {};
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
		widget:Mount({
			name     = name;
			varID    = data.varID;
			field    = data.field;
			newObj   = newObj;
			owner    = self.owner;
			registry = env;
		})
		widget.layoutIndex = layoutIndex()
		widget:Show()
	end
end

function Settings:OnShow()
	self:ReleaseHeaders()
	self:MarkDirty()

	local sortedGroups, layoutIndex = {}, CreateCounter();
	foreach(env.Variables, function(var, data)
		local group = ('%s | %s'):format(data.main or SETTINGS, data.head or MISCELLANEOUS);

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
		if not self.hiddenGroups[group] then
			self:DrawGroup(group, set, layoutIndex)
		end
	end
end

---------------------------------------------------------------
local SettingsContainer = {};
---------------------------------------------------------------

function SettingsContainer:OnLoad()
	self.Tabs:AddTabs({
		{ text = OPTIONS,        data = 'Options' },
		{ text = L'Layout',      data = 'Loadout' },
		{ text = ADVANCED_LABEL, data = 'Advanced' },
	})
	self.Tabs:RegisterCallback(ButtonGroupBaseMixin.Event.Selected, self.OnTabSelected, self)
	self.Tabs:SelectAtIndex(1)
	self.headerPool = CreateFramePool('Button', self, 'CPPopupHeaderTemplate')
	Mixin(self.ScrollChild.Options, Settings):OnLoad(self:GetParent(), self.headerPool)
	Mixin(self.ScrollChild.Loadout, env.SharedConfig.Loadout):OnLoad(self:GetParent(), self.headerPool)
	Mixin(self.ScrollChild.Advanced, env.SharedConfig.Advanced):OnLoad(self:GetParent(), self.headerPool)
	CPAPI.Start(self)
end

function SettingsContainer:OnTabSelected(button)
	for _, child in ipairs({self.ScrollChild:GetChildren()}) do
		child:Hide()
	end
	self.ScrollChild[button.data]:Show()
end

---------------------------------------------------------------
local CommandButton = { ignoreInLayout = true };
---------------------------------------------------------------

function CommandButton:Setup(config, data)
	Mixin(self, config)
	self.data = data;
	CPSquareIconButtonMixin.OnLoad(self)
end

function CommandButton:Reset()
	self.data = nil;
end

---------------------------------------------------------------
local Config = CreateFromMixins(CPButtonCatcherMixin);
---------------------------------------------------------------

function Config:OnLoad()
	CPButtonCatcherMixin.OnLoad(self)
	self:SetUserPlaced(false)
	Mixin(Setting, env.SharedConfig.Env.Setting) -- borrow code from the config for the settings

	self.Name:SetText(L'Action Bar Configuration')
	self.Portrait.Icon:SetTexture(env.GetAsset([[Textures\Icons\Unbound]]))
	self.Mover:SetTooltipInfo(L'Move', L'Start moving the configuration window.')
	self.Mover:SetOnClickHandler(GenerateClosure(env.TriggerEvent, env, 'OnMoveFrame', self, nil, 10))
	self.Main:SetTooltipInfo(L'Open Main Config', L'Open the main configuration window.')
	self.Main:SetOnClickHandler(function()
		self:Hide()
		ConsolePort()
	end)

	Mixin(self.SettingsContainer, SettingsContainer):OnLoad()
	self:RegisterForDrag('LeftButton')
	self.OnDragStart = self.StartMoving;
	self.OnDragStop  = self.StopMovingOrSizing;
	CPAPI.Start(self)
	env:RegisterCallback('OnCombatLockdown', self.OnCombatLockdown, self)
end

function Config:OnShow()
	ConsolePortConfig:Hide()
	self:SetDefaultClosures()
	env:TriggerEvent('OnConfigShown', true, self)
end

function Config:OnHide()
	self:ReleaseClosures()
	env:TriggerEvent('OnConfigShown', false, self)
end

function Config:SetDefaultClosures()
	self:ReleaseClosures()
	self:CatchButton('PADLSHOULDER', self.SettingsContainer.Tabs.Decrement, self.SettingsContainer.Tabs)
	self:CatchButton('PADRSHOULDER', self.SettingsContainer.Tabs.Increment, self.SettingsContainer.Tabs)
end

function Config:OnCombatLockdown(isLocked)
	if isLocked and self:IsShown() then
		self.showAfterCombat = true;
		return self:Hide()
	elseif self.showAfterCombat then
		self.showAfterCombat = nil;
		return self:Show()
	end
end

---------------------------------------------------------------
-- Factory
---------------------------------------------------------------
env:RegisterSafeCallback('OnConfigToggle', function()
	if not env.Config then
		CPAPI.LoadAddOn('ConsolePort_Config');
		env.Config, env.SharedConfig.Env = CPAPI.CreateConfigFrame(Config, 'Frame', 'ConsolePortActionBarConfig', UIParent, 'CPActionBarConfig')
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
	CmdButton   = CommandButton;
	CreateEditBox = function(parent)
		local editor = CreateFrame('Frame', nil, parent, 'ScrollingEditBoxTemplate')
		editor.BG = CreateFrame('Frame', nil, parent, 'BackdropTemplate')
		editor.BG:SetBackdrop(CPAPI.Backdrops.Opaque)
		editor.BG:SetBackdropColor(0.15, 0.15, 0.15, 1)
		editor.BG:SetPoint('TOPLEFT', editor, 'TOPLEFT', -4, 4)
		editor.BG:SetPoint('BOTTOMRIGHT', editor, 'BOTTOMRIGHT', 4, 0)
		editor.BG:SetFrameLevel(editor:GetFrameLevel() - 1)
		return editor;
	end;
	CreateSquareButtonPool = function(parent, config)
		return CreateFramePool('Button', parent, 'CPSquareButtonTemplate', CPAPI.HideAndClearAnchorsWithReset, false, function(self)
			self:SetSize(38, 38)
			self.owner = self:GetParent()
			if config then Mixin(self, config) end;
			if self.Init then self:Init(config) end;
			SquareIconButtonMixin.OnLoad(self)
		end)
	end;
};