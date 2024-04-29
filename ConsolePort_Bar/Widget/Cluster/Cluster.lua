local _, env, db = ...; db = env.db;
---------------------------------------------------------------
local NOMOD, SHIFT, CTRL, CTRL_SHIFT, ALT = env.ClusterConstants.ModNames();
local CLUSTER_BAR, CLUSTER_HANDLE, CLUSTER_BUTTON, CLUSTER_HOTKEY, CLUSTER_SHADOW = env.ClusterConstants.Types();
local ClusterLayout = env.ClusterConstants.Layout;
---------------------------------------------------------------
local Cluster = {};
---------------------------------------------------------------

function Cluster:OnLoad(buttonID, parent)
	self.buttonID = buttonID;
	self.header   = parent;
	self:OnVariableChanged()
	env:RegisterCallbacks(self.OnVariableChanged, self,
		'Settings/swipeColor'
	);
end

function Cluster:OnVariableChanged()
	self:SetSwipeColor(env:GetColor('swipeColor'))
end

function Cluster:Enumerate()
	return pairs(self.buttons)
end

function Cluster:Show()
	for _, button in self:Enumerate() do
		button:Show()
	end
end

function Cluster:Hide()
	for _, button in self:Enumerate() do
		button:Hide()
	end
end

function Cluster:SetPoint(...)
	local main = self:GetMainButton();
	local p, x, y = ...;
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

function Cluster:SetConfig(config)
	self:SetPoint(unpack(config.point))
	self:SetDirection(config.dir)
	self:SetSize(config.size)
end

function Cluster:SetBindings(bindings)
	for modifier, button in self:Enumerate() do
		button:SetBindings(bindings[modifier], bindings)
	end
end

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
local Icon = {}; -- LAB custom type dynamic icon textures
---------------------------------------------------------------

function Icon:SetTexture(texture, ...)
	if (type(texture) == 'function') then
		return texture(self, self:GetParent(), ...)
	end
	return getmetatable(self).__index.SetTexture(self, texture, ...)
end

local function GetClusterTextureForButtonID(buttonID)
	local texture = db('Icons/64/'..buttonID)
	if texture then
		return GenerateClosure(function(set, texture, obj)
			set(obj, texture)
		end, CPAPI.SetTextureOrAtlas, {texture, db.Gamepad.UseAtlasIcons})
	end
	return env.GetAsset([[Textures\Icons\Unbound]]);
end

---------------------------------------------------------------
local Cooldown = {};
---------------------------------------------------------------

function Cooldown:OnLoad(modifier)
	self.text = self:GetRegions()
	if ( modifier ~= NOMOD ) then
		-- Flyout cluster buttons should have smaller CD font
		local file, height, flags = self.text:GetFont()
		self.text:SetFont(file, height * 0.75, flags)
	end
end

function Cooldown:SetHideCountdownNumbers(...)
	self:GetParent().countdownNumbersHidden = ...;
	getmetatable(self).__index.SetHideCountdownNumbers(self, ...)
end

function Cooldown:SetCooldown(...)
	self:GetParent():OnCooldownSet(self, ...)
	getmetatable(self).__index.SetCooldown(self, ...)
end

function Cooldown:Clear(...)
	self:GetParent():OnCooldownClear(self, ...)
	getmetatable(self).__index.Clear(self, ...)
end

function Cooldown:Hide()
	self:GetParent():OnCooldownClear(self)
	getmetatable(self).__index.Hide(self)
end

---------------------------------------------------------------
local FlyoutButton = { FadeIn = db.Alpha.FadeIn, FadeOut = db.Alpha.FadeOut, visibility = 0};
---------------------------------------------------------------
do  -- Visibility update closures
	local function UpdateFlags(flag, flags, predicate)
		return predicate and bit.bor(flags, flag) or bit.band(flags, bit.bnot(flag))
	end

	FlyoutButton.VisibilityFlags = {
		AlwaysShow    = 0x01;
		OnCooldown    = 0x02;
		OverlayActive = 0x04;
		MouseOver     = 0x08;
		ShowGrid      = 0x10;
	};

	FlyoutButton.VisibilityState = {};
	for flagName, flagValue in pairs(FlyoutButton.VisibilityFlags) do
		FlyoutButton.VisibilityState[flagName] = GenerateClosure(UpdateFlags, flagValue);
	end

	FlyoutButton.VisibilityEvents = {
		ACTIONBAR_SHOWGRID = { FlyoutButton.VisibilityState.ShowGrid, true  };
		ACTIONBAR_HIDEGRID = { FlyoutButton.VisibilityState.ShowGrid, false };
	};
end

function FlyoutButton:OnShowAll(showAll)
	self:UpdateFade(self.VisibilityState.AlwaysShow, showAll)
end

function FlyoutButton:OnShowOverlay()
	self:UpdateFade(self.VisibilityState.OverlayActive, true)
end

function FlyoutButton:OnHideOverlay()
	self:UpdateFade(self.VisibilityState.OverlayActive, false)
end

function FlyoutButton:OnMouseMotionFocus()
	self:UpdateFade(self.VisibilityState.MouseOver, true)
end

function FlyoutButton:OnMouseMotionClear()
	self:UpdateFade(self.VisibilityState.MouseOver, false)
end

function FlyoutButton:OnVisibilityEvent(event)
	local eventClosure = self.VisibilityEvents[event];
	if eventClosure then
		self:UpdateFade(unpack(eventClosure))
	end
end

function FlyoutButton:OnLoad(modifier)
	env:RegisterCallback('Settings/clusterShowAll', self.OnShowAll, self)
	env:RegisterCallback('Settings/clusterShowFlyoutIcons', self.ToggleHotkeys, self)

	self:OnShowAll(env('clusterShowAll'))
	self.OnCooldownClearCallback = GenerateClosure(self.OnCooldownClear, self)
	Mixin(self.cooldown, Cooldown):OnLoad(modifier)
	self:HookScript('OnEnter', self.OnMouseMotionFocus)
	self:HookScript('OnLeave', self.OnMouseMotionClear)
	self:HookScript('OnEvent', self.OnVisibilityEvent)
	for event in pairs(self.VisibilityEvents) do
		self:RegisterEvent(event)
	end
end

function FlyoutButton:OnCooldownSet(cooldown, _, duration, enable)
	local onCooldown = (cooldown and duration and duration > 0);
	local hotkey1, hotkey2 = self.Hotkey1, self.Hotkey2;
	if hotkey1 then hotkey1:SetShown(not onCooldown) end;
	if hotkey2 then hotkey2:SetShown(not onCooldown) end;
	cooldown:HookScript('OnCooldownDone', self.OnCooldownClearCallback)
	self:UpdateFade(self.VisibilityState.OnCooldown, onCooldown)
end

function FlyoutButton:OnCooldownClear()
	self:ToggleHotkeys(env('clusterShowFlyoutIcons'))
	self:UpdateFade(self.VisibilityState.OnCooldown, false)
end

function FlyoutButton:SetAlpha(alpha, force)
	if force then return getmetatable(self).__index.SetAlpha(self, alpha) end
end

function FlyoutButton:UpdateFade(closure, state)
	self.visibility = closure(self.visibility, state);
	local fadeOut = self.visibility == 0;
	if fadeOut then
		self:FadeOut(0.25, self:GetAlpha())
	else
		self:FadeIn(0.25, self:GetAlpha())
	end
end

---------------------------------------------------------------
local MainButton = {};
---------------------------------------------------------------

function MainButton:OnLoad()
	env:RegisterCallback('Settings/clusterShowMainIcons', self.ToggleHotkeys, self)
	self:ToggleHotkeys(env('clusterShowMainIcons'))
end

---------------------------------------------------------------
local Button = {};
---------------------------------------------------------------

function Button:OnLoad(modifier, layoutData)
	self:SetAttribute(CPAPI.SkipHotkeyRender, true)
	self:SetAttribute('id', self.id)
	self:SetAttribute('mod', modifier)
	self.mod = modifier;
	self.layoutData = layoutData;
	self:UpdateSkin()
	if ( layoutData.Level ) then
		self:SetFrameLevel(layoutData.Level)
	end
	Mixin(self.icon, Icon)
	Mixin(self, modifier == NOMOD and MainButton or FlyoutButton):OnLoad(modifier)
end

function Button:ToggleHotkeys(enabled)
	local hotkey1, hotkey2 = self.Hotkey1, self.Hotkey2;
	if hotkey1 then hotkey1:SetShown(enabled) end;
	if hotkey2 then hotkey2:SetShown(enabled) end;
end

function Button:UpdateLocal(force)
	self:Skin(force)
end

function Button:UpdateSkin()
	self.Skin = env.LIB.Skin.ClusterBar[self.mod] or nop; -- Skins.lua
end

function Button:GetOverlayColor()
	return env:GetColorRGBA('procColor')
end

function Button:SetBindings(primary, allBindings)
	if ( self.mod == NOMOD ) then
		for modifier, binding in pairs(allBindings) do
			self:RefreshBinding(modifier, binding)
		end
	else
		for modifier, binding in pairs(allBindings) do
			if ( modifier ~= self.mod ) then
				self:RefreshBinding(modifier, primary)
			end
		end
		self:RefreshBinding(self.mod, allBindings[NOMOD])
		self:RefreshBinding(ALT..self.mod, allBindings[ALT..self.mod])
	end
end

function Button:RefreshBinding(modifier, binding)
	local actionID = binding and db('Actionbar/Binding/'..binding)
	local stateType, stateID;
	if actionID then
		stateType, stateID = self:SetActionBinding(modifier, actionID)
	elseif binding and binding:len() > 0 then
		stateType, stateID = self:SetXMLBinding(binding)
	else
		stateType, stateID = self:SetEligbleForRebind(modifier)
	end
	self:SetState(modifier, stateType, stateID)
end

function Button:SetActionBinding(modifier, actionID)
	if ( self.mod == NOMOD ) then
		env.Manager:RegisterOverride(self, modifier..self.id, self:GetName())
	end
	return 'action', actionID;
end

function Button:SetXMLBinding(binding)
	local info = env.GetXMLBindingInfo(binding)
	return 'custom', {
		tooltip = info.tooltip or env.GetBindingName(binding);
		texture = info.texture or env.GetBindingIcon(binding) or GetClusterTextureForButtonID(self.id);
		func    = function() end; -- TODO
	}
end

function Button:SetEligbleForRebind(modifier)
	return 'custom', {
		tooltip = 'Click to bind this button';
		texture = GetClusterTextureForButtonID(self.id);
		func    = print; -- TODO
	};
end

---------------------------------------------------------------
local Hotkey = {};
---------------------------------------------------------------

function Hotkey:OnLoad(buttonID, iconSize, atlasSize, point, controlID)
	self.controlID = controlID or buttonID;
	self.iconSize  = { iconSize, iconSize };
	self.atlasSize = { atlasSize, atlasSize };
	self:SetPoint(unpack(point))
	self:SetAlpha(not controlID and 1 or 0.75)
	self:OnIconsChanged()
	db:RegisterCallback('OnIconsChanged', self.OnIconsChanged, self)
end

function Hotkey:SetTexture(...)
	self.icon:SetTexture(...)
end

function Hotkey:SetAtlas(...)
	self.icon:SetAtlas(...)
end

function Hotkey:OnIconsChanged()
	self.iconID = db.UIHandle:GetUIControlBinding(self.controlID)
	db.Gamepad.SetIconToTexture(self, self.iconID, 32, self.iconSize, self.atlasSize)
end

---------------------------------------------------------------
CPClusterBar = CreateFromMixins(CPActionBar);
---------------------------------------------------------------

function CPClusterBar:OnLoad()
	CPActionBar.OnLoad(self)
	env:RegisterSafeCallback('OnNewBindings', self.OnNewBindings, self)
	env:RegisterCallback('Settings/procColor', self.OnVariableChanged, self)
	self.ProcAnimation:SetSize(200, 200)
	self.ProcAnimation:SetAnimationSpeedMultiplier(0.5)
	self:RegisterModifierDriver(env.ClusterConstants.ModDriver, [[
		self:SetAttribute('state', newstate)
		control:ChildUpdate('state', newstate)
		cursor::ActionPageChanged()
	]])
end

function CPClusterBar:SetConfig(config)
	self:SetCommonConfig(config)
	self:UpdateClusters(config.buttons or {})
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
	self:RunDriver('modifier')
end

function CPClusterBar:UpdateClusters(clusters)
	self:OnRelease()
	for buttonID, config in pairs(clusters) do
		local cluster = env:Acquire(CLUSTER_HANDLE, buttonID, self)
		if ( cluster:GetParent() ~= self ) then
			cluster:SetParent(self)
		end
		cluster:SetConfig(config)
	end
end

function CPClusterBar:OnRelease()
	env:Map(CLUSTER_HANDLE, nil, function(cluster)
		if ( cluster:GetParent() == self ) then
			env:Release(cluster)
		end
	end)
end

function CPClusterBar:OnVariableChanged()
	self.ProcAnimation:SetVertexColor(env:GetColorRGBA('procColor'))
end

---------------------------------------------------------------
do -- Cluster bar factory
---------------------------------------------------------------

env:AddFactory(CLUSTER_BAR, function(id)
	local frame = CreateFrame('Frame', 'ConsolePortBar'..id, env.Manager, 'CPClusterBar')
	frame:OnLoad()
	return frame;
end)

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
end)

env:AddFactory(CLUSTER_BUTTON, function(id, buttonID, modifier, parent, layoutData)
	local button = Mixin(env.LAB:CreateButton(buttonID, id, parent, env.ClusterConstants.LABConfig), Button)
	env.LIB.SkinUtility.PreventSkinning(button)
	for i, hotkeyData in ipairs(layoutData.Hotkey) do
		local hotkeyID = env.MakeID('%s_%s_%d', id, modifier, i)
		button['Hotkey'..i] = env:Acquire(CLUSTER_HOTKEY, hotkeyID, button, hotkeyData)
	end
	if ( layoutData.Shadow ) then
		button.Shadow = env:Acquire(CLUSTER_SHADOW, buttonID, parent, button, layoutData.Shadow)
	end
	button:OnLoad(modifier, layoutData)
	return button;
end)

env:AddFactory(CLUSTER_HOTKEY, function(_, parent, layoutData)
	local hotkey = Mixin(CreateFrame('Frame', nil, parent), Hotkey)
	hotkey.icon = hotkey:CreateTexture(nil, 'OVERLAY', nil, 7)
	hotkey.icon:SetAllPoints()
	hotkey:OnLoad(parent.id, unpack(layoutData))
	return hotkey;
end)

env:AddFactory(CLUSTER_SHADOW, function(_, parent, owner, layoutData)
	local shadow = Mixin(parent:CreateTexture(nil, 'BACKGROUND', nil, 7), Shadow)
	shadow:OnLoad(owner, unpack(layoutData))
	return shadow;
end)

end -- Cluster bar factory