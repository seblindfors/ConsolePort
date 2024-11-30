local _, env, db, L = ...; db = env.db; L = db.Locale;
local TOOLBAR_WATCH_UNIT = 16;
---------------------------------------------------------------
local TooltipButton = {};
---------------------------------------------------------------

function TooltipButton:OnEnter()
	GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
	GameTooltip_SetTitle(GameTooltip, self.title)
	if self.instruction then GameTooltip_AddInstructionLine(GameTooltip, self.instruction) end
	if self.error then GameTooltip_AddErrorLine(GameTooltip, self.error) end
	GameTooltip:Show()
	db.Alpha.Flash(self.FlashBorder, 1, 1, -1, false, 0, 0, 'microbutton')
end

function TooltipButton:OnLeave()
	db.Alpha.Stop(self.FlashBorder)
end

---------------------------------------------------------------
local Eye = CreateFromMixins(TooltipButton, {
---------------------------------------------------------------
	instruction = L'Toggle visibility of all modifier flyouts.';
});

function Eye:OnLoad()
	env:RegisterCallback('Settings/clusterShowAll', self.OnShowAll, self)
	self:OnShowAll(env('clusterShowAll'))
	self:RegisterForClicks('AnyDown', 'AnyUp')
	CPAPI.Start(self)
end

function Eye:OnShowAll(showAll)
	local icon = showAll and env.GetAsset([[Textures\Show]]) or env.GetAsset([[Textures\Hide]]);
	self.NormalTexture:SetTexture(icon)
	self.PushedTexture:SetTexture(icon)
	self.title = showAll and L'Hide Flyout Buttons' or L'Show Flyout Buttons';
end

function Eye:OnClick()
	env('Settings/clusterShowAll', not env('clusterShowAll'))
	self:OnEnter()
end

---------------------------------------------------------------
local Config = CreateFromMixins(TooltipButton, {
---------------------------------------------------------------
	title       = L'Action Bar Configuration';
	instruction = L'Open the configuration menu for the action bar.';
});

function Config:OnLoad()
	self:RegisterForClicks('AnyDown', 'AnyUp')
	self:RegisterEvent('PLAYER_REGEN_ENABLED')
	self:RegisterEvent('PLAYER_REGEN_DISABLED')
	CPAPI.Start(self)
end

function Config:OnEvent()
	self:SetEnabled(not InCombatLockdown())
	self.error = InCombatLockdown() and L'Cannot open configuration menu in combat.' or nil;
end

function Config:OnClick()
	env:TriggerEvent('OnConfigToggle')
end

---------------------------------------------------------------
local ExitVehicle = CreateFromMixins(TooltipButton, {
---------------------------------------------------------------
	title       = L'Exit Vehicle';
	onVehicle   = L'Exit the vehicle you are currently controlling.';
	onTaxi      = L'Request early landing from the taxi you are currently riding.';
	Events      = {
		'UPDATE_BONUS_ACTIONBAR';
		'UPDATE_MULTI_CAST_ACTIONBAR';
		'UNIT_ENTERED_VEHICLE';
		'UNIT_EXITED_VEHICLE';
		'VEHICLE_UPDATE';
	};
});

function ExitVehicle:OnLoad()
	self:RegisterForClicks('AnyDown', 'AnyUp')
	self.NormalTexture:SetSize(24, 32)
	self.HighlightTexture:SetSize(24, 32)
	CPAPI.RegisterFrameForEvents(self, self.Events)
	CPAPI.Start(self)
	self:OnEvent()
end

function ExitVehicle:SetNormal()
	CPMicroButton.SetNormal(self)
	self.HighlightTexture:SetSize(24, 32)
end

function ExitVehicle:OnClick()
	if UnitOnTaxi('player') then
		TaxiRequestEarlyLanding()
		self:Disable()
		self:LockHighlight()
	else
		VehicleExit()
	end
end

