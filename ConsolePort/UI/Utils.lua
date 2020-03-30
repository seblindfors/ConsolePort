local _, db = ...
local mx = db.table.mixin
local UI = ConsolePortUI

---------------------------------------------------------------
-- Return the essential objects that modules are likely to use
---------------------------------------------------------------

function UI:GetEssentials()
	return self, self:GetControlHandle(), db
end

---------------------------------------------------------------
-- Frame pools (extended with mixins)
---------------------------------------------------------------
local FramePoolMixin = {}

function FramePoolMixin:creationFunc()
	local index = #self.registry + 1
	local frame = CreateFrame(
		--[[frame]]    self.frameType, 
		--[[name]]    '$parentItem'..index, 
		--[[parent]]   self.parent, 
		--[[template]] self.frameTemplate)
	if self.mixin then
		mx(frame, self.mixin)
	end
	self.registry[index] = frame
	return frame
end

function FramePoolMixin:Acquire(...)
	local frame, newObj = self:_Acquire(...)
	self.activeInOrder[self.numActiveObjects] = frame
	return frame, newObj
end

function FramePoolMixin:GetObjectByIndex(index)
	return self.activeInOrder[index]
end

function FramePoolMixin:ReleaseAll(...)
	wipe(self.activeInOrder)
	return self:_ReleaseAll(...)
end

function UI:CreateFramePool(frameType, parent, template, mixin)
	assert(type(frameType) == 'string', 'CreateFramePool: Frametype is invalid.')
	assert(type(parent) == 'table', 'CreateFramePool: Parent is invalid.')
	assert(type(template) == 'string', 'CreateFramePool: Template is invalid.')
	local pool = CreateFramePool(frameType, parent, template)

	for name, func in pairs(FramePoolMixin) do
		if pool[name] then
			pool['_'..name] = pool[name]
		end
		pool[name] = func
	end

	pool.registry = {}
	pool.activeInOrder = {}
	pool.mixin = mixin
	return pool
end
