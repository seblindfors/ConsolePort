--[[

-- Idea abandoned for now, but this seems like it could be useful.

local an, ab = ...
local acb = ab.libs.acb

local HANDLE = CreateFrame('Frame', 'ConsolePortBarActionPlacer', UIParent, 'SecureHandlerStateTemplate')

RegisterStateDriver(HANDLE, 'cursor', '[cursor]true;nil')
RegisterStateDriver(HANDLE, 'combat', '[combat]true;nil')

HANDLE:SetAttribute('_onstate-combat', 'self:SetAttribute('incombat', newstate)')
HANDLE:SetAttribute('_onstate-cursor', "
	if not self:GetAttribute('incombat') and newstate then
		self:Show()
	else
		self:Hide()
	end
")


function HANDLE:OnShow()
	if not self.gridExists then
		local noop = function () end
		local xml = 'SecureHandlerBaseTemplate, SecureActionButtonTemplate, CPUISquareActionButtonTemplate'
		local xoffset = NUM_ACTIONBAR_BUTTONS/2 * 42
		self.FadeIn = noop
		self.FadeOut = noop
		for bar=1, 6 + GetNumShapeshiftForms() do
			for slot=1, NUM_ACTIONBAR_BUTTONS do
				local buttonID = ( ( bar - 1 ) * 12 ) + slot
				local button = acb:CreateButton(buttonID, '$parentButton'..buttonID, self, nil, xml)
				 --lib:CreateButton(id, name, header, config, templates)
				button.isMainButton = true
				button:SetAttribute('type', 'action')
				button:SetAttribute('action', buttonID)
				button:SetAttribute('actionpage', bar)
				button:FadeIn(1, 0.2)
				button.FadeOut = noop
				button.FadeIn = noop
				button.forceShow = true
				button:SetSize(40, 40)
				button:SetPoint('TOPLEFT', ((slot-1)*42) - xoffset, -(bar-1)*42)
				button:SetState('', 'action', buttonID)
	 			button:Execute("self:RunAttribute('UpdateState', '') self:CallMethod('UpdateAction')")
			end
		end
		ConsolePort:LoadHotKeyTextures()
		self.gridExists = true
	end
end

HANDLE:SetScript('OnShow', HANDLE.OnShow)
HANDLE:SetPoint('CENTER', 0, 0)
HANDLE:SetSize(1, 1)
HANDLE:Hide()
]]