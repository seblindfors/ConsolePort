---------------------------------------------------------------
-- UIProbe.lua: Secure probes for signed code
---------------------------------------------------------------
-- Probes are used to trigger callbacks to different handles
-- when an event happens that normally can't be processed in a
-- secure scope. A probed object needs to be signed or secure.
-- Probed objects will become inherently secure after probing.

local Probe, _probeID = {}, 1

local assert, mixin = assert, Mixin
local CreateFrame, InCombatLockdown = CreateFrame, InCombatLockdown
local SCRIPT, TEMPLATES 

--- Create a new secure probe.
-- @param 	owner 	: Owner of the probe. The owner will be shown/hidden in response to the probe.
-- @param 	object 	: Object to probe. Use only on secure addon objects or signed (official) objects.
-- @param 	state 	: State to which the probe should respond.
-- @param 	name 	: Name of the probe. Can safely be omitted.
-- @param 	script 	: Script to fire when using probescript template. Requires a secure environment.
-- @return 	probe 	: Returns the created probe. Generally not useful, unless the probe will be re-cycled.
function ConsolePortUI:CreateProbe(owner, object, state, name, script)
	assert(object ~= nil and owner ~= nil and state ~= nil, 'Usage: UI:CreateProbe(object, owner, state)')
	assert(not InCombatLockdown(), 'Probe cannot be created in combat.')
	if type(object) == 'string' then object = _G[object] end
	assert(type(object) == 'table', 'Probed object is not a valid frame.')
	local probe = CreateFrame('Frame', name or ('ConsolePortProbe%s'):format(_probeID), object, 'SecureHandlerShowHideTemplate, SecureHandlerEnterLeaveTemplate')
	Mixin(probe, Probe)
	probe:SetType(state)
	probe:SetOwner(owner)
	probe:SetObject(object)
	probe:SetResponseScript(script)
	_probeID = _probeID + 1
	return probe
end

--- Show/Hide hook wrapper (insecure)
-- @param 	owner 	: Responding frame. Will be shown/hidden in response to the target object.
-- @param 	object 	: Object to hook.
function ConsolePortUI:InsecureHookShowHide(owner, object)
	assert(object ~= nil and owner ~= nil, 'Usage: UI:InsecureHookShowHide(object, owner)')
	if type(object) == 'string' then object = _G[object] end
	assert(type(object) == 'table', 'Probed object is not a valid frame.')
	object:HookScript('OnShow', function() owner:Show() end)
	object:HookScript('OnHide', function() owner:Hide() end)
	owner:SetShown(object:IsShown())
end

function ConsolePortUI:HideFrame(frame, ignoreAlpha)
	assert(frame, 'Usage: UI:HideFrame(frame)')
	frame:SetSize(0, 0)
	frame:EnableMouse(false)
	frame:EnableKeyboard(false)
	frame:SetAlpha(ignoreAlpha and frame:GetAlpha() or 0)
	frame:ClearAllPoints()
	ConsolePort:ForbidFrame(frame)
end

function Probe:SetType(pType)
	local template = TEMPLATES[pType]
	assert(template, 'Usage: UI:CreateProbe(object, owner, state): Supported states: showhide, enterleave, all')
	for script in pairs(TEMPLATES.all) do
		self:SetAttribute(script, nil)
	end
	for script, snippet in pairs(template) do
		self:SetAttribute(script, snippet)
	end
end

function Probe:SetOwner(new)
	assert(not InCombatLockdown(), (self:GetName() or 'Probe')..' cannot be repurposed in combat.')
	self:SetFrameRef('owner', new)
	self:Execute([[owner = self:GetFrameRef('owner')]])
end

function Probe:SetObject(new)
	assert(not InCombatLockdown(), (self:GetName() or 'Probe')..' cannot be relocated in combat.')
	self:SetParent(new)
end

function Probe:SetResponseScript(script)
	if type(script) == 'string' and loadstring(script) then
		self:Execute( ("_cb=[[%s]]"):format(script) )
	end
end

function Probe:DebugConnection()
	assert(not InCombatLockdown(), 'Cannot debug probe connection in combat.')
	self:Execute([[
		local probedObject = self:GetParent()
		print('Probe name:', self:GetName() or '<unnamed>')
		print('Probed state:', owner:GetAttribute('pc') or 0)
		print('Probed object:', (not probedObject and '<missing>') or (probedObject:GetName() or '<unnamed>'))
		print('Owner of probe:', owner:GetName() or '<unnamed>')
		print('Owner probe script:', owner:GetAttribute('_onprobecount'))]])
end

----------------------------
SCRIPT = {
	show = [[local _=(owner:GetAttribute('pc') or 0)+1 owner:SetAttribute('pc',_) owner:Hide() owner:Show()]],
	hide = [[local _=(owner:GetAttribute('pc') or 1)-1 owner:SetAttribute('pc',_) if _ < 1 then owner:Hide() end]],
	pcsh = [[local _=(owner:GetAttribute('pc') or 0)+1 owner:SetAttribute('pc',_) if _cb then owner:Run(_cb,_) end]],
	pchi = [[local _=(owner:GetAttribute('pc') or 1)-1 owner:SetAttribute('pc',_) if _cb then owner:Run(_cb,_) end]],
	omit = [[return nil]],
}
----------------------------
TEMPLATES = {
	all = {
		_onenter = SCRIPT.show,
		_onleave = SCRIPT.hide,
		_onshow  = SCRIPT.show,
		_onhide  = SCRIPT.hide,
	},
	enterleave = {
		_onenter = SCRIPT.show,
		_onleave = SCRIPT.hide,
	},
	showhide = {
		_onshow  = SCRIPT.show,
		_onhide  = SCRIPT.hide,
	},
	probescript = {
		_onshow  = SCRIPT.pcsh,
		_onhide  = SCRIPT.pchi,
	},
	------------------------
	invertall = {
		_onenter = SCRIPT.hide,
		_onleave = SCRIPT.show,
		_onshow  = SCRIPT.hide,
		_onhide  = SCRIPT.show,
	},
	invertenterleave = {
		_onenter = SCRIPT.hide,
		_onleave = SCRIPT.show,
	},
	invertshowhide = {
		_onshow  = SCRIPT.hide,
		_onhide  = SCRIPT.show,
	},
	------------------------
	omit = {
		_onshow = SCRIPT.omit,
		_onhide = SCRIPT.omit,
	},
}
----------------------------