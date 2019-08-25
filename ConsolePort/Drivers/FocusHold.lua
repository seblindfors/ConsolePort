if CPAPI:IsClassicVersion() then return end
---------------------------------------------------------------
-- FocusHold.lua: Reroute spells to focus target
---------------------------------------------------------------
-- Modified clicks only accept real modifiers, so this handle
-- simulates the FOCUSCAST modifier by caching secure frames
-- and temporarily setting their unit attribute to focus.
-- The net result is the same, but an edge case where a unit
-- attribute is changed between press/release will restore
-- a faulty unit on release.

local FOCUS = ConsolePortFocusButton
FOCUS:SetFrameRef('UIParent', UIParent)
FOCUS:Execute([[
	UIParent = self:GetFrameRef('UIParent')
	CACHE = newtable()
]])
FOCUS:SetAttribute('AddToCache', [[
	local node = CURRENT
	if node:GetAttribute('useparent-unit') or not node:IsProtected() then return end
	
	local children 	= newtable(node:GetChildren())
	CACHE[node] 	= false

	if children then
		for i, child in pairs(children) do
			CURRENT = child
			self:RunAttribute('AddToCache')
		end
	end
]])

FOCUS:SetAttribute('UpdateUnit', [[
	if CURRENT:GetAttribute('useparent-unit') then return end
	CACHE[CURRENT] = ( CURRENT:GetAttribute('unit') or false )
]])

FOCUS:SetAttribute('UpdateFrameCache', [[
	local frames = newtable(UIParent:GetChildren())
	for i, frame in ipairs(frames) do
		if frame:IsProtected() and not CACHE[frame] then
			CURRENT = frame
			self:RunAttribute('AddToCache')
		end
	end
	for frame in pairs(CACHE) do
		CURRENT = frame
		self:RunAttribute('UpdateUnit')
	end
]])

FOCUS:SetAttribute('_onclick', [[
	if down then
		self:RunAttribute('UpdateFrameCache')
		for node in pairs(CACHE) do
			node:SetAttribute('unit', 'focus')
		end
	else
		for node, originalUnit in pairs(CACHE) do
			node:SetAttribute('unit', originalUnit or nil)
		end
	end
]])