function ExitVehicle:OnEvent()
	self.instruction = UnitOnTaxi('player') and self.onTaxi or self.onVehicle;
	self:SetShown(self:CanExitVehicle())
	if self:CanExitVehicle() then
		self:Enable()
	else
		self:UnlockHighlight()
	end
end

function ExitVehicle:CanExitVehicle()
	if not CanExitVehicle then
		return UnitOnTaxi('player')
	else
		return CanExitVehicle()
	end
end

---------------------------------------------------------------
CPMicroButton = {
---------------------------------------------------------------
	ValidateTextures = {
		Background       = false;
		PushedBackground = false;
		FlashBorder      = 'Flash';
	};
};

local LoadMicroButtonTextures, MovePortraitTextures, MovePerformanceBar = nop, nop, nop;
if not CPAPI.IsRetailVersion then
	local TextureKit = {
		AchievementMicroButton = 'Achievements';
		CharacterMicroButton   = 'ButtonBG';
		CollectionsMicroButton = 'Collections';
		EJMicroButton          = 'AdventureGuide';
		GuildMicroButton       = 'GuildCommunities';
		HelpMicroButton        = 'Shop';
		LFGMicroButton         = 'Groupfinder';
		MainMenuMicroButton    = 'GameMenu';
		PVPMicroButton         = 'ButtonBG';
		QuestLogMicroButton    = 'Questlog';
		SocialsMicroButton     = 'GuildCommunities';
		SpellbookMicroButton   = 'SpellbookAbilities';
		TalentMicroButton      = 'SpecTalents';
		WorldMapMicroButton    = 'Groupfinder';
	};

	function LoadMicroButtonTextures(button)
		local kit = TextureKit[button:GetName()];
		local atlas = 'UI-HUD-MicroMenu-%s-%s';
		if kit then
			button.normalAtlas    = atlas:format(kit, 'Up');
			button.pushedAtlas    = atlas:format(kit, 'Down');
			button.disabledAtlas  = atlas:format(kit, 'Disabled');
			button.highlightAtlas = atlas:format(kit, 'Mouseover');
			button.SetNormalTexture    = nop; -- HACK: might taint?
			button.SetPushedTexture    = nop;
			button.SetDisabledTexture  = nop;
			button.SetHighlightTexture = nop;
		end
	end

	local PortraitTextures = {
		MicroButtonPortrait   = { 0.2000, 0.8000, 0.0666, 0.9000 };
		PVPMicroButtonTexture = { 0.1250, 0.5000, 0.0000, 0.6000 };
	};

	function MovePortraitTextures()
		for name, coords in pairs(PortraitTextures) do
			local portrait = _G[name];
			if portrait then
				portrait:ClearAllPoints()
				portrait:SetPoint('TOPLEFT', 7, -7)
				portrait:SetPoint('BOTTOMRIGHT', -7, 7)
				portrait:SetTexCoord(unpack(coords))
			end
		end
	end
end

if CPAPI.IsClassicEraVersion then
	function MovePerformanceBar(self)
		local frame  = MainMenuBarPerformanceBarFrame;
		local status = MainMenuBarPerformanceBar;
		if not frame or not self.props.micromenu then return end;
		frame:Show()
		frame:SetParent(self)
		frame:SetAllPoints(self.Divider1)
		frame:SetFrameStrata(self.Divider1:GetFrameStrata())
		frame:SetFrameLevel(self.Divider1:GetFrameLevel() + 1)
		CPAPI.LockPoints(frame)
		frame.ignoreInLayout = true;
		if not status then return end;
		status:SetParent(frame)
		status:SetAllPoints(frame)
		CPAPI.LockPoints(status)
	end
end

