local _, env, db = ...; db = env.db;
local FadeIn, FadeOut = db.Alpha.FadeIn, db.Alpha.FadeOut;
---------------------------------------------------------------
CPPetRingButton = Mixin({
---------------------------------------------------------------
	ActiveIconVertex   = CreateColor(1.0, 1.0, 1.0);
	InactiveIconVertex = CreateColor(0.4, 0.4, 0.4);
}, CPActionButtonMixin);
---------------------------------------------------------------

local function OnCooldownDone(self)
	local button = self:GetParent()
	button.onCooldown = nil;
	button:SetChecked(false)
	if not button:GetParent():IsOpaque() then
		FadeOut(button, 0.1, button:GetAlpha(), 0)
	end
end

function CPPetRingButton:Init(i)
	local x, y, r = 0, 0, 68; -- index, xOffset, yOffset, radius
	local angle = ( i - 4 ) * rad( 360 / (NUM_PET_ACTION_SLOTS) );

	self.textureRotation = rad(270) - angle;
	self:SetAttribute('action', i)
	self:SetPoint('CENTER', x + r * math.cos(angle), -(y + r * math.sin(angle)))

	local name = self:GetName()
	self.cooldown       = self.cooldown or _G[name..'Cooldown'];
	self.AutoCastable   = self.AutoCastable or _G[name..'AutoCastable']
	self.Shine          = self.Shine or _G[name..'Shine']
	self.NormalTexture  = self.NormalTexture or _G[name..'NormalTexture']
	self.NormalTexture2 = _G[name..'NormalTexture2'] or self.NormalTexture

	if self.SlotBackground then
		self.SlotBackground:SetTexture(nil)
		self.SlotBackground:ClearAllPoints()
		self.SlotBackground:Hide()
	end

	self.Flash:SetMask('Interface\\Minimap\\UI-Minimap-Background')
	self.Flash:SetAlpha(0.25)

	self.HotKey:SetAlpha(0)

	if self.IconMask then
		self.icon:RemoveMaskTexture(self.IconMask)
	end
	self.icon:AddMaskTexture(self:GetParent().Ring.Mask)
	self.icon:SetRotation(self.textureRotation)
	self.icon:SetAllPoints()

	self.AutoCastable:SetRotation(self.textureRotation)
	self.AutoCastable:Hide()

	self.NormalTexture:SetTexture(nil)
	self.NormalTexture:ClearAllPoints()
	self.NormalTexture:SetPoint('CENTER', 0, 0)

	self.NormalTexture2:SetTexture(nil)
	self.NormalTexture2:ClearAllPoints()
	self.NormalTexture2:SetPoint('CENTER', 0, 0)

	self.PushedTexture    = self:GetPushedTexture()
	self.HighlightTexture = self:GetHighlightTexture()
	self.CheckedTexture   = self:GetCheckedTexture()

	self.PushedTexture:SetTexture(env.GetAsset'Textures\\Button\\Pet10Pushed')
	self.PushedTexture:SetPoint('TOPLEFT', -6, 6)
	self.PushedTexture:SetPoint('BOTTOMRIGHT', 6, -6)
	self.PushedTexture:SetRotation(self.textureRotation)

	self.HighlightTexture:SetTexture(env.GetAsset'Textures\\Button\\Pet10Hilite')
	self.HighlightTexture:SetPoint('TOPLEFT', -6, 6)
	self.HighlightTexture:SetPoint('BOTTOMRIGHT', 6, -6)
	self.HighlightTexture:SetRotation(self.textureRotation)

	self.CheckedTexture:SetTexture(env.GetAsset'Textures\\Button\\Pet10Checked')
	self.CheckedTexture:SetPoint('TOPLEFT', -6, 6)
	self.CheckedTexture:SetPoint('BOTTOMRIGHT', 6, -6)
	self.CheckedTexture:SetRotation(self.textureRotation)

	self.cooldown:SetDrawSwipe(false)
	self.cooldown:SetDrawBling(false)
	self.cooldown:SetHideCountdownNumbers(false)
	self.cooldown:SetScript('OnCooldownDone', OnCooldownDone)
end

