----------------------------------
-- PowerLevel.lua - GamePad Power Level Display
----------------------------------

local _, db = ...
local FadeIn, FadeOut, PowerLevel = db('Alpha/FadeIn'), db('Alpha/FadeOut'), db:Register("CPPowerLevel", CPPowerLevel)
local plShow, plIconShow, plTextShow = db("showPowerLevel"), db("showGamepadIcon"), db('showPowerLevelText')

local PowerLevels = {
	'Critical',
	'Low',
	'Medium',
	'High',
	'Charging',
	'Unknown'
}

local fadeSpeed = 0.25

function PowerLevel:OnShow()
	if plShow then
		FadeIn(PowerLevel_Widget, fadeSpeed, PowerLevel_Widget:GetAlpha(), 1)
	end
end

function PowerLevel:OnHide()
	if not plShow then
		FadeOut(PowerLevel_Widget, fadeSpeed, PowerLevel_Widget:GetAlpha(), 0)
	end
end

function PowerLevel:SetPowerLevel()
	local level = db.Gamepad:GetPowerLevel() + 1
	local PowerLeveltoSet = PowerLevels[level]
	FadeOut(PowerLevel_Widget_LevelText, fadeSpeed, PowerLevel_Widget_LevelText:GetAlpha(), 0)
	for i=1,6 do
		if i ~= level then
			print('Hiding: '..PowerLevels[i])
			if _G["PowerLevel_Widget_"..PowerLeveltoSet].Animation then
				_G["PowerLevel_Widget_"..PowerLeveltoSet].Animation:Stop()
			end
			_G["PowerLevel_Widget_"..PowerLevels[i]]:SetAlpha(0)
		end
	end
	print('Showing: '..PowerLeveltoSet)
	PowerLevel_Widget_LevelText:SetFormattedText(PowerLeveltoSet)
	FadeIn(PowerLevel_Widget_LevelText, fadeSpeed, PowerLevel_Widget_LevelText:GetAlpha(), 1)
	if _G["PowerLevel_Widget_"..PowerLeveltoSet].Animation then
		_G["PowerLevel_Widget_"..PowerLeveltoSet].Animation:Play()
	else
		FadeIn(_G["PowerLevel_Widget_"..PowerLeveltoSet], fadeSpeed, _G["PowerLevel_Widget_"..PowerLeveltoSet]:GetAlpha(), 1)
	end
end

function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
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
	plTextShow = db('showPowerLevelText')
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