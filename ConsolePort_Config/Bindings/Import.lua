local _, env = ...; local db = env.db;
local Preset, Import = {}, CreateFromMixins(CPFocusPoolMixin)
local PRESETS_WIDTH, FIXED_OFFSET = 600, 8 
local CURRENT_BINDINGS;

env.ImportManager = Import;

function Preset:OnLoad()
	self:SetWidth(PRESETS_WIDTH - 32)
	self:SetScript('OnClick', self.OnClick)
	self:SetScript('OnShow', self.OnShow)
end

function Preset:OnClick()
	for button, set in pairs(self.preset) do
		for modifier, binding in pairs(set) do
			SetBinding(modifier..button, binding)
		end
	end
	env.Bindings.Import:Hide()
	env.Bindings.Manager:Show()
	env.Bindings.Control.Import:Uncheck()
end

function Preset:OnShow()
	if db.table.compare(self.preset, CURRENT_BINDINGS) then
		self:Check()
	else
		self:Uncheck()
	end
end

function Import:DrawPreset(name, settings, anchor)
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

function Import:DrawOptions()
	self:ReleaseAll()
	CURRENT_BINDINGS = db.Gamepad:GetBindings()

	local prev;
	for name, device in db:For('Gamepad/Devices', true) do
		local bindings = device.Preset and device.Preset.Bindings;
		if bindings then
			prev = self:DrawPreset(name, db.table.copy(bindings), prev)
		end
	end
	for name, settings in db:For('Shared/Data', true) do
		if settings.Bindings then
			prev = self:DrawPreset(name, db.table.copy(settings.Bindings), prev)
		end
	end
	self.Child:SetHeight(nil)
end

function Import:OnShow()
	self:DrawOptions()
end

function Import:OnHide()
	self:ReleaseAll()
	CURRENT_BINDINGS = nil;
end

function Import:OnLoad()
	CPFocusPoolMixin.OnLoad(self)
	env.OpaqueMixin.OnLoad(self)
	self:CreateFramePool('IndexButton',
		'CPIndexButtonBindingHeaderTemplate', Preset, nil, self.Child)
	Mixin(self.Child, env.ScaleToContentMixin)
	self.Child:SetAllPoints()
	self.Child:SetMeasurementOrigin(self, self.Child, 600, 12)
end