function CPMicroButton:OnLoad()
	self:SetSize(32, 40)

	self.NormalTexture    = self.NormalTexture or self:GetNormalTexture()
	self.PushedTexture    = self.PushedTexture or self:GetPushedTexture()
	self.HighlightTexture = self.HighlightTexture or self:GetHighlightTexture()
	self.DisabledTexture  = self.DisabledTexture or self:GetDisabledTexture()

	for texture, parentKey in pairs(self.ValidateTextures) do
		if not self[texture] then
			local object = parentKey and self[parentKey] or self:CreateTexture(nil, 'BACKGROUND')
			object:ClearAllPoints()
			object:SetSize(32, 41)
			object:SetPoint('CENTER')
			self[texture] = object;
		end
	end

	CPAPI.SetAtlas(self.Background, 'UI-HUD-MicroMenu-ButtonBG-Up', true)
	CPAPI.SetAtlas(self.PushedBackground, 'UI-HUD-MicroMenu-ButtonBG-Down', true)
	CPAPI.SetAtlas(self.FlashBorder, 'UI-HUD-MicroMenu-Highlightalert', false)

	for atlas, texture in pairs({
		normalAtlas    = self.NormalTexture;
		pushedAtlas    = self.PushedTexture;
		disabledAtlas  = self.DisabledTexture;
		highlightAtlas = self.HighlightTexture;
	}) do
		if self[atlas] then
			if not CPAPI.SetAtlas(texture, self[atlas], true) then
				texture:Hide()
			end
		end
	end
end

function CPMicroButton:OnEnter()
	if self.normalAtlas then
		self.NormalTexture:SetAlpha(0)
	end
end

function CPMicroButton:OnLeave()
	if self.normalAtlas then
		self.NormalTexture:SetAlpha(1)
	end
end

function CPMicroButton:SetPushed()
	self.Background:Hide()
	self.PushedBackground:Show()

	self:SetButtonState('PUSHED', true)
	if self.highlightAtlas then
		self.HighlightTexture:SetBlendMode('ADD')
		self.HighlightTexture:SetAlpha(0.5)
	end
end

function CPMicroButton:SetNormal()
	self:SetButtonState('NORMAL')
	if self.highlightAtlas then
		CPAPI.SetAtlas(self.HighlightTexture, self.highlightAtlas, true)
		self.HighlightTexture:SetBlendMode('BLEND')
		self.HighlightTexture:SetAlpha(1)
	end
	self.Background:Show()
	self.PushedBackground:Hide()
end

function CPMicroButton:OnShow()
	self:GetParent():Layout()
end

function CPMicroButton:OnHide()
	self:GetParent():Layout()
end

function CPMicroButton:OnMouseDown()
	if self:IsEnabled() then
		self:SetPushed()
	end
end

function CPMicroButton:OnMouseUp()
	if self:IsEnabled() then
		self:SetNormal()
	end
end

---------------------------------------------------------------
local PopoutFrame = {};
---------------------------------------------------------------
function PopoutFrame:OnLoad()
	Mixin(self.Eye, Eye):OnLoad()
	Mixin(self.Config, Config):OnLoad()
	Mixin(self.ExitVehicle, ExitVehicle):OnLoad()

	self.MicroButtons = {};
	for i, name in ipairs(MICRO_BUTTONS) do
		local button = _G[name];
		if button then
			self.MicroButtons[button] = CPAPI.IsRetailVersion and button.layoutIndex or i;
		end
	end

	self:SlideOut()
	RunNextFrame(function()
		self:Layout()
	end)

	if OverrideMicroMenuPosition then
		hooksecurefunc('OverrideMicroMenuPosition', GenerateClosure(self.OnOverrideMicroMenuPosition, self))
	end
	if UpdateMicroButtonsParent then
		hooksecurefunc('UpdateMicroButtonsParent', GenerateClosure(self.OnUpdateMicroButtonsParent, self))
	end
	if UpdateMicroButtons then
		hooksecurefunc('UpdateMicroButtons', GenerateClosure(self.OnUpdateMicroButtonsParent, self))
	end

	self:HookScript('OnShow', self.MoveMicroButtons)
