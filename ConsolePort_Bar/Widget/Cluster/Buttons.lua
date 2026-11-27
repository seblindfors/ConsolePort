local env, db = CPAPI.GetEnv(...)
---------------------------------------------------------------
local NOMOD, _, _, _, ALT = env.Const.Cluster.ModNames();
local _, _, CLUSTER_BUTTON, CLUSTER_SHADOW = env.Const.Cluster.Types();
local CLUSTER_DESIGN = env.Const.ClusterDesign;
local Const          = env.Const.Cluster;
---------------------------------------------------------------
local EQUIPPED_BORDER_COLOR = CreateColor(0, 1, 0, 1);
local BORDER_TUNING = {
	RestingBrightness      = Const.RimBrightness;
	HoverWhiteMix          = 0.20;
	PressedBrightness      = 0.68;
	GoldHoverOpacity       = 0.55;
	BeveledHoverOpacity    = 0.72;
	ToggledOpacityBonus    = 0.12;
	ToggledHoverMultiplier = 0.25;
};
---------------------------------------------------------------
local PROC_FLYOUT_PADDING = 1 / 14;
local PROC_LOOP_PADDING   = 0.2;
local PROC_INTRO_PADDING  = 0.6;
local PROC_LOOP_DURATION  = 1;
local PROC_INTRO_DURATION = 0.4;
local PROC_SHEET_ROWS     = 4;
local PROC_SHEET_COLUMNS  = 8;
local PROC_SHEET_FRAMES   = 30;
local PROC_PULSE_ALPHA    = 0.6;
local PROC_PULSE_DURATION = 0.5;
local PROC_BURST_DURATION = 0.28;
local PROC_BURST_SCALE    = 1.28;
local PROC_GLOW_SUBLEVEL  = 6;
local PROC_BURST_SUBLEVEL = 7;

---------------------------------------------------------------
local FlyoutCooldown = {};
---------------------------------------------------------------

function FlyoutCooldown:OnLoad()
	-- Flyout cluster buttons should have smaller CD font
	local text = self:GetRegions();
	local file, height, flags = text:GetFont();
	text:SetFont(file, height * 0.75, flags)
	self:HookScript('OnShow', self.UpdateModifierIcons)
	self:HookScript('OnHide', self.UpdateModifierIcons)
	hooksecurefunc(self, 'SetHideCountdownNumbers', self.UpdateModifierIcons)
end

function FlyoutCooldown:UpdateModifierIcons()
	local button = self:GetParent();
	button:ToggleHotkeys(button.showFlyoutIcons and not button:HasVisibleCooldownNumbers())
end

---------------------------------------------------------------
local FlyoutArrow = {};
---------------------------------------------------------------

do -- Flyout arrow owner check, report to parent
	local function CheckSpellFlyoutOwnership(self)
		local native, custom = SpellFlyout, env.LAB:GetSpellFlyoutFrame();
		return (native and native:IsShown() and native:GetParent() == self)
			or (custom and custom:IsShown() and custom:GetParent() == self)
	end

	function FlyoutArrow:Show()
		local parent = self:GetParent()
		parent:OnSpellFlyout(CheckSpellFlyoutOwnership(parent))
		return CPAPI.Index(self).Show(self)
	end

	function FlyoutArrow:Hide()
		self:GetParent():OnSpellFlyout(false)
		return CPAPI.Index(self).Hide(self)
	end
end

---------------------------------------------------------------
local FlyoutButton = {
	FadeIn  = db.Alpha.FadeIn;
	FadeOut = db.Alpha.FadeOut;
	alpha   = 0;
	shown   = 0;
};
---------------------------------------------------------------
do -- Alpha update closures
	FlyoutButton.AlphaState = CPAPI.CreateFlagClosures({
		AlwaysShow    = 0x01;
		OnCooldown    = 0x02;
		OverlayActive = 0x04;
		MouseOver     = 0x08;
		ShowGrid      = 0x10;
		Flyout        = 0x20;
		ConfigShown   = 0x40;
		LockHighlight = 0x80;
		Casting       = 0x100;
		Targeting     = 0x200;
		Swing         = 0x400;
		CastFeedback  = 0x800;
	});

	FlyoutButton.VisibilityState = CPAPI.CreateFlagClosures({
		NoBinding     = 0x01;
		Disabled      = 0x02;
	});
end

function FlyoutButton:OnShowAll(showAll)
	self:UpdateAlpha(self.AlphaState.AlwaysShow, showAll)
end

function FlyoutButton:OnOverlayGlow(state)
	self:UpdateAlpha(self.AlphaState.OverlayActive, state)
end

function FlyoutButton:OnMouseMotionFocus()
	self:UpdateAlpha(self.AlphaState.MouseOver, true)
	self:SetIgnoreParentAlpha(true)
end

function FlyoutButton:OnMouseMotionClear()
	self:UpdateAlpha(self.AlphaState.MouseOver, false)
	self:SetIgnoreParentAlpha(false)
end

function FlyoutButton:OnSpellFlyout(enabled)
	self:UpdateAlpha(self.AlphaState.Flyout, enabled)
end

function FlyoutButton:OnConfigShown(shown)
	self:UpdateAlpha(self.AlphaState.ConfigShown, shown)
end

function FlyoutButton:LockHighlight()
	self:UpdateAlpha(self.AlphaState.LockHighlight, true)
	CPAPI.Index(self).LockHighlight(self)
end

function FlyoutButton:UnlockHighlight()
	self:UpdateAlpha(self.AlphaState.LockHighlight, false)
	CPAPI.Index(self).UnlockHighlight(self)
end

function FlyoutButton:OnEnabledChanged(enabled)
	self:UpdateVisibility(self.VisibilityState.Disabled, not enabled)
end

function FlyoutButton:ACTIONBAR_SHOWGRID()
	self:UpdateAlpha(self.AlphaState.ShowGrid, true)
end

local function clearDragHover(button)
	if not ( button:IsMouseMotionFocus() or ConsolePort:IsCursorNode(button) ) then
		button:OnMouseMotionClear()
	end
end

function FlyoutButton:ACTIONBAR_HIDEGRID()
	self:UpdateAlpha(self.AlphaState.ShowGrid, false)
	if ( self.AlphaState.MouseOver(self.alpha, false) ~= self.alpha ) then
		CPAPI.Next(clearDragHover, self)
	end
end

function FlyoutButton:OnLoad()
	env:RegisterCallback('Settings/clusterShowAll', self.OnShowAll, self)
	env:RegisterCallback('Settings/clusterShowFlyoutIcons', self.OnShowFlyoutIcons, self)
	env:RegisterCallback('OnLoadoutConfigShown', self.OnConfigShown, self)

	Mixin(self.cooldown, FlyoutCooldown):OnLoad()
	self:WatchCooldownVisibility()
	self:OnShowAll(env('clusterShowAll'))
	self:OnShowFlyoutIcons(env('clusterShowFlyoutIcons'))
	self:OnConfigShown(env:IsLoadoutConfigShown())

	local flyoutArrow = self.FlyoutArrowContainer or self.FlyoutArrow or self.Arrow;
	if flyoutArrow then
		Mixin(flyoutArrow, FlyoutArrow)
	end

	self:HookScript('OnEnter', self.OnMouseMotionFocus)
	self:HookScript('OnLeave', self.OnMouseMotionClear)
	self:HookScript('OnEvent', CPAPI.EventMixin.OnEvent)
	CPAPI.RegisterFrameForEvents(self, {'ACTIONBAR_SHOWGRID'; 'ACTIONBAR_HIDEGRID';})
end

function FlyoutButton:OnShowFlyoutIcons(enabled)
	self.showFlyoutIcons = enabled;
	self.cooldown:UpdateModifierIcons()
end

function FlyoutButton:SetAlpha(alpha, force)
	if force then return CPAPI.Index(self).SetAlpha(self, alpha) end
end

function FlyoutButton:UpdateAlpha(closure, state)
	self.alpha = closure(self.alpha, state);
	local fadeOut = self.alpha == 0;
	local alpha = self:GetAlpha();
	if ( fadeOut and CPAPI.IsSecret(self.flyoutCooldownZero) ) then
		if not CPAPI.IsSecret(alpha) then db.Alpha.CancelFade(self) end;
		return self:SetAlphaFromBoolean(self.flyoutCooldownZero, 0, 1);
	end
	if CPAPI.IsSecret(alpha) then
		return self:SetAlpha(fadeOut and 0 or 1, true);
	end
	if fadeOut then
		self:FadeOut(0.25, alpha)
	else
		self:FadeIn(0.25, alpha)
	end
end

function FlyoutButton:UpdateVisibility(closure, state)
	self.shown = closure(self.shown, state);
	self:ToggleShown(self.shown == 0)
end

function FlyoutButton:SetBindings(primary, allBindings)
	local emulation = db.Gamepad.Index.Modifier.Owner[self.id];
	if emulation and env.IsModSubset(emulation, self.mod) then
		return self:UpdateVisibility(self.VisibilityState.NoBinding, true)
	end
	for modifier in pairs(allBindings) do
		if not env.IsModSubset(self.mod, modifier) then
			self:RefreshBinding(modifier, primary)
		else
			self:RefreshBinding(modifier, emulation and allBindings[NOMOD] or primary)
		end
	end
	local fallback = db('layersStrictModifiers') and allBindings[self.mod] or allBindings[NOMOD];
	self:RefreshBinding(self.mod, fallback)
	self:RefreshBinding(ALT .. self.mod, allBindings[ALT .. self.mod])
	self:UpdateVisibility(self.VisibilityState.NoBinding, false)
end

function FlyoutButton:GetEffectiveCombination()
	return self.mod, self.id;
end

---------------------------------------------------------------
local MainButton = {};
---------------------------------------------------------------

function MainButton:OnLoad()
	env:RegisterCallback('Settings/showMainIcons', self.ToggleHotkeys, self)
	self:ToggleHotkeys(env('showMainIcons'))

	self:HookScript('OnEnter', self.OnMouseMotionFocus)
	self:HookScript('OnLeave', self.OnMouseMotionClear)
	self:HookScript('PostClick', self.OnControllerClick)
	self:HookScript('OnHide', self.ClearControllerPress)
end

function MainButton:OnControllerClick(button, down)
	if ( button ~= 'ControllerInput' or not self.texturedBorder ) then return end;
	if not ( down and self:IsVisible() ) then
		return self:ClearControllerPress();
	end
	self.controllerPressed = true;
	self:SetButtonState('PUSHED')
end

function MainButton:ClearControllerPress()
	if not self.controllerPressed then return end;
	self.controllerPressed = nil;
	self:SetButtonState('NORMAL')
end

function MainButton:OnMouseMotionFocus()
	if self.mouseMotionTimeout then
		self.mouseMotionTimeout = self.mouseMotionTimeout:Cancel()
	end
	self:SetIgnoreParentAlpha(true)
end

function MainButton:OnMouseMotionClear()
	if self.mouseMotionTimeout then
		self.mouseMotionTimeout = self.mouseMotionTimeout:Cancel()
	end
	self.mouseMotionTimeout = C_Timer.NewTimer(5, function()
		self:SetIgnoreParentAlpha(false)
	end)
end

function MainButton:SetBindings(_, allBindings)
	local emulation = db.Gamepad.Index.Modifier.Owner[self.id];
	for modifier, binding in pairs(allBindings) do
		if not emulation then
			self:RefreshBinding(modifier, binding)
		else
			self:RefreshBinding(modifier, allBindings[env.ModComplement(modifier, emulation)])
		end
	end
end

function MainButton:ShouldOverrideActionBarBinding()
	return true;
end

function MainButton:GetOverrideBinding(modifier)
	return modifier .. self.id;
end

---------------------------------------------------------------
local Button = CreateFromMixins(env.ProxyButton, env.ClusterCooldownMixin, {SetNormalTexture = nop;});
---------------------------------------------------------------

local function updateBorderState(button)
	if not button.texturedBorder then return end;
	local pressed      = button:GetButtonState() == 'PUSHED';
	local hoverAlpha   = env:IsGoldClusterDesign()
		and BORDER_TUNING.GoldHoverOpacity
		or  BORDER_TUNING.BeveledHoverOpacity;
	local checkedAlpha = math.min(1, hoverAlpha + BORDER_TUNING.ToggledOpacityBonus);
	if button:GetChecked() then
		hoverAlpha = hoverAlpha * BORDER_TUNING.ToggledHoverMultiplier;
	end
	button.HighlightTexture:SetAlpha(pressed and 0 or hoverAlpha)
	button.CheckedTexture:SetAlpha(pressed and 0 or checkedAlpha)
end

local function updateBorderStateAfterMouse(button)
	if not button.texturedBorder then return end;
	CPAPI.Next(updateBorderState, button)
end

local function updateEquippedBorder(button)
	button.Border:SetVertexColor(EQUIPPED_BORDER_COLOR:GetRGBA())
end

local function clearTexturedBorder(button)
	button.texturedBorder = nil;
	if button.controllerPressed then button:ClearControllerPress() end;
	button.HighlightTexture:SetVertexColor(1, 1, 1, 1)
	button.PushedTexture:SetVertexColor(1, 1, 1, 1)
	button.CheckedTexture:SetVertexColor(1, 1, 1, 1)
	button.HighlightTexture:SetAlpha(1)
	button.CheckedTexture:SetAlpha(1)
end

function Button:OnLoad(modifier, layoutData)
	env.ProxyButton.OnLoad(self)
	self:SetAttribute(CPAPI.SkipHotkeyRender, true)
	self:SetAttribute('id', self.id)
	self:SetAttribute('mod', modifier)

	self.CheckedTexture   = self.CheckedTexture   or self:GetCheckedTexture();
	self.PushedTexture    = self.PushedTexture    or self:GetPushedTexture();
	self.NormalTexture    = self.NormalTexture    or self:GetNormalTexture();
	self.HighlightTexture = self.HighlightTexture or self:GetHighlightTexture();
	self:HookScript('OnMouseDown', updateBorderStateAfterMouse)
	self:HookScript('OnMouseUp', updateBorderStateAfterMouse)
	self:HookScript('OnEnter', updateBorderState)
	hooksecurefunc(self, 'SetButtonState', updateBorderState)
	hooksecurefunc(self, 'SetChecked', updateBorderState)

	self.mod        = modifier;
	self.layoutData = layoutData;
	if ( layoutData.Level ) then
		self:SetFrameLevel(layoutData.Level)
	end

	self:InitializeCooldowns()
	Mixin(self, modifier == NOMOD and MainButton or FlyoutButton):OnLoad()
	env:InitializeClusterCast(self)
	self.UpdateLocal = updateEquippedBorder;
	self:UpdateLocal()
	self.UpdateClusterSkin = env.LIB.Skin.ClusterBar[modifier] or nop;
	self:UpdateClusterSkin()
end

function Button:ToggleHotkeys(enabled)
	local hotkey1, hotkey2 = self.Hotkey1, self.Hotkey2;
	if hotkey1 then hotkey1:SetShown(enabled) end;
	if hotkey2 then hotkey2:SetShown(enabled) end;
end

function Button:ToggleShown(enabled)
	self:SetShown(enabled)
	self:SetAttribute(env.Attributes.Hidden, not enabled)
end

function Button:SetBorderColor(color)
	self.borderColor = color;
	if ( env('clusterDesign') == CLUSTER_DESIGN.Original ) then
		self.NormalTexture:SetVertexColor(color:GetRGBA())
		if self.texturedBorder then
			clearTexturedBorder(self)
		end
		return;
	end
	self.texturedBorder = true;
	local r, g, b, a = color:GetRGBA();
	local rest       = BORDER_TUNING.RestingBrightness;
	local lighten    = BORDER_TUNING.HoverWhiteMix;
	local pressed    = BORDER_TUNING.PressedBrightness;
	local hr, hg, hb = r + (1 - r) * lighten, g + (1 - g) * lighten, b + (1 - b) * lighten;
	self.NormalTexture:SetVertexColor(r * rest, g * rest, b * rest, a)
	self.HighlightTexture:SetVertexColor(hr, hg, hb, a)
	self.PushedTexture:SetVertexColor(r * pressed, g * pressed, b * pressed, a)
	self.CheckedTexture:SetVertexColor(hr, hg, hb, a)
	updateBorderState(self)
end

---------------------------------------------------------------
-- Spell proc glow
---------------------------------------------------------------
local function createProcFade(group, texture, toAlpha, duration, smoothing)
	local fade = group:CreateAnimation('Alpha');
	fade:SetTarget(texture)
	fade:SetOrder(1)
	fade:SetFromAlpha(1)
	fade:SetToAlpha(toAlpha)
	fade:SetDuration(duration)
	fade:SetSmoothing(smoothing)
end

local function createProcFlipBook(group, texture, duration)
	local flipBook = group:CreateAnimation('FlipBook');
	flipBook:SetTarget(texture)
	flipBook:SetOrder(1)
	flipBook:SetDuration(duration)
	flipBook:SetFlipBookRows(PROC_SHEET_ROWS)
	flipBook:SetFlipBookColumns(PROC_SHEET_COLUMNS)
	flipBook:SetFlipBookFrames(PROC_SHEET_FRAMES)
	flipBook:SetFlipBookFrameWidth(0)
	flipBook:SetFlipBookFrameHeight(0)
end

local function createFlyoutProcAnimations(glow, burst, loop, intro)
	glow:SetVertexColor(Const.ProcGlowColor:GetRGB())
	burst:SetVertexColor(Const.ProcBurstColor:GetRGB())
	loop:SetLooping('BOUNCE')
	createProcFade(loop, glow, PROC_PULSE_ALPHA, PROC_PULSE_DURATION, 'IN_OUT')

	local scale = intro:CreateAnimation('Scale');
	scale:SetTarget(burst)
	scale:SetOrder(1)
	scale:SetDuration(PROC_BURST_DURATION)
	scale:SetOrigin('CENTER', 0, 0)
	scale:SetSmoothing('OUT')
	scale:SetScale(PROC_BURST_SCALE, PROC_BURST_SCALE)
	createProcFade(intro, burst, 0, PROC_BURST_DURATION, 'OUT')
end

local function createProcGlow(button)
	local glow  = button:CreateTexture(nil, 'OVERLAY', nil, PROC_GLOW_SUBLEVEL);
	local burst = button:CreateTexture(nil, 'OVERLAY', nil, PROC_BURST_SUBLEVEL);
	glow:SetBlendMode('ADD')
	burst:SetBlendMode('ADD')
	glow:Hide()
	burst:Hide()

	local isMain = button.mod == NOMOD;
	local loop   = button:CreateAnimationGroup();
	local intro  = button:CreateAnimationGroup();
	if isMain then
		loop:SetLooping('REPEAT')
		createProcFlipBook(loop, glow, PROC_LOOP_DURATION)
		createProcFlipBook(intro, burst, PROC_INTRO_DURATION)
	else
		createFlyoutProcAnimations(glow, burst, loop, intro)
	end
	intro:SetScript('OnFinished', function()
		burst:Hide()
		if ( isMain and button.procGlowActive ) then
			glow:Show()
			loop:Play()
		end
	end)
	button.procGlow,      button.procGlowLoop  = glow,  loop;
	button.procGlowBurst, button.procGlowIntro = burst, intro;
end

local function setProcGlowBounds(glow, border, padding)
	local xPadding = border:GetWidth() * padding;
	local yPadding = border:GetHeight() * padding;
	glow:ClearAllPoints()
	glow:SetPoint('TOPLEFT', border, 'TOPLEFT', -xPadding, yPadding)
	glow:SetPoint('BOTTOMRIGHT', border, 'BOTTOMRIGHT', xPadding, -yPadding)
end

local function setProcFlipBookTexture(region, texture)
	if ( region.procTexture ~= texture ) then
		region:SetTexture(texture)
		region.procTexture = texture;
	end
end

local function showProcGlow(button)
	if not button.procGlow then
		createProcGlow(button)
	end
	local glow, burst = button.procGlow, button.procGlowBurst;
	local border  = button.SpellHighlightTexture or button.NormalTexture;
	local texture = button.procGlowTexture;
	local isMain  = button.mod == NOMOD;
	setProcGlowBounds(glow, border, isMain and PROC_LOOP_PADDING or PROC_FLYOUT_PADDING)
	setProcGlowBounds(burst, border, isMain and PROC_INTRO_PADDING or PROC_FLYOUT_PADDING)
	if isMain then
		setProcFlipBookTexture(glow, texture.Loop)
		setProcFlipBookTexture(burst, texture.Start)
	else
		glow:SetTexture(texture)
		burst:SetTexture(texture)
		glow:SetTexCoord(border:GetTexCoord())
		burst:SetTexCoord(border:GetTexCoord())
	end
	if not ( glow:IsShown() or burst:IsShown() ) then
		burst:Show()
		button.procGlowIntro:Play()
		if not isMain then
			glow:Show()
			button.procGlowLoop:Play()
		end
	end
end

function Button:ShowOverlayGlow()
	self.procGlowActive = true;
	if self.procGlowTexture then
		showProcGlow(self)
	end
end

function Button:HideOverlayGlow()
	self.procGlowActive = nil;
	if self.procGlow then
		self.procGlowLoop:Stop()
		self.procGlowIntro:Stop()
		self.procGlow:Hide()
		self.procGlowBurst:Hide()
	end
end

function Button:SetProcGlowTexture(texture)
	self.procGlowTexture = texture;
	if self.procGlowActive then
		showProcGlow(self)
	end
end

---------------------------------------------------------------
-- Cluster button factory
---------------------------------------------------------------

env:AddFactory(CLUSTER_BUTTON, function(id, buttonID, modifier, parent, layoutData)
	local button = Mixin(env.LAB:CreateButton(buttonID, id, parent, env.Button:GetConfig()), Button)
	env.LIB.SkinUtility.PreventSkinning(button)
	for i, hotkeyData in ipairs(layoutData.Hotkey) do
		local hotkeyID = env.MakeID('%s_%s_%d', id, modifier, i)
		local hotkey = Mixin(CreateFrame('Frame', hotkeyID, button), env.ProxyHotkey)
		hotkey.icon = hotkey:CreateTexture(nil, 'OVERLAY', nil, 7)
		hotkey.icon:SetAllPoints()
		hotkey:OnLoad(buttonID, unpack(hotkeyData))
		button['Hotkey' .. i] = hotkey;
	end
	if ( layoutData.Shadow ) then
		button.Shadow = env:Acquire(CLUSTER_SHADOW, buttonID, parent, button, layoutData.Shadow)
	end
	button:OnLoad(modifier, layoutData)
	return button;
end)
