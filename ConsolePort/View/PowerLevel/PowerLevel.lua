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
	"Unknown"
}

local fadeSpeed = 0.25

function PowerLevel:OnShow()
	plShow = db("showPowerLevel")
	if plShow then
		FadeIn(PowerLevel_Widget, fadeSpeed, PowerLevel_Widget:GetAlpha(), 1)
	else
		self:OnHide()
	end
end

function PowerLevel:OnHide()
	plShow = db("showPowerLevel")
	if not plShow then
		FadeOut(PowerLevel_Widget, fadeSpeed, PowerLevel_Widget:GetAlpha(), 0)
	end
end

function PowerLevel:SetPowerLevel()
	local level = db.Gamepad:GetPowerLevel() + 1
	local PowerLeveltoSet = Levels[level]
	FadeOut(PowerLevel_Widget_LevelText, fadeSpeed, PowerLevel_Widget_LevelText:GetAlpha(), 0)
	for i = 1, 6 do
		if i ~= level then
			print("Hiding: " .. Levels[i])
			FadeOut(_G["PowerLevel_Widget_" .. Levels[i]], fadeSpeed, 1, 0)
			_G["PowerLevel_Widget_" .. Levels[i]]:Hide()
			if _G["PowerLevel_Widget_" .. Levels[i]].Anim then
				print("Pausing " .. Levels[i] .. " animation")
				_G["PowerLevel_Widget_" .. Levels[i]].Anim:Pause()
			end
		end
	end
	print("Showing: " .. PowerLeveltoSet)
	PowerLevel_Widget_LevelText:SetFormattedText(PowerLeveltoSet)
	FadeIn(PowerLevel_Widget_LevelText, fadeSpeed, 0, 1)
	if _G["PowerLevel_Widget_" .. PowerLeveltoSet].Anim then
		print("Playing " .. PowerLeveltoSet .. " animation")
		_G["PowerLevel_Widget_" .. PowerLeveltoSet].Anim:Play()
		_G["PowerLevel_Widget_" .. PowerLeveltoSet].Anim:Restart()
	end
	_G["PowerLevel_Widget_" .. PowerLeveltoSet]:Show()
	FadeIn(_G["PowerLevel_Widget_" .. PowerLeveltoSet], fadeSpeed, 0, 1)
end

function PowerLevel:ShowIcon()
	plIconShow = db("showGamepadIcon")
	if plIconShow then
		FadeIn(PowerLevel_Widget_Icon, fadeSpeed, PowerLevel_Widget_Icon:GetAlpha(), 1)
	else
		FadeOut(PowerLevel_Widget_Icon, fadeSpeed, PowerLevel_Widget_Icon:GetAlpha(), 0)
	end
end

function PowerLevel:ShowText()
	plTextShow = db("showPowerLevelText")
	if plTextShow then
		FadeIn(PowerLevel_Widget_LevelText, fadeSpeed, PowerLevel_Widget_LevelText:GetAlpha(), 1)
	else
		FadeOut(PowerLevel_Widget_LevelText, fadeSpeed, PowerLevel_Widget_LevelText:GetAlpha(), 0)
	end
end

function PowerLevel:OnIconChange()
	db.Gamepad.SetIconToTexture(PowerLevel_Widget_Icon, "PADSYSTEM")
end

db:RegisterCallback("OnIconsChanged", PowerLevel.OnIconChange, PowerLevel)
db:RegisterCallback("OnGamePadPowerChange", PowerLevel.SetPowerLevel, PowerLevel)
db:RegisterCallback("OnGamePadConnect", PowerLevel.OnShow, PowerLevel)
db:RegisterCallback("OnGamePadDisconnect", PowerLevel.OnHide, PowerLevel)
db:RegisterCallback("Settings/showPowerLevel", PowerLevel.OnShow, PowerLevel)
db:RegisterCallback("Settings/showPowerLevelText", PowerLevel.ShowText, PowerLevel)
db:RegisterCallback("Settings/showGamepadIcon", PowerLevel.ShowIcon, PowerLevel)