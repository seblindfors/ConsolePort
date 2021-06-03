local addOn, env = ...;
---------------------------------------------------------------
local Bar, Lib, db = env.bar, env.libs.button, env.db;
---------------------------------------------------------------
local FadeIn, FadeOut = db.Alpha.FadeIn, db.Alpha.FadeOut;
---------------------------------------------------------------
local Pet = CreateFrame('Button', '$parentPet', Bar, 'SecureActionButtonTemplate, SecureHandlerBaseTemplate, SecureHandlerStateTemplate')
local Button = {}

local GetPetActionCooldown = GetPetActionCooldown
local AutoCastShine_AutoCastStart = AutoCastShine_AutoCastStart
local AutoCastShine_AutoCastStop = AutoCastShine_AutoCastStop

Bar.Pet = Pet
Pet:Hide()
Pet.Buttons = {}
Pet.showgrid = 0
Pet.locked = 0
Pet.mode = 'show'
Pet.unit = 'pet'
Pet:SetMovable(true)
Pet:SetClampedToScreen(true)
Pet:RegisterForDrag('LeftButton')
Pet:SetScript('OnDragStart', Pet.StartMoving)
Pet:SetScript('OnDragStop', Pet.StopMovingOrSizing)
Pet:SetPoint('TOPRIGHT', 0, 50)
Pet:SetSize(70, 70)

for _, event in pairs({
	'PET_BAR_UPDATE',
	'PET_BAR_UPDATE_COOLDOWN',
	'PET_SPECIALIZATION_CHANGED',
	'PLAYER_CONTROL_GAINED',
	'PLAYER_CONTROL_LOST',
	'PLAYER_FARSIGHT_FOCUS_CHANGED',
	'UNIT_AURA',
	'UNIT_FLAGS',
	'UNIT_PET',
	'UNIT_PORTRAIT_UPDATE',
}) do pcall(Pet.RegisterEvent, Pet, event) end

Pet:RegisterForClicks('AnyUp', 'AnyDown')
Pet:SetAttribute('unit', 'pet')

Pet.Portrait = Pet:CreateTexture(nil, 'ARTWORK')
Pet.Shadow = Pet:CreateTexture(nil, 'ARTWORK')
Pet.Border = Pet:CreateTexture(nil, 'OVERLAY')

Pet.Portrait:SetPoint('TOPLEFT', 2, -2)
Pet.Portrait:SetPoint('BOTTOMRIGHT', -2, 2)
Pet.Portrait:SetMask('Interface\\Minimap\\UI-Minimap-Background')

Pet.Shadow:SetPoint('CENTER', 0, -5)
Pet.Shadow:SetSize(82, 82)
Pet.Shadow:SetTexture('Interface\\AddOns\\ConsolePort_Bar\\Textures\\Button\\BigShadow')
Pet.Shadow:SetAlpha(0.75)

Pet.Border:SetAllPoints()
Pet.Border:SetTexture('Interface\\AddOns\\ConsolePort_Bar\\Textures\\Button\\BigNormal')

Pet.Ring = CreateFrame('Frame', nil, Pet)
Pet.Ring:SetFrameLevel(3)
Pet.Ring:SetPoint('TOPLEFT', -48, 48)
Pet.Ring:SetPoint('BOTTOMRIGHT', 48, -48)
Pet.Ring.Texture = Pet.Ring:CreateTexture(nil, 'OVERLAY')
Pet.Ring.Texture:SetAllPoints()
Pet.Ring.Texture:SetTexture('Interface\\AddOns\\ConsolePort_Bar\\Textures\\Button\\PetRing')
Pet.Ring.Texture:SetRotation(rad(18))
Pet.Ring.Mask = Pet.Ring:CreateMaskTexture()
Pet.Ring.Mask:SetAllPoints()
Pet.Ring.Mask:SetTexture('Interface\\AddOns\\ConsolePort_Bar\\Textures\\Button\\PetRingMask')

RegisterStateDriver(Pet, 'visibility', '[pet] show; hide')


function Pet:FadeIn()
	for i, button in ipairs(self.Buttons) do
		FadeIn(button, 0.2, button:GetAlpha(), 1)
	end
	FadeIn(self.Ring, 0.2, self.Ring:GetAlpha(), 1)
	self.isOpaque = true;
end

function Pet:FadeOut()
	if env:Get('disablepetfade') then return end
	for i, button in ipairs(self.Buttons) do
		if not button.onCooldown then
			FadeOut(button, 0.2, button:GetAlpha(), 0)
		end
	end
	FadeOut(self.Ring, 0.2, self.Ring:GetAlpha(), 0)
	self.isOpaque = false;
end

