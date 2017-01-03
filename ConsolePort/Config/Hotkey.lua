---------------------------------------------------------------
-- Hotkey.lua: Hotkey styling system
---------------------------------------------------------------
-- A system for creating themed hotkey templates.

local addOn, db = ...
---------------------------------------------------------------
local ICONS = db.ICONS
---------------------------------------------------------------
local IsControlKeyDown = IsControlKeyDown
local IsShiftKeyDown = IsShiftKeyDown
---------------------------------------------------------------
local function AnimateModifierChange(self)
	local ctrl, shift = IsControlKeyDown(), IsShiftKeyDown()
	if self.mod == "" then
		if shift or ctrl then
			self:Hide()
		else
			self:Show()
		end
	else
		self:Show()
		if 	self.mod == "CTRL-SHIFT-" and (ctrl and shift) or
			self.mod == "CTRL-" and (ctrl and not shift) or
			self.mod == "SHIFT-" and (shift and not ctrl) then
			self.mod1:Hide()
			if self.mod2 then
				self.mod2:Hide()
			end
			self:ClearAllPoints()
			self:SetPoint("TOP", 0, 12)
			self.main:ClearAllPoints()
			self.main:SetPoint("TOP", 0, 0)
			self.main.Group:Play()
		elseif self.mod == "CTRL-SHIFT-" and (ctrl or shift) or
			self.mod == "CTRL-" and shift or
			self.mod == "SHIFT-" and ctrl then
			self:Hide()
		else
			self.mod1:Show()
			if self.mod2 then
				self.mod2:Show()
			end
			self:ClearAllPoints()
			self:SetPoint("TOPRIGHT", 0, 0)
			self.main:ClearAllPoints()
			self.main:SetPoint("TOPRIGHT", 12, 12)
		end
	end
end

local function SetModTextures(modType, mod1, mod2)
	if modType == "SHIFT-" then
		mod1:SetTexture(ICONS.CP_M1)
	elseif modType == "CTRL-" then
		mod1:SetTexture(ICONS.CP_M2)
	elseif modType == "CTRL-SHIFT-" then
		mod1:SetTexture(ICONS.CP_M2)
		mod2:SetTexture(ICONS.CP_M1)
	end
end

---------------------------------------------------------------

function ConsolePort:CreateHotKey(forceStyle)
	-- self is the secure button wrapper in this case
	local count = self.HotKeys and #self.HotKeys+1 or 1
	local hotKey = CreateFrame("Frame", "$parentHOTKEY"..count, self)
	hotKey:SetSize(1,1)
	hotKey.mod = self.mod

	local mod1, mod2
	local main = hotKey:CreateTexture("$parent_MAIN", "OVERLAY", nil, 7)
	hotKey.main = main

	if self.mod ~= "" then
		mod1 = hotKey:CreateTexture("$parent_MOD1", "OVERLAY", nil, 6)
		hotKey.mod1 = mod1
		if self.mod == "CTRL-SHIFT-" then
			mod2 = hotKey:CreateTexture("$parent_MOD2", "OVERLAY", nil, 5)
			hotKey.mod2 = mod2
		end
	end

	local style = forceStyle or ConsolePortSettings.actionBarStyle

	-- Animated revamp, static revamp
	---------------------------------------------------------------
	if not style or style == 1 or style == 2 then
		main:SetSize(32, 32)
		main:SetTexture(ICONS[self.name])
		main:SetPoint("TOPRIGHT", 12, 12)

		-- Animated
		if not style or style == 1 then
			main.Group = main:CreateAnimationGroup()
			main.Group:SetScript("OnFinished", function() main:SetSize(32, 32) end)
			main.Group:SetScript("OnPlay", function() main:SetSize(64, 64) end)
			main.Animation = main.Group:CreateAnimation("SCALE")

			main.Animation:SetScale(0.5, 0.5)
			main.Animation:SetDuration(0.2)
			main.Animation:SetSmoothing("OUT")
			main.Animation:SetOrigin("TOP", 0, 0)

			hotKey:SetScript("OnEvent", AnimateModifierChange)
			hotKey:RegisterEvent("MODIFIER_STATE_CHANGED")
		end

		if self.mod ~= "" then
			mod1:SetSize(24, 24)
			if self.mod == "CTRL-SHIFT-" then
				mod1:SetPoint("RIGHT", main, "LEFT", 15, -2)
				mod2:SetPoint("RIGHT", mod1, "LEFT", 14, 0)
				mod2:SetSize(24, 24)
			else
				mod1:SetPoint("RIGHT", main, "LEFT", 14, -2)
			end
		end
		if mod1 then
			mod1:SetAlpha(0.75)
		end
		if mod2 then
			mod2:SetAlpha(0.75)
		end

	-- Consistent
	---------------------------------------------------------------
	elseif style == 3 then
		main:SetSize(24, 24)
		main:SetTexture(ICONS[self.name])

		main:SetPoint("TOPRIGHT", 4, 4)

		if self.mod ~= "" then
			mod1:SetPoint("RIGHT", main, "LEFT", 14, 0)
			mod1:SetSize(24, 24)
			if self.mod == "CTRL-SHIFT-" then
				mod1:SetTexture(ICONS.CP_M2)

				mod2:SetPoint("RIGHT", mod1, "LEFT", 14, 0)
				mod2:SetSize(24, 24)
			end
		end
	end
	SetModTextures(self.mod, mod1, mod2)
	return hotKey
end

---------------------------------------------------------------

function ConsolePort:LoadHotKeyTextures(newSet)
	local set = newSet or db.Bindings
	local index, subSet, modifier, binding, ID
	local actionButtons = self:GetActionButtons(true)

	for secureBtn in pairs(db.SECURE) do
		for i, HotKey in pairs(secureBtn.HotKeys) do
			HotKey:ClearAllPoints()
			HotKey:SetParent(secureBtn)
			HotKey:Hide()
		end
		index = 0
		modifier = secureBtn.mod
		subSet = set[secureBtn.name]
		binding = subSet and subSet[modifier]
		ID = binding and self:GetActionID(binding)

		if ID then
			for actionButton, actionID in pairs(actionButtons) do
				if 	ID == actionID or 
					self:GetActionBinding(ID) == self:GetActionBinding(actionID) then
					index = index + 1
					secureBtn.HotKeys[index] = 	secureBtn.HotKeys[index] or secureBtn:CreateHotKey()

					secureBtn:ShowHotKey(index, actionButton)

					if actionButton.HotKey then
						actionButton.HotKey:SetAlpha(0)
					end
				end
			end
		elseif binding then
			local button = _G[(gsub(gsub(binding, "CLICK ", ""), ":.+", ""))]
			if type(button) == 'table' and button.IsObjectType then
				secureBtn:ShowInterfaceHotKey(button)
			end
		end
	end
end