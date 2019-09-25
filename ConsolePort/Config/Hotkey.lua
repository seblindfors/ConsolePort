---------------------------------------------------------------
-- Hotkey.lua: Hotkey styling system
---------------------------------------------------------------
-- A system for creating themed hotkey templates.

local addOn, db = ...
---------------------------------------------------------------
local ICONS, HotkeyMixin = db.ICONS, {}
---------------------------------------------------------------
local IsControlKeyDown, IsShiftKeyDown = IsControlKeyDown, IsShiftKeyDown
local function GetStates()
	return IsControlKeyDown(), IsShiftKeyDown()
end
---------------------------------------------------------------
local function IsMatch(mod, ctrl, shift)
	return ((mod == 'CTRL-SHIFT-' and (ctrl and shift)) or
			(mod == 'CTRL-' and (ctrl and not shift)) or
			(mod == 'SHIFT-' and (shift and not ctrl)) );
end

local function IsMismatch(mod, ctrl, shift)
	return ((mod == 'CTRL-SHIFT-' and (ctrl or shift)) or
			(mod == 'CTRL-' and shift) or
			(mod == 'SHIFT-' and ctrl) );
end

function HotkeyMixin:ToggleModifiers(mod1, mod2)
	if self.mod1 then self.mod1:SetShown(mod1) end
	if self.mod2 then self.mod2:SetShown(mod2) end
end

function HotkeyMixin:SetModTextures(modType, mod1, mod2)
	if modType == "" then
		self:ToggleModifiers(false, false)
	elseif modType == "SHIFT-" then
		self:ToggleModifiers(true, false)
		mod1:SetTexture(ICONS.CP_M1)
	elseif modType == "CTRL-" then
		self:ToggleModifiers(true, false)
		mod1:SetTexture(ICONS.CP_M2)
	elseif modType == "CTRL-SHIFT-" then
		self:ToggleModifiers(true, true)
		mod1:SetTexture(ICONS.CP_M2)
		mod2:SetTexture(ICONS.CP_M1)
	end
end

function HotkeyMixin:SetMainTexture(id)
	if not self.main then
		self.main = self:CreateTexture("$parent_MAIN", "OVERLAY", nil, 7)
	end
	self.main:SetTexture(ICONS[id])
end

function HotkeyMixin:SetBindingCombination(id, mod)
	self.mod = mod
	self:SetMainTexture(id)

	if self.mod ~= "" then
		if not self.mod1 then
			self.mod1 = self:CreateTexture("$parent_MOD1", "OVERLAY", nil, 6)
		end
		if self.mod == "CTRL-SHIFT-" and not self.mod2 then
			self.mod2 = self:CreateTexture("$parent_MOD2", "OVERLAY", nil, 5)
		end
	end
	self:SetModTextures(self.mod, self.mod1, self.mod2)
end

function HotkeyMixin:GetTextureObjects()
	return self.main, self.mod1, self.mod2
end

---------------------------------------------------------------
local function AddModifierAnimation(hotKey, child, name, onEvent, onPlay, onFinished, onStop)
	hotKey[child][name] = hotKey[child]:CreateAnimationGroup()
	hotKey[child][name]:SetScript('OnPlay', onPlay)
	hotKey[child][name]:SetScript('OnFinished', onFinished)
	hotKey[child][name]:SetScript('OnStop', onStop)
	hotKey:SetScript("OnEvent", onEvent)
	hotKey.GetStates = GetStates
	hotKey:RegisterEvent("MODIFIER_STATE_CHANGED")
end
---------------------------------------------------------------

local function AnimateModifierFlyin(self)
	local ctrl, shift = self.GetStates()
	if self.mod == "" then
		self:SetShown(not (shift or ctrl))
	else
		self:Show()
		-- modifier match -> animate
		if 	IsMatch(self.mod, ctrl, shift) then
			self:ToggleModifiers(false, false)

			self:ClearAllPoints()
			self:SetPoint("TOP", 0, 12)
			self.main:ClearAllPoints()
			self.main:SetPoint("TOP", 0, 0)
			self.main.Group:Play()
		-- modifier held, but doesn't match -> hide
		elseif IsMismatch(self.mod, ctrl, shift) then
			self:Hide()
		-- no modifiers held -> show base
		else
			self:ToggleModifiers(true, true)

			self:ClearAllPoints()
			self:SetPoint("TOPRIGHT", 0, 0)
			self.main:ClearAllPoints()
			self.main:SetPoint("TOPRIGHT", 12, 12)
		end
	end
end

local function FlyinOnFinished(group) group:GetParent():SetSize(32, 32) end
local function FlyinOnPlay(group) group:GetParent():SetSize(64, 64) end
---------------------------------------------------------------

local function AnimateModifierSlide(self)
	local ctrl, shift = self.GetStates()
	if self.mod == "" then
		self:SetShown(not (shift or ctrl))
	else
		self:Show()
		self.main.InGroup:Stop()
		self.main.OutGroup:Stop()
		-- modifier match -> animate
		if 	IsMatch(self.mod, ctrl, shift) then
			self:ToggleModifiers(false, false)

			self.main.InAni:SetOffset((-self:GetParent():GetWidth() / 2) +self.xOffset, 0)
			self.main.InGroup:Play()
		-- modifier held, but doesn't match -> hide
		elseif IsMismatch(self.mod, ctrl, shift) then
			self:Hide()
		-- no modifiers held -> show base
		else
			self.main.OutAni:SetOffset((self:GetParent():GetWidth() / 2) -self.xOffset, 0)
			self.main.OutGroup:Play()
		end
	end