function CPPetRingButton:OnEnter()
	self:GetParent():UpdateFade()
	if not self.tooltipName then return end;
	local uber = GetCVarBool('UberTooltips')
	if not uber then
		GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
		local bindingText = GetBindingText(GetBindingKey('BONUSACTIONBUTTON'..self:GetID()))
		if ( bindingText and bindingText ~= '' ) then
			GameTooltip:SetText(self.tooltipName..NORMAL_FONT_COLOR_CODE..' ('..bindingText..')'..FONT_COLOR_CODE_CLOSE, 1.0, 1.0, 1.0)
		else
			GameTooltip:SetText(self.tooltipName, 1.0, 1.0, 1.0)
		end
		GameTooltip:Show()
		self.UpdateTooltip = nil;
	else
		GameTooltip_SetDefaultAnchor(GameTooltip, self)
		if ( GameTooltip:SetPetAction(self:GetID()) ) then
			self.UpdateTooltip = self.OnEnter;
		else
			self.UpdateTooltip = nil;
		end
	end
end

function CPPetRingButton:OnLeave()
	self:GetParent():UpdateFade()
end

function CPPetRingButton:StartFlash()
	self.flashing  = true;
	self.flashtime = 0;
end

function CPPetRingButton:StopFlash()
	self.flashing = false;
	self.Flash:Hide()
end

function CPPetRingButton:OnSizeChanged(width, height)
	local normalX, normalY = width * (46/32), height * (46/32);
	self.PushedTexture:SetSize(normalX, normalY)
	self.NormalTexture:SetSize(normalX, normalY)
	self.NormalTexture2:SetSize(normalX, normalY)
end

function CPPetRingButton:Update()
	local i = self:GetID()
	local name, texture, isToken, isActive, autoCastAllowed, autoCastEnabled = GetPetActionInfo(i)
	if ( not isToken ) then
		self:SetIcon(texture)
		self.tooltipName = name;
	else
		self:SetIcon(_G[texture])
		self.tooltipName = _G[name];
	end
	if ( isActive ) then
		if ( IsPetAttackAction(i) ) then
			self:StartFlash()
			-- the checked texture looks a little confusing at full alpha (looks like you have an extra ability selected)
			self:GetCheckedTexture():SetAlpha(0.5)
		else
			self:StopFlash()
			self:GetCheckedTexture():SetAlpha(1.0)
		end
		self:SetChecked(true)
	else
		self:StopFlash()
		self:SetChecked(false)
	end
	if ( autoCastEnabled ) then
		AutoCastShine_AutoCastStart(self.Shine, CPAPI.GetClassColor())
	else
		AutoCastShine_AutoCastStop(self.Shine)
	end
	if ( texture ) then
		local color = GetPetActionSlotUsable(i) and self.ActiveIconVertex or self.InactiveIconVertex;
		self.icon:SetVertexColor(color:GetRGB())
	end
	self:UpdateCooldown()
end

function CPPetRingButton:UpdateCooldown(time) time = time or GetTime();
	local start, duration, enable = GetPetActionCooldown(self:GetID())
	CooldownFrame_Set(self.cooldown, start, duration, enable)
	if (time < start + duration) then
		self.onCooldown = true;
		self:SetChecked(true)
		FadeIn(self, 0.1, self:GetAlpha(), 1)
	end
	if GameTooltip:IsOwned(self) then
		self:OnEnter()
	end
end

---------------------------------------------------------------
CPPetRing = Mixin({
---------------------------------------------------------------
	Events  = {
		'PET_BAR_UPDATE_COOLDOWN';
		'PET_BAR_UPDATE';
		'PET_SPECIALIZATION_CHANGED';
		'PLAYER_CONTROL_GAINED';
		'PLAYER_CONTROL_LOST';
		'PLAYER_FARSIGHT_FOCUS_CHANGED';
	};
	PetEvents = {
		'UNIT_AURA';
		'UNIT_FLAGS';
		'UNIT_PORTRAIT_UPDATE';
	};
	PlayerEvents = {
		'UNIT_PET';
	};
}, env.ConfigurableWidgetMixin);

