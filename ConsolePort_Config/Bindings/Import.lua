local _, env = ...; local db = env.db;
local Preset, Import = {}, CreateFromMixins(CPFocusPoolMixin)
local PRESETS_WIDTH, FIXED_OFFSET = 360, 8 
local CURRENT_BINDINGS;

env.ImportManager = Import;

local function GenerateEmptyPreset()
	local bindings = db.Gamepad:GetBindings(true)
	for btn, set in pairs(bindings) do
		for mod, _ in pairs(set) do
			bindings[btn][mod] = '';
		end
	end
	return bindings;
end

---------------------------------------------------------------
-- Preset
---------------------------------------------------------------
function Preset:OnLoad()
	self:SetWidth(PRESETS_WIDTH - 16)
	self.Label:ClearAllPoints()
	self.Label:SetPoint('LEFT', 16, 0)
	self.Label:SetPoint('RIGHT', -16, 0)
	self.Label:SetJustifyH('LEFT')
	self.Label:SetTextColor(1, 1, 1)
	self:SetDrawOutline(true)
	CPAPI.Start(self)
end

function Preset:OnClick()
	for button, set in pairs(self.preset) do
		for modifier, binding in pairs(set) do
			SetBinding(modifier..button, binding)
		end
	end
	env.Bindings.Control.Import:Click()
end

function Preset:OnShow()
	if db.table.compare(self.preset, CURRENT_BINDINGS) then
		self:Check()
	else
		self:Uncheck()
	end
end

function Preset:OnEnter()
	GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
	GameTooltip:SetText(self:GetText():trim())
	if self.gamepadType then
		GameTooltip:AddDoubleLine(TYPE, self.gamepadType, 1, 1, 1, 1, 1, 1)
	end
	if self.classID and GetNumClasses and GetClassInfo then
		for i=1, GetNumClasses() do
			local className, classID = GetClassInfo(i)
			if (self.classID == classID) then
				GameTooltip:AddDoubleLine(CLASS, className, 1, 1, 1, 1, 1, 1)
			end
		end
	end
	if self.specID and GetSpecializationInfoByID then
		local specName = select(2, GetSpecializationInfoByID(self.specID))
		GameTooltip:AddDoubleLine(SPECIALIZATION, specName, 1, 1, 1, 1, 1, 1)
	end
	GameTooltip:Show()
end

function Preset:OnLeave()
	if GameTooltip:IsOwned(self) then
		GameTooltip:Hide()
	end
end


function Preset:SetData(data)
	local color = data.Class and RAID_CLASS_COLORS[data.Class] or WHITE_FONT_COLOR;
	local icon = data.Icon and CPAPI.CreateSimpleTextureMarkup(data.Icon, 20, 20) or '     ';
	self:SetText(('%s %s'):format(icon, color:WrapTextInColorCode(data.Name)))
	self.specID = data.Spec;
	self.classID = data.Class;
	self.gamepadType = data.Type;
end
---------------------------------------------------------------
-- Panel
---------------------------------------------------------------
function Import:DrawPreset(meta, settings, anchor)
	local widget, newObj = self:Acquire(meta.Name)
	if newObj then
		widget:OnLoad()
		widget:SetSiblings(self.Registry)
	end
	widget:Show()
	widget.preset = settings;
	if anchor then
		widget:SetPoint('TOP', anchor, 'BOTTOM', 0, -FIXED_OFFSET)
	else
		widget:SetPoint('TOP', 0, -FIXED_OFFSET)
	end
	widget:SetData(meta)
	return widget;
end

function Import:DrawOptions()
	self:ReleaseAll()
	CURRENT_BINDINGS = db.Gamepad:GetBindings()

	local prev = self:DrawPreset({Name = EMPTY}, GenerateEmptyPreset());
	for name, device in db:For('Gamepad/Devices', true) do
		local bindings = device.Preset and device.Preset.Bindings;
		if bindings then
			local asset = db('Gamepad/Index/Splash/'..name)
			local icon = asset and CPAPI.GetAsset('Splash\\Gamepad\\'..asset)
			prev = self:DrawPreset({Name = name, Icon = icon}, db.table.copy(bindings), prev)
		end
	end
	for name, settings in db:For('Shared/Data', true) do
		if settings.Bindings then
			prev = self:DrawPreset(settings.Meta, db.table.copy(settings.Bindings), prev)
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
	self:CreateFramePool('IndexButton',
		'CPIndexButtonBindingHeaderTemplate', Preset, nil, self.Child)
	Mixin(self.Child, env.ScaleToContentMixin)
	self.Child:SetAllPoints()
	self.Child:SetMeasurementOrigin(self, self.Child, 600, 12)
end