end

function PopoutFrame:ToggleSlices(invert)
    local tLeft  = self.TopLeftCorner;
    local tRight = self.TopRightCorner;
	local bLeft  = self.BottomLeftCorner;
	local bRight = self.BottomRightCorner;
	local left   = self.LeftEdge;
	local right  = self.RightEdge;

	tLeft:SetShown(not invert)
	tRight:SetShown(not invert)
	bLeft:SetShown(invert)
	bRight:SetShown(invert)

	self.TopEdge:SetShown(not invert)
	self.BottomEdge:SetShown(invert)

	left:ClearAllPoints()
	right:ClearAllPoints()

	if not invert then
		left:SetPoint('TOPLEFT', tLeft, 'BOTTOMLEFT', 0, 0)
		left:SetPoint('BOTTOMLEFT', 0, 0)
		right:SetPoint('TOPRIGHT', tRight, 'BOTTOMRIGHT', 0, 0)
		right:SetPoint('BOTTOMRIGHT', 0, 0)
	else
		left:SetPoint('TOPLEFT', -34, 0)
		left:SetPoint('BOTTOMRIGHT', bLeft, 'TOPRIGHT', 0, 0)
		right:SetPoint('TOPRIGHT', 34, 0)
		right:SetPoint('BOTTOMLEFT', bRight, 'TOPLEFT', 0, 0)
	end
end

function PopoutFrame:Layout()
	local container = self:GetParent()
	local toolbar = ConsolePortToolbar;
	local delta = self.inverted and -1 or 1;
	local orientation = self.inverted and 'TOP' or 'BOTTOM';

	self:ToggleSlices(self.inverted)

	self.maximumWidth = toolbar:GetWidth() - 64;
	self.stride = math.floor(self.maximumWidth / 32) - 1;

	container:ClearAllPoints()
	container:SetPoint(orientation, toolbar, orientation, 0, delta * (TOOLBAR_WATCH_UNIT + 1))
	self:UpdatePoint(self.isActive)

	GridLayoutFrameMixin.Layout(self)
	container:SetSize(self:GetWidth() + 64, self:GetHeight() + 64)
	container.SlideIn.Translate:SetOffset(0,   delta * self:GetHeight())
	container.SlideOut.Translate:SetOffset(0, -delta * self:GetHeight())
end

function PopoutFrame:MoveMicroButtons()
	self.Divider1:SetShown(self.props.micromenu)
	if not self.props.micromenu then return end;
	for button, index in pairs(self.MicroButtons) do
		button:SetParent(self)
		button:ClearAllPoints()
		button:SetIgnoreParentAlpha(true)
		if ( button.layoutIndex ~= index ) then
			button.layoutIndex = index;
		end
		if not CPAPI.IsRetailVersion and not button.ValidateTextures then
			LoadMicroButtonTextures(button)
			button:SetHitRectInsets(0, 0, 0, 0)
			Mixin(button, CPMicroButton):OnLoad()
		end
	end
	MovePerformanceBar(self)
	MovePortraitTextures()
	self:Layout()
end

function PopoutFrame:SlideIn()
	self:GetParent().SlideIn:Play()
end

function PopoutFrame:SlideOut()
	self:GetParent().SlideOut:Play()
end

function PopoutFrame:UpdatePoint(active)
	local anchor = self.inverted and 'TOP' or 'BOTTOM';
	local delta  = self.inverted and -1 or 1;
	self:ClearAllPoints()
	self:SetPoint(anchor, 0, active and 0 or -delta * self:GetHeight())
end

function PopoutFrame:SetActive(active)
	self:UpdatePoint(active)
	self.isActive = active;
	if not self.MicroButtons then return end;
	for button in pairs(self.MicroButtons) do
		-- Show help tip frames when the micro buttons are hidden by clipping,
		-- which is why this is true when the popout is NOT active.
		button:SetIgnoreParentAlpha(not active)
	end
