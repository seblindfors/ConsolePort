local _, UI = ...
UI.Data = ConsolePort:GetData()
UI.Utils = {}

function UI.Utils.MixinNormal(object, ...)
	for i = 1, select("#", ...) do
		local mixin = select(i, ...)
		for k, v in pairs(mixin) do
			object[k] = v
		end
	end

	return object
end

local gMixin = UI.Utils.MixinNormal

function UI.Utils.Mixin(t, ...)
	t = gMixin(t, ...)
	if t.HasScript then
		for k, v in pairs(t) do
			if t:HasScript(k) then
				if t:GetScript(k) then
					t:HookScript(k, v)
				else
					t:SetScript(k, v)
				end
			end
		end
	end
end

function UI.Utils.Copy(src)
	local srcType, t = type(src)
	if srcType == "table" then
		t = {}
		for key, value in next, src, nil do
			t[UI.Utils.Copy(key)] = UI.Utils.Copy(value)
		end
		setmetatable(t, UI.Utils.Copy(getmetatable(src)))
	else
		t = src
	end
	return t
end

---------------------------------------------------------------
-- spairs: Sort by non-numeric key, handy for string keys
---------------------------------------------------------------
function UI.Utils.spairs(t, order)
	local keys = {}
	for k in pairs(t) do keys[#keys+1] = k end
	if order then
		table.sort(keys, function(a,b) return order(t, a, b) end)
	else
		table.sort(keys)
	end
	local i = 0
	return function()
		i = i + 1
		if keys[i] then
			return keys[i], t[keys[i]]
		end
	end
end

---------------------------------------------------------------
-- Wrappers
---------------------------------------------------------------
function UI:GetDataSafeMode()
	return UI.Utils.Copy(self.Data)
end

function UI:GetEssentials()
	return self, self:GetControlHandle(), self.Data
end

---------------------------------------------------------------
-- Frame pools
---------------------------------------------------------------
local function FramePoolFactory(self)
	self.poolCount = self.poolCount + 1
	local frame = CreateFrame(
		self.frameType, 
		'$parentItem'..self.poolCount, 
		self.parent, 
		self.frameTemplate)
	if self.mixin then
		UI.Utils.Mixin(frame, self.mixin)
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
