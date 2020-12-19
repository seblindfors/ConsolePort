local _, env = ...; local db, L = env.db;
local Config = {};

local FIXED_OFFSET   = 8;
local PRESETS_WIDTH  = 270;
local OPTIONS_WIDTH  = 300;
local CLUSTER_WIDTH  = 414;
local CLUSTER_HEIGHT = 80;

---------------------------------------------------------------
-- Config management
---------------------------------------------------------------
function env:SetConfig(cfg, triggerEvent, saveToShared)
	self.cfg = cfg;
	ConsolePort_BarSetup = cfg;
	if triggerEvent then
		db:TriggerEvent('OnActionBarConfigChanged', cfg, true)
	end
end

function env:SaveConfig(cfg)
	env.db.Shared:SavePlayerData('Bar', cfg, true)
end

function env:Get(key)
	if self.cfg then
		return self.cfg[key]
	end
end

function env:Set(key, ...)
	if not self.cfg then
		self:SetConfig({})
	end
	if select('#', ...) > 1 then
		self.cfg[key] = {...};
	else
		self.cfg[key] = ...;
	end
	db:TriggerEvent('OnActionBarConfigChanged', self.cfg, false)
end

---------------------------------------------------------------
-- Base mixin for collections
---------------------------------------------------------------
local BaseMixin = CreateFromMixins(CPFocusPoolMixin)

function BaseMixin:OnShow()
	self:DrawOptions()
end

function BaseMixin:OnHide()
	self:ReleaseAll()
end

function BaseMixin:OnLoad()
	CPFocusPoolMixin.OnLoad(self)
	self:CreateFramePool('IndexButton',
		'CPIndexButtonBindingHeaderTemplate', self.WidgetMixin, nil, self.Child)
	Mixin(self.Child, env.config.ScaleToContentMixin)
	self.Child:SetAllPoints()
	self.Child:SetMeasurementOrigin(self, self.Child, self.FixedWidth, FIXED_OFFSET)
end

---------------------------------------------------------------
-- Presets
---------------------------------------------------------------
local Preset, Presets = {}, CreateFromMixins(BaseMixin)
Presets.WidgetMixin, Presets.FixedWidth = Preset, PRESETS_WIDTH;

function Preset:OnLoad()
	self:SetWidth(PRESETS_WIDTH - FIXED_OFFSET)
	self:SetScript('OnClick', self.OnClick)
	self:SetScript('OnShow', self.OnShow)
end

function Preset:OnClick()
	env:SetConfig(db.table.copy(self.preset), true, true)
	self:Check()
end

function Preset:OnShow()
	if db.table.compare(self.preset, env.cfg) then
		self:Check()
	else
		self:Uncheck()
	end
end

function Presets:DrawPreset(name, settings, anchor)
	local widget, newObj = self:Acquire(name)
	if newObj then
		widget:OnLoad()
		widget:SetSiblings(self.Registry)
	end
	widget:Show()
	widget:SetText(name)
	widget.preset = settings;
	if anchor then
		widget:SetPoint('TOP', anchor, 'BOTTOM', 0, -FIXED_OFFSET)
	else
		widget:SetPoint('TOP', 0, -FIXED_OFFSET)
	end
	return widget;
end

function Presets:DrawOptions()
	self:ReleaseAll()
	local prev;
	for name, settings in db.table.spairs(env:GetPresets()) do
		prev = self:DrawPreset(name, settings, prev)
	end
	for name, settings in db.table.spairs(env:GetUserPresets()) do
		prev = self:DrawPreset(name, settings, prev)
	end
	self.Child:SetHeight(nil)
end

---------------------------------------------------------------
-- General settings
---------------------------------------------------------------
local Option, Options = {}, CreateFromMixins(BaseMixin)
Options.WidgetMixin, Options.FixedWidth = Option, OPTIONS_WIDTH;

function Option:OnLoad()
	self.Label:ClearAllPoints()
	self.Label:SetPoint('LEFT', 16, 0)
	self.Label:SetJustifyH('LEFT')
	self.Label:SetTextColor(1, 1, 1)
	self:SetWidth(OPTIONS_WIDTH - FIXED_OFFSET)
	self:SetDrawOutline(true)
end