end

function PopoutFrame:SetProps(props, inverted)
	self.inverted = inverted;
	self.props = props;
	self.Eye:SetShown(props.eye)
	self:MoveMicroButtons()
	self:Layout()
end

function PopoutFrame:OnOverrideMicroMenuPosition(...)
	if not self.props.micromenu then return end;
	for button in pairs(self.MicroButtons) do
		button:SetParent(MicroMenu)
	end
	MicroMenu:Layout()
end

function PopoutFrame:OnUpdateMicroButtonsParent(...)
	if not self.props.micromenu then return end;
	self:MoveMicroButtons()
	self:MarkDirty()
end

---------------------------------------------------------------
CPToolbar = CreateFromMixins(env.ConfigurableWidgetMixin);
---------------------------------------------------------------

function CPToolbar:OnLoad()
	env:RegisterCallbacks(self.OnDataLoaded, self,
		'OnDataLoaded',
		'Settings/enableXPBar',
		'Settings/fadeXPBar',
		'Settings/tintColor',
		'Settings/xpBarColor'
	);

	db:RegisterCallback('OnHintsFocus', self.OnHints, self, 0)
	db:RegisterCallback('OnHintsClear', self.OnHints, self, 1)

	self.snapToPixels = 16;
	self.TotemBar  = not CPAPI.IsRetailVersion and MultiCastActionBarFrame;
	self.CastBar   = not CPAPI.IsRetailVersion and CastingBarFrame;
	self.StanceBar = not CPAPI.IsRetailVersion and StanceBarFrame;
	self:RegisterEvent('CURSOR_CHANGED')
	self.PopoutContainer:SetParent(self:GetParent())
	self.PopoutContainer:SetFrameLevel(self:GetFrameLevel() + 10)
	Mixin(self.PopoutContainer.PopoutFrame, PopoutFrame):OnLoad()
end

function CPToolbar:OnEnter()
	if self:GetScript('OnUpdate') then return end;
	self.PopoutContainer.SlideIn:Play()
	self:SetScript('OnUpdate', self.OnUpdate)
	self.fadeOutTimer = 0;
end

function CPToolbar:OnSizeChanged()
	self.PopoutContainer.PopoutFrame:Layout()
	if ( not self.XPBar ) then return end;
	self.XPBar:SetWidth(self:GetWidth() * 0.8)
	self.XPBar:UpdateBarsShown()
end

function CPToolbar:OnUpdate(elapsed)
	if self.PopoutContainer:IsMouseOver() then
		self.fadeOutTimer = 0;
		return;
	end
	self.fadeOutTimer = self.fadeOutTimer + elapsed;
	if self.fadeOutTimer > 1 then
		self.PopoutContainer.SlideOut:Play()
		self:SetScript('OnUpdate', nil)
	end
end

function CPToolbar:OnEvent()
	self.PopoutContainer:SetShown(not GetCursorInfo())
end

function CPToolbar:SetTintColor(r, g, b, a)
	local orientation, minColor, maxColor = env:GetColorGradient(r, g, b, a, .25, self.inverted)
	self.BG:SetGradient(orientation, minColor, maxColor)
	self.DividerLine:SetVertexColor(r, g, b, a)
	self.PopoutContainer.PopoutFrame.Gradient:SetGradient(orientation, minColor, maxColor)
end

function CPToolbar:OnDataLoaded()
	self:SetTintColor(env:GetColorRGBA('tintColor'))
	self:ToggleXPBar(env('enableXPBar'))
	self:ToggleXPBarFade(env('enableXPBar'))
end

function CPToolbar:SetProps(props)
	self:OnDataLoaded()
	self:UpdateInversion(props)
	self:SetDynamicProps(props)
	self:OnSizeChanged()
	self:Show()
	self:SetTotemBarProps(props.totem)
	self:SetCastBarProps(props.castbar)
	self:SetStanceBarProps(props.totem)
	self.PopoutContainer.PopoutFrame:SetProps(props.menu, self.inverted)
end

function CPToolbar:UpdateInversion(props)
	self.inverted = not not props.pos.point:match('^TOP');

	local delta = self.inverted and -1 or 1;
	local orientation = self.inverted and 'TOP' or 'BOTTOM';

	self.DividerLine:ClearAllPoints()
	self.DividerLine:SetPoint(orientation..'LEFT', 0, TOOLBAR_WATCH_UNIT * delta)
	self.DividerLine:SetPoint(orientation..'RIGHT', 0, TOOLBAR_WATCH_UNIT * delta)

	local bgOffsetTop = self.inverted and -16 or 60;
	local bgOffsetBot = self.inverted and -60 or 16;
	self.BG:SetPoint('TOPLEFT', TOOLBAR_WATCH_UNIT, bgOffsetTop)
	self.BG:SetPoint('BOTTOMRIGHT', -TOOLBAR_WATCH_UNIT, bgOffsetBot)

	if ( not self.XPBar ) then return end;
	self.XPBar:ClearAllPoints()
	self.XPBar:SetPoint(orientation)
	self.XPBar:SetInversion(self.inverted)
end

function CPToolbar:OnPropsUpdated()
	self:SetProps(self.props)
end


---------------------------------------------------------------
-- Elements
---------------------------------------------------------------
function CPToolbar:ToggleXPBar(enabled)
	if ( not self.XPBar ) then
		if not enabled then return end;
		self.XPBar = CreateFrame('Frame', nil, self, 'CPWatchBarContainer')
	end
	self.XPBar:SetShown(enabled)
	self.XPBar:SetMainBarColor(env:GetColorRGB('xpBarColor'))
end

function CPToolbar:ToggleXPBarFade(xpBarEnabled)
	if ( not self.XPBar ) then return end;
	if not xpBarEnabled then return end;
	self.XPBar:OnShow() -- env('fadeXPBar') is handled by the XPBar itself
end

function CPToolbar:SetTotemBarProps(props)
	if not self.TotemBar or not props.enabled then return end;
	if not self.TotemBar.SetDynamicProps then
		Mixin(self.TotemBar, env.ConfigurableWidgetMixin)
		self.TotemBar:SetScript('OnUpdate', nil)
		self.TotemBar.OnPropsUpdated = function(self) self:SetDynamicProps(self.props) end;
	end
	self.TotemBar:SetDynamicProps(props)
	self.TotemBar:SetParent(props.hidden and env.UIHandler or UIParent)
end

function CPToolbar:SetStanceBarProps(props)
	if not self.StanceBar or not props.enabled then return end;
	if not self.StanceBarUpdate then
		local stanceButtons = self.StanceBar.StanceButtons;
		self.StanceBarUpdate = function(stanceBar)
			local numForms = GetNumShapeshiftForms()
			if ( numForms == 0 ) then return end;
			local fL, fR = math.huge, 0;
			for i = 1, numForms do
				local button = stanceButtons[i];
				local left, _, width = button:GetRect()
				fL = min(fL, left)
				fR = max(fR, left + width)
			end
			env:RunSafe(stanceBar.SetWidth, stanceBar, fR - fL + 22)
			StanceBarLeft:SetTexture(nil)
			StanceBarMiddle:SetTexture(nil)
			StanceBarRight:SetTexture(nil)
		end;
		for i = 1, NUM_STANCE_SLOTS do
			local texture = stanceButtons[i]:GetNormalTexture()
			texture:ClearAllPoints()
			texture:SetPoint('TOPLEFT', -11, 11)
			texture:SetPoint('BOTTOMRIGHT', 12, -12)
		end
		self.StanceBar:HookScript('OnEvent', self.StanceBarUpdate)
		self.StanceBarUpdate(self.StanceBar)
	end
	if self.TotemBar then
		self.StanceBar:ClearAllPoints()
		self.StanceBar:SetPoint('CENTER', self.TotemBar, 'CENTER', 0, 0)
	else -- Classic Era (probably), no totem bar so stance bar owns the positioning
		if not self.StanceBar.SetDynamicProps then
			Mixin(self.StanceBar, env.ConfigurableWidgetMixin)
			self.StanceBar.OnPropsUpdated = function(self) self:SetDynamicProps(self.props) end;
		end
		self.StanceBar:SetDynamicProps(props)
		self.StanceBarUpdate(self.StanceBar)
	end
	self.StanceBar:SetParent(props.hidden and env.UIHandler or UIParent)
end

local MoveCastingBarFrame;
function CPToolbar:SetCastBarProps(props)
	-- Classic only, hook persists until /reload
    if not self.CastBar or not props or not props.enabled then return end;

	local inverted = self.inverted;
	local delta = inverted and -1 or 1;
	local point = inverted and 'TOP' or 'BOTTOM';

	if self.castBarAnchor then
		self.castBarAnchor[1] = point;
		self.castBarAnchor[3] = point;
		self.castBarAnchor[5] = delta;
		return MoveCastingBarFrame()
	end

	self.castBarAnchor = { point, self, point, 0, delta };
	-- TODO: check if this is still needed with disabled vehicle UI
	hooksecurefunc(self.CastBar, 'SetPoint', function(bar, _, region)
		if region ~= self then
			bar:ClearAllPoints()
			bar:SetPoint(unpack(self.castBarAnchor))
		end
	end)

	local function ModifyCastingBarFrame()
		CastingBarFrame_SetLook(self.CastBar, 'UNITFRAME')
		self.CastBar.Border:SetShown(false)
		self.CastBar.Text:SetPoint('TOPLEFT', 0, 0)
		self.CastBar.Text:SetPoint('TOPRIGHT', 0, 0)
		self.CastBar.Flash:SetTexture([[Interface\QUESTFRAME\UI-QuestLogTitleHighlight]])
		self.CastBar.Flash:SetAllPoints(self.CastBar)
		self.CastBar.BorderShield:SetTexture([[Interface\CastingBar\UI-CastingBar-Arena-Shield]])
		self.CastBar.BorderShield:SetPoint('CENTER', self.CastBar.Icon, 'CENTER', 10, 0)
		self.CastBar.BorderShield:SetSize(49, 49)
		local r, g, b = env:GetColorRGB('xpBarColor')
		CastingBarFrame_SetStartCastColor(self.CastBar, r, g, b)
	end

	function MoveCastingBarFrame()
		ModifyCastingBarFrame()
		self.CastBar:ClearAllPoints()
		self.CastBar:SetPoint(unpack(self.castBarAnchor))
		self.CastBar:SetSize(self:GetWidth() - 190, 14)
	end

	env:RegisterCallback('Settings/xpBarColor', ModifyCastingBarFrame)
	MoveCastingBarFrame()

	self:HookScript('OnSizeChanged', MoveCastingBarFrame)
	self:HookScript('OnShow', MoveCastingBarFrame)
	self:HookScript('OnHide', MoveCastingBarFrame)
end

function CPToolbar:OnHints(alpha)
	if self.TotemBar  then self.TotemBar:SetAlpha(alpha)  end;
	if self.StanceBar then self.StanceBar:SetAlpha(alpha) end;
end

---------------------------------------------------------------
-- Factory
---------------------------------------------------------------
env:AddFactory('Toolbar', function()
	if not ConsolePortToolbar then
		ConsolePortToolbar = CreateFrame('Frame', 'ConsolePortToolbar', env.Manager, 'CPToolbar')
	end
	return ConsolePortToolbar;
end, env.Interface.Toolbar)