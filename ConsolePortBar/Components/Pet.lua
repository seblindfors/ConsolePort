---------------------------------------------------------------
local db = ConsolePort:GetData()
---------------------------------------------------------------
local addOn, ab = ...
---------------------------------------------------------------
local FadeIn = db.UIFrameFadeIn
---------------------------------------------------------------
local Bar = ab.bar
local Lib = ab.libs.button
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
Pet:SetSize(64, 64)

for _, event in pairs({
	'PET_BAR_UPDATE_COOLDOWN',
	'PET_BAR_UPDATE',
	'PLAYER_CONTROL_LOST',
	'PLAYER_CONTROL_GAINED',
	'PLAYER_FARSIGHT_FOCUS_CHANGED',
	'UNIT_PET',
	'UNIT_FLAGS',
	'UNIT_AURA',
	'UNIT_PORTRAIT_UPDATE',
	'PET_BAR_UPDATE',
	'PET_BAR_UPDATE_COOLDOWN',
	'PET_SPECIALIZATION_CHANGED',
}) do pcall(Pet.RegisterEvent, Pet, event) end

Pet:RegisterForClicks('AnyUp', 'AnyDown')
Pet:SetAttribute('unit', 'pet')

Pet.Portrait = Pet:CreateTexture(nil, 'ARTWORK')
Pet.Shadow = Pet:CreateTexture(nil, 'ARTWORK')
Pet.Border = Pet:CreateTexture(nil, 'OVERLAY')

Pet.Portrait:SetAllPoints()
Pet.Border:SetAllPoints()
Pet.Shadow:SetPoint('CENTER', 0, -5)

Pet.Border:SetTexture('Interface\\AddOns\\ConsolePortBar\\Textures\\Button\\BigNormal')
Pet.Portrait:SetMask('Interface\\Minimap\\UI-Minimap-Background')

Pet.Shadow:SetSize(82, 82)
Pet.Shadow:SetTexture('Interface\\AddOns\\ConsolePortBar\\Textures\\Button\\BigShadow')
Pet.Shadow:SetAlpha(0.75)

RegisterStateDriver(Pet, 'visibility', '[pet] show; hide')

function Button:OnEnter()
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
	local RADIAN_FRACTION = rad( 360 / (NUM_PET_ACTION_SLOTS - 2) )
	local Mixin = db.table.mixin
	local BUTTON_SIZE = 40

	for i=1, NUM_PET_ACTION_SLOTS do
		local x, y, r = 0, 0, 60 -- xOffset, yOffset, radius
		local angle = (i+3) * RADIAN_FRACTION
		local ptx, pty = x + r * math.cos( angle ), y + r * math.sin( angle )

		local name = addOn..'Pet'..i
		local button = CreateFrame('CheckButton', name, Pet, 'SecureActionButtonTemplate, PetActionButtonTemplate')
		button:SetAttribute('type', 'pet')
		button:RegisterForClicks('LeftButtonUp', 'RightButtonUp', 'MiddleButtonDown', 'MiddleButtonUp')
		button:SetAttribute('action', i)
		button:SetID(i)
		button:SetScript('OnEnter', nil)
		button.HotKey:SetAlpha(0)

		Mixin(button, ConsolePortActionButtonMixin)

		button.AutoCastable = _G[name..'AutoCastable']
		button.Shine = _G[name..'Shine']
		button.cooldown = _G[name..'Cooldown'];
		button.NormalTexture = _G[name..'NormalTexture2']

		button.Flash:SetMask('Interface\\Minimap\\UI-Minimap-Background')
		button.Flash:SetAlpha(0.25)
		button.icon:SetMask('Interface\\Minimap\\UI-Minimap-Background')
		button.icon:SetAllPoints()

		button.AutoCastable:Hide()

		button.NormalTexture:SetTexture('Interface\\AddOns\\ConsolePortBar\\Textures\\Button\\PetNormal')
		button.NormalTexture:ClearAllPoints()
		button.NormalTexture:SetPoint('CENTER', 0, 0)

		button.PushedTexture = button:GetPushedTexture()
		button.HighlightTexture = button:GetHighlightTexture()
		button.CheckedTexture = button:GetCheckedTexture()

		button.PushedTexture:SetTexture('Interface\\AddOns\\ConsolePortBar\\Textures\\Button\\PetPushed')
		button.PushedTexture:ClearAllPoints()
		button.PushedTexture:SetPoint('CENTER', 0, 0)

		button.HighlightTexture:SetTexture('Interface\\AddOns\\ConsolePort\\Textures\\Button\\Hilite')
		button.HighlightTexture:SetAllPoints()

		button.CheckedTexture:SetTexture('Interface\\AddOns\\ConsolePort\\Textures\\Button\\Hilite')
		button.CheckedTexture:SetAllPoints()

		button.cooldown:SetSwipeTexture('Interface\\AddOns\\ConsolePort\\Textures\\Button\\Normal')
		button.cooldown:SetBlingTexture('Interface\\AddOns\\ConsolePort\\Textures\\Button\\Bling')

		Mixin(button, Button)

		if i > 2 then
			button:SetPoint('CENTER', ptx, -pty -8)
			button:SetSize(BUTTON_SIZE, BUTTON_SIZE)
		else
			button.HotkeyIcon = button:CreateTexture(nil, 'BORDER')
			button.HotkeyIcon:SetSize(32, 32)
			button.HotkeyIcon:SetPoint('BOTTOM', button, 'CENTER', 0, 0)
			button.HotkeyIcon:SetTexture(db.ICONS['CP_T'.. i])
			button.HotkeyIcon:Hide()
			button:SetPoint(i == 1 and 'BOTTOMLEFT' or 'BOTTOMRIGHT', i == 1 and 4 or -4, -12)
			button:SetSize(28, 28)
		end


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
end)