end

local function SlideInOnFinished(group)
	local self = group:GetParent():GetParent()
	self:ClearAllPoints()
	self:SetPoint('TOP', self.xOffset, 0)
end

local function SlideOutOnFinished(group)
	local self = group:GetParent():GetParent()
	self:ToggleModifiers(true, true)
	self:ClearAllPoints()
	self:SetPoint('TOPRIGHT', 0, 0)
end

local function SlideOnPlay(group)
	local self = group:GetParent():GetParent()
	self:ClearAllPoints()
	self:SetPoint('TOPRIGHT', 0, 0)
end

local SlideOnStop = SlideOnPlay

local function SlideAnimationSetup(hotKey, main, xOffset)
	AddModifierAnimation(hotKey, 'main', 'InGroup', AnimateModifierSlide, SlideOnPlay, SlideInOnFinished, SlideOnStop)
	AddModifierAnimation(hotKey, 'main', 'OutGroup', AnimateModifierSlide, SlideInOnFinished, SlideOutOnFinished)

	hotKey.xOffset = xOffset
	main.InAni = main.InGroup:CreateAnimation("Translation")
	main.InAni:SetDuration(0.1)
	main.InAni:SetSmoothing("OUT")

	main.OutAni = main.OutGroup:CreateAnimation("Translation")
	main.OutAni:SetDuration(0.075)
	main.OutAni:SetSmoothing("OUT")
end

---------------------------------------------------------------

function db.CreateHotkey(self, forceStyle, forceName, forceMod)
	-- self is the secure button in this case
	local count = self.HotKeys and #self.HotKeys+1 or 1
	local hotKey = CreateFrame("Frame", "$parentHOTKEY"..count, self)
	Mixin(hotKey, HotkeyMixin)

	hotKey:SetSize(1,1)
	hotKey:SetBindingCombination(forceName or self.name, forceMod or self.mod)

	local main, mod1, mod2 = hotKey:GetTextureObjects()
	local style = forceStyle or db('actionBarStyle')

	-- Animated (flyin) revamp, animated (slidein) revamp, static revamp
	---------------------------------------------------------------
	if not style or style <= 3 then
		main:SetSize(32, 32)
		main:SetPoint("TOPRIGHT", 12, 12)

		-- Animated
		if not style or style == 1 then
			AddModifierAnimation(hotKey, 'main', 'Group', AnimateModifierFlyin, FlyinOnPlay, FlyinOnFinished)

			main.Animation = main.Group:CreateAnimation("SCALE")
			main.Animation:SetScale(0.5, 0.5)
			main.Animation:SetDuration(0.2)
			main.Animation:SetSmoothing("OUT")
			main.Animation:SetOrigin("TOP", 0, 0)
		elseif style == 2 then
			SlideAnimationSetup(hotKey, main, 3)
		end

		if hotKey.mod ~= "" then
			mod1:SetSize(24, 24)
			if hotKey.mod == "CTRL-SHIFT-" then
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

	-- Animated consistent, static consistent
	---------------------------------------------------------------
	elseif style >= 4 and style <= 5 then
		main:SetSize(24, 24)
		main:SetPoint("TOPRIGHT", 4, 4)

		if style == 5 then
			SlideAnimationSetup(hotKey, main, 7)
		end

		if hotKey.mod ~= "" then
			mod1:SetPoint("RIGHT", main, "LEFT", 14, 0)
			mod1:SetSize(24, 24)
			if hotKey.mod == "CTRL-SHIFT-" then
				mod1:SetTexture(ICONS.CP_M2)

				mod2:SetPoint("RIGHT", mod1, "LEFT", 14, 0)
				mod2:SetSize(24, 24)
			end
		end
	end
	---------------------------------------------------------------
	return hotKey
end

---------------------------------------------------------------

function ConsolePort:LoadHotKeyTextures(set) set = set or db.Bindings
	if not set then return end
	
	local actionButtons = self:GetActionButtons(true)
	for secureBtn in pairs(db.SECURE) do
		for i, hotkey in pairs(secureBtn.HotKeys) do
			hotkey:ClearAllPoints()
			hotkey:SetParent(secureBtn)
			hotkey:Hide()
		end
		local index = 0
		local modifier = secureBtn.mod
		local subSet = set[secureBtn.name]
		local binding = subSet and subSet[modifier]
		local ID = binding and self:GetActionID(binding)

		if ID then
			for actionButton, actionID in pairs(actionButtons) do
				if 	ID == actionID or 
					self:GetActionBinding(ID) == self:GetActionBinding(actionID) then
					index = index + 1
					secureBtn.HotKeys[index] = 	secureBtn.HotKeys[index] or secureBtn:CreateHotkey()

					secureBtn:ShowHotkey(index, actionButton)

					if actionButton.HotKey then
						actionButton.HotKey:SetAlpha(0)
					end
				end
			end
		elseif binding and not binding:match('ConsolePort') then
			local button = _G[(gsub(gsub(binding, 'CLICK ', ''), ':.+', ''))]
			if C_Widget.IsFrameWidget(button) then
				secureBtn:ShowInterfaceHotkey(button)
			end
		end
	end
end