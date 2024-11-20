local _, env, db, Widgets, L = ...; db = env.db; L = db.Locale;
---------------------------------------------------------------
-- Helpers
---------------------------------------------------------------
local function PATH(name, child) return name..'/'..child end;

local ROOT = 'Layout';
local BASE = PATH(ROOT, 'children');
local COPY = CALENDAR_COPY_EVENT or L'Copy';

local function ConvertName(name, path)
	local text = name or path;
	local button = text:match('/(PAD%w+)$');
	if button then
		local activeDevice = db('Gamepad/Active');
		if activeDevice then
			return activeDevice:GetHotkeyStringForButton(button);
		end
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

local function GetElementNameSuggestion(name, config, i) i = i or CreateCounter(1);
	while config[name] do
		name = ('%s %d'):format(name:gsub('%d', ''):trim(), i())
	end
	return name;
end

local function IsElementNameValid(editBox, config)
	return UserEditBoxNonEmpty(editBox) and not config[editBox:GetText():trim()];
end

local function ValidatePresets(presets)
	if type(presets) ~= 'table' then
		return false;
	end
	for id, preset in pairs(presets) do
		CPAPI.Log('Validating preset %s...', BLUE_FONT_COLOR:WrapTextInColorCode(id))
		if not env.IsV1Layout(preset) and not env.IsV2Layout(preset) then
			CPAPI.Log('Preset %s is not a valid layout.', ORANGE_FONT_COLOR:WrapTextInColorCode(id))
			return false;
		end
	end
	CPAPI.Log('All presets are valid.')
	return true;
end

local function GetPresets()
	local presets = {};
	local function LoadPresets(tbl, isUserPreset)
		for id, preset in db.table.spairs(tbl) do
			tinsert(presets, {
				id       = id;
				preset   = preset;
				readonly = not isUserPreset;
			})
		end
	end
	LoadPresets(env.Presets, true)
	LoadPresets(getmetatable(env.Presets).__index, false)
	return presets;
end

---------------------------------------------------------------
local LoadoutSetting, DP = Mixin({
	LineMinColor = CreateColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 0.05);
	LineMaxColor = NORMAL_FONT_COLOR;
}, env.SharedConfig.Setting), 1;
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
	local icon, hasChildren, isChecked = self.Icon, self:HasChildren(), self:GetChecked();
	self:ToggleChildren(isChecked)
	icon:SetShown(hasChildren)
	if hasChildren then
		CPAPI.SetAtlas(icon, ('Waypoint-MapPin-Minimap-%s'):format(isChecked and 'Tracked' or 'Untracked'))
	end
end

function LoadoutSetting:HasChildren()
	return self.children and next(self.children) ~= nil;
end

function LoadoutSetting:AddChild(child)
	if not self.children then
		self.children = {};
	end
	self.children[child] = true;
	child:SetShown(self:GetChecked())
end

function LoadoutSetting:ToggleChildren(show)
	self.Line:SetShown(self.children and show)
	if self.children then
		for child in pairs(self.children) do
			child:SetShown(show)
		end
		self:GetParent().refreshChildren = self.children;
		self:GetParent():MarkDirty()
		if show then
			RunNextFrame(function()
				local target = self;
				for child in pairs(self.children) do
					if child.layoutIndex > target.layoutIndex then
						target = child;
					end
				end
				self.Line:SetPoint('BOTTOM', target, 'BOTTOM', 0, 0)
			end)
		end
	end
end

function LoadoutSetting:OnHide()
	self:SetChecked(false)
	self:OnExpandOrCollapse()
	if self.isHighlighted then
		self:OnLeaveHighlight()
	end
end

function LoadoutSetting:OnEnterHighlight()
	env:TriggerPathEvent(self.path, 'OnHighlight', true)
	self.isHighlighted = true;
end

function LoadoutSetting:OnLeaveHighlight()
	env:TriggerPathEvent(self.path, 'OnHighlight', false)
	self.isHighlighted = false;
end

function LoadoutSetting:OnCreate()
	env.SharedConfig.Setting.OnCreate(self)
	self:HookScript('OnHide', self.OnHide)
	self:HookScript('OnEnter', self.OnEnterHighlight)
	self:HookScript('OnLeave', self.OnLeaveHighlight)

	self.Line = self:CreateTexture(nil, 'BACKGROUND', nil, -1)
	self.Line:SetColorTexture(WHITE_FONT_COLOR:GetRGBA())
	self.Line:SetGradient('VERTICAL', self.LineMinColor, self.LineMaxColor)
	self.Line:SetPoint('TOP', self.Icon, 'CENTER', 0, 0)
	self.Line:SetWidth(2)
	self.Line:Hide()
end

function LoadoutSetting:OnChildChanged(child, value)
	env:TriggerPathEvent(self.path, GetEndpoint(child.path), value)
end

---------------------------------------------------------------
-- Widgets
---------------------------------------------------------------
-- Reusable widgets for manipulating the loadout.

---------------------------------------------------------------
local Popout = {};
---------------------------------------------------------------

function Popout:Init()
	self.buttonPool = CreateFramePool('BUTTON', self, 'CPSelectionPopoutEntryTemplate')
	self:HookScript('OnHide', self.OnPopoutHide)
	self:SetFrameLevel(100)
end

function Popout:SetInitialAnchor(initialAnchor)
	self.initialAnchor = initialAnchor;
end

function Popout:SetLayout(direction, stride)
	if self.stride ~= stride then
		self.stride = stride;
		self.layout = AnchorUtil.CreateGridLayout(direction, stride)
	end
end

function Popout:OnPopoutHide()
	if not self.buttonPool then return end;
	self.buttonPool:ReleaseAll()
end

function Popout:SetData(entries, init)
	if not self.buttonPool then self:Init() end;
	local buttons, counter, maxDetailsWidth = {}, CreateCounter(), 0;
	for _, data in ipairs(entries) do
		local button = self.buttonPool:Acquire()
		button:SetupEntry(data, counter(), false)
		if init then init(button) end;
		maxDetailsWidth = math.max(maxDetailsWidth, button.SelectionDetails:GetWidth())
		tinsert(buttons, button)
	end
	for _, button in ipairs(buttons) do
		button.SelectionDetails:SetWidth(maxDetailsWidth)
		button:Layout()
		button:Show()
	end
	AnchorUtil.GridLayout(buttons, self.initialAnchor, self.layout)
	self:Show()
	return buttons;
end

---------------------------------------------------------------
local DeleteButton = {
---------------------------------------------------------------
	icon         = [[Interface\RAIDFRAME\ReadyCheck-NotReady]];
	iconSize     = 18;
	tooltipTitle = RED_FONT_COLOR:WrapTextInColorCode(DELETE);
	tooltipText  = L('Delete this element.');
	popupName    = 'ConsolePort_Mutable_Confirm_Delete';
	popupData    = {
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
			YELLOW_FONT_COLOR:WrapTextInColorCode('%s'),
			YELLOW_FONT_COLOR:WrapTextInColorCode('%s'));
	};
};

function DeleteButton:Init()
	self:SetScript('OnHide', self.OnHide)
end

function DeleteButton:Reset()
	self.variableID, self.sourceName = nil, nil;
end

function DeleteButton:SetTarget(path, target, sourceName)
	self.variableID = path;
	self.sourceName = sourceName;
	self:SetParent(target)
	self:ClearAllPoints()
	self:SetPoint('RIGHT', target, 'RIGHT', 0, 0)
	self:Show()
end

function DeleteButton:IsTargetPath(path)
	return self.variableID == path;
end

function DeleteButton:onClickHandler()
	local target = self:GetParent()
	CPAPI.Popup(self.popupName, self.popupData, target:GetText(), self.sourceName or self.owner:GetText(), {
		variableID = self.variableID;
		owner    = self.owner;
		target   = target;
		trigger  = self;
	})
end

local function CreateDeleteButtonPool(self) -- Helper since this is used in multiple widgets
	self.deleteButtonPool = self.deleteButtonPool
		or env.SharedConfig.CreateSquareButtonPool(self, DeleteButton)
end

---------------------------------------------------------------
local CopyButton = {
---------------------------------------------------------------
	icon         = [[Interface\BUTTONS\UI-GuildButton-OfficerNote-Up]];
	iconSize     = 18;
	tooltipTitle = BLUE_FONT_COLOR:WrapTextInColorCode(COPY);
	tooltipText  = L('Copy this element to a new name.');
	popupName    = 'ConsolePort_Mutable_Confirm_Copy';
	popupData    = {
		button1    = OKAY;
		button2    = CANCEL;
		showAlert  = true;
		hasEditBox = 1;
		OnAccept = function(popup, data)
			data.owner:OnCopy(data.variableID, popup.editBox:GetText():trim())
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
			popup.editBox:SetText(data.suggest)
		end;
		EditBoxOnTextChanged = function(editBox, data)
			local parent = editBox:GetParent()
			parent.button1:SetEnabled(IsElementNameValid(editBox, data.owner.config))
		end;
		text = L('Copy %s from %s:',
			YELLOW_FONT_COLOR:WrapTextInColorCode('%s'),
			YELLOW_FONT_COLOR:WrapTextInColorCode('%s'));
	};
};

function CopyButton:onClickHandler()
	local target = self:GetParent()
	CPAPI.Popup(self.popupName, self.popupData, target:GetText(), self.owner:GetText(), {
		variableID = self.variableID;
		owner    = self.owner;
		target   = target;
		trigger  = self;
		suggest  = GetElementNameSuggestion(target:GetText(), self.owner.config);
	})
end

function CopyButton:Reset()
	self.variableID = nil;
end

---------------------------------------------------------------
-- Config widgets
---------------------------------------------------------------
-- TODO: if these are ever used anywhere else, they should be
-- moved to a more appropriate location (aka Widgets.lua)

local ExpandableWidgets = {
	Point   = true;
	Mutable = true;
	Table   = true;
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
	};
};

function Mutable:OnLoad(...)
	Widgets.Base.OnLoad(self, ...)
	CreateDeleteButtonPool(self)
	self.disableTooltipHints = true;
	Mixin(self.Popout, Popout)
end

function Mutable:TogglePopout(show)
	if self.Popout:IsShown() then return self.Popout:Hide() end;
	if not show then return end;

	if not self.addButtonInit then
		self.OnCancelClick = GenerateClosure(self.TogglePopout, self, false)
		self.addButtonInit = function(button)
			button.OnCancelClick = self.OnCancelClick;
		end;
		self.Popout:SetInitialAnchor(AnchorUtil.CreateAnchor('TOPLEFT', self.Popout, 'TOPLEFT', 6, -12))
	end

	local entries = {};
	for key, info in db.table.spairs(self.controller:GetAvailableKeys()) do
		-- HACK: GetBindingText is hardcoded, but it returns the original string if the key is not a binding
		tinsert(entries, { name = GetBindingText(key), key = key, value = info })
	end
	if not next(entries) then return end;

	local maxColumns = 3;
	local stride = math.ceil(#entries / maxColumns);
	self.Popout:SetLayout(GridLayoutMixin.Direction.TopLeftToBottomRightVertical, stride)

	local buttons = self.Popout:SetData(entries, self.addButtonInit)
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
			 -- HACK: mutable children can have lingering tooltips, because they share widget
			 -- type with the toplevel containers. This is a workaround to prevent that, for now.
			child.tooltipText = nil;
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
	self.disableTooltipHints = true;
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

function Point:OnMoveCompleted(point, _, relativePoint, x, y)
	self.registry(self.variableID..'/point', point)
	self.registry(self.variableID..'/relPoint', relativePoint)
	self.registry(self.variableID..'/x', Round(x)) -- get rid of rounding errors
	self.registry(self.variableID..'/y', Round(y))
end

---------------------------------------------------------------
local Table = { OnClick = nop, OnShow = nop };
---------------------------------------------------------------
function Table:OnLoad(...)
	Widgets.Base.OnLoad(self, ...)
	self.disableTooltipHints = true;
end

---------------------------------------------------------------
local Preset = {
---------------------------------------------------------------
	Reset = nop;
	Export = {
		tooltipTitle = L'Export';
		tooltipText  = L'Export this preset to a string that can be shared with others.';
		icon         = CPAPI.GetAsset([[Textures\Frame\Export]]);
		iconSize     = 18;
		onClickHandler = function(self)
			local parent = self:GetParent()
			local popupName = 'ConsolePort_Loadout_Export';
			local popupData = parent.Popups[popupName];
			CPAPI.Popup(popupName, popupData, self.data.name, nil, {
				owner  = parent;
				string = env.SharedConfig.Env.Serialize({ [self.data.name] = self.data });
			})
		end;
	};
};

function Preset:GetType()
	return 'Preset';
end

function Preset:OnLoad()
	Mixin(self, Widgets.Base)
	self:SetScript('OnEnter', Widgets.Base.OnEnter)
	self:SetScript('OnLeave', Widgets.Base.OnLeave)
	self:HookScript('OnEnter', self.LockHighlight)
	self:HookScript('OnLeave', self.UnlockHighlight)
	self:SetScript('OnClick', self.OnPresetClick)
	self.disableTooltipHints = true;
end

function Preset:OnPresetClick()
	self:GetParent():OnPresetClick(self.preset, self)
end

---------------------------------------------------------------
local Loadout = CreateFromMixins(env.SharedConfig.HeaderOwner, CPFramePoolCollectionMixin);
---------------------------------------------------------------

local function IsConfigurableType(datapoint)
	return not not Widgets[datapoint[DP]:GetType()];
end

local function IsInterface(datapoint)
	return datapoint.IsType and datapoint:IsType('Interface');
end

local function IsUniqueInterface(interface)
	return env.Toplevel[interface.type];
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
	return widget, newObj;
end

function Loadout:NudgeLayoutIndex(layoutIndex, rate)
	local function NudgePoolObjects(pool)
		for object in pool:EnumerateActive() do
			if object.layoutIndex >= layoutIndex then
				object.layoutIndex = object.layoutIndex + rate;
			end
		end
	end
	NudgePoolObjects(self)
	NudgePoolObjects(self.headerPool)
	self.layoutIndexOffset = self.layoutIndexOffset + rate;
	self:MarkDirty()
end

function Loadout:OnLoad(inputHandler, headerPool)
	local sharedConfig = env.SharedConfig;
	sharedConfig.HeaderOwner.OnLoad(self, env.SharedConfig.Header)
	CPFramePoolCollectionMixin.OnLoad(self)
	Widgets = sharedConfig.Env.Widgets;

	Mixin(Widgets.CreateWidget('Point', Widgets.Base, PointBlueprint), Point)
	Mixin(Widgets.CreateWidget('Mutable', Widgets.Base, MutableBlueprint), Mutable)
	Mixin(Widgets.CreateWidget('Table', Widgets.Base), Table)
	Mixin(Widgets.CreateWidget('Preset', Widgets.Base), Preset)

	Mixin(LoadoutSetting, sharedConfig.Env.SettingMixin)

	self.owner = inputHandler;
	self.headerPool = headerPool;

	CreateDeleteButtonPool(self)
	self.copyButtonPool = sharedConfig.CreateSquareButtonPool(self, CopyButton)
	self.cmdButtonPool  = sharedConfig.CreateSquareButtonPool(self, sharedConfig.CmdButton)

	self.factory = Mixin(CreateFrame('Frame', nil, self, 'CPSelectionPopoutTemplate'), Popout)
	self.factory:SetPoint('TOPRIGHT', -32, 0)
	self.factory:SetLayout(GridLayoutMixin.Direction.TopLeftToBottomRightVertical, 10)
	self.factory:SetInitialAnchor(AnchorUtil.CreateAnchor('TOPLEFT', self.factory, 'TOPLEFT', 6, -12))
	self.factory:Hide()

	CPAPI.Start(self)
end

---------------------------------------------------------------
-- Loadout controls
---------------------------------------------------------------
Loadout.LayoutControls = {
	{
		tooltipTitle = GREEN_FONT_COLOR:WrapTextInColorCode(ADD);
		tooltipText  = L'Add a new element to your loadout.';
		icon         = [[Interface\PaperDollInfoFrame\Character-Plus]];
		iconSize     = 18;
		onClickHandler = function(self)
			self:GetParent():ToggleFactory(true)
		end;
	};
	{
		tooltipTitle = SAVE;
		tooltipText  = L'Save your current loadout to the preset list.';
		icon         = [[Interface\BUTTONS\UI-GuildButton-PublicNote-Up]];
		iconSize     = 18;
		onClickHandler = function(self)
			self:GetParent():TogglePresetSaveFrame(true)
		end;
	};
};

Loadout.PresetControls = {
	{
		tooltipTitle = L'Import';
		tooltipText  = L'Import serialized preset(s) from an external source.';
		icon         = CPAPI.GetAsset([[Textures\Frame\Import]]);
		iconSize     = 18;
		onClickHandler = function(self)
			local parent = self:GetParent()
			local popupName = 'ConsolePort_Loadout_Import';
			local popupData = parent.Popups[popupName];
			CPAPI.Popup(popupName, popupData, nil, nil, {
				owner = parent;
			})
		end;
	};
	{
		tooltipTitle = L'Export All';
		tooltipText  = L'Export all your custom presets to a string that can be shared with others.';
		icon         = CPAPI.GetAsset([[Textures\Frame\Export]]);
		iconSize     = 18;
		onClickHandler = function(self)
			if not next(env.Presets) then return end;
			local parent = self:GetParent()
			local popupName = 'ConsolePort_Loadout_Export';
			local popupData = parent.Popups[popupName];
			CPAPI.Popup(popupName, popupData, L'Presets', nil, {
				owner  = parent;
				string = env.SharedConfig.Env.Serialize(CopyTable(env.Presets));
			})
		end;
	};
};

Loadout.Popups = {
	ConsolePort_Loadout_Confirm_Add = {
		button1   = OKAY;
		button2   = CANCEL;
		showAlert = true;
		hasEditBox = 1;
		enterClicksFirstButton = true;
		OnAccept = function(popup, data)
			data.owner:OnAdd(data.interface, popup.editBox:GetText():trim())
		end;
		OnShow = function(popup, data)
			popup.button1:Disable()
			popup.editBox:SetText(data.suggest)
		end;
		EditBoxOnTextChanged = function(editBox, data)
			local parent = editBox:GetParent()
			parent.button1:SetEnabled(IsElementNameValid(editBox, data.owner.config))
		end;
		text = L('Please provide a unique name for a new %s in %s:',
			YELLOW_FONT_COLOR:WrapTextInColorCode('%s'),
			YELLOW_FONT_COLOR:WrapTextInColorCode('%s'));
	};
	ConsolePort_Loadout_Confirm_Overwrite = {
		button1   = YES;
		button2   = CANCEL;
		showAlert = true;
		enterClicksFirstButton = true;
		OnAccept = function(_, data)
			data.owner:OnLoadPreset(data.preset)
		end;
		OnHide = function(_, data)
			CPIndexButtonMixin.Uncheck(data.trigger)
		end;
		text = L('Are you sure you want to overwrite %s with %s?',
			YELLOW_FONT_COLOR:WrapTextInColorCode('%s'),
			YELLOW_FONT_COLOR:WrapTextInColorCode('%s'));
	};
	ConsolePort_Loadout_Confirm_Save = {
		button1   = OKAY;
		button2   = CANCEL;
		enterClicksFirstButton = true;
		text = L('Save preset from %s:', YELLOW_FONT_COLOR:WrapTextInColorCode('%s'));
		OnShow = function(popup, data)
			local dialog = popup.insertedFrame;
			for key, value in pairs(data) do
				if dialog[key] then
					dialog[key]:SetText(value)
				end
			end
			dialog.options:SetChecked(false)
			dialog.pager:SetChecked(false)
			dialog:Layout()
		end;
		OnAccept = function(popup, data)
			local dialog = popup.insertedFrame;
			local values = {};
			for key in pairs(data) do
				if dialog[key] then
					values[key] = dialog[key]:GetEditBox():GetText():trim()
				end
			end
			data.owner:OnSave(values,
				dialog.options:GetChecked(),
				dialog.pager:GetChecked()
			);
		end;
	};
	ConsolePort_Loadout_Export = {
		button1    = OKAY;
		hasEditBox = 1;
		text = L('Export %s to a string:', YELLOW_FONT_COLOR:WrapTextInColorCode('%s'));
		enterClicksFirstButton = true;
		OnShow = function(popup, data)
			popup.editBox:SetText(data.string)
		end;
		EditBoxOnTextChanged = function(editBox, data)
			if editBox:GetText() ~= data.string then
				editBox:SetText(data.string)
			end
			editBox:SetCursorPosition(0)
			editBox:HighlightText()
		end;
	};
	ConsolePort_Loadout_Import = {
		button1    = OKAY;
		button2    = CANCEL;
		hasEditBox = 1;
		enterClicksFirstButton = true;
		text = L('Import serialized preset(s):');
		OnShow = function(popup)
			popup.button1:Disable()
		end;
		OnAccept = function(popup, data)
			local text = popup.editBox:GetText():trim()
			data.owner:OnImport(env.SharedConfig.Env.Deserialize(text))
		end;
		EditBoxOnTextChanged = function(editBox)
			local parent = editBox:GetParent()
			local text = editBox:GetText():trim()
			local deserialized = env.SharedConfig.Env.Deserialize(text)
			parent.button1:SetEnabled(ValidatePresets(deserialized))
		end;
	};
};

---------------------------------------------------------------
-- Element factory
---------------------------------------------------------------
function Loadout:ToggleFactory(show)
	if self.factory:IsShown() then return self.factory:Hide() end;
	if not show then return end;

	local entries = {};
	for key, unique in db.table.spairs(env.Toplevel) do
		local available = not unique;
		if not available then
			available = true;
			for _, interface in pairs(self.config) do
				if ( interface.type == key ) then
					available = false;
					break;
				end
			end
		end
		if available then
			tinsert(entries, { name = L(key), interface = env.Interface[key] })
		end
	end
	if not next(entries) then return end;

	local buttons = self.factory:SetData(entries)
	ConsolePort:SetCursorNodeIfActive(buttons[1])
end

function Loadout:OnEntryMouseEnter(entry)
	local interface = entry.selectionData.interface;
	local metadata  = interface[DP];
	GameTooltip:SetOwner(entry, 'ANCHOR_RIGHT')
	GameTooltip:SetText(L(metadata.name))
	GameTooltip:AddLine(L(metadata.desc), 1, 1, 1)
	GameTooltip:Show()
end

function Loadout:OnEntryMouseLeave(entry)
	if GameTooltip:IsOwned(entry) then
		GameTooltip:Hide()
	end
end

function Loadout:OnEntryClick(entryData)
	local interface = entryData.interface;
	local metadata  = interface[DP];
	local popupName = 'ConsolePort_Loadout_Confirm_Add';
	local popupData = self.Popups[popupName];
	self.factory:Hide()
	CPAPI.Popup(popupName, popupData, metadata.name, self:GetText(), {
		owner     = self;
		interface = interface;
		suggest   = GetElementNameSuggestion(metadata.name, self.config);
	})
end

function Loadout:OnDelete(path, widget)
	local owner = widget.owner;
	if owner then
		env:Release(owner)
	end
	self:ReleaseAll()
	env(path, nil)
	self:Update()
end

function Loadout:OnCopy(path, name)
	local newPath = path:gsub(GetEndpoint(path), name);
	local newObj = CopyTable(env(path))
	env(newPath, newObj)
	env:TriggerEvent('OnLayoutChanged', true)
	self:Update()
end

function Loadout:OnAdd(interface, name)
	local newPath = PATH(BASE, name)
	local newObj = interface:Render()
	env(newPath, newObj)
	env:TriggerEvent('OnLayoutChanged', true)
	self:Update()
end

Loadout.OnPopoutShown = nop;

---------------------------------------------------------------
-- Preset management
---------------------------------------------------------------

function Loadout:GetPresetSaveFrame()
	if not self.presetSaveFrame then
		local frame, i = CreateFrame('Frame', nil, nil, 'VerticalLayoutFrame'), CreateCounter()
		frame:Hide()
		frame:SetSize(300, 240)
		frame.spacing = 8;

		local function CreateHeader(text)
			local header = frame:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
			header:SetText(text)
			header.layoutIndex = i()
			return header;
		end

		local function CreateEditBox(height)
			local editor = env.SharedConfig.CreateEditBox(frame)
			editor.layoutIndex = i()
			editor:SetSize(284, height)
			return editor;
		end

		local function CreateCheckBox(text, tooltipText)
			local check = CreateFrame('CheckButton', nil, frame, 'CPCheckButtonTemplate')
			check.layoutIndex = i()
			check:SetText(text)
			check:SetHitRectInsets(0, -check:GetFontString():GetStringWidth(), 0, 0)
			check.OnEnter = Widgets.Base.OnEnter;
			check.OnLeave = Widgets.Base.OnLeave;
			check.UpdateTooltip = Widgets.Base.UpdateTooltip;
			check.tooltipText = tooltipText;
			CPAPI.Start(check)
			return check;
		end

		frame.breaker = CreateFrame('Frame', nil, frame, 'CPPopupHeaderTemplate')
		frame.breaker:SetSize(284, 16)
		frame.breaker.layoutIndex = i()

		frame.nameHeader = CreateHeader(NAME)
		frame.name = CreateEditBox(20)

		frame.descHeader = CreateHeader(DESCRIPTION)
		frame.desc = CreateEditBox(60)

		frame.advancedHeader = CreateHeader(ADVANCED_LABEL)
		frame.options = CreateCheckBox(
			L'Export current options',
			L('Include the current options from the %s tab in the preset data.', BLUE_FONT_COLOR:WrapTextInColorCode(OPTIONS))
		);

		frame.pager = CreateCheckBox(
			L'Export action page logic',
			L'Include the current action page logic in the preset data.'
		);
		frame.pager.disableTooltipHints = true;

		frame.showHeader = CreateHeader(L'Global Visibility')
		frame.visibility = CreateEditBox(60)

		self.presetSaveFrame = frame;
	end

	local tooltipHints = ( next(env.Settings) ~= nil ) and { NORMAL_FONT_COLOR:WrapTextInColorCode(L'Modifications'..':') };
	if tooltipHints then
		for variableID in db.table.spairs(env.Settings) do
			local variable = env.Variables[variableID];
			if variable then
				local head, name = variable.head, variable.name;
				tinsert(tooltipHints, ('• %s: %s'):format(
					BLUE_FONT_COLOR:WrapTextInColorCode(L(head)),
					GREEN_FONT_COLOR:WrapTextInColorCode(L(name))));
			end
		end
	end
	self.presetSaveFrame.options:SetEnabled(tooltipHints);
	self.presetSaveFrame.options.tooltipHints = tooltipHints;
	self.presetSaveFrame.options.disableTooltipHints = not tooltipHints;

	self.presetSaveFrame.pager:SetEnabled(db('actionPageCondition') ~= nil or db('actionPageResponse') ~= nil);

	return self.presetSaveFrame;
end

function Loadout:TogglePresetSaveFrame(show)
	local frame = self:GetPresetSaveFrame()
	if frame:IsShown() then return frame:Hide() end;
	if not show then return end;

	local popupName = 'ConsolePort_Loadout_Confirm_Save';
	local popupData = self.Popups[popupName];
	CPAPI.Popup(popupName, popupData, env.Const.DefaultPresetName, nil, {
		owner       = self;
		name        = ('%s - %s'):format(env(PATH(ROOT, 'name')), env.Const.DefaultPresetName);
		desc        = env(PATH(ROOT, 'desc'));
		visibility  = env(PATH(ROOT, 'visibility'));
	}, frame)
end

function Loadout:OnLoadPreset(preset)
	self:ReleaseAll()
	env:ReleaseAll()

	preset = CopyTable(preset)
	if preset.settings then
		for path, data in pairs(preset.settings) do
			env(path, data)
		end
		preset.settings = nil;
	end
	if preset.pager then
		for path, data in pairs(preset.pager) do
			db(path, data)
		end
		preset.pager = nil;
	end

	env(ROOT, env.UpgradeLayout(preset))
	env:TriggerEvent('OnLayoutChanged', true)
	self:Update()
end

function Loadout:OnImport(presets)
	for name, preset in pairs(presets) do
		env(PATH('Presets', name), env.UpgradeLayout(preset))
	end
	self:Update()
end

function Loadout:OnSave(values, exportSettings, exportPager)
	self:ReleaseAll()

	local preset = CopyTable(env(ROOT))
	for key, value in pairs(values) do
		preset[key] = value;
	end
	if exportSettings then
		preset.settings = CopyTable(env('Settings'))
	end
	if exportPager then
		preset.pager = {
			actionPageCondition = db('actionPageCondition');
			actionPageResponse  = db('actionPageResponse');
		};
	end
	env(PATH('Presets', values.name), preset)

	self:Update()
end

function Loadout:OnPresetClick(preset, trigger)
	local popupName = 'ConsolePort_Loadout_Confirm_Overwrite';
	local popupData = self.Popups[popupName];
	CPAPI.Popup(popupName, popupData, self:GetText(), preset.name, {
		owner   = self;
		preset  = preset;
		trigger = trigger;
	})
end

function Loadout:DrawHeaderControls(header, controls)
	local left, right = math.huge, 0;
	for i, control in ipairs(controls) do
		local button = self.cmdButtonPool:Acquire()
		button:SetPoint('RIGHT', header, 'RIGHT', -(32 * (i - 1)), 0)
		button:Setup(control)
		button:SetFrameLevel(header:GetFrameLevel() + 1)
		button:Show()
		left, right = math.min(left, button:GetLeft()), math.max(right, button:GetRight())
	end
	header:SetIndentation(-(right - left))
end

function Loadout:DrawPresets(layoutIndex)
	self.presetHeader = self:CreateHeader('Presets')
	self.presetHeader.layoutIndex = layoutIndex()

	self:DrawHeaderControls(self.presetHeader, self.PresetControls)

	self.presetButtons = self.presetButtons or {};
	for _, preset in ipairs(self.presetButtons) do
		if preset:IsShown() then
			self:Release(preset)
			if preset.deleteButton then
				if preset.deleteButton:IsTargetPath(preset.path) then
					self.deleteButtonPool:Release(preset.deleteButton)
				end
				preset.deleteButton = nil;
			end
		end
	end
	wipe(self.presetButtons)

	for _, data in ipairs(GetPresets()) do
		local widget, newObj = self:AcquireSetting(PATH('Presets', data.id), Preset, layoutIndex)
		if newObj then
			Mixin(widget, Preset):OnLoad()
		end
		widget:SetText(data.preset.name)
		widget.tooltipText = data.preset.desc;
		widget.preset = data.preset;
		tinsert(self.presetButtons, widget)

		if not data.readonly then
			local deleteButton = self.deleteButtonPool:Acquire()
			deleteButton:SetTarget(PATH('Presets', data.id), widget, L'Presets')
			deleteButton:SetParent(widget)
			deleteButton:SetPoint('RIGHT', widget, 'RIGHT', 0, 0)
			deleteButton:Show()
			widget.deleteButton = deleteButton;

			local exportButton = self.cmdButtonPool:Acquire()
			exportButton:Setup(Preset.Export, data.preset)
			exportButton:SetPoint('RIGHT', widget, 'RIGHT', -32, 0)
			exportButton:SetFrameLevel(widget:GetFrameLevel() + 1)
			exportButton:Show()
		end
	end
end

---------------------------------------------------------------
-- Loadout management
---------------------------------------------------------------
function Loadout:DrawConfiguration(layoutIndex)
	self.layoutHeader = self:CreateHeader('Loadout')
	self.layoutHeader.layoutIndex = layoutIndex()

	self:DrawHeaderControls(self.layoutHeader, self.LayoutControls)

	if self.updated then return end; self.updated = true;

	self:ReleaseAll()
	self.deleteButtonPool:ReleaseAll()
	self.copyButtonPool:ReleaseAll()

	self.config = env:GetConfiguration()
	for name, interface in db.table.spairs(self.config) do
		local path = PATH(BASE, name);
		local widget = self:DrawTopLevel(name, path, interface, layoutIndex, 1)

		local deleteButton = self.deleteButtonPool:Acquire()
		deleteButton:SetTarget(path, widget)
		deleteButton:SetScript('OnHide', nil)

		if not IsUniqueInterface(interface) then
			local copyButton = self.copyButtonPool:Acquire()
			copyButton.variableID = path;
			copyButton:SetParent(widget)
			copyButton:SetPoint('RIGHT', widget, 'RIGHT', -32, 0)
			copyButton:Show()
		end
	end
	self.layoutIndexOffset = layoutIndex()
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
function Loadout:DrawTopLevel(name, path, interface, layoutIndex, depth)
	local widget = self:AcquireSetting(path, interface.props, layoutIndex)
	widget:SetText(name)
	widget:SetIndentation(depth)
	widget:Construct(name, path, interface[DP], true, env, path, interface.widget)
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
	return L'your current loadout';
end

---------------------------------------------------------------
-- Display
---------------------------------------------------------------
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
	self:ToggleFactory(false)
	env:TriggerEvent('OnLoadoutConfigShown', false)
end

function Loadout:Draw()
	self.headerPool:ReleaseAll()
	self.cmdButtonPool:ReleaseAll()
	-- NOTE: securecallfunction to avoid panel-wide error in case of a single widget error
	-- Draw the layout controls
	local layoutIndex = CreateCounter()
	securecallfunction(self.DrawConfiguration, self, layoutIndex)
	-- Draw the preset controls
	layoutIndex = CreateCounter(self.layoutIndexOffset)
	securecallfunction(self.DrawPresets, self, layoutIndex)
end

env.SharedConfig.Loadout = Loadout;