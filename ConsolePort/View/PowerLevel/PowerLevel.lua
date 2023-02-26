if CPAPI.IsClassicEraVersion then return end;
---------------------------------------------------------------
-- Power level display
---------------------------------------------------------------

local _, db = ...; local L = db.Locale;
local PowerLevel = ConsolePortPowerLevel;
local FadeIn, FadeOut = db.Alpha.FadeIn, db.Alpha.FadeOut;

local FADE_SPEED = 0.25;

PowerLevel.Levels = {
	{fill = 1, color = RED_FONT_COLOR,    name = L'Critical', animation = 'Critical'};
	{fill = 1, color = ORANGE_FONT_COLOR, name = L'Low'};
	{fill = 2, color = YELLOW_FONT_COLOR, name = L'Medium'};
	{fill = 3, color = GREEN_FONT_COLOR,  name = L'High'};
	{fill = 3, color = BLUE_FONT_COLOR,   name = L'Charging', animation = 'Charging'};
	{fill = 0, color = WHITE_FONT_COLOR,  name = L'Disconnected'};
}

function PowerLevel:SetPowerLevel(level)
	local info = self.Levels[level + 1];
	local text = self.OverlayFrame.Text;

	FadeOut(text, FADE_SPEED, text:GetAlpha(), 0)

	if self.currentAnimation then
		self.currentAnimation:Stop()
		self.currentAnimation:Finish()
		self.currentAnimation = nil;
	end

	text:SetFormattedText(info.name)

	FadeIn(text, FADE_SPEED, 0, 1)
	self.currentAnimation = info.animation and self[info.animation];
	if self.currentAnimation then
		self.currentAnimation:Play()
		self.currentAnimation:Restart()
	end

	self:SetValue(info.fill)
	self.BarTexture:SetVertexColor(info.color:GetRGB())
	FadeIn(self, 0, 1)
end

function PowerLevel:OnDataLoaded()
	self:SetShown(db('powerLevelShow'))
	if not self:IsShown() then return end

	local showIcon = db('powerLevelShowIcon')
	local showText = db('powerLevelShowText')

	local text = self.OverlayFrame.Text;
	local icon = self.OverlayFrame.Icon;

	self:SetPowerLevel(db.Gamepad:GetPowerLevel())
	FadeIn(self, FADE_SPEED, self:GetAlpha(), 1)
	if showText then
		FadeIn(text, FADE_SPEED, text:GetAlpha(), 1)
	else
		FadeOut(text, FADE_SPEED, text:GetAlpha(), 0)
	end
	if showIcon then
		db.Gamepad.SetIconToTexture(icon, 'PADSYSTEM')
		FadeIn(icon, FADE_SPEED, icon:GetAlpha(), 1)
	else
		FadeOut(icon, FADE_SPEED, icon:GetAlpha(), 0)
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
      GameTooltip_SetDefaultAnchor(GameTooltip, self)
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
CPAPI.EventHandler(PowerLevel)