function Option:SetAsHeader(name)
	self.OnValueChanged = nop;
	self.Label:ClearAllPoints()
	self.Label:SetPoint('CENTER', 0, 0)
	self.Label:SetJustifyH('CENTER')
	self.Label:SetTextColor(1, 1, 0)
	self:SetText(L(name))
	self:SetDrawOutline(false)
	self:SetForceChecked(true)
	self:Check()
	self:Show()
end

function Option:Construct(objType, data, newObj, widgets, get)
	if newObj then
		self:SetText(L(data.name))
		local baseObject = db('Data/'..objType)
		if get then
			controller = baseObject(get())
		else
			controller = baseObject(env:Get(data.cvar))
		end
		local constructor = widgets[data.cvar] or widgets[controller:GetType()]
		if constructor then
			constructor(self, data.cvar, data, controller, data.desc, data.note)
			controller:SetCallback(function(...)
				env:Set(data.cvar, ...)
				self:OnValueChanged(...)
			end)
		end
		if get then
			self.Get = get;
		end
	end
	self:Hide()
	self:Show()
end

function Option:Get()
	return env:Get(self.variableID)
end

function Options:OnLoad()
	BaseMixin.OnLoad(self)
	db:RegisterCallback('OnActionBarConfigChanged', self.UpdateOptions, self)
end

function Options:UpdateOptions()
	for obj in self:EnumerateActive() do
		obj:OnValueChanged(obj:Get())
	end
end

function Options:DrawOption(cvar, data, type, widgets, anchor, get)
	local widget, newObj = self:TryAcquireRegistered(cvar or data.name)
	if newObj then
		widget:OnLoad()
	end
	if cvar then
		widget:Construct(type, data, newObj, widgets, get)
	else
		widget:SetAsHeader(data.name)
	end
	if anchor then
		widget:SetPoint('TOP', anchor, 'BOTTOM', 0, -FIXED_OFFSET)
	else
		widget:SetPoint('TOP', 0, -FIXED_OFFSET)
	end
	return widget;
end

function Options:DrawOptions()
	self:ReleaseAll()
	local widgets, widget = env.config.Widgets;
	for i, data in ipairs(env:GetNumberSettings()) do
		widget = self:DrawOption(data.cvar, data, 'Number', widgets, widget)
		if widget.controller then
			widget.controller:SetStep(data.step)
		end
	end
	for i, data in ipairs(env:GetBooleanSettings()) do
		widget = self:DrawOption(data.cvar, data, 'Bool', widgets, widget)
	end
	for i, data in ipairs(env:GetColorSettings()) do
		local colorCode = data.cvar and data.cvar:gsub('RGB', '')
		widget = self:DrawOption(data.cvar, data, 'Color', widgets, widget, function()
			return env:GetRGBColorFor(colorCode)
		end)
		-- augment OnClick to reset colors
		if widget.controller then
			local script = widget:GetScript('OnClick')
			widget:RegisterForClicks('AnyUp')
			widget:SetScript('OnClick', function(self, button)
				self:Uncheck()
				if (button == 'RightButton') then
					env:Set(data.cvar, nil)
					return self:OnValueChanged(self:Get())
				end
				script(self, button)
			end)
		end
	end
	self.Child:SetHeight(nil)
end

---------------------------------------------------------------
-- Clusters
---------------------------------------------------------------
local Cluster, Field, Clusters = {}, {}, CreateFromMixins(BaseMixin)
Clusters.WidgetMixin, Clusters.FixedWidth = Cluster, CLUSTER_WIDTH;

local VALID_POINTS = {
	'TOP',
	'BOTTOM',
	'CENTER',
	'LEFT', 'TOPLEFT', 'BOTTOMLEFT',
	'RIGHT', 'TOPRIGHT', 'BOTTOMRIGHT',
};

local VALID_DIRS = {
	'up',
	'left',
	'down',
	'right',
	'<hide>',
}

local POINT_MAP = {
	anchor  = 1;
	xOffset = 2;
	yOffset = 3;
}

local Data = db.Data;
local Carpenter, Blueprint = LibStub('Carpenter'), {
	Dir = {
		_Type  = 'IndexButton';
		_Size  = {230, 36};
		_Point = {'TOPRIGHT', 0, -4};
		cvar   = 'dir';
		text   = 'Cluster Direction';
		desc   = 'Direction of modifier flyouts.';
		field  = Data.Select('<hide>', unpack(VALID_DIRS));
	};
	Size = {
		_Type  = 'IndexButton';
		_Size  = {90, 36};
		_Point = {'RIGHT', '$parent.Dir', 'LEFT', 0, 0};
		cvar   = 'size';
		text   = 'Size';
		desc   = 'Size of the main button.';
		note   = 'Modifier buttons will adapt their size accordingly.';
		label  = 'S:';
		field  = Data.Number(64, 1, true);
	};
	Anchor = {
		_Type  = 'IndexButton';
		_Size  = {230, 36};
		_Point = {'BOTTOMRIGHT', 0, 4};
		cvar   = 'anchor';
		text   = 'Anchor Point';
		desc   = 'Point on the bar frame where the cluster is anchored.';
		field  = Data.Select('CENTER', unpack(VALID_POINTS));
	};
	Y = {
		_Type  = 'IndexButton';
		_Size  = {90, 36};
		_Point = {'RIGHT', '$parent.Anchor', 'LEFT', 0, 0};
		cvar   = 'yOffset';
		text   = 'Vertical Offset';
		desc   = 'Number of vertical pixel units from the origin point.';
		label  = 'Y:';
		field  = Data.Number(0, 1);
	};
	X = {
		_Type  = 'IndexButton';
		_Size  = {90, 36};
		_Point = {'RIGHT', '$parent.Y', 'LEFT', 0, 0};
		cvar   = 'xOffset';
		text   = 'Horizontal Offset';
		desc   = 'Number of horizontal pixel units from the origin point.';
		label  = 'X:';
		field  = Data.Number(0, 1);
	};
	Enabled = {
		_Type  = 'IndexButton';
		_Size  = {68, 36};
		_Point = {'RIGHT', '$parent.Size', 'LEFT', 0, 0};
		cvar   = 'enabled';
		text   = 'Enabled';
		desc   = 'Show the cluster for this binding.';
		label  = ('|T%s:14:28:0:0:128:64|t'):format('Interface\\AddOns\\ConsolePort_Bar\\Textures\\Show');
		field  = Data.Bool(true);
	};
}

function Field:GetText()
	return self.text;
end

function Field:Get()
	local clusterData = env:Get('layout')[self.binding];
	local cvar = self.cvar;
	if (cvar == 'enabled') then
		return clusterData ~= nil;
	end
	if clusterData then
		local anchorCvar = POINT_MAP[cvar];

		if anchorCvar then
			local anchor = clusterData.point;
			if anchor and anchorCvar then
				return anchor[anchorCvar];
			end
		elseif (clusterData[cvar] ~= nil) then
			return clusterData[cvar];
		end
	end
	return self.default;
end

function Cluster:IsEnabled()
	return env:Get('layout')[self.binding] ~= nil;
end

function Cluster:ConstructOnClick()
	self:SetScript('OnClick', nil) -- remove so it doesn't get hooked
	self:Construct(true)
end

function Cluster:SetPendingConstruct()
	local abbreviation = _G[('KEY_ABBR_%s'):format(self.binding)] or '';
	local bindingName  = _G[('KEY_%s'):format(self.binding)] or '';
	self:SetScript('OnClick', self.ConstructOnClick)
	self.Label:ClearAllPoints()
	self.Label:SetPoint('LEFT', 16, 0)
	self.Label:SetJustifyH('LEFT')
	self.Label:SetText(('%s %s'):format(
		abbreviation,
		abbreviation:match('ConsolePort') and
		('|cFFFFFFFF%s|r'):format(bindingName) or
		('|cFF555555%s|r'):format(bindingName)
	));
end

function Cluster:Recompile()
	local layout = env:Get('layout') or {};
	local set = layout[self.binding] or {};

	for obj, data in pairs(Blueprint) do
		local controller = self[obj].controller;
		local anchorCvar = POINT_MAP[data.cvar];

		if (data.cvar == 'enabled') then
			if not controller:Get() then
				set = nil;
				break;
			end
		elseif anchorCvar then
			local point = set.point or {};
			point[anchorCvar] = controller:Get()
			set.point = point;
		else
			set[data.cvar] = controller:Get()
		end
	end
	layout[self.binding] = set;
	env:Set('layout', layout)
end

function Cluster:OnLoad()
	self:SetDrawOutline(true)
	self:SetWidth(CLUSTER_WIDTH - (FIXED_OFFSET/2))
end

function Cluster:MoveLabel()
	self.Label:ClearAllPoints()
	self.Label:SetPoint('TOPLEFT', 4, -4)
	self.Label:SetJustifyH('LEFT')
	self.Label:SetTextColor(1, 1, 1)
	self.Label:SetText(_G[('KEY_ABBR_%s'):format(self.binding)])
end

function Cluster:Construct(newObj)
	if newObj then
		self:SetHeight(CLUSTER_HEIGHT)
		self:SetDrawOutline(false)
		self:SetForceChecked(true)
		self:SetThumbPosition('TOP', .5)
		self:MoveLabel()
		self:Check()
		Carpenter:BuildFrame(self, Blueprint, false, true)
		for obj, data in pairs(Blueprint) do
			local container = self[obj];
			local controller = data.field();
			local constructor = self.widgets[controller:GetType()];
			----------------------------------
			container.controller = controller;
			container.default    = controller:Get()
			container.binding    = self.binding;
			container.cvar       = data.cvar;
			----------------------------------
			Mixin(container, Field)
			constructor(container, data.cvar, nil, controller, data.desc, data.note)
			controller:Set(container:Get())
			controller:SetCallback(function(...)
				self:Recompile()
				container:OnValueChanged(...)
			end)
			----------------------------------
			if data.label then
				container.Label = container:CreateFontString(nil, 'ARTWORK', 'GameFontWhiteTiny')
				container.Label:SetPoint('LEFT', 6, 0)
				container.Label:SetJustifyH('LEFT')
				container.Label:SetText(data.label)
			end
		end
	end
	self:Hide()
	self:Show()
end

function Clusters:DrawOption(binding, widgets, anchor)
	local widget, newObj = self:TryAcquireRegistered(binding)
	if newObj then
		widget.widgets = widgets;
		widget.binding = binding;
		widget.Label:SetText(_G[('KEY_%s'):format(binding)])
		widget:OnLoad()
		if widget:IsEnabled() then
			widget:Construct(newObj)
		else
			widget:SetPendingConstruct()
		end
	end
	widget:Show()
	if anchor then
		widget:SetPoint('TOP', anchor, 'BOTTOM', 0, -FIXED_OFFSET)
	else
		widget:SetPoint('TOP', 0, -FIXED_OFFSET)
	end
	return widget;
end

function Clusters:OnLoad()
	BaseMixin.OnLoad(self)
	db:RegisterCallback('OnActionBarConfigChanged', self.UpdateOptions, self)
end

function Clusters:DrawOptions()
	self:ReleaseAll()
	local widgets, device, widget = env.config.Widgets, db('Gamepad/Active');
	-- Separate bindings into enabled/disabled, so that enabled
	-- buttons come out on top. 
	local enabled, disabled = {}, {};
	for binding in ConsolePort:GetBindings() do
		if device:IsButtonValidForBinding(binding) then
			if env:Get('layout')[binding] then
				enabled[binding] = true;
			else
				disabled[binding] = true;
			end
		end
	end
	for binding in db.table.spairs(enabled) do
		widget = self:DrawOption(binding, widgets, widget)
	end
	for binding in db.table.spairs(disabled) do
		widget = self:DrawOption(binding, widgets, widget)
	end
	self.Child:SetHeight(nil)
end

function Clusters:UpdateOptions()
	for obj in self:EnumerateActive() do
		obj:Hide()
		obj:Show()
	end
end

---------------------------------------------------------------
-- Mover
---------------------------------------------------------------
local Mover = {};

function Mover:OnDragStart()
	local button = self.button;
	button:SetClampedToScreen(true)
	button:SetMovable(true)
	button:StartMoving()
	env.db.Alpha.FadeOut(env.config.Config, 0.25, env.config.Config:GetAlpha(), 0)
	self:RegisterEvent('PLAYER_REGEN_DISABLED')
	self:SetScript('OnEvent', self.OnDragStop)
end

function Mover:OnDragStop()
	local button = self.button;
	button:StopMovingOrSizing()
	button:SetMovable(false)
	button:SetClampedToScreen(false)

	env.db.Alpha.FadeIn(env.config.Config, 0.25, env.config.Config:GetAlpha(), 1)
	self:UnregisterAllEvents()
	self:SetScript('OnEvent', nil)

	local layout = env:Get('layout')
	local barX, barY = env.bar:GetCenter()
	local point, x, y = 'CENTER', button:GetCenter()

	layout[button.plainID].point = {point, floor(x - barX), floor(y - barY)};
	env:Set('layout', layout)