function CPPetRing:OnLoad()
	for _, event in ipairs(self.Events) do
		pcall(self.RegisterEvent, self, event)
	end
	for _, event in ipairs(self.PetEvents) do
		pcall(self.RegisterUnitEvent, self, event, 'pet')
	end
	for _, event in ipairs(self.PlayerEvents) do
		pcall(self.RegisterUnitEvent, self, event, 'player')
	end

	for i, button in ipairs(self.Buttons) do
		button:Init(i)
	end
	env:RegisterCallback('Settings/clusterBorderStyle', self.OnPropsUpdated, self)
	env:RegisterCallback('OnLoadoutConfigShown', self.OnLoadoutConfigShown, self)
end

function CPPetRing:SetProps(props)
	self:SetDynamicProps(props)

	local style = env.Const.Cluster.BorderStyle[env('clusterBorderStyle')];
	self.Border:SetTexture(style.NormalTexture)
	RegisterStateDriver(self, 'visibility', '[pet] show; hide')

	self:Update()
	self:UpdateCooldowns()
end

function CPPetRing:OnPropsUpdated()
	self:FadeIn()
	self:SetProps(self.props)
	self:UpdateFade()
end

function CPPetRing:OnShow()
	self:UNIT_PORTRAIT_UPDATE()
	FadeIn(self, 0.2, 0, 1)
end

function CPPetRing:OnEnter()
	UnitFrame_UpdateTooltip(self)
	self:UpdateFade()
end

function CPPetRing:OnLeave()
	self.UpdateTooltip = nil;
	GameTooltip:Hide()
	self:FadeOut()
end

function CPPetRing:OnEvent(event, ...)
	if self[event] then
		return self[event](self, ...)
	end
	self:Update()
end

function CPPetRing:OnRelease()
	UnregisterStateDriver(self, 'visibility')
end

---------------------------------------------------------------
-- Events
---------------------------------------------------------------
function CPPetRing:Update()
	for _, button in ipairs(self.Buttons) do
		button:Update()
	end
end

function CPPetRing:UpdateCooldowns()
	local time = GetTime()
	for _, button in ipairs(self.Buttons) do
		button:UpdateCooldown(time)
	end
end

function CPPetRing:UNIT_PORTRAIT_UPDATE()
	SetPortraitTexture(self.Portrait, 'pet')
end

function CPPetRing:PET_BAR_UPDATE_COOLDOWN()
	self:UpdateCooldowns()
end

function CPPetRing:UNIT_PET()
	self:UNIT_PORTRAIT_UPDATE()
	self:Update()
end

---------------------------------------------------------------
-- Display
---------------------------------------------------------------
function CPPetRing:FadeIn()
	for _, button in ipairs(self.Buttons) do
		FadeIn(button, 0.2, button:GetAlpha(), 1)
	end
	FadeIn(self.Ring, 0.2, self.Ring:GetAlpha(), 1)
	self.isOpaque = true;
end

function CPPetRing:FadeOut()
	if not self.props.fade then return end;
	for _, button in ipairs(self.Buttons) do
		if not button.onCooldown then
			FadeOut(button, 0.2, button:GetAlpha(), 0)
		end
	end
	FadeOut(self.Ring, 0.2, self.Ring:GetAlpha(), 0)
	self.isOpaque = false;
end

function CPPetRing:IsOpaque()
	return self.isOpaque;
end

function CPPetRing:UpdateFade()
	local isMouseOver = self:IsMouseMotionFocus()
	if isMouseOver then return self:FadeIn() end;
	for _, button in ipairs(self.Buttons) do
		if button:IsMouseMotionFocus() then
			return self:FadeIn()
		end
	end
	self:FadeOut()
end

function CPPetRing:OnLoadoutConfigShown(show)
	if show then
		self:FadeIn()
	else
		self:FadeOut()
	end
end

---------------------------------------------------------------
-- Factory
---------------------------------------------------------------
env:AddFactory('Petring', function()
	if not ConsolePortBarPetRing then
		ConsolePortBarPetRing = CreateFrame('Button', 'ConsolePortBarPetRing', env.Manager, 'CPPetRing')
	end
	return ConsolePortBarPetRing;
end, env.Interface.Petring)