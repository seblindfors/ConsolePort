---------------------------------------------------------------
-- Scroll management
---------------------------------------------------------------
-- Handles centered, interpolated and manual scrolling
-- of scroll frames and scroll boxes. The keyword "super" is
-- used to refer to a candidate scroll frame or scroll box that
-- is above the node in the hierarchy by one or more levels.

local Scroll, Node, Clamp, env, db =
	CreateFrame('Frame', '$parentUIScrollHandler', ConsolePort),
	LibStub('ConsolePortNode'),
	Clamp, CPAPI.GetEnv(...);

---------------------------------------------------------------
-- Auto-scrolling
---------------------------------------------------------------
function Scroll:To(node, super, prev, force)
	local nodeX, nodeY = Node.GetCenter(node)
	local scrollX, scrollY = super:GetCenter()
	if nodeY and scrollY then

		if self:IsValidScrollFrame(super) then
			local prevX, prevY = nodeX, nodeY;
			if prev then
				prevX, prevY = Node.GetCenter(prev)
			end

			local current, range = super:GetVerticalScroll(), super:GetVerticalScrollRange();
			local target = self:GetVerticalScrollTarget(current, scrollY, nodeY, prevY, force, range)
			self:Interpolate(super, current, target, GenerateClosure(super.SetVerticalScroll, super))

		elseif self:IsValidScrollBox(super) then
			local index = self:GetScrollBoxElementDataIndex(super, node)
			if index then
				return super:ScrollToElementDataIndex(index)
			end
		end
	end
end

function Scroll:GetVerticalScrollTarget(currVert, scrollY, nodeY, prevY, force, maxVert)
	return Clamp(self:GetScrollTarget(currVert, scrollY, nodeY, prevY, force), 0, maxVert)
end

function Scroll:GetScrollTarget(curr, scrollPos, nodePos, prevPos, force)
	local new = curr + (scrollPos - nodePos)
	return force and new or (new > curr) == (nodePos > prevPos) and curr or new;
end

function Scroll:IsValidScrollFrame(super)
	-- HACK: make sure this isn't a hybrid scroll frame
	return super:IsObjectType('ScrollFrame') and
		super:GetScript('OnLoad') ~= HybridScrollFrame_OnLoad;
end

function Scroll:IsValidScrollBox(super)
	return rawget(super, 'ScrollToElementDataIndex')
end

function Scroll:GetImmediateScrollTargetNode(super, node)
	local scrollTarget = super:GetScrollTarget()
	while ( node and node:GetParent() ~= scrollTarget ) do
		node = node:GetParent()
	end
	return node;
end

function Scroll:GetScrollBoxElementDataIndex(super, node)
	node = self:GetImmediateScrollTargetNode(super, node)
	if not node then return end;
	local getter = rawget(node, 'GetElementDataIndex')
	if not getter then return end;
	local ok, index = pcall(getter, node)
	return ok and index;
end

---------------------------------------------------------------
-- Interpolated scrolling
---------------------------------------------------------------
function Scroll:Interpolate(super, current, target, setter)
	local active, interpolators = self:GetPools()
	if active[super] then
		interpolators:Release(active[super])
	end
	local interpolator = self.Interpolators:Acquire()
	interpolator:Interpolate(current, target, .11, setter, function()
		if interpolators:Release(interpolator) then
			active[super] = nil;
		end
	end)
	active[super] = interpolator;
end

function Scroll:GetPools()
	if not self.Active then
		self.Active = {};
		self.Interpolators = CreateObjectPool(
			GenerateClosure(CreateInterpolator, InterpolatorUtil.InterpolateEaseOut),
			function(_, interpolator) interpolator:Cancel() end
		);
	end
	return self.Active, self.Interpolators;
end


---------------------------------------------------------------
-- Scroll controller
---------------------------------------------------------------
local ScrollControllerPrimitive, ScrollProxyMixin = ScrollControllerMixin, {};

function ScrollProxyMixin:Execute()
	local parent = self:GetParent();
	local super = parent.ActiveController;
	if super then
		env.ExecuteScript(super, 'OnMouseWheel', self.Delta)
	end
end

function ScrollProxyMixin:OnClick(_, down)
	if down then
		self:Execute()
		self.timer = -db('UIholdRepeatDelayFirst');
		self.ticker = db('UIholdRepeatDelay');
	end
	self:SetScript('OnUpdate', down and self.OnUpdate or nil)
end

function ScrollProxyMixin:OnUpdate(elapsed)
	self.timer = self.timer + elapsed;
	if self.timer > self.ticker then
		self.timer = 0;
		self:Execute()
	end
end

for direction, ProxyButton in pairs({
	Up   = Mixin(CreateFrame('Button', '$parentProxyUp', Scroll),   ScrollProxyMixin, { Delta = ScrollControllerPrimitive.Directions.Increase });
	Down = Mixin(CreateFrame('Button', '$parentProxyDown', Scroll), ScrollProxyMixin, { Delta = ScrollControllerPrimitive.Directions.Decrease });
}) do Scroll[direction] = ProxyButton;
	ProxyButton:SetScript('OnClick', ProxyButton.OnClick)
	ProxyButton:RegisterForClicks('AnyUp', 'AnyDown')
end

function Scroll:GetScrollButtonsForController(node, super)
	if self:IsValidScrollController(super) then
		self.ActiveController = super;
		return self.Up, self.Down;
	end
	-- We're at most two levels deep (thumb or up/down buttons),
	-- so we want to find the first scroll controller in the hierarchy.
	local depth, parent = 2, node:GetParent();
	while parent and depth > 0 do
		if self:IsValidScrollController(parent) then
			self.ActiveController = parent;
			return self.Up, self.Down;
		end
		depth, parent = depth - 1, parent:GetParent();
	end
	self.ActiveController = nil;
end

function Scroll:IsValidScrollController(super)
	return super and super:GetScript('OnMouseWheel') == ScrollControllerPrimitive.OnMouseWheel;
end