function Button:OnEnter()
	self:GetParent():FadeIn()
	if ( not self.tooltipName ) then
		return
	end
	local uber = GetCVar('UberTooltips')
	if ( uber == '0' ) then
		GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
		local bindingText = GetBindingText(GetBindingKey('BONUSACTIONBUTTON'..self:GetID()))
		if (bindingText and bindingText ~= '') then
			GameTooltip:SetText(self.tooltipName..NORMAL_FONT_COLOR_CODE..' ('..bindingText..')'..FONT_COLOR_CODE_CLOSE, 1.0, 1.0, 1.0)
		else
			GameTooltip:SetText(self.tooltipName, 1.0, 1.0, 1.0)
		end
		GameTooltip:Show()
		self.UpdateTooltip = nil
	else
		GameTooltip_SetDefaultAnchor(GameTooltip, self)
		if (GameTooltip:SetPetAction(self:GetID())) then
			self.UpdateTooltip = self.OnEnter
		else
			self.UpdateTooltip = nil
		end
	end
end

function Button:OnLeave()
	self:GetParent():FadeOut()
end

function Button:StartFlash()
	self.flashing = true
	self.flashtime = 0
end

function Button:StopFlash()
	self.flashing = false
	self.Flash:Hide()
end

function Button:OnSizeChanged(width, height)
	local normalX, normalY = (width * (46/32)), (height * (46/32))
	self.NormalTexture:SetSize(normalX, normalY)
	self.PushedTexture:SetSize(normalX, normalY)
end


do 
	local RADIAN_FRACTION = rad( 360 / (NUM_PET_ACTION_SLOTS) )
	local Mixin = db.table.mixin
	local BUTTON_SIZE = 40

	local function OnCooldownDone(self)
		local button = self:GetParent()
		button.onCooldown = nil;
		button:SetChecked(false)
		if not Pet.isOpaque then
			FadeOut(button, 0.1, button:GetAlpha(), 0)
		end
	end

	for i=1, NUM_PET_ACTION_SLOTS do
		local x, y, r = 0, 0, 68 -- xOffset, yOffset, radius
		local angle = (i-4) * RADIAN_FRACTION
		local ptx, pty = x + r * math.cos( angle ), y + r * math.sin( angle )

		local name = addOn..'Pet'..i
		local button = CreateFrame('CheckButton', name, Pet, 'SecureActionButtonTemplate, PetActionButtonTemplate')
		button:RegisterForClicks('LeftButtonUp', 'RightButtonUp', 'MiddleButtonDown', 'MiddleButtonUp')
		button:SetAttribute('type', 'pet')
		button:SetAttribute('action', i)
		button:SetID(i)
		button:SetScript('OnEnter', nil)
		button.textureRotation = rad(270) - angle;
		button.HotKey:SetAlpha(0)

		Mixin(button, CPActionButtonMixin)

		button.AutoCastable = _G[name..'AutoCastable']
		button.Shine = _G[name..'Shine']
		button.cooldown = _G[name..'Cooldown'];
		button.NormalTexture = _G[name..'NormalTexture2']

		button.Flash:SetMask('Interface\\Minimap\\UI-Minimap-Background')
		button.Flash:SetAlpha(0.25)
		button.icon:AddMaskTexture(Pet.Ring.Mask)
		button.icon:SetAllPoints()

		button.AutoCastable:SetRotation(button.textureRotation)
		button.AutoCastable:Hide()

		button.NormalTexture:SetTexture(nil)--'Interface\\AddOns\\ConsolePort_Bar\\Textures\\Button\\Pet10')
		button.NormalTexture:ClearAllPoints()
		button.NormalTexture:SetPoint('CENTER', 0, 0)

		button.PushedTexture = button:GetPushedTexture()
		button.HighlightTexture = button:GetHighlightTexture()
		button.CheckedTexture = button:GetCheckedTexture()

		button.PushedTexture:SetTexture('Interface\\AddOns\\ConsolePort_Bar\\Textures\\Button\\Pet10Pushed')
		button.PushedTexture:SetPoint('TOPLEFT', -6, 6)
		button.PushedTexture:SetPoint('BOTTOMRIGHT', 6, -6)
		button.PushedTexture:SetRotation(button.textureRotation)

		button.HighlightTexture:SetTexture('Interface\\AddOns\\ConsolePort_Bar\\Textures\\Button\\Pet10Hilite')
		button.HighlightTexture:SetPoint('TOPLEFT', -6, 6)
		button.HighlightTexture:SetPoint('BOTTOMRIGHT', 6, -6)
		button.HighlightTexture:SetRotation(button.textureRotation)

		button.CheckedTexture:SetTexture('Interface\\AddOns\\ConsolePort_Bar\\Textures\\Button\\Pet10Checked')
		button.CheckedTexture:SetPoint('TOPLEFT', -6, 6)
		button.CheckedTexture:SetPoint('BOTTOMRIGHT', 6, -6)
		button.CheckedTexture:SetRotation(button.textureRotation)

		button.cooldown:SetDrawSwipe(false)
		button.cooldown:SetDrawBling(false)
		button.cooldown:SetHideCountdownNumbers(false)
		button.cooldown:SetScript('OnCooldownDone', OnCooldownDone)

		Mixin(button, Button)

		button:SetPoint('CENTER', ptx, -pty)
		button:SetSize(BUTTON_SIZE, BUTTON_SIZE)
		Pet.Buttons[i] = button
	end
end

Pet:HookScript('OnShow', function(self)
	self:Update()
	SetPortraitTexture(self.Portrait, 'pet')
	FadeIn(self, 0.2, 0, 1)
end)

Pet:HookScript('OnEnter', function(self)
	UnitFrame_UpdateTooltip(self)
	self:FadeIn()
end)

Pet:HookScript('OnLeave', function(self)
	self.UpdateTooltip = nil
	GameTooltip:Hide()
	self:FadeOut()
end)

Pet:SetScript('OnEvent', function(self, event, ...)
	local arg1 = ...
	if event == 'PET_BAR_UPDATE' or event == 'PET_SPECIALIZATION_CHANGED' or
		(event == 'UNIT_PET' and arg1 == 'player') or
		((event == 'UNIT_FLAGS' or event == 'UNIT_AURA') and arg1 == 'pet') or
		event == 'PLAYER_CONTROL_LOST' or event == 'PLAYER_CONTROL_GAINED' or event == 'PLAYER_FARSIGHT_FOCUS_CHANGED' then
		self:Update()
	elseif event == 'PET_BAR_UPDATE_COOLDOWN' then
		self:UpdateCooldowns()
	end
	if 	( event == 'UNIT_PORTRAIT_UPDATE' and arg1 == 'pet' ) or
		( event == 'UNIT_PET' and arg1 == 'player' ) then
		SetPortraitTexture(self.Portrait, 'pet')
	end
end)

function Pet:Update()
	local petActionButton, petActionIcon, petAutoCastableTexture, petAutoCastShine
	for i, petActionButton in ipairs(self.Buttons) do
		petActionIcon = petActionButton.icon
		petAutoCastableTexture = petActionButton.AutoCastable
		petAutoCastShine = petActionButton.Shine
		local name, texture, isToken, isActive, autoCastAllowed, autoCastEnabled = GetPetActionInfo(i)
		if ( not isToken ) then
			petActionButton:SetIcon(texture)
			petActionButton.tooltipName = name
		else
			petActionButton:SetIcon(_G[texture])
			petActionButton.tooltipName = _G[name]
		end
		petActionButton.icon:SetRotation(petActionButton.textureRotation)
		petActionButton.isToken = isToken
		if ( isActive ) then
			if ( IsPetAttackAction(i) ) then
				petActionButton:StartFlash()
				-- the checked texture looks a little confusing at full alpha (looks like you have an extra ability selected)
				petActionButton:GetCheckedTexture():SetAlpha(0.5)
			else
				petActionButton:StopFlash()
				petActionButton:GetCheckedTexture():SetAlpha(1.0)
			end
			petActionButton:SetChecked(true)
		else
			petActionButton:StopFlash()
			petActionButton:SetChecked(false)
		end
		-- if ( autoCastAllowed ) then
		-- 	petAutoCastableTexture:Show()
		-- else
		-- 	petAutoCastableTexture:Hide()
		-- end
		if ( autoCastEnabled ) then
			AutoCastShine_AutoCastStart(petAutoCastShine, CPAPI.GetClassColor())
		else
			AutoCastShine_AutoCastStop(petAutoCastShine)
		end
		if ( texture ) then
			if ( GetPetActionSlotUsable(i) ) then
				petActionIcon:SetVertexColor(1, 1, 1)
			else
				petActionIcon:SetVertexColor(0.4, 0.4, 0.4)
			end
		end
	end
	self:UpdateCooldowns()
end

function Pet:UpdateCooldowns()
	local time = GetTime()
	for i=1, NUM_PET_ACTION_SLOTS, 1 do
		local button = Pet.Buttons[i]
		local cooldown = button.cooldown
		local start, duration, enable = GetPetActionCooldown(i)
		CooldownFrame_Set(cooldown, start, duration, enable)

		if (time < start + duration) then
			button.onCooldown = true;
			button:SetChecked(true)
			FadeIn(button, 0.1, button:GetAlpha(), 1)
		end
		
		-- Update tooltip
		if ( GameTooltip:GetOwner() == button ) then
			button:OnEnter()
		end
	end
end

do
	Pet:Execute([[
		---------------------------------------------------------------
		TARGET_PET = 'LeftButton'
		TOGGLE_MENU = 'RightButton'
		---------------------------------------------------------------
	]])

	Pet:WrapScript(Pet, 'PreClick', [[
		self:SetAttribute('type', nil)

		-- Target pet on regular click
		if button == TARGET_PET then
			if not down then
				self:SetAttribute('type', 'target')
			end

		-- Show unit menu on right click
		elseif button == TOGGLE_MENU then
			if not down then
				self:SetAttribute('type', 'togglemenu')
			end
		end
	]])
end