local env, db, _, L = CPAPI.GetEnv(...)
---------------------------------------------------------------
local Panel = { name = L'Rings' };
---------------------------------------------------------------

function Panel:OnLoad()
	CPAPI.Start(self)
	env:RegisterCallback('OnHideEmbedded', self.OnHideEmbedded, self)
end

function Panel:OnShow()
	self.canvas = self:GetCanvas(true)
	self.canvas:Show()
	env:TriggerEvent('ToggleConfig', nil, true)
	self:SetEmbedded(true)
end

function Panel:OnHide()
	self:SetEmbedded(false)
end

function Panel:OnDefaults()
	local source  = db('Settings')
	local changed = {};
	for varID in pairs(env.Variables) do
		if source[varID] ~= nil then
			source[varID]  = nil;
			changed[varID] = true;
		end
	end
	for varID in pairs(changed) do
		db:TriggerEvent('Settings/'..varID, db(varID))
	end
	CPAPI.Log('Rings settings have been reset to default.')
end

function Panel:OnHideEmbedded(delta)
	env.SharedConfig.Env.Frame:SetPanelByDelta(delta)
end

function Panel:InitCanvas(canvas)
	self.canvas = canvas;
end

function Panel:InitConfig(parent)
	local config = env.Config;
	config:SetParent(parent)
	config:ClearAllPoints()
	return config;
end

function Panel:SetEmbedded(embed)
	local window = env.SharedConfig.Env.Frame;
	local config = self:InitConfig(embed and self.canvas or UIParent)

	foreach({
		config.CloseButton,
		config.Name,
		config.NameHighlight,
	}, function(_, region)
		region:SetShown(not embed)
	end)

	-- Update widths
	for region, width in pairs({
		[config]         = embed and 1260 or 1054;
		[config.Display] = embed and 894  or 680;
	}) do
		region:SetWidth(width)
	end
	-- Update height
	for region, height in pairs({
		[config]         = embed and 744 or 762;
		[config.Sets]    = embed and 670 or 680;
		[config.Loadout] = embed and 670 or 680;
	}) do
		region:SetHeight(height)
	end

	config:SetPoint('CENTER', 0, embed and -12 or 0)
	config:SetBackgroundAlpha(embed and 0 or 1)
	config:SetFrameStrata('HIGH')
	config.Tabs:SetAttribute('nodeignore', not embed)
	config.CloseButton:SetEnabled(not embed)
	config.Display.BorderArt:SetShown(not embed)
	config.Display.Tutorial:SetPoint('LEFT', embed and 100 or 20, 0)
	config.Display.Details.IconSelector:SetCustomStride(embed and 13 or nil)
	config.Display.Details.IconSelector.left = embed and 18 or nil;
	config.Display.Details.IconSelector:Init()

	if embed then
		config.Portrait:SetParent(self)
		config.Portrait:SetPoint('TOPLEFT', window, 'TOPLEFT', -20, 20)
		config.Tabs:SetParent(self)
		config.Tabs:SetPoint('BOTTOMRIGHT', self.canvas, 'TOPRIGHT', -140, 2)
	else
		config.Portrait:SetParent(config)
		config.Portrait:SetPoint('TOPLEFT', config, 'TOPLEFT', -16, 16)
		config.Tabs:SetParent(config)
		config.Tabs:SetPoint('BOTTOMRIGHT', config.Display, 'TOPRIGHT', -32, 2)
	end

	window.Credits:SetShown(not embed)
	window.Search:SetShown(not embed)
	config:SetShown(embed)
end

ConsolePort:RegisterConfigCallback(function(_, configEnv)
	configEnv:CreatePanel(Panel)
end, env)