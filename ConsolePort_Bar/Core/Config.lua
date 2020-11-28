local _, env = ...; local db, L = env.db;
local Config = {};

local PRESETS_WIDTH = 270;
local OPTIONS_WIDTH = 300;
local CLUSTER_WIDTH = 414;
local FIXED_OFFSET  = 8;

function env:SetConfig(cfg, triggerEvent)
	self.cfg = cfg;
	ConsolePort_BarSetup = cfg;
	if triggerEvent then
		db:TriggerEvent('OnActionBarConfigChanged', cfg, true)
	end
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
	db:TriggerEvent('OnActionBarConfigChanged', self.cfg, true)
end

---------------------------------------------------------------
-- Presets
---------------------------------------------------------------
local Preset, Presets = {}, CreateFromMixins(CPFocusPoolMixin)

function Preset:OnLoad()
	self:SetWidth(PRESETS_WIDTH - FIXED_OFFSET)
	self:SetScript('OnClick', self.OnClick)
	self:SetScript('OnShow', self.OnShow)
end

function Preset:OnClick()
	env:SetConfig(db.table.copy(self.preset), true)
	self:Check()
end

function Preset:OnShow()
	if db.table.compare(self.preset, env.cfg) then
		self:Check()
	else
		self:Uncheck()
	end
end

function Presets:OnLoad()
	CPFocusPoolMixin.OnLoad(self)
	self:CreateFramePool('IndexButton',
		'CPIndexButtonBindingHeaderTemplate', Preset, nil, self.Child)
	Mixin(self.Child, env.config.ScaleToContentMixin)
	self.Child:SetAllPoints()
	self.Child:SetMeasurementOrigin(self, self.Child, PRESETS_WIDTH, FIXED_OFFSET)
end

function Presets:OnHide()
	self:ReleaseAll()
end

function Presets:OnShow()
	self:DrawOptions()
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
	self.Child:SetHeight(nil)
end

---------------------------------------------------------------
-- General settings
---------------------------------------------------------------
local Option, Options = {}, CreateFromMixins(CPFocusPoolMixin)

function Option:OnLoad()
	self.Label:ClearAllPoints()
	self.Label:SetPoint('LEFT', 16, 0)
	self.Label:SetJustifyH('LEFT')
	self.Label:SetTextColor(1, 1, 1)
	self:SetWidth(OPTIONS_WIDTH - FIXED_OFFSET)
	self:SetDrawOutline(true)
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
	CPFocusPoolMixin.OnLoad(self)
	self:CreateFramePool('IndexButton',
		'CPIndexButtonBindingHeaderTemplate', Option, nil, self.Child)
	Mixin(self.Child, env.config.ScaleToContentMixin)
	self.Child:SetAllPoints()
	self.Child:SetMeasurementOrigin(self, self.Child, OPTIONS_WIDTH, FIXED_OFFSET)
	db:RegisterCallback('OnActionBarConfigChanged', self.UpdateOptions, self)
end

function Options:UpdateOptions()
	for obj in self:EnumerateActive() do
		obj:OnValueChanged(obj:Get())
	end
end

function Options:DrawOption(i, data, type, widgets, anchor, get)
	local widget, newObj = self:TryAcquireRegistered(i)
	if newObj then
		widget:OnLoad()
	end
	widget:Construct(type, data, newObj, widgets, get)
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
		widget.controller:SetStep(data.step)
	end
	for i, data in ipairs(env:GetBooleanSettings()) do
		widget = self:DrawOption(data.cvar, data, 'Bool', widgets, widget)
	end
	for i, data in ipairs(env:GetColorSettings()) do
		local colorCode = data.cvar:gsub('RGB', '')
		widget = self:DrawOption(data.cvar, data, 'Color', widgets, widget, function()
			return env:GetRGBColorFor(colorCode)
		end)
		-- augment OnClick to reset colors
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
	self.Child:SetHeight(nil)
end

function Options:OnShow()
	self:DrawOptions()
end

function Options:OnHide()
	self:ReleaseAll()
end

---------------------------------------------------------------
-- Panel
---------------------------------------------------------------
function Config:OnFirstShow()
	local presets = self:CreateScrollableColumn('Presets', {
		_Mixin = Presets;
		_Width = PRESETS_WIDTH;
		_Setup = {'CPSmoothScrollTemplate'};
		_Points = {
			{'TOPLEFT', 0, 1};
			{'BOTTOMLEFT', 0, -1};
		};
	})
	local options = self:CreateScrollableColumn('Options', {
		_Mixin = Options;
		_Width = OPTIONS_WIDTH;
		_Setup = {'CPSmoothScrollTemplate', 'BackdropTemplate'};
		_Backdrop = CPAPI.Backdrops.Opaque;
		_Points = {
			{'TOPLEFT', '$parent.Presets', 'TOPRIGHT', 0, 0};
			{'BOTTOMLEFT', '$parent.Presets', 'BOTTOMRIGHT', 0, 0};
		};
	})
	local clusters = self:CreateScrollableColumn('Clusters', {
		_Mixin = {};
		_Width = 414;
		_Setup = {'CPSmoothScrollTemplate', 'BackdropTemplate'};
		_Backdrop = CPAPI.Backdrops.Opaque;
		_Points = {
			{'TOPLEFT', '$parent.Options', 'TOPRIGHT', 0, 0};
			{'BOTTOMLEFT', '$parent.Options', 'BOTTOMRIGHT', 0, 0};
		};
	})
	env.config.OpaqueMixin.OnLoad(options)
	env.config.OpaqueMixin.OnLoad(clusters)
end


db:RegisterCallback('OnConfigLoaded', function(localEnv, config, env)
	localEnv.config, L = env, env.L;
	env.Bars = config:CreatePanel({
		name  = BINDING_HEADER_ACTIONBAR;
		mixin = Config;
		scaleToParent = true;
		forbidRecursiveScale = true;
	})
end, env)