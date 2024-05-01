---------------------------------------------------------------
-- Power level display
---------------------------------------------------------------

local _, db = ...; local L = db.Locale;
local PowerLevel = db:Register('Battery', ConsolePortPowerLevel);
local FadeIn, FadeOut = db.Alpha.FadeIn, db.Alpha.FadeOut;

local FADE_SPEED = 0.25;

PowerLevel.Levels = CPAPI.Proxy({
	{fill = 1, color = RED_FONT_COLOR,    atlas = 'ui-frame-bar-fill-red',    name = L'Critical', animation = 'Critical'};
	{fill = 1, color = ORANGE_FONT_COLOR, atlas = 'ui-frame-bar-fill-yellow', name = L'Low'};
	{fill = 2, color = YELLOW_FONT_COLOR, atlas = 'ui-frame-bar-fill-yellow', name = L'Medium'};
	{fill = 3, color = GREEN_FONT_COLOR,  atlas = 'ui-frame-bar-fill-green',  name = L'High'};
	{fill = 3, color = BLUE_FONT_COLOR,   atlas = 'ui-frame-bar-fill-blue',   name = L'Charging', animation = 'Charging'};
	{fill = 0, color = WHITE_FONT_COLOR,  atlas = 'ui-frame-bar-fill-white',  name = L'Disconnected'};
}, function() return
	{fill = 3, color = WHITE_FONT_COLOR,  atlas = 'ui-frame-bar-fill-white',  name = UNKNOWN}
end)

function PowerLevel:GetPowerLevelInfo(level)
	return self.Levels[level + 1];
end

function PowerLevel:SetPowerLevel(level)
	local info = self:GetPowerLevelInfo(level)

	FadeOut(self.Text, FADE_SPEED, self.Text:GetAlpha(), 0)

	if self.currentAnimation then
		self.currentAnimation:Stop()
		self.currentAnimation:Finish()
		self.currentAnimation = nil;
	end

	self.Text:SetFormattedText(info.name)

	FadeIn(self.Text, FADE_SPEED, 0, 1)
	self.currentAnimation = info.animation and self[info.animation];
	if self.currentAnimation then
		self.currentAnimation:Play()
		self.currentAnimation:Restart()
	end

	self:SetValue(info.fill)
	if C_Texture.GetAtlasInfo(info.atlas) then
		self.BarTexture:SetAtlas(info.atlas)
	else
		self.BarTexture:SetVertexColor(info.color:GetRGB())
	end
	FadeIn(self, 0, 1)
end

function PowerLevel:OnDataLoaded()
	self:SetShown(db('powerLevelShow'))
	if not self:IsShown() then return end

	local showIcon = db('powerLevelShowIcon')
	local showText = db('powerLevelShowText')

	self:SetPowerLevel(db.Gamepad:GetPowerLevel())
	FadeIn(self, FADE_SPEED, self:GetAlpha(), 1)

	self.Text:SetShown(showText)
	self.Icon:SetShown(showIcon)
	
	if showIcon then
		db.Gamepad.SetIconToTexture(self.Icon, 'PADSYSTEM')
	end

	if CPAPI.IsRetailVersion then
		self.Background:SetAtlas('jailerstower-wayfinder-rewardbackground-disable')
	end
end

db:RegisterCallback('OnGamePadPowerChange', PowerLevel.SetPowerLevel, PowerLevel)
db:RegisterCallbacks(PowerLevel.OnDataLoaded, PowerLevel,
	'OnIconsChanged',
	'OnNewBindings',
	'Settings/powerLevelShow',
	'Settings/powerLevelShowIcon',
	'Settings/powerLevelShowText'
)

---------------------------------------------------------------
-- Scripts
---------------------------------------------------------------
function PowerLevel:OnEnter()
	local header = L'Battery Level'
	local device = db('Gamepad/Active')
	local desc = device and device:GetTooltipButtonPrompt('PADSYSTEM', header, 64) or header;
	local info = self:GetPowerLevelInfo(db.Gamepad:GetPowerLevel())

	GameTooltip_SetDefaultAnchor(GameTooltip, self)
	GameTooltip:SetText(('%s: %s'):format(desc, info.color:WrapTextInColorCode(info.name)))
	GameTooltip:AddLine('Hold Shift + Left Click to move.')
	GameTooltip:Show()
end

function PowerLevel:OnLeave()
	if GameTooltip:IsOwned(self) then
		GameTooltip:Hide()
	end
end

PowerLevel:RegisterForDrag('LeftButton')

function PowerLevel:OnDragStart()
	if IsShiftKeyDown() then
		self:StartMoving()
	end
end

function PowerLevel:OnDragStop()
	self:StopMovingOrSizing()
end

CPAPI.Start(PowerLevel)
CPAPI.DataHandler(PowerLevel)

---------------------------------------------------------------
-- Textures
---------------------------------------------------------------
if CPAPI.IsRetailVersion then
	PowerLevel.BorderLeft:SetAtlas('ui-frame-bar-borderleft')
	PowerLevel.BorderRight:SetAtlas('ui-frame-bar-borderright')
	PowerLevel.BorderCenter:SetAtlas('ui-frame-bar-bordercenter')
	PowerLevel.Tick1:SetAtlas('ui-frame-bar-bordertick')
	PowerLevel.Tick2:SetAtlas('ui-frame-bar-bordertick')
	PowerLevel.GlowLeft:SetAtlas('ui-frame-bar-glowleft')
	PowerLevel.GlowRight:SetAtlas('ui-frame-bar-glowright')
	PowerLevel.GlowCenter:SetAtlas('ui-frame-bar-glowcenter')
else
	PowerLevel.BorderCenter:SetAtlas('bonusobjectives-bar-frame')
	PowerLevel.BorderCenter:ClearAllPoints()
	PowerLevel.BorderCenter:SetSize(130, 34)
	PowerLevel.BorderCenter:SetPoint('CENTER', 10, 0)
	PowerLevel.GlowCenter:SetAtlas('bonusobjectives-bar-glow')
	PowerLevel.GlowCenter:ClearAllPoints()
	PowerLevel.GlowCenter:SetSize(114, 24)
	PowerLevel.GlowCenter:SetPoint('CENTER', 1, 0)
end