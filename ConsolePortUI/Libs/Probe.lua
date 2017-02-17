local _, UI = ...

local Probe = CreateFrame('Frame')
local Probe_MT = {__index = Probe}

local setmetatable, assert = setmetatable, assert
local CreateFrame, InCombatLockdown = CreateFrame, InCombatLockdown
local SCRIPT, TEMPLATES 

--- Create a new secure probe.
-- @param 	owner 	: Owner of the probe. The owner will be shown/hidden in response to the probe.
-- @param 	object 	: Object to probe. Use only on secure addon objects or official Blizzard objects.
-- @param 	state 	: State to which the probe should respond.
-- @return 	probe 	: Returns the created probe. Generally not useful, unless the probe will be re-cycled.
function UI:CreateProbe(owner, object, state, name)
	assert(object ~= nil and owner ~= nil and state ~= nil, 'Usage: UI:CreateProbe(object, owner, state)')
	assert(not InCombatLockdown(), 'Probe cannot be created in combat.')
	if type(object) == 'string' then object = _G[object] end
	assert(type(object) == 'table', 'Probed object is not a valid frame.')
	local probe = setmetatable(CreateFrame('Frame', name, object, 'SecureHandlerShowHideTemplate, SecureHandlerEnterLeaveTemplate'), Probe_MT)
	probe:SetType(state)
	probe:SetOwner(owner)
	probe:SetObject(object)
	return probe
end

--- Show/Hide hook wrapper (insecure)
-- @param 	owner 	: Responding frame. Will be shown/hidden in response to the target object.
-- @param 	object 	: Object to hook.
function UI:InsecureHookShowHide(owner, object)
	assert(object ~= nil and owner ~= nil, 'Usage: UI:InsecureHookShowHide(object, owner)')
	if type(object) == 'string' then object = _G[object] end
	assert(type(object) == 'table', 'Probed object is not a valid frame.')
	object:HookScript('OnShow', function() owner:Show() end)
	object:HookScript('OnHide', function() owner:Hide() end)
	owner:SetShown(object:IsShown())
end

function UI:HideFrame(frame)
	assert(frame, 'Usage: UI:HideFrame(frame)')
	frame:SetSize(0, 0)
	frame:EnableMouse(false)
	frame:EnableKeyboard(false)
	frame:SetAlpha(0)
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

----------------------------
SCRIPT = {
	show = [[_=(owner:GetAttribute('pc') or 0)+1 owner:SetAttribute('pc',_) owner:Show()]],
	hide = [[_=(owner:GetAttribute('pc') or 1)-1 owner:SetAttribute('pc',_) if _ < 1 then owner:Hide() end]],
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
}
----------------------------