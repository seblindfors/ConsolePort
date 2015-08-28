local _, db = ...
local interval = 0.1
local frameTimers = { 0,0,0,0 }
local popupFrames = {
	StaticPopup1,
	StaticPopup2,
	StaticPopup3,
	StaticPopup4
}

function ConsolePort:Popup (key, state) return end

local function ButtonsLinked(button, clickbutton)
	return button:GetAttribute("clickbutton") == clickbutton
end

local function PopupTypeAssigned(button, type)
	return button:GetAttribute("type") == type
end

for i, frame in pairs(popupFrames) do
	frame:HookScript("OnUpdate", function(self, elapsed)
		frameTimers[i] = frameTimers[i] + elapsed
		while frameTimers[i] > interval do
			if 	self:IsVisible() then
				if popupFrames[i+1] and popupFrames[i+1]:IsVisible() then
					self:SetAlpha(popupFrames[i+1]:GetAlpha()*0.75)
				elseif not InCombatLockdown() then
					self:SetAlpha(1)
				end
				if 	ConsolePort:GetFocusFrame().frame == self and
					not InCombatLockdown() then
					if 	not ButtonsLinked(CP_R_LEFT_NOMOD, _G[self:GetName().."Button1"]) or
						not PopupTypeAssigned(CP_R_LEFT_NOMOD, "Popup") then
						ClearOverrideBindings(ConsolePortCursor)
						CP_R_RIGHT_NOMOD:SetAttribute("type", "Popup");
						CP_R_LEFT_NOMOD:SetAttribute("type", "Popup");
						if _G[self:GetName().."Button3"]:IsVisible() then
							ConsolePort:SetClickButton(CP_R_RIGHT_NOMOD, _G[self:GetName().."Button3"])
						else
							ConsolePort:SetClickButton(CP_R_RIGHT_NOMOD, _G[self:GetName().."Button2"])
						end
						ConsolePort:SetClickButton(CP_R_LEFT_NOMOD, _G[self:GetName().."Button1"])
					end
				end
			end
			frameTimers[i] = frameTimers[i] - interval
		end
	end)
end