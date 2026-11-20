local env, db = CPAPI.GetEnv(...)
---------------------------------------------------------------
local NOMOD = env.Const.Cluster.ModNames();
local CLUSTER_BAR, CLUSTER_HANDLE, CLUSTER_BUTTON, CLUSTER_SHADOW = env.Const.Cluster.Types();
local CLUSTER_LAYOUT = env.Const.Cluster.Layout;
local GOLD_SHAPES    = env.Const.Cluster.GoldShapes;
-- Outward axis and the side occupied by Shift in the original cluster.
local FLYOUT_AXES = {
	UP    = { 0;  1; -1;};
	RIGHT = { 1;  0;  1;};
	DOWN  = { 0; -1;  1;};
	LEFT  = {-1;  0;  1;};
};
---------------------------------------------------------------
local Cluster = CreateFromMixins(env.DynamicWidgetMixin, env.MovableWidgetMixin);
---------------------------------------------------------------

function Cluster:OnLoad(buttonID, parent)
	self.buttonID = buttonID;
	self.header   = parent;
	-- Keep the saved position and mover on the configured footprint.
	self.anchor = CreateFrame('Frame', nil, parent);
	self.anchor:SetFrameLevel(self:GetMainButton():GetFrameLevel())
	self:OnVariableChanged()
	env:RegisterCallbacks(self.OnVariableChanged, self,
		'Settings/borderColor',
		'Settings/disableDND'
	);
end

function Cluster:OnVariableChanged()
	self:SetBorderColor(env:GetColor('borderColor'))
	for _, button in self:Enumerate() do
		button:DisableDragNDrop(env('disableDND'))
	end
end

function Cluster:Enumerate()
	return pairs(self.buttons)
end

function Cluster:Show()
	self.anchor:Show()
	for _, button in self:Enumerate() do
		-- Preset switches release cached buttons from the widget registry.
		env:Acquire(CLUSTER_BUTTON, button:GetName())
		button:ToggleShown(true)
	end
end

local function hideClusterButton(button)
	button:ToggleShown(false)
end

function Cluster:Hide()
	self.anchor:Hide()
	for _, button in self:Enumerate() do
		env:Release(button, hideClusterButton)
	end
end

function Cluster:SetPoint(...)
	local point, _, _, x, y = ...;
	self.anchor:ClearAllPoints()
	if ( point and x and y ) then
		-- Preset changes clear anchors on cached buttons as well as the handle.
		local main = self:GetMainButton();
		main:ClearAllPoints()
		main:SetPoint('CENTER', self.anchor, 'CENTER')
		return self.anchor:SetPoint(...)
	end
end

function Cluster:ClearAllPoints()
	self.anchor:ClearAllPoints()
end

local function layoutFlyout(button, main, size, shape)
	local data = button.layoutData;
	local axes = shape and FLYOUT_AXES[button.direction];
	if axes then
		-- Convert outward and sideways offsets to the cluster's screen direction.
		local x, y, shiftSide = unpack(axes);
		local isMiddle       = data.Prefix == 'M3';
		local outward        = isMiddle and shape.Middle or shape.Outward;
		local side           = isMiddle and 0 or shape.Side * (data.Prefix == 'M1' and shiftSide or -shiftSide);
		button:ClearAllPoints()
		button:SetPoint('CENTER', main, 'CENTER', size * (x * outward + y * side), size * (y * outward - x * side))
		return size * shape.Size;
	end
	local anchor = data[button.direction];
	if anchor then
		local point, relativePoint, x, y = unpack(anchor);
		local offset = data.Offset or 1;
		button:ClearAllPoints()
		button:SetPoint(point, main, relativePoint, x * offset, y * offset)
	end
	return size * data.Size;
end

function Cluster:SetSize(size)
	local main  = self:GetMainButton();
	local shape = GOLD_SHAPES[env('clusterDesign')];
	self.anchor:SetSize(size, size)
	if ( shape and shape.MainHitInset ) or ( main.clusterShape and main.clusterShape.MainHitInset ) then
		local inset = size * (shape and shape.MainHitInset or 0);
		main:SetHitRectInsets(inset, inset, inset, inset)
	end
	if ( main.Hotkey1 and (shape or main.clusterShape) ) then
		main.Hotkey1:ClearAllPoints()
		if shape then
			main.Hotkey1:SetPoint('CENTER', 0, size * 0.30)
		else
			main.Hotkey1:SetPoint(unpack(main.layoutData.Hotkey[1][3]))
		end
	end
	for modifier, button in self:Enumerate() do
		local buttonSize = modifier == NOMOD and size or layoutFlyout(button, main, size, shape);
		button.clusterShape = shape;
		button:SetSize(buttonSize, buttonSize)
		button:UpdateClusterSkin()
	end
end

function Cluster:SetBorderColor(color)
	for _, button in self:Enumerate() do
		button:SetBorderColor(color)
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
	self.anchor:SetParent(parent)
	for _, button in self:Enumerate() do
		button:NewHeader(parent) -- TODO: do we need to unwrap the LAB button scripts?
	end
end

function Cluster:SetDirection(direction)
	for modifier, button in self:Enumerate() do
		button.clusterDirection = direction;
		if modifier == NOMOD then
			button:SetAttribute('flyoutDirection', 'DOWN')
		else
			button:SetAttribute('flyoutDirection', direction)
			button.direction = direction;
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
	self:SetSize(props.size)
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

function Cluster:GetMoveTarget()
	return self.anchor;
end

Cluster.GetSnapSize = CPAPI.Static(env.Const.Cluster.SnapPixels);

---------------------------------------------------------------
local Shadow = {};
local SHAPED_SHADOW_Y_OFFSET = 3;
---------------------------------------------------------------

function Shadow:OnLoad(owner, relativeSize, alpha, texture, point)
	local update = GenerateClosure(self.Update, self)
	self.owner        = owner;
	self.point        = point;
	self.relativeSize = relativeSize;
	self.baseTexture  = texture;
	self:SetAlpha(alpha)
	self:SetTexture(texture)
	owner:HookScript('OnShow', update)
	owner:HookScript('OnHide', update)
	owner:HookScript('OnSizeChanged', update)
end

function Shadow:SetShapeTexture(texture)
	if ( self.shapeTexture == texture ) then return end;
	self.shapeTexture = texture;
	self:SetTexture(texture or self.baseTexture)
	self:Update()
end

function Shadow:Update()
	local size = self.owner:GetSize() * self.relativeSize;
	local pt, x, y = unpack(self.point)
	self:SetShown(self.owner:IsShown())
	self:SetParent(self.owner:GetParent())
	self:SetSize(size, size)
	self:SetPoint(pt, self.owner, pt, x, y + (self.shapeTexture and SHAPED_SHADOW_Y_OFFSET or 0))
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
	self:RegisterModifierDriver(db('Gamepad/Index/Modifier/LayeredDriver')..driver, [[
		self:SetAttribute('state', newstate)
		control:ChildUpdate('state', newstate)
		cursor::OwnerChanged(self:GetName())
	]], db.Layers:GetActiveLayer())
end

function CPClusterBar:UpdateClusters(clusters)
	self:OnRelease()
	for buttonID, props in pairs(clusters) do
		local cluster = env:Acquire(CLUSTER_HANDLE, buttonID, self)
		if ( cluster:GetParent() ~= self ) then
			cluster:SetParent(self)
		end
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
	local cluster = CPAPI.Proxy({buttons = buttons;}, CPAPI.Proxy(buttons, Cluster))

	for modifier, layoutData in pairs(CLUSTER_LAYOUT) do
		local name = env.MakeID('CPB_%s_%s', id, modifier)
		local button = env:Acquire(CLUSTER_BUTTON, name, id, modifier, parent, layoutData)
		cluster.buttons[modifier] = button;
	end
	cluster:OnLoad(id, parent)
	return cluster;
end, env.Interface.ClusterHandle)

env:AddFactory(CLUSTER_SHADOW, function(_, parent, owner, layoutData)
	local shadow = Mixin(parent:CreateTexture(nil, 'BACKGROUND', nil, 7), Shadow)
	shadow:OnLoad(owner, unpack(layoutData))
	return shadow;
end)

env:RegisterSafeCallback('Settings/clusterDesign', function(self)
	self:Map(CLUSTER_HANDLE, nil, function(cluster)
		cluster:SetSize(cluster.props.size)
	end)
end, env)
