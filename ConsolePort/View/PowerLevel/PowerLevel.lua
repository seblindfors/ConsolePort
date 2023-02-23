----------------------------------
-- PowerLevel.lua - GamePad Power Level Display
----------------------------------

local db = ConsolePort:DB()
local FadeIn, FadeOut, PowerLevel = db("Alpha/FadeIn"), db("Alpha/FadeOut"), CPAPI.EventHandler(CPPowerLevel)
local plShow, plIconShow, plTextShow = db("showPowerLevel"), db("showGamepadIcon"), db("showPowerLevelText")

local Levels = {
	"Critical",
	"Low",
	"Medium",
	"High",
	"Charging",
	"Disconnected"
}

local fadeSpeed = 0.25

function PowerLevel:SetPowerLevel()
	local level = db.Gamepad:GetPowerLevel() + 1
	local PowerLeveltoSet = Levels[level]
	FadeOut(CPPowerLevel_LevelText, fadeSpeed, CPPowerLevel_LevelText:GetAlpha(), 0)
	for i = 1, 6 do
		if i ~= level then
			FadeOut(_G["CPPowerLevel_" .. Levels[i]], fadeSpeed, 1, 0)
			_G["CPPowerLevel_" .. Levels[i]]:Hide()
			if _G["CPPowerLevel_" .. Levels[i]].Anim then
				_G["CPPowerLevel_" .. Levels[i]].Anim:Pause()
			end
		end
	end
	CPPowerLevel_LevelText:SetFormattedText(PowerLeveltoSet)
	FadeIn(CPPowerLevel_LevelText, fadeSpeed, 0, 1)
	if _G["CPPowerLevel_" .. PowerLeveltoSet].Anim then
		_G["CPPowerLevel_" .. PowerLeveltoSet].Anim:Play()
		_G["CPPowerLevel_" .. PowerLeveltoSet].Anim:Restart()
	end
	_G["CPPowerLevel_" .. PowerLeveltoSet]:Show()
	FadeIn(_G["CPPowerLevel_" .. PowerLeveltoSet], fadeSpeed, 0, 1)
end

function PowerLevel:OnConfigChanged()
	plTextShow = db("showPowerLevelText")
	plIconShow = db("showGamepadIcon")
	plShow = db("showPowerLevel")
	if plShow then
		self:SetPowerLevel()
		FadeIn(self, fadeSpeed, self:GetAlpha(), 1)
		if plTextShow then
			FadeIn(CPPowerLevel_LevelText, fadeSpeed, CPPowerLevel_LevelText:GetAlpha(), 1)
		else
			FadeOut(CPPowerLevel_LevelText, fadeSpeed, CPPowerLevel_LevelText:GetAlpha(), 0)
		end
		if plIconShow then
			db.Gamepad.SetIconToTexture(CPPowerLevel_Icon, "PADSYSTEM")
			FadeIn(CPPowerLevel_Icon, fadeSpeed, CPPowerLevel_Icon:GetAlpha(), 1)
		else
			FadeOut(CPPowerLevel_Icon, fadeSpeed, CPPowerLevel_Icon:GetAlpha(), 0)
		end
	else
		FadeOut(self, fadeSpeed, self:GetAlpha(), 0)
	end
end

db:RegisterCallbacks(
	PowerLevel.OnConfigChanged,
	PowerLevel,
	"OnGamePadPowerChange",
	"OnIconsChanged",
	"OnNewBindings",
	"Settings/showGamepadIcon",
	"Settings/showPowerLevelText",
	"Settings/showPowerLevel"
)
