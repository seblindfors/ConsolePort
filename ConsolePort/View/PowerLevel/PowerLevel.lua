----------------------------------
-- PowerLevel.lua - GamePad Power Level Display
----------------------------------

local _, db = ...

local PowerLevel = db:Register("PowerLevel", PowerLevelMeter)

local PowerLevels = {
	'Critical',
	'Low',
	'Medium',
	'High',
	'Charging',
	'Unknown'
}

function PowerLevel:OnLoad()
	local plShow = db("showPowerLevel")
	local plIconShow = db("showGamepadIcon")
	local powerLevel = db('Gamepad/Active/Powerlevel')
	local activeDevice = db('Gamepad/Active')
	local plTextShow = db('showPowerLevelText')
	if plShow and activeDevice ~= {} then
		for i in ipairs(PowerLevels) do
			if i == powerLevel + 1 then
				PowerLevelMeter_LevelText:SetFormattedText(PowerLevels[i])
				_G["PowerLevelMeter_" .. PowerLevels[i]]:Show()
			else
				_G["PowerLevelMeter_" .. PowerLevels[i]]:Hide()
			end
		end
		self:Show()
	else
		self:Hide()
	end

	if plTextShow then
		PowerLevelMeter_LevelText:Show()
	else
		PowerLevelMeter_LevelText:Hide()
	end

	if plIconShow then
		PowerLevelMeter_Icon:Show()
	else
		PowerLevelMeter_Icon:Hide()
	end
end

db:RegisterCallback(
	"OnIconsChanged",
	function()
		db.Gamepad.SetIconToTexture(PowerLevelMeter_Icon, "PADSYSTEM")
	end,
	PowerLevelMeter_Icon
)

db:RegisterCallbacks(
	PowerLevel.OnLoad,
	PowerLevel,
	"Settings/showPowerLevel",
	"Settings/showPowerLevelText",
	"Settings/showGamepadIcon",
	"Gamepad/Active/Powerlevel",
	"Gamepad/Active"
)
