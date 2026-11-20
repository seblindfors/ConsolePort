local env, db = CPAPI.GetEnv(...)
---------------------------------------------------------------
local NOMOD, _, _, _, ALT = env.Const.Cluster.ModNames();
local _, _, CLUSTER_BUTTON, CLUSTER_SHADOW = env.Const.Cluster.Types();

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
	-- The modifier glyphs share space with the cooldown number.
	local button = self:GetParent();
	button:ToggleHotkeys(button.showFlyoutIcons and not button:HasVisibleCooldownNumbers())
end

---------------------------------------------------------------
local FlyoutArrow = {};
---------------------------------------------------------------

do -- Flyout arrow owner check, report to parent
	local function checkSpellFlyoutOwnership(self)
		local native, custom = SpellFlyout, env.LAB:GetSpellFlyoutFrame();
		return (native and native:IsShown() and native:GetParent() == self)
			or (custom and custom:IsShown() and custom:GetParent() == self)
	end

	function FlyoutArrow:Show()
		local parent = self:GetParent()
		parent:OnSpellFlyout(checkSpellFlyoutOwnership(parent))
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
	-- Closing the drag grid can return control to the camera before OnLeave fires.
	if not button:IsMouseMotionFocus() and not ConsolePort:IsCursorNode(button) then
		button:OnMouseMotionClear()
	end
end

function FlyoutButton:ACTIONBAR_HIDEGRID()
	self:UpdateAlpha(self.AlphaState.ShowGrid, false)
	if self.AlphaState.MouseOver(self.alpha, false) ~= self.alpha then
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
	if fadeOut and CPAPI.IsSecret(self.flyoutCooldownZero) then
		if not CPAPI.IsSecret(alpha) then db.Alpha.CancelFade(self) end;
		return self:SetAlphaFromBoolean(self.flyoutCooldownZero, 0, 1);
	end
	if CPAPI.IsSecret(alpha) then
		-- A public visibility reason takes over from the native cooldown display.
		return self:SetAlpha(fadeOut and 0 or 1, true);
	end
	-- A quarter-second fade lets changes of modifier or cooldown state settle visually.
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
	self:RefreshBinding(self.mod, allBindings[NOMOD])
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
	if button ~= 'ControllerInput' or not self.texturedBorder then return end;
	if not (down and self:IsVisible()) then
		return self:ClearControllerPress();
	end
	-- Bound controller clicks do not use the native mouse press path.
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

-- Textured border tuning values range from 0 to 1.
local BORDER_TUNING = {
	RestingBrightness      = 0.86; -- Fraction of Border Vertex Color used at rest.
	HoverWhiteMix          = 0.20; -- Amount of white mixed into the hover tint.
	PressedBrightness      = 0.68; -- Fraction of the border color used while held.
	GoldHoverOpacity       = 0.55; -- Strength of the hover highlight on gold designs.
	BeveledHoverOpacity    = 0.72; -- Strength of the hover highlight on Beveled Silver.
	ToggledOpacityBonus    = 0.12; -- Extra opacity over hover for the checked border.
	ToggledHoverMultiplier = 0.25; -- Fraction of normal hover opacity while toggled on.
	EquippedOpacity        = 1.00; -- Strength of the green equipped-item highlight.
};
---------------------------------------------------------------

local function updateBorderState(button)
	if not button.texturedBorder then return end;
	local pressed      = button:GetButtonState() == 'PUSHED';
	local hoverAlpha   = env:IsGoldClusterDesign() and BORDER_TUNING.GoldHoverOpacity or BORDER_TUNING.BeveledHoverOpacity;
	local checkedAlpha = math.min(1, hoverAlpha + BORDER_TUNING.ToggledOpacityBonus);
	if button:GetChecked() then
		hoverAlpha = hoverAlpha * BORDER_TUNING.ToggledHoverMultiplier;
	end
	button.HighlightTexture:SetAlpha(pressed and 0 or hoverAlpha)
	button.CheckedTexture:SetAlpha(pressed and 0 or checkedAlpha)
end

local function updateBorderStateAfterMouse(button)
	if not button.texturedBorder then return end;
	-- Mouse scripts can run before the native button state changes.
	CPAPI.Next(updateBorderState, button)
end

local function updateEquippedBorder(button)
	button.Border:SetVertexColor(0, 1, 0, BORDER_TUNING.EquippedOpacity)
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
	-- LAB calls UpdateLocal after setting the equipped-item border.
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
	if env('clusterDesign') == env.Const.ClusterDesign.Original then
		self.NormalTexture:SetVertexColor(color:GetRGBA())
		if self.texturedBorder then
			-- Clear the textured state overrides when returning to the original border.
			self.texturedBorder = nil;
			if self.controllerPressed then self:ClearControllerPress() end;
			self.HighlightTexture:SetVertexColor(1, 1, 1, 1)
			self.PushedTexture:SetVertexColor(1, 1, 1, 1)
			self.CheckedTexture:SetVertexColor(1, 1, 1, 1)
			self.HighlightTexture:SetAlpha(1)
			self.CheckedTexture:SetAlpha(1)
		end
		return;
	end
	self.texturedBorder = true;
	local r, g, b, a  = color:GetRGBA();
	local rest        = BORDER_TUNING.RestingBrightness;
	local lighten     = BORDER_TUNING.HoverWhiteMix;
	local pressed     = BORDER_TUNING.PressedBrightness;
	local hr, hg, hb  = r + (1 - r) * lighten, g + (1 - g) * lighten, b + (1 - b) * lighten;
	self.NormalTexture:SetVertexColor(r * rest, g * rest, b * rest, a)
	self.HighlightTexture:SetVertexColor(hr, hg, hb, a)
	self.PushedTexture:SetVertexColor(r * pressed, g * pressed, b * pressed, a)
	self.CheckedTexture:SetVertexColor(hr, hg, hb, a)
	updateBorderState(self)
end

---------------------------------------------------------------
-- Spell proc glow
-- Main buttons play the intro before the loop. Flyouts pulse during the burst.
---------------------------------------------------------------
local PROC_GLOW_PADDING  = 1 / 14; -- eight pixels around the 112-pixel border art
local PROC_LOOP_PADDING  = 0.2; -- Per side, relative to the main border size.
local PROC_INTRO_PADDING = 0.6; -- The intro sheet has a wider halo than the loop.

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
	-- The proc sheets store 30 animation frames in an 8-column, 4-row grid.
	flipBook:SetFlipBookRows(4)
	flipBook:SetFlipBookColumns(8)
	flipBook:SetFlipBookFrames(30)
	flipBook:SetFlipBookFrameWidth(0)
	flipBook:SetFlipBookFrameHeight(0)
end

local function createFlyoutProcAnimations(glow, burst, loop, intro)
	-- The gold loop breathes from full to 60% opacity every half second.
	glow:SetVertexColor(1, 0.82, 0.42)
	burst:SetVertexColor(1, 0.94, 0.70)
	loop:SetLooping('BOUNCE')
	createProcFade(loop, glow, 0.6, 0.5, 'IN_OUT')

	-- The paler intro expands 28% as it fades over 0.28 seconds.
	local duration = 0.28;
	local scale = intro:CreateAnimation('Scale');
	scale:SetTarget(burst)
	scale:SetOrder(1)
	scale:SetDuration(duration)
	scale:SetOrigin('CENTER', 0, 0)
	scale:SetSmoothing('OUT')
	scale:SetScale(1.28, 1.28)
	createProcFade(intro, burst, 0, duration, 'OUT')
end

local function createProcGlow(button)
	local glow  = button:CreateTexture(nil, 'OVERLAY', nil, 6);
	local burst = button:CreateTexture(nil, 'OVERLAY', nil, 7);
	glow:SetBlendMode('ADD')
	burst:SetBlendMode('ADD')
	glow:Hide()
	burst:Hide()

	local isMain = button.mod == NOMOD;
	local loop   = button:CreateAnimationGroup();
	local intro  = button:CreateAnimationGroup();
	if isMain then
		-- Main buttons play the 0.4-second reveal once, then repeat the one-second loop.
		loop:SetLooping('REPEAT')
		createProcFlipBook(loop, glow, 1)
		createProcFlipBook(intro, burst, 0.4)
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
	button.procGlow, button.procGlowLoop = glow, loop;
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
	if region.procTexture ~= texture then
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
	setProcGlowBounds(glow, border, isMain and PROC_LOOP_PADDING or PROC_GLOW_PADDING)
	setProcGlowBounds(burst, border, isMain and PROC_INTRO_PADDING or PROC_GLOW_PADDING)
	if isMain then
		setProcFlipBookTexture(glow, texture.Loop)
		setProcFlipBookTexture(burst, texture.Start)
	else
		glow:SetTexture(texture)
		burst:SetTexture(texture)
		-- Wedge glows follow the same rotation and mirroring as the border.
		glow:SetTexCoord(border:GetTexCoord())
		burst:SetTexCoord(border:GetTexCoord())
	end
	if not (glow:IsShown() or burst:IsShown()) then
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