Pet:HookScript('OnLeave', function(self)
	self.UpdateTooltip = nil
	GameTooltip:Hide()
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
			AutoCastShine_AutoCastStart(petAutoCastShine)
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
	for i=1, NUM_PET_ACTION_SLOTS, 1 do
		local button = Pet.Buttons[i]
		local cooldown = button.cooldown
		local start, duration, enable = GetPetActionCooldown(i)
		CooldownFrame_Set(cooldown, start, duration, enable)
		
		-- Update tooltip
		if ( GameTooltip:GetOwner() == button ) then
			button:OnEnter()
		end
	end
end

function Pet:OnControlPet(hasControl)
	if hasControl then
		self.Buttons[1].HotkeyIcon:Show()
		self.Buttons[2].HotkeyIcon:Show()
	else

		self.Buttons[1].HotkeyIcon:Hide()
		self.Buttons[2].HotkeyIcon:Hide()
	end
end 

do -- Wheel setup
	Pet:Execute([[
		Bar = self
		---------------------------------------------------------------
		TARGET_PET = 'LeftButton'
		TOGGLE_MENU = 'RightButton'
		CONTROL_PET = 'MiddleButton'
		---------------------------------------------------------------
		BUTTONS = newtable()
		---------------------------------------------------------------
		KEYS = newtable()
		BINDINGS = newtable()
		---------------------------------------------------------------
		INDEX = 0
		---------------------------------------------------------------
		KEYS.UP 	= false		KEYS.W 		= false
		KEYS.LEFT 	= false		KEYS.A 		= false
		KEYS.DOWN 	= false		KEYS.S 		= false
		KEYS.RIGHT 	= false		KEYS.D 		= false
		---------------------------------------------------------------
		OnKey = [=[
			if self:IsVisible() then
				local key, down = ...
				-----------------------------
				if BUTTON then
					BUTTON:SetWidth(40)
					BUTTON:SetHeight(40)
				end
				-----------------------------
				if down then
					if key == 'UP' then
						KEYS.DOWN = false
						KEYS.UP = true
					elseif key == 'DOWN' then
						KEYS.UP = false
						KEYS.DOWN = true
					elseif key == 'LEFT' then
						KEYS.RIGHT = false
						KEYS.LEFT = true
					elseif key == 'RIGHT' then
						KEYS.LEFT = false
						KEYS.RIGHT = true
					end
				else
					KEYS[key] = false
				end
				-----------------------------
				INDEX = 
					( KEYS.UP and KEYS.RIGHT 	) and 2 or -- Up/right
					( KEYS.DOWN and KEYS.RIGHT 	) and 4 or -- Down/right
					( KEYS.DOWN and KEYS.LEFT 	) and 6 or -- Down/left
					( KEYS.UP and KEYS.LEFT 	) and 8 or -- Up/left
					( KEYS.UP 					) and 1 or -- Up
					( KEYS.RIGHT 				) and 3 or -- Right
					( KEYS.DOWN 				) and 5 or -- Down
					( KEYS.LEFT 				) and 7 or 0 -- Left || none
				-----------------------------
				self:SetAttribute('index', INDEX)
				BUTTON = BUTTONS[INDEX]
				if BUTTON then
					BUTTON:SetWidth(50)
					BUTTON:SetHeight(50)
				end
				-----------------------------
			end
		]=]
		SetBindingClick = [=[
			local binding, owner, ID = ...
			self:SetBindingClick(true, binding, owner, ID)
			self:SetBindingClick(true, 'CTRL-'..binding, owner, ID)
			self:SetBindingClick(true, 'SHIFT-'..binding, owner, ID)
			self:SetBindingClick(true, 'CTRL-SHIFT-'..binding, owner, ID)
		]=]
	]])

	Pet:WrapScript(Pet, 'PreClick', [[
		self:SetAttribute('type', nil)

		-- Target pet on regular click
		-----------------------------
		if button == TARGET_PET then
			if not down then
				self:SetAttribute('type', 'target')
			end
		-----------------------------

		-- Show unit menu on right click
		-----------------------------	
		elseif button == TOGGLE_MENU then
			if not down then
				self:SetAttribute('type', 'togglemenu')
			end
		-----------------------------

		-- Pet control
		-----------------------------
		elseif button == CONTROL_PET then
			-----------------------------
			-- Enable
			-----------------------------
			if down then
				for binding, keyID in pairs(BINDINGS) do
					self:Run(SetBindingClick, binding, self:GetFrameRef(keyID):GetName(), 'MiddleButton')
				end

				-- Attack / follow buttons
				-----------------------------
				local key1 = GetBindingKey('CP_T1')
				local key2 = GetBindingKey('CP_T2')

				if key1 then self:Run(SetBindingClick, key1, 'ConsolePortBarPet1', 'LeftButton') end
				if key2 then self:Run(SetBindingClick, key2, 'ConsolePortBarPet2', 'LeftButton') end
				-----------------------------

				-- Signal the insecure changes
				self:CallMethod('OnControlPet', true)
			-----------------------------
			-- Disable
			-----------------------------
			else
				if BUTTON then
					self:SetAttribute('type', 'macro')
					self:SetAttribute('macrotext', ('/click %s'):format(BUTTON:GetName()))
					BUTTON:SetWidth(40)
					BUTTON:SetHeight(40)
					BUTTON = nil
				end
				self:ClearBindings()
				self:CallMethod('OnControlPet', false)
			end
		end
	]])

	Pet:WrapScript(Pet, 'OnHide', [[
		self:ClearBindings()
	]])

	-- Set these buttons to handle the input for the ring.
	local actionButtons = {
		[Pet.Buttons[3]] = 'UP',
		[Pet.Buttons[5]] = 'RIGHT',
		[Pet.Buttons[7]] = 'DOWN',
		[Pet.Buttons[9]] = 'LEFT',
	}

	for button, keyID in pairs(actionButtons) do
		button:SetAttribute('keyID', keyID)
		Pet:SetFrameRef(keyID, button)
		Pet:WrapScript(button, 'PreClick', [[
			self:SetAttribute('type', nil)
			if button == 'LeftButton' or button == 'RightButton' then
				self:SetAttribute('type', 'pet')
			else
				Bar:Run(OnKey, self:GetAttribute('keyID'), down)
			end
		]])
	end

	-- Define the inputs to control the pet ring
	local buttons = {
		['UP'] 		= {'W', 'UP'},
		['LEFT'] 	= {'A', 'LEFT'},
		['DOWN'] 	= {'S', 'DOWN'},
		['RIGHT'] 	= {'D', 'RIGHT'},
	}

	for direction, keys in pairs(buttons) do
		for _, key in pairs(keys) do
			Pet:Execute(format([[
				BINDINGS.%s = '%s'
			]], key, direction))
		end
	end

	-- Reference buttons 3-10 so they can be used like the utility ring
	for i=3, NUM_PET_ACTION_SLOTS do
		Pet:SetFrameRef('button', Pet.Buttons[i])
		Pet:Execute(format([[
			BUTTONS[%d] = self:GetFrameRef('button')
		]], i-2))
	end
end