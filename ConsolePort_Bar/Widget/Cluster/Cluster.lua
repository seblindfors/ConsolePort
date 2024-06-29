local _, env, db = ...; db = env.db;
---------------------------------------------------------------
local NOMOD, _, _, _, ALT = env.Const.Cluster.ModNames();
local CLUSTER_BAR, CLUSTER_HANDLE, CLUSTER_BUTTON, CLUSTER_SHADOW = env.Const.Cluster.Types();
local ClusterLayout = env.Const.Cluster.Layout;
---------------------------------------------------------------
local Cluster = CreateFromMixins(env.DynamicWidgetMixin, env.MovableWidgetMixin);
---------------------------------------------------------------

function Cluster:OnLoad(buttonID, parent)
	self.buttonID = buttonID;
	self.header   = parent;
	self:OnVariableChanged()
	env:RegisterCallbacks(self.OnVariableChanged, self,
		'Settings/swipeColor',
		'Settings/borderColor',
		'Settings/disableDND'
	);
end

function Cluster:OnVariableChanged()
	self:SetSwipeColor(env:GetColor('swipeColor'))
	self:SetBorderColor(env:GetColor('borderColor'))
	for _, button in self:Enumerate() do
		button:DisableDragNDrop(env('disableDND'))
	end
end

function Cluster:Enumerate()
	return pairs(self.buttons)
end

function Cluster:Show()
	for _, button in self:Enumerate() do
		button:ToggleShown(true)
	end
end

function Cluster:Hide()
	for _, button in self:Enumerate() do
		button:ToggleShown(false)
	end
end

function Cluster:SetPoint(...)
	local main = self:GetMainButton();
	local p, _, _, x, y = ...;
	main:ClearAllPoints()
	if p and x and y then
		return main:SetPoint(...)
	end
end

function Cluster:ClearAllPoints()
	local main = self:GetMainButton();
	main:ClearAllPoints()
end

function Cluster:SetSize(size)
	local main = self:GetMainButton();
	for _, button in self:Enumerate() do
		local layoutData = button.layoutData;
		local objSize = size * (layoutData.Size or 1);
		local relativePointData = layoutData[button.direction];
		if relativePointData then
			local p, rel, x, y = unpack(relativePointData);
			local offset = layoutData.Offset or 1;
			button:ClearAllPoints()
			button:SetPoint(p, main, rel, x * offset, y * offset)
		end
		button:SetSize(objSize, objSize)
		button:UpdateLocal(true)
	end
end

function Cluster:SetSwipeColor(color)
	local main = self:GetMainButton();
	main.cooldown:SetSwipeColor(color:GetRGBA())
	main.swipeColor = color;
end

function Cluster:SetBorderColor(color)
	for _, button in self:Enumerate() do
		button.NormalTexture:SetVertexColor(color:GetRGBA())
		button.borderColor = color;
	end
end

function Cluster:GetParent()
	return self.header;
end

function Cluster:GetMainButton()
	return self.buttons[NOMOD];
end

function Cluster:SetParent(parent)
	self.header = parent;
	for _, button in self:Enumerate() do
		button:NewHeader(parent) -- TODO: do we need to unwrap the LAB button scripts?
	end
end

function Cluster:SetDirection(direction)
	for modifier, button in self:Enumerate() do
		if modifier == NOMOD then
			button:SetAttribute('flyoutDirection', 'DOWN')
		else
			button:SetAttribute('flyoutDirection', direction)
			button.direction = direction;
			button:UpdateLocal(true)
		end
	end
end

function Cluster:SetProps(props)
	self:SetDynamicProps(props)
	self:OnPropsUpdated()
end

function Cluster:ToggleFlyouts(enabled)
	local main = self:GetMainButton()
	for _, button in self:Enumerate() do
		if ( button ~= main ) then
			button:OnEnabledChanged(enabled)
		end
	end
end

function Cluster:OnPropsUpdated()
	local props = self.props;
	local pos = props.pos;
	self:Show()
	self:SetPoint(pos.point, self:GetParent(), pos.relPoint, pos.x, pos.y)
	self:SetDirection(props.dir)
	self:SetSize(props.size) -- TODO: flyout size is not consistent
	self:ToggleFlyouts(not not props.showFlyouts)

	local bindings = env.Manager:GetBindings(self.buttonID);
	if bindings then
		self:SetBindings(bindings)
	end
end

function Cluster:SetBindings(bindings)
	for modifier, button in self:Enumerate() do
		button:SetBindings(bindings[modifier], bindings)
	end
end

Cluster.GetMoveTarget = Cluster.GetMainButton;
Cluster.GetSnapSize   = function() return env.Const.Cluster.SnapPixels end;

---------------------------------------------------------------
local Shadow = {};
---------------------------------------------------------------

function Shadow:OnLoad(owner, relativeSize, alpha, texture, point)
	local update = GenerateClosure(self.Update, self)
	self.owner = owner;
	self.point = point;
	self.relativeSize = relativeSize;
	self:SetAlpha(alpha)
	self:SetTexture(texture)
	owner:HookScript('OnShow', update)
	owner:HookScript('OnHide', update)
	owner:HookScript('OnSizeChanged', update)
end

function Shadow:Update()
	local size = self.owner:GetSize() * self.relativeSize;
	local pt, x, y = unpack(self.point)
	self:SetShown(self.owner:IsShown())
	self:SetParent(self.owner:GetParent())
	self:SetSize(size, size)
	self:SetPoint(pt, self.owner, pt, x, y)
end

---------------------------------------------------------------
local FlyoutCooldown = CreateFromMixins(env.ProxyCooldown);
---------------------------------------------------------------

function FlyoutCooldown:OnLoad()
	env.ProxyCooldown.OnLoad(self)
	self.text = self:GetRegions()
	-- Flyout cluster buttons should have smaller CD font
	local file, height, flags = self.text:GetFont()
	self.text:SetFont(file, height * 0.75, flags)
end

function FlyoutCooldown:SetDrawBling(enabled, force)
	if force then return getmetatable(self).__index.SetDrawBling(self, enabled) end
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
		return getmetatable(self).__index.Show(self)
	end

	function FlyoutArrow:Hide()
		self:GetParent():OnSpellFlyout(false)
		return getmetatable(self).__index.Hide(self)
	end
end

---------------------------------------------------------------
local FlyoutButton = { FadeIn = db.Alpha.FadeIn, FadeOut = db.Alpha.FadeOut, alpha = 0, shown = 0};
---------------------------------------------------------------
do  -- Alpha update closures
	FlyoutButton.AlphaState = env.CreateFlagClosures({
		AlwaysShow    = 0x01;
		OnCooldown    = 0x02;
		OverlayActive = 0x04;
		MouseOver     = 0x08;
		ShowGrid      = 0x10;
		Flyout        = 0x20;
		ConfigShown   = 0x40;
	});

	FlyoutButton.AlphaEvents = {
		ACTIONBAR_SHOWGRID = { FlyoutButton.AlphaState.ShowGrid, true  };
		ACTIONBAR_HIDEGRID = { FlyoutButton.AlphaState.ShowGrid, false };
	};

	FlyoutButton.VisibilityState = env.CreateFlagClosures({
		NoBinding     = 0x01;
		Disabled	  = 0x02;
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

function FlyoutButton:OnEnabledChanged(enabled)
	self:UpdateVisibility(self.VisibilityState.Disabled, not enabled)
end

function FlyoutButton:OnAlphaEvent(event)
	local eventClosure = self.AlphaEvents[event];
	if eventClosure then
		self:UpdateAlpha(unpack(eventClosure))
	end
end

function FlyoutButton:OnLoad()
	env:RegisterCallback('Settings/clusterShowAll', self.OnShowAll, self)
	env:RegisterCallback('Settings/clusterShowFlyoutIcons', self.OnShowFlyoutIcons, self)
	env:RegisterCallback('OnLoadoutConfigShown', self.OnConfigShown, self)

	self:OnShowAll(env('clusterShowAll'))
	self:OnShowFlyoutIcons(env('clusterShowFlyoutIcons'))

	Mixin(self.cooldown, FlyoutCooldown):OnLoad()
	Mixin(self.FlyoutArrowContainer or self.FlyoutArrow, FlyoutArrow)

	self:HookScript('OnEnter', self.OnMouseMotionFocus)
	self:HookScript('OnLeave', self.OnMouseMotionClear)
	self:HookScript('OnEvent', self.OnAlphaEvent)
	for event in pairs(self.AlphaEvents) do
		self:RegisterEvent(event)
	end
end

function FlyoutButton:OnCooldownSet(cooldown, _, duration)
	local onCooldown = (cooldown and duration and duration > 0);
	local fadeInForCD = onCooldown and duration > 2;
	local hotkey1, hotkey2 = self.Hotkey1, self.Hotkey2;
	if hotkey1 then hotkey1:SetShown(not onCooldown) end;
	if hotkey2 then hotkey2:SetShown(not onCooldown) end;
	self:UpdateAlpha(self.AlphaState.OnCooldown, fadeInForCD)
end

function FlyoutButton:OnCooldownClear()
	self:ToggleHotkeys(self.showFlyoutIcons)
	self:UpdateAlpha(self.AlphaState.OnCooldown, false)
end

function FlyoutButton:OnShowFlyoutIcons(enabled)
	self.showFlyoutIcons = enabled;
	self:ToggleHotkeys(enabled)
end

function FlyoutButton:SetAlpha(alpha, force)
	if force then return getmetatable(self).__index.SetAlpha(self, alpha) end
end

function FlyoutButton:UpdateAlpha(closure, state)
	self.alpha = closure(self.alpha, state);
	local fadeOut = self.alpha == 0;
	if fadeOut then
		self:FadeOut(0.25, self:GetAlpha())
	else
		self:FadeIn(0.25, self:GetAlpha())
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
	self:RefreshBinding(ALT..self.mod, allBindings[ALT..self.mod])
	self:UpdateVisibility(self.VisibilityState.NoBinding, false)
end

function FlyoutButton:GetEffectiveCombination()
	return self.mod, self.id;
end

---------------------------------------------------------------
local MainButton = { OnCooldownClear = nop };
---------------------------------------------------------------

function MainButton:OnLoad()
	env:RegisterCallback('Settings/showMainIcons', self.ToggleHotkeys, self)
	self:ToggleHotkeys(env('showMainIcons'))

	self:HookScript('OnEnter', self.OnMouseMotionFocus)
	self:HookScript('OnLeave', self.OnMouseMotionClear)

	Mixin(self.cooldown, env.ProxyCooldown):OnLoad()
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

function MainButton:OnCooldownSet()
	self:Skin(false)
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
	return modifier..self.id;
end

---------------------------------------------------------------
local Button = Mixin({ SetNormalTexture = nop }, env.ProxyButton);
---------------------------------------------------------------

function Button:OnLoad(modifier, layoutData)
	env.ProxyButton.OnLoad(self)
	self:SetAttribute(CPAPI.SkipHotkeyRender, true)
	self:SetAttribute('id', self.id)
	self:SetAttribute('mod', modifier)

	self.CheckedTexture = self.CheckedTexture or self:GetCheckedTexture()
	self.PushedTexture  = self.PushedTexture  or self:GetPushedTexture()
	self.NormalTexture  = self.NormalTexture  or self:GetNormalTexture()
	self.HighlightTexture = self.HighlightTexture or self:GetHighlightTexture()

	self.mod = modifier;
	self.layoutData = layoutData;
	self:UpdateSkin()
	if ( layoutData.Level ) then
		self:SetFrameLevel(layoutData.Level)
	end

	Mixin(self, modifier == NOMOD and MainButton or FlyoutButton):OnLoad()
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

function Button:UpdateLocal(force)
	if self.Skin then
		self:Skin(force)
	end
end

function Button:UpdateSkin()
	self.Skin = env.LIB.Skin.ClusterBar[self.mod] or nop; -- Skins.lua
	self:Skin(true)
end

function Button:GetOverlayColor()
	return env:GetColorRGBA('procColor')
end

function Button:ShowOverlayGlow()
	env.LIB.RoundGlow.ShowOverlayGlow(self)
end

function Button:HideOverlayGlow()
	env.LIB.RoundGlow.HideOverlayGlow(self)
end

---------------------------------------------------------------
CPClusterBar = CreateFromMixins(CPActionBar, env.MovableWidgetMixin);
---------------------------------------------------------------

function CPClusterBar:OnLoad()
	CPActionBar.OnLoad(self)

	env:RegisterSafeCallback('OnNewBindings', self.OnNewBindings, self)
	env:RegisterSafeCallback('Settings/clusterFullStateModifier', self.OnDriverChanged, self)
	db:RegisterSafeCallback('OnModifierChanged', self.OnDriverChanged, self)

	self:OnDriverChanged()
	self:RegisterPageResponse([[
		local newstate = ...;
		self:ChildUpdate('actionpage', newstate)
	]])
end

function CPClusterBar:SetProps(props)
	self:SetDynamicProps(props)
	self:UpdateClusters(props.children or {})
	CPActionBar.OnDriverChanged(self)
	CPActionBar.OnHierarchyChanged(self)
end

function CPClusterBar:OnPropsUpdated()
	self:SetProps(self.props)
end

function CPClusterBar:OnNewBindings(bindings)
	if not env:IsActive(self) then return end;
	for buttonID, set in pairs(bindings) do
		env:Map(CLUSTER_HANDLE, buttonID, function(cluster)
			if ( cluster:GetParent() == self ) then
				cluster:SetBindings(set)
			end
		end)
	end
	self:RunAttribute(env.Attributes.OnPage, self:GetAttribute('actionpage'))
	self:RunDriver('modifier')
end

function CPClusterBar:OnDriverChanged()
	local driver = env('clusterFullStateModifier') and env.Const.Cluster.ModDriver
		or db('Gamepad/Index/Modifier/Driver');
	self:RegisterModifierDriver(driver, [[
		self:SetAttribute('state', newstate)
		control:ChildUpdate('state', newstate)
		cursor::OwnerChanged(self:GetName())
	]])
end

function CPClusterBar:UpdateClusters(clusters)
	self:OnRelease()
	for buttonID, props in pairs(clusters) do
		local cluster = env:Acquire(CLUSTER_HANDLE, buttonID, self)
		if ( cluster:GetParent() ~= self ) then
			cluster:SetParent(self)
		end
		cluster:Show()
		cluster:SetProps(props)
	end
end

function CPClusterBar:OnRelease()
	self:UnregisterVisibilityDriver()
	env:Map(CLUSTER_HANDLE, nil, function(cluster)
		if ( cluster:GetParent() == self ) then
			env:Release(cluster)
		end
	end)
end

function CPClusterBar:GetSnapSize()
	return env.Const.Cluster.SnapPixels * 4;
end

---------------------------------------------------------------
-- Cluster bar factory
---------------------------------------------------------------

env:AddFactory(CLUSTER_BAR, function(id)
	local frame = CreateFrame('Frame', env.MakeID('ConsolePortBar%s', id), env.Manager, 'CPClusterBar')
	frame:OnLoad()
	return frame;
end, env.Interface.Cluster)

env:AddFactory(CLUSTER_HANDLE, function(id, parent)
	local buttons = {};
	local cluster = CPAPI.Proxy({buttons = buttons}, CPAPI.Proxy(buttons, Cluster))

	for modifier, layoutData in pairs(ClusterLayout) do
		local name = env.MakeID('CPB_%s_%s', id, modifier)
		local button = env:Acquire(CLUSTER_BUTTON, name, id, modifier, parent, layoutData)
		cluster.buttons[modifier] = button;
	end
	cluster:OnLoad(id, parent)
	return cluster;
end, env.Interface.ClusterHandle)

env:AddFactory(CLUSTER_BUTTON, function(id, buttonID, modifier, parent, layoutData)
	local button = Mixin(env.LAB:CreateButton(buttonID, id, parent, env.Button:GetConfig()), Button)
	env.LIB.SkinUtility.PreventSkinning(button)
	for i, hotkeyData in ipairs(layoutData.Hotkey) do
		local hotkeyID = env.MakeID('%s_%s_%d', id, modifier, i)
		local hotkey = Mixin(CreateFrame('Frame', hotkeyID, button), env.ProxyHotkey)
		hotkey.icon = hotkey:CreateTexture(nil, 'OVERLAY', nil, 7)
		hotkey.icon:SetAllPoints()
		hotkey:OnLoad(buttonID, unpack(hotkeyData))
		button['Hotkey'..i] = hotkey;
	end
	if ( layoutData.Shadow ) then
		button.Shadow = env:Acquire(CLUSTER_SHADOW, buttonID, parent, button, layoutData.Shadow)
	end
	button:OnLoad(modifier, layoutData)
	return button;
end)

env:AddFactory(CLUSTER_SHADOW, function(_, parent, owner, layoutData)
	local shadow = Mixin(parent:CreateTexture(nil, 'BACKGROUND', nil, 7), Shadow)
	shadow:OnLoad(owner, unpack(layoutData))
	return shadow;
end)

env:RegisterCallbacks(function(self)
	local style = self.Const.Cluster.BorderStyle[self('clusterBorderStyle')];
	for key, texture in pairs(style) do
		self.Const.Cluster.AdjustTextures[NOMOD][key] = texture;
	end
	self:Map(CLUSTER_HANDLE, nil, function(cluster)
		cluster:GetMainButton():Skin(true)
	end)
end, env, 'OnDataLoaded', 'Settings/clusterBorderStyle')