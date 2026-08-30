local env, db, _, L = CPAPI.GetEnv(...);
local Guide, Modules = env:GetContextPanel(), db.Modules;
local TUTORIAL_ID = 'ModuleSelection';
local PRESET_BUTTON_SPACING = 118;

---------------------------------------------------------------
local Card = {};
---------------------------------------------------------------

function Card:OnLoad()
	CPCardBaseMixin.OnLoad(self)
	self.Toggle:SetScript('OnClick', GenerateClosure(self.OnToggleClicked, self))
	self:SetScript('OnShow', self.OnShow)
	self:SetScript('OnHide', self.OnHide)
end

function Card:SetModule(entry)
	self.entry = entry;
	local name, desc = Modules:GetInfo(entry)
	self.Name:SetText(name)
	self.Desc:SetText(desc)
	self.Image:SetTexture(entry.image)
	if entry.presets then
		self:CreatePresets(entry.presets)
	end
	self:Update()
end

function Card:OnShow()
	db:RegisterCallback('Settings/'..self.entry.variable, self.Update, self)
	self:Update()
end

function Card:OnHide()
	db:UnregisterCallback('Settings/'..self.entry.variable, self)
end

function Card:Update()
	local enabled = Modules:IsEnabled(self.entry)
	self:SetChecked(enabled)
	self.Toggle:SetChecked(enabled)
	self:OnButtonStateChanged()
	if self.Presets then
		local current = self:GetCurrentPresetName()
		for _, button in ipairs(self.Presets) do
			button:SetEnabled(enabled)
			button:SetChecked(button.preset.name == current)
		end
	end
end

function Card:OnClick()
	Modules:SetEnabled(self.entry, self:GetChecked())
	self:Update()
end

function Card:OnToggleClicked()
	Modules:SetEnabled(self.entry, self.Toggle:GetChecked())
	self:Update()
end

---------------------------------------------------------------
-- Presets (action bar)
---------------------------------------------------------------
function Card:CreatePresets(presets)
	self.Presets = {};
	for i, preset in ipairs(presets) do
		local button = CreateFrame('CheckButton', nil, self, 'CPCheckButtonTemplate')
		button:SetPoint('BOTTOMLEFT', 16 + (i - 1) * PRESET_BUTTON_SPACING, 14)
		button.Text:SetText(L(preset.name))
		button.preset = preset;
		button:SetScript('OnClick', GenerateClosure(self.OnPresetClicked, self, button))
		self.Presets[i] = button;
	end
end

function Card:GetModuleEnv()
	if Modules:IsLoaded(self.entry) then
		return LibStub('RelaTable')(self.entry.addon)
	end
end

function Card:GetCurrentPresetName()
	local module = self:GetModuleEnv()
	return module and module('Layout/name')
end

function Card:OnPresetClicked(button)
	self:Update()
	CPAPI.Popup('ConsolePort_Features_Preset', {
		text      = L'Switch the action bar layout to %s? Your current layout will be replaced.';
		button1   = YES;
		button2   = CANCEL;
		timeout   = 0;
		showAlert = 1;
		OnAccept  = function(_, data)
			data.card:ApplyPreset(data.preset)
		end;
	}, L(button.preset.name), nil, { card = self, preset = button.preset })
end

function Card:ApplyPreset(preset)
	Modules:SetEnabled(self.entry, true)
	db:RunSafe(function()
		if not Modules:Load(self.entry) then return end;
		local module = self:GetModuleEnv()
		local layout = module and module.Presets[preset.id];
		if layout then
			module:ApplyPreset(layout)
		end
		self:Update()
	end)
end

---------------------------------------------------------------
local Continue = {};
---------------------------------------------------------------

function Continue:OnClick()
	self:SetChecked(false)
	CPAPI.SetTutorialComplete(TUTORIAL_ID)
	Guide:AutoSelectContent()
end

---------------------------------------------------------------
local Features = {};
---------------------------------------------------------------

function Features:OnLoad()
	self:SetAllPoints(self:GetCanvas())
	CPAPI.SpecializeOnce(self.Continue, Continue)

	local grid = self.Browser.ScrollChild.Grid;
	for i, entry in Modules:Enumerate() do
		local card = CreateFrame('CheckButton', nil, grid, 'CPFeatureCardTemplate')
		card.layoutIndex = i;
		CPAPI.SpecializeOnce(card, Card)
		card:SetModule(entry)
	end
	grid:Layout()
	CPAPI.Start(self)
end

function Features:OnShow()
	local scrollChild = self.Browser.ScrollChild;
	scrollChild:SetMinimumWidth(self.Browser:GetWidth())
	scrollChild:Layout()
end

---------------------------------------------------------------
-- Content
---------------------------------------------------------------
do local TutorialIncomplete, HasActiveDevice = env.TutorialPredicate(TUTORIAL_ID), env.HasActiveDevice();

	local function ShowFeaturesPredicate()
		return HasActiveDevice() and TutorialIncomplete();
	end

	Guide:AddContent('Features', ShowFeaturesPredicate,
	function(canvas, GetCanvas)
		if not canvas.Features then
			canvas.Features = CreateFrame('Frame', nil, canvas, 'CPFeaturesPanel')
			canvas.Features.GetCanvas = GetCanvas;
			CPAPI.SpecializeOnce(canvas.Features, Features)
		end
		canvas.Features:Show()
	end, function(canvas)
		if not canvas.Features then return end;
		canvas.Features:Hide()
	end, HasActiveDevice)
end