end

function Mover:OnLoad()
	self:RegisterForDrag('LeftButton')
	self:EnableMouse(true)
end

---------------------------------------------------------------
-- Panel
---------------------------------------------------------------
function Config:DrawMovers()
	self.Movers:ReleaseAll()
	local mixer = env.db.table.mixin;
	for i, cluster in ipairs(env.bar.Buttons) do
		local button = cluster[''];
		local mover, newObj = self.Movers:Acquire()
		if newObj then
			mixer(mover, Mover)
			mover:OnLoad()
		end
		mover:SetAllPoints(button)
		mover:SetFrameLevel(button:GetFrameLevel() + 1)
		mover:Show()
		mover.button = button;
	end
end

function Config:OnShow()
	self:DrawMovers()
end

function Config:OnHide()
	env:SaveConfig(env.cfg)
	self.Movers:ReleaseAll()
end

function Config:OnFirstShow()
	local cvars = Carpenter:BuildFrame(self, {
		Cvars = {
			_Type  = 'Frame';
			_Setup = 'BackdropTemplate';
			_Backdrop = CPAPI.Backdrops.Opaque; 
			_Width = PRESETS_WIDTH + 1;
			_Points = {
				{'TOPLEFT', '$parent', 'BOTTOMLEFT', -1, 50 + FIXED_OFFSET};
				{'BOTTOMLEFT', -1, -1};
			};
			{
				CooldownNum = {
					_Type  = 'IndexButton';
					_Setup = 'CPIndexButtonBindingHeaderTemplate';
					_Point = {'TOP', 0, -FIXED_OFFSET};
					meta = {
						type = Data.Bool;
						cvar = 'countdownForCooldowns';
						name = 'Cooldown Numbers';
						desc = OPTION_TOOLTIP_COUNTDOWN_FOR_COOLDOWNS; 
					};
				};
			};
		};
	}, false, true).Cvars;
	local presets = self:CreateScrollableColumn('Presets', {
		_Mixin = Presets;
		_Width = PRESETS_WIDTH;
		_Setup = {'CPSmoothScrollTemplate'};
		_Points = {
			{'TOPLEFT', 0, 1};
			{'BOTTOMLEFT', '$parent.Cvars', 'TOPLEFT', 0, 0};
		};
	})
	local options = self:CreateScrollableColumn('Options', {
		_Mixin = Options;
		_Width = OPTIONS_WIDTH;
		_Setup = {'CPSmoothScrollTemplate', 'BackdropTemplate'};
		_Backdrop = CPAPI.Backdrops.Opaque;
		_Points = {
			{'TOPLEFT', '$parent.Presets', 'TOPRIGHT', 0, 0};
			{'BOTTOMLEFT', '$parent.Cvars', 'BOTTOMRIGHT', -1, 0};
		};
	})
	local clusters = self:CreateScrollableColumn('Clusters', {
		_Mixin = Clusters;
		_Width = CLUSTER_WIDTH;
		_Setup = {'CPSmoothScrollTemplate', 'BackdropTemplate'};
		_Backdrop = CPAPI.Backdrops.Opaque;
		_Points = {
			{'TOPLEFT', '$parent.Options', 'TOPRIGHT', 0, 0};
			{'BOTTOMLEFT', '$parent.Options', 'BOTTOMRIGHT', 0, 0};
		};
	})
	self.Movers = CreateFramePool('Frame', env.bar);
	env.config.OpaqueMixin.OnLoad(options)
	env.config.OpaqueMixin.OnLoad(clusters)
	env.config.OpaqueMixin.OnLoad(cvars)


	cvars.OnVariableChanged = nop; -- need this to ignore callback
	for i, child in ipairs({'CooldownNum'}) do
		local cvar = cvars[child];
		env.db.table.mixin(cvar, env.config.CvarMixin)
		cvar:OnLoad()
		cvar:SetWidth(PRESETS_WIDTH - FIXED_OFFSET - 1)
		cvar:Construct(cvar.meta, true, cvars)
	end
end


db:RegisterCallback('OnConfigLoaded', function(localEnv, config, env)
	localEnv.config, localEnv.panel, L = env, config, env.L;
	env.Bars = config:CreatePanel({
		name  = BINDING_HEADER_ACTIONBAR;
		mixin = Config;
		scaleToParent = true;
		forbidRecursiveScale = true;
	})
end, env)