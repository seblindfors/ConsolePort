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
local function FramePoolFactory(self)
	self.poolCount = self.poolCount + 1
	local frame = CreateFrame(
		self.frameType, 
		'$parentItem'..self.poolCount, 
		self.parent, 
		self.frameTemplate)
	if self.mixin then
		mx(frame, self.mixin)
	end
	self.registry[self.poolCount] = frame
	return frame
end

function UI:CreateFramePool(frameType, parent, template, mixin)
	assert(type(frameType) == 'string', 'CreateFramePool: Frametype is invalid.')
	assert(type(parent) == 'table', 'CreateFramePool: Parent is invalid.')
	assert(type(template) == 'string', 'CreateFramePool: Template is invalid.')
	local pool = CreateFramePool(frameType, parent, template)
	pool.registry = {}
	pool.poolCount = 0
	pool.mixin = mixin
	pool.creationFunc = FramePoolFactory
	return pool
end
