local db = select(2, ...)
---------------------------------------------------------------
-- Gradient mixin
---------------------------------------------------------------
CPGradientMixin = {};

function CPGradientMixin:OnLoad()
	self.VertexColor  = CPAPI.GetClassColorObject()
	self.VertexValid  = CreateColor(1, .81, 0, 1)
	self.VertexOrient = 'VERTICAL';
end

function CPGradientMixin:SetGradientDirection(direction)
	assert(direction == 'VERTICAL' or direction == 'HORIZONTAL', 'Valid: VERTICAL, HORIZONTAL')
	self.VertexOrient = direction;
end

function CPGradientMixin:GetClassColor()
	return self.VertexColor:GetRGB()
end

function CPGradientMixin:GetValidColor()
	return self.VertexColor:GetRGB()
end

function CPGradientMixin:GetMixGradient(...)
	return CPAPI.GetReverseMixColorGradient(self.VertexOrient, ...)
end

function CPGradientMixin:GetReverseMixGradient(...)
	return CPAPI.GetMixColorGradient(self.VertexOrient, ...)
end

function CPGradientMixin:GetFadeGradient(...)
	return self.VertexOrient, 1, 1, 1, 0, ...;
end


---------------------------------------------------------------
-- Frame background
---------------------------------------------------------------
CPBackgroundMixin = CreateFromMixins(BackdropTemplateMixin);

function CPBackgroundMixin:OnLoad()
	local r, g, b = CPAPI.GetWebColor(CPAPI.GetClassFile()):GetRGB()
	self:HookScript('OnSizeChanged', self.OnBackdropSizeChanged)
	self.Background = self:CreateTexture(nil, 'BACKGROUND', nil, 2)
	self.Rollover   = self:CreateTexture(nil, 'BACKGROUND', nil, 3)
	self.Rollover:SetAllPoints(self.Background)
	self.Rollover:SetTexture(CPAPI.GetAsset([[Textures\Frame\Backdrop_Vertex_White]]))
	CPAPI.SetGradient(self.Rollover, 'VERTICAL',
		{r = r*0.5, g = g*0.5, b = b*0.5, a = 1},
		{r = r*0.5, g = g*0.5, b = b*0.5, a = 0}
	)
	self:SetOriginTop(true)
	self:CreateBackground(2048, 2048, 2048, 2048, CPAPI.GetAsset([[Art\Background\%s]]):format(CPAPI.GetClassFile()))
end

function CPBackgroundMixin:GetBGOffset(point, size)
	return ((point / 2) / size)
end

function CPBackgroundMixin:GetBGFraction(point, size)
	return (point / size)
end

function CPBackgroundMixin:SetBackgroundDimensions(w, h, x, y)
	assert(self.Background, 'Frame is missing background.')
	self.Background.maxWidth = w;
	self.Background.maxHeight = h;
	self.Background.sizeX = x;
	self.Background.sizeY = y;
end

function CPBackgroundMixin:SetOriginTop(enabled)
	self.originTop = enabled;
end

function CPBackgroundMixin:OnAspectRatioChanged()
	local maxWidth, maxHeight = self.Background.maxWidth, self.Background.maxHeight;
	local sizeX, sizeY = self.Background.sizeX, self.Background.sizeY;
	local width, height = self:GetSize()

	local maxCoordX, maxCoordY, centerCoordX, centerCoordY =
		self:GetBGFraction(maxWidth, sizeX),
		self:GetBGFraction(maxHeight, sizeY),
		self:GetBGOffset(maxWidth, sizeX),
		self:GetBGOffset(maxHeight, sizeY);

	local top, bottom, left, right = 0, 1, 0, 1;
	if width > height then
		local newHeight = self:GetBGFraction(height, width) * maxWidth;
		if self.originTop then
			top, left, right = 0, 0, maxCoordX;
			bottom = self:GetBGFraction(newHeight, sizeY)
		else
			local offset = self:GetBGOffset(newHeight, sizeY)
			left, right = 0, maxCoordX;
			top = centerCoordY - offset;
			bottom = centerCoordY + offset;
		end
	end
	if height > width or (top < 0 or bottom < 0) then
		local newWidth = self:GetBGFraction(width, height) * maxHeight;
		local offset = self:GetBGOffset(newWidth, sizeX)
		top, bottom = 0, maxCoordY;
		left = centerCoordX - offset;
		right = centerCoordX + offset;
	end
	self.Background:SetTexCoord(left, right, top, bottom)
end

function CPBackgroundMixin:SetBackgroundInsets(enabled, value)
	self.Background:ClearAllPoints()
	if enabled then
		local inset = value or 8;
		self.Background:SetPoint('TOPLEFT', inset, -inset)
		self.Background:SetPoint('BOTTOMRIGHT', -inset, inset)
	else
		self.Background:SetAllPoints()
	end
end

function CPBackgroundMixin:CreateBackground(w, h, x, y, texture)
	self.Background:SetTexture(texture)
	self:SetBackgroundDimensions(w, h, x, y)
	self:OnAspectRatioChanged()
	self:HookScript('OnShow', self.OnAspectRatioChanged)
	self:HookScript('OnSizeChanged', self.OnAspectRatioChanged)
end

function CPBackgroundMixin:SetBackgroundVertexColor(...)
	self.Background:SetVertexColor(...)
end

---------------------------------------------------------------
-- Smooth scroll
---------------------------------------------------------------
do local Scroller, Clamp = CreateFrame('Frame'), Clamp; Scroller.Frames = {};
	function Scroller:OnUpdate(elapsed)
		local current, delta, target, range;
		for frame, data in pairs(self.Frames) do
			range = frame:GetRange()
			current = frame:GetScroll()
			if abs(current - data.targetPos) < 1 then
				frame:SetScroll(data.targetPos)
				self:RemoveFrame(frame)
			else
				delta = current > data.targetPos and -1 or 1;
				target = current +
					(delta * abs(current - data.targetPos) / data.stepSize * 8)
				frame:SetScroll(Clamp(target, 0, range));
			end
		end
	end

	function Scroller:AddFrame(frame, targetPos, stepSize)
		self.Frames[frame] = {
			targetPos = targetPos;
			stepSize  = stepSize;
		};
		self:SetScript('OnUpdate', self.OnUpdate)
	end

	function Scroller:RemoveFrame(frame)
		self.Frames[frame] = nil;
		if not next(self.Frames) then
			self:SetScript('OnUpdate', nil)
		end
		return frame.OnScrollFinished and frame:OnScrollFinished()
	end

	-----------------------------------------------------------
	-- Mixin
	-----------------------------------------------------------
	CPSmoothScrollMixin = {
		MouseWheelDelta = 100;
		Horizontal = {
			GetRange  = 'GetHorizontalScrollRange';
			GetScroll = 'GetHorizontalScroll';
			SetScroll = 'SetHorizontalScroll';
			GetAnchor = 'GetLeft';
			GetElementOffsetFromAnchor = 'GetElementOffsetFromLeftAnchor';
		};
		Vertical = {
			GetRange  = 'GetVerticalScrollRange';
			GetScroll = 'GetVerticalScroll';
			SetScroll = 'SetVerticalScroll';
			GetAnchor = 'GetTop';
			GetElementOffsetFromAnchor = 'GetElementOffsetFromTopAnchor';
		};
	}

	function CPSmoothScrollMixin:SetScrollOrientation(orient)
		assert(self[orient], 'Orientation must be either Horizontal or Vertical.')
		self.ScrollOrientationSet = true;
		for alias, metaname in pairs(self[orient]) do
			self[alias] = self[metaname]
		end
	end

	function CPSmoothScrollMixin:SetDelta(delta)
		self.MouseWheelDelta = delta;
	end

	function CPSmoothScrollMixin:OnScrollMouseWheel(delta)
		local range = self:GetRange()
		local current = self.targetPos or self:GetScroll()
		local new = current - delta * self.MouseWheelDelta;

		Scroller:AddFrame(self, Clamp(new, 0, range), self.MouseWheelDelta)
	end

	function CPSmoothScrollMixin:ScrollTo(frac, steps)
		local range = self:GetRange()
		local step = range / steps;
		local new = frac <= 0 and 0 or frac >= steps and range or step * (frac - 1);
		local target = Clamp(new, 0, range)

		Scroller:AddFrame(self, target, step)
		if range > 0 then
			return target / range;
		end
	end

	function CPSmoothScrollMixin:GetElementPosition(element)
		local wrapper = self:GetScrollChild();
		return ClampedPercentageBetween(select(2, element:GetCenter()), wrapper:GetTop(), wrapper:GetBottom())
	end

	function CPSmoothScrollMixin:GetElementOffsetFromTopAnchor(element, padding)
		local getAnchor = self.GetAnchor;
		return getAnchor(self) - getAnchor(element) + self:GetScroll() + (padding or 0);
	end

	function CPSmoothScrollMixin:GetElementOffsetFromLeftAnchor(element, padding)
		local getAnchor = self.GetAnchor;
		return getAnchor(element) - getAnchor(self) + self:GetScroll() + (padding or 0);
	end

	function CPSmoothScrollMixin:ScrollToOffset(offset)
		Scroller:AddFrame(self, offset * self:GetRange(), self.MouseWheelDelta)
	end

	function CPSmoothScrollMixin:ScrollToPosition(position)
		Scroller:AddFrame(self, position, self.MouseWheelDelta)
	end

	function CPSmoothScrollMixin:ScrollToElement(element, padding)
		Scroller:AddFrame(self, Clamp(self:GetElementOffsetFromAnchor(element, padding), 0, self:GetRange()), self.MouseWheelDelta)
	end

	function CPSmoothScrollMixin:OnScrollSizeChanged(...)
		if not self.ScrollOrientationSet then return end;
		if (self:GetScroll() > self:GetRange()) then
			self:SetScroll(self:GetRange())
		end
	end
end


---------------------------------------------------------------
-- Specific button catcher with callbacks
---------------------------------------------------------------
CPButtonCatcherMixin = {};

function CPButtonCatcherMixin:OnLoad()
	self.ClosureRegistry = {};
end

function CPButtonCatcherMixin:OnGamePadButtonDown(button)
	if not self.catcherPaused then
		if self.catchAllCallback and self:IsButtonValid(button) then
			self.catchAllCallback(button)
			return self:SetPropagateKeyboardInput(false)
		elseif self.ClosureRegistry[button] then
			self.ClosureRegistry[button](button)
			return self:SetPropagateKeyboardInput(false)
		end
	end
	self:SetPropagateKeyboardInput(true)
end

function CPButtonCatcherMixin:OnKeyDown(button)
	local emulatedButton = db.Paddles:GetEmulatedButton(button)
	if emulatedButton and not self.catcherPaused then
		if self.catchAllCallback and self:IsButtonValid(emulatedButton) then
			self.catchAllCallback(emulatedButton)
			return self:SetPropagateKeyboardInput(false)
		elseif self.ClosureRegistry[emulatedButton] then
			self.ClosureRegistry[emulatedButton](emulatedButton)
			return self:SetPropagateKeyboardInput(false)
		end
	end
	self:SetPropagateKeyboardInput(true)
end

function CPButtonCatcherMixin:OnHide()
	self:ReleaseClosures()
end

function CPButtonCatcherMixin:CatchAll(callback, ...)
	self.catchAllCallback = GenerateClosure(callback, ...)
	return true;
end

function CPButtonCatcherMixin:CatchButton(button, callback, ...)
	if not button then return end;
	local closure = GenerateClosure(callback, ...)
	self.ClosureRegistry[button] = closure;
	self:ToggleInputs(true)
	return closure; -- return the event owner
end

function CPButtonCatcherMixin:FreeButton(button, ...)
	if not button then return end;
	if select('#', ...) > 0 then
		local closure = ...;
		if closure and (self.ClosureRegistry[button] ~= closure) then
			return false; -- assert event owner if supplied
		end
	end
	self.ClosureRegistry[button] = nil;
	if not next(self.ClosureRegistry) then
		self:ToggleInputs(false)
	end
	return true;
end

function CPButtonCatcherMixin:PauseCatcher()
	self.catcherPaused = true;
end

function CPButtonCatcherMixin:ResumeCatcher()
	self.catcherPaused = false;
end

function CPButtonCatcherMixin:ReleaseClosures()
	self.catchAllCallback = nil;
	self:ToggleInputs(false)
	if self.ClosureRegistry then
		wipe(self.ClosureRegistry)
	end
end

function CPButtonCatcherMixin:ToggleInputs(enabled)
	self:EnableGamePadButton(enabled)
	self:EnableKeyboard(enabled)
end

function CPButtonCatcherMixin:IsButtonValid(button)
	return CPAPI.IsButtonValidForBinding(button)
end

---------------------------------------------------------------
-- Propagation mixin
---------------------------------------------------------------
CPPropagationMixin = {};

function CPPropagationMixin:SetPropagation(enabled)
	if not InCombatLockdown() then
		self:SetPropagateKeyboardInput(enabled)
	end
end

---------------------------------------------------------------
-- Pools
---------------------------------------------------------------
local CreateFramePool, CreateObjectPool = CreateFramePool, CreateObjectPool;
---------------------------------------------------------------
-- Indexed widget pool
---------------------------------------------------------------
CPIndexPoolMixin = {};

function CPIndexPoolMixin:OnLoad()
	self.Registry = {};
end

function CPIndexPoolMixin:CreateFramePool(type, template, mixin, resetterFunc, parent)
	assert(not self.ObjectPool, 'Frame pool already exists.')
	self.ObjectPool = CreateFramePool(type, parent or self, template, resetterFunc)
	self.ObjectPoolMixin = mixin;
	return self.ObjectPool;
end

function CPIndexPoolMixin:CreateObjectPool(creationFunc, resetterFunc, mixin)
	assert(not self.ObjectPool, 'Object pool already exists.')
	self.ObjectPool = CreateObjectPool(creationFunc, resetterFunc)
	self.ObjectPoolMixin = mixin;
	return self.ObjectPool;
end

function CPIndexPoolMixin:Acquire(index)
	local widget, newObj = self.ObjectPool:Acquire()
	if newObj and self.ObjectPoolMixin then
		Mixin(widget, self.ObjectPoolMixin)
	end
	self.Registry[index] = widget;
	return widget, newObj;
end

function CPIndexPoolMixin:TryAcquireRegistered(index)
	local widget = self.Registry[index];
	if widget then
		local pool = self.ObjectPool;
		local inactiveIndex = tIndexOf(pool.inactiveObjects, widget)
		if inactiveIndex then
			pool.activeObjects[tremove(pool.inactiveObjects, inactiveIndex)] = true;
			pool.numActiveObjects = pool.numActiveObjects + 1;
		end
		return widget;
	end
	return self:Acquire(index)
end

function CPIndexPoolMixin:GetObjectByIndex(index)
	return self.Registry[index];
end

function CPIndexPoolMixin:EnumerateActive()
	return self.ObjectPool:EnumerateActive()
end

function CPIndexPoolMixin:GetNumActive()
	return self.ObjectPool:GetNumActive()
end

function CPIndexPoolMixin:GetNumVisible()
	local count = 0;
	for object in self:EnumerateActive() do
		if object:IsVisible() then
			count = count + 1;
		end
	end
	return count;
end

function CPIndexPoolMixin:ReleaseAll()
	self.ObjectPool:ReleaseAll()
end

---------------------------------------------------------------
-- Trackable widget pool
---------------------------------------------------------------
CPFocusPoolMixin = CreateFromMixins(CPIndexPoolMixin);

function CPFocusPoolMixin:OnPostHide()
	self.focusIndex = nil;
end

function CPFocusPoolMixin:GetFocusIndex()
	return self.focusIndex
end

function CPFocusPoolMixin:GetFocusWidget()
	return self.focusIndex and self.Registry[self.focusIndex]
end

function CPFocusPoolMixin:SetFocusByIndex(index)
	local old = self.focusIndex ~= index and self.focusIndex;
	self.focusIndex = index;

	local oldObj = old and self.Registry[old];
	local newObj = self.Registry[index];
	return newObj, oldObj;
end

function CPFocusPoolMixin:SetFocusByWidget(widget)
	return self:SetFocusByIndex(tIndexOf(self.Registry, widget))
end

---------------------------------------------------------------
-- Pools
---------------------------------------------------------------
if ObjectPoolMixin and FramePoolMixin then
	CPFramePoolCollectionMixin = FramePoolCollectionMixin;
	return; -- we're done here, using old pool system already
end
---------------------------------------------------------------

local ObjectPoolMixin = {};

function ObjectPoolMixin:OnLoad(creationFunc, resetterFunc)
	self.creationFunc = creationFunc;
	self.resetterFunc = resetterFunc;
	self.activeObjects = {};
	self.inactiveObjects = {};
	self.numActiveObjects = 0;
end

function ObjectPoolMixin:Acquire()
	local numInactiveObjects = #self.inactiveObjects;
	if numInactiveObjects > 0 then
		local obj = self.inactiveObjects[numInactiveObjects];
		self.activeObjects[obj] = true;
		self.numActiveObjects = self.numActiveObjects + 1;
		self.inactiveObjects[numInactiveObjects] = nil;
		return obj, false;
	end

	local newObj = self.creationFunc(self);
	if self.resetterFunc and not self.disallowResetIfNew then
		self.resetterFunc(self, newObj)
	end
	self.activeObjects[newObj] = true;
	self.numActiveObjects = self.numActiveObjects + 1;
	return newObj, true;
end

function ObjectPoolMixin:Release(obj)
	if self:IsActive(obj) then
		self.inactiveObjects[#self.inactiveObjects + 1] = obj;
		self.activeObjects[obj] = nil;
		self.numActiveObjects = self.numActiveObjects - 1;
		if self.resetterFunc then
			self.resetterFunc(self, obj)
		end
		return true;
	end
	return false;
end

function ObjectPoolMixin:ReleaseAll()
	for obj in pairs(self.activeObjects) do
		self:Release(obj)
	end
end

function ObjectPoolMixin:SetResetDisallowedIfNew(disallowed)
	self.disallowResetIfNew = disallowed;
end

function ObjectPoolMixin:EnumerateActive()
	return pairs(self.activeObjects)
end

function ObjectPoolMixin:GetNextActive(current)
	return (next(self.activeObjects, current))
end

function ObjectPoolMixin:GetNextInactive(current)
	return (next(self.inactiveObjects, current))
end

function ObjectPoolMixin:IsActive(object)
	return (self.activeObjects[object] ~= nil)
end

function ObjectPoolMixin:GetNumActive()
	return self.numActiveObjects;
end

function ObjectPoolMixin:EnumerateInactive()
	return ipairs(self.inactiveObjects);
end

function CreateObjectPool(creationFunc, resetterFunc)
	local objectPool = CreateFromMixins(ObjectPoolMixin)
	objectPool:OnLoad(creationFunc, resetterFunc)
	return objectPool;
end

local FramePoolMixin = CreateFromMixins(ObjectPoolMixin)

local function FramePoolFactory(framePool)
	return CreateFrame(framePool.frameType, nil, framePool.parent, framePool.frameTemplate)
end

function FramePoolMixin:OnLoad(frameType, parent, frameTemplate, resetterFunc, forbidden, frameInitFunc)
	local creationFunc = FramePoolFactory;
	if frameInitFunc ~= nil then
		creationFunc = function(framePool)
			local frame = CreateFrame(framePool.frameType, nil, framePool.parent, framePool.frameTemplate)
			frameInitFunc(frame);
			return frame;
		end
	end

	ObjectPoolMixin.OnLoad(self, creationFunc, resetterFunc)
	self.frameType = frameType;
	self.parent = parent;
	self.frameTemplate = frameTemplate;
end

function FramePoolMixin:GetTemplate()
	return self.frameTemplate;
end

function CreateFramePool(frameType, parent, frameTemplate, resetterFunc, forbidden, frameInitFunc)
	local framePool = CreateFromMixins(FramePoolMixin)
	framePool:OnLoad(frameType, parent, frameTemplate, resetterFunc or CPAPI.HideAndClearAnchors, forbidden, frameInitFunc)
	return framePool;
end

---------------------------------------------------------------
CPFramePoolCollectionMixin = {};
---------------------------------------------------------------
local function FramePoolCollection_GetPoolKey(template, specialization)
	return template..tostring(specialization);
end

local function FramePoolCollection_GetSpecializedFrameInit(specialization)
	local specializationType = type(specialization);
	if specializationType == "function" then
		return specialization;
	elseif specializationType == "table" then
		local function SpecializationFrameInit(frame)
			FrameUtil.SpecializeFrameWithMixins(frame, specialization)
		end
		return SpecializationFrameInit;
	end
	return nil;
end

function CPFramePoolCollectionMixin:OnLoad()
	self.pools = {};
end

function CPFramePoolCollectionMixin:GetNumActive()
	local numTotalActive = 0;
	for _, pool in pairs(self.pools) do
		numTotalActive = numTotalActive + pool:GetNumActive();
	end
	return numTotalActive;
end

-- Returns the pool, and whether or not the pool needed to be created.
function CPFramePoolCollectionMixin:GetOrCreatePool(frameType, parent, template, resetterFunc, forbidden, specialization)
	local pool = self:GetPool(template, specialization)
	if not pool then
		return self:CreatePool(frameType, parent, template, resetterFunc, forbidden, specialization), true;
	end
	return pool, false;
end

function CPFramePoolCollectionMixin:CreatePool(frameType, parent, template, resetterFunc, forbidden, specialization)
	assert(self:GetPool(template, specialization) == nil)
	local frameInitFunc = FramePoolCollection_GetSpecializedFrameInit(specialization)
	local pool = CreateFramePool(frameType, parent, template, resetterFunc, forbidden, frameInitFunc)
	local poolKey = FramePoolCollection_GetPoolKey(template, specialization)
	self.pools[poolKey] = pool;
	return pool;
end

function CPFramePoolCollectionMixin:CreatePoolIfNeeded(frameType, parent, template, resetterFunc, forbidden, specialization)
	if not self:GetPool(template, specialization) then
		self:CreatePool(frameType, parent, template, resetterFunc, forbidden, specialization)
	end
end

function CPFramePoolCollectionMixin:GetPool(template, specialization)
	local poolKey = FramePoolCollection_GetPoolKey(template, specialization)
	return self.pools[poolKey];
end

function CPFramePoolCollectionMixin:Acquire(template, specialization)
	local pool = self:GetPool(template, specialization)
	assert(pool);
	return pool:Acquire();
end

function CPFramePoolCollectionMixin:Release(object)
	for _, pool in pairs(self.pools) do
		if pool:Release(object) then
			return;
		end
	end
	assert(false)
end

function CPFramePoolCollectionMixin:ReleaseAllByTemplate(template, specialization)
	local pool = self:GetPool(template, specialization)
	if pool then
		pool:ReleaseAll()
	end
end

function CPFramePoolCollectionMixin:ReleaseAll()
	for key, pool in pairs(self.pools) do
		pool:ReleaseAll()
	end
end

function CPFramePoolCollectionMixin:EnumerateActiveByTemplate(template, specialization)
	local pool = self:GetPool(template, specialization);
	if pool then
		return pool:EnumerateActive()
	end
	return nop;
end

function CPFramePoolCollectionMixin:EnumerateActive()
	local currentPoolKey, currentPool = next(self.pools, nil)
	local currentObject = nil;
	return function()
		if currentPool then
			currentObject = currentPool:GetNextActive(currentObject)
			while not currentObject do
				currentPoolKey, currentPool = next(self.pools, currentPoolKey)
				if currentPool then
					currentObject = currentPool:GetNextActive();
				else
					break;
				end
			end
		end

		return currentObject;
	end, nil;
end

function CPFramePoolCollectionMixin:EnumerateInactiveByTemplate(template, specialization)
	local pool = self:GetPool(template, specialization)
	if pool then
		return pool:EnumerateInactive()
	end
	return nop;
end

function CPFramePoolCollectionMixin:EnumerateInactive()
	local currentPoolKey, currentPool = next(self.pools, nil)
	local currentObject = nil;
	return function()
		if currentPool then
			currentObject = currentPool:GetNextInactive(currentObject);
			while not currentObject do
				currentPoolKey, currentPool = next(self.pools, currentPoolKey)
				if currentPool then
					currentObject = currentPool:GetNextInactive()
				else
					break;
				end
			end
		end
		return currentObject;
	end, nil;
end