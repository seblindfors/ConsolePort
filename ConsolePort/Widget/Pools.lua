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