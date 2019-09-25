---------------------------------------------------------------
-- Radial action bar base handler
---------------------------------------------------------------
-- Manages radial action bars (RAB), using radial key data
-- from Drivers\Radial.lua. This mixin handles the backend of
-- all RABs, and is in turn reliant on the radial driver for
-- managing key input. Use the callbacks to update frontend.
-- Callbacks:
--     OnButtonFocused(detail)
--     OnNewButton(button, index, angle, rotation)
--     OnNewRotation(value)
--     OnRefresh(size)
---------------------------------------------------------------
ConsolePortRingMixin = {}
---------------------------------------------------------------


function ConsolePortRingMixin:Initialize(ctype, ctemplate, cmixin)
	if self:GetAttribute('initialized') then return end
	----------------------------------
	self.cmixin = cmixin;
	self.ctype  = ctype or 'Button';
	self.ctemplate = ctemplate or 'ConsolePortRingButtonTemplate';
	----------------------------------
	self.HANDLE = ConsolePortRadialHandler
	self.HANDLE:RegisterFrame(self)
	----------------------------------
	self:WrapScript(self, 'PreClick', self:GetAttribute('_preclick'))
	self:WrapScript(self, 'OnDoubleClick', self:GetAttribute('_ondoubleclick'))
	----------------------------------
	self:SetAttribute('initialized', true)
end

function ConsolePortRingMixin:Disable()
	if not self:GetAttribute('initialized') then return end
	----------------------------------
	self:UnwrapScript(self, 'PreClick')
	self:UnwrapScript(self, 'OnDoubleClick')
	----------------------------------
	self:SetAttribute('initialized', false)
end

function ConsolePortRingMixin:Refresh()
	local size = self.HANDLE:GetIndexSize()
	self:SetAttribute('size', size)
	self:SetAttribute('fraction', rad(360 / size))

	self.Buttons = self.Buttons or {}
	self:Recall()
	self:Draw(size)

	self:OnRefresh(size)
end

----------------------------------
-- Button loops
----------------------------------
function ConsolePortRingMixin:Recall()
	for i, button in ipairs(self.Buttons) do
		button:ClearAllPoints()
		button:Hide()
	end
end

function ConsolePortRingMixin:Draw(numButtons)
	for i=1, numButtons do
		self:SpawnButtonAtIndex(i)
	end
end

function ConsolePortRingMixin:ClearFocus()
	for i, button in ipairs(self.Buttons) do
		button:OnLeave()
	end
end

----------------------------------
-- Button spawns
----------------------------------
local CENTER_OFFSET = 180

function ConsolePortRingMixin:GetFraction()
	return self:GetAttribute('fraction')
end

function ConsolePortRingMixin:GetButtonFromAngle(angle)
	return self:GetAttribute(angle)
end

function ConsolePortRingMixin:SpawnButtonAtIndex(i)
	local angle  =  self.HANDLE:GetAngleForIndex(i)
	local rotate =  (i - 1) * self:GetFraction()
	local button =  self:GetButtonFromAngle(angle) or
					CreateFrame(self.ctype, '$parent'..self.ctype..i, self, self.ctemplate)

	button:SetPoint('CENTER', -(CENTER_OFFSET * cos(angle)), CENTER_OFFSET * sin(angle))
	button:SetAttribute('rotation', -rotate)
	button:SetAttribute('angle', angle)
	button:SetID(i)
	button:Show()

	self.Buttons[i] = button
	self:SetAttribute(angle, button)
	self:SetFrameRef(tostring(i), button)
	self:SetFrameRef(tostring(angle), button)
	self:OnNewButton(button, i, angle, rotate)
end

----------------------------------
-- State drivers
----------------------------------
function ConsolePortRingMixin:SetCursorDrop(enabled)
	local call = enabled and RegisterStateDriver or UnregisterStateDriver
	call(self, 'cursor', self:GetAttribute('_driver-cursor'))
end

function ConsolePortRingMixin:SetExtraButtonDrop(enabled)
	local call = enabled and RegisterStateDriver or UnregisterStateDriver
	call(self, 'extrabar', self:GetAttribute('_driver-extrabar'))
end

----------------------------------
-- Rotation handler
----------------------------------
local abs = math.abs

function ConsolePortRingMixin:SetRotation(value)
	if not value then return end
	self:OnNewRotation(value)
end

function ConsolePortRingMixin:SetNewRotationValue(anglenew)
	self.anglenew = anglenew
	if self.anglecur then
		local diff = abs(anglenew) - abs(self.anglecur)
		-- Case: lap reset, causing rotation in wrong direction in upperleft quadrant
		-- Solution: reverse delta and rotate in from a negative value
		if abs(diff) > 1 then
			self.anglecur = anglenew - ((diff > 0 and 1 or -1) * self:GetAttribute('fraction'))
		end
		return true -- if rotation is required
	end
	self.anglecur = anglenew
	self:SetRotation(anglenew)
end

----------------------------------
-- Scripts (extend with HookScript)
----------------------------------
local ANI_SPEED, ANI_SMOOTH, ANI_INF = 1.5, 1.4, 0.005

function ConsolePortRingMixin:OnUpdate(elapsed)
	-- flatten and update rotation angle
	local new, cur = self.anglenew, self.anglecur
	if cur ~= new then
		local dist = new - cur
		local flat = abs(dist / ANI_SPEED) ^ ANI_SMOOTH
		local diff = cur + (dist < 0 and -flat or flat)
		----------------------------------
		self.anglecur = abs(abs(diff)-abs(new)) < ANI_INF and new or diff
		----------------------------------
	end
	self:SetRotation(self.anglecur)
end

function ConsolePortRingMixin:OnShow()
	self.anglecur = nil
	self.anglenew = nil
end

function ConsolePortRingMixin:OnHide()
	self:ClearFocus()
	self.anglecur = nil
	self.anglenew = nil
end

----------------------------------
-- Callback overrides
----------------------------------
function ConsolePortRingMixin:OnButtonFocused(detail)
	-- replace with callback
end

function ConsolePortRingMixin:OnNewButton(button, index, angle, rotation)
	-- replace with callback
end

function ConsolePortRingMixin:OnNewRotation(value)
	-- replace with callback
end

function ConsolePortRingMixin:OnRefresh(size)
	-- replace with callback
end



---------------------------------------------------------------
-- Radial action button handler
---------------------------------------------------------------
-- Manages radial action buttons. These action buttons behave
-- similarly to normal action buttons, but abstracts frontend
-- so that RABs don't need to handle state updates.
-- Callbacks:
--     OnContentChanged()
--     OnContentRemoved()
---------------------------------------------------------------
ConsolePortRingButtonMixin = {}
---------------------------------------------------------------


local DROP_TYPES = {
	item = true,
	spell = true,
	macro = true,
	mount = true,
}

local TEXTURE_GETS = {
	----------------------------------
	item   = function(id) if id then return select(10, GetItemInfo(id)), select(12, GetItemInfo(id)) == LE_ITEM_CLASS_QUESTITEM end end;
	spell  = function(id) if id then return select(3, GetSpellInfo(id)), nil end end;
	macro  = function(id) if id then return select(2, GetMacroInfo(id)), nil end end;
	action = function(id) if id then return GetActionTexture(id) end end;
	----------------------------------
	none = function(id) return end;
} setmetatable(TEXTURE_GETS,{__index = function(t) return t.none end})

local TRANSLATE_CURSOR_INFO = {
	----------------------------------
	item = function(self, id)
		if tonumber(id) then
			self:SetAttribute('item', GetItemInfo(id))
			return true
		end
	end;
	mount = function(self, id)
		local spellID = select(2, C_MountJournal.GetMountInfoByID(id))
		self:SetAttribute('mountID', spellID)
		self:SetAttribute('type', 'spell')
		self:SetAttribute('spell', spellID)
		return true
	end;
	----------------------------------
	none = function(id) return end;
} setmetatable(TRANSLATE_CURSOR_INFO,{__index = function(t) return t.none end})
---------------------------------------------------------------

----------------------------------
-- Script handlers
----------------------------------
function ConsolePortRingButtonMixin:OnLoad()
	local border = self.Border
	self.Highlight = border.Highlight
	self.Quest = border.Quest
	self.Pushed:SetParent(border)
	self.Pushed:SetDrawLayer('OVERLAY', 5)
	self.NormalTexture:SetParent(border)
	self.NormalTexture:SetDrawLayer('OVERLAY', 4)

	self.Tooltip = self:GetParent().Tooltip
	self.FadeIn, self.FadeOut = ConsolePort:GetData().GetFaders()
end

function ConsolePortRingButtonMixin:OnEnter()
	self:SetFocus(true)
	self.FadeIn(self.Pushed, 0.1, self.Pushed:GetAlpha(), 1)
	self.FadeIn(self.Highlight, 0.1, self.Highlight:GetAlpha(), 1)
	self.FadeOut(self.NormalTexture, 0.1, self.NormalTexture:GetAlpha(), 1)
	self.FadeOut(self.Quest, 0.1, self.Quest:GetAlpha(), 0)
end

function ConsolePortRingButtonMixin:OnLeave()
	self:SetFocus(false)
	self.FadeOut(self.Pushed, 0.2, self.Pushed:GetAlpha(), 0)
	self.FadeOut(self.Highlight, 0.2, self.Highlight:GetAlpha(), 0)
	self.FadeIn(self.NormalTexture, 0.2, self.NormalTexture:GetAlpha(), 0.75)
	self.FadeIn(self.Quest, 0.2, self.Quest:GetAlpha(), 1)
end

function ConsolePortRingButtonMixin:PreClick(button)
	if not InCombatLockdown() then
		if button == 'RightButton' then
			self:SetAttribute('type', nil)
			self.Cooldown:SetCooldown(0, 0)
			self.Count:SetText()
			ClearCursor()
		elseif DROP_TYPES[GetCursorInfo()] then
			self:SetAttribute('type', nil)
		end
	end
end

function ConsolePortRingButtonMixin:PostClick(button)
	if DROP_TYPES[GetCursorInfo()] then
		local cursorType, id,  _, spellID = GetCursorInfo()
		ClearCursor()

		if InCombatLockdown() then return end

		local newValue
		-- Garrison ability
		if cursorType == 'spell' and spellID == 161691 then
			newValue = spellID
		-- Convert spellID to name
		elseif cursorType == 'spell' then
			newValue = GetSpellInfo(id, 'spell')
		-- Summon favorite mount, ignore this
		elseif cursorType == 'mount' and id == 268435455 then
			return
		elseif cursorType == 'mount' then
			newValue = C_MountJournal.GetMountInfoByID(id)
			cursorType = 'spell'
		end

		self:SetAttribute('type', cursorType)
		self:SetAttribute('cursorID', id)
		self:SetAttribute(cursorType, newValue or id)
	end
end


function ConsolePortRingButtonMixin:OnAttributeChanged(attribute, detail)
	-- omit on autoassigned and statehidden
	if (attribute == 'autoassigned' or attribute == 'statehidden' or attribute == 'unit') then return end
	if detail then
		-- omit on item/mount added, because they need translation first.
		if TRANSLATE_CURSOR_INFO[attribute](self, detail) then return end
		ClearCursor()
	end

	-- update the icon texture
	self:UpdateTexture()
	
	-- run callback if this button has content
	local actionType = self:GetAttribute('type')
	if actionType then
		self:OnContentChanged(actionType)
	else
		self:SetAttribute('autoassigned', nil)
		self:OnContentRemoved()
	end
end

function ConsolePortRingButtonMixin:OnTooltipUpdate(elapsed)
	self.idle = self.idle + elapsed
	if self.idle > 1 then
		local action = self:GetAttribute('type')
		if action == 'item' then
			self.Tooltip:SetOwner(self, 'ANCHOR_BOTTOM', 0, -16)
			self.Tooltip:SetItemByID(self:GetAttribute('cursorID'))
		elseif action == 'spell' then
			local id = select(7, GetSpellInfo(self:GetAttribute('spell')))
			if id then
				self.Tooltip:SetOwner(self, 'ANCHOR_BOTTOM', 0, -16)
				self.Tooltip:SetSpellByID(id)
			end
		end
		self:SetScript('OnUpdate', nil)
	end
end

----------------------------------
-- Tooltip
----------------------------------
function ConsolePortRingButtonMixin:SetFocus(enabled)
	if self.Tooltip then
		if enabled then
			self.idle = 0
			self:SetScript('OnUpdate', self.OnTooltipUpdate)
		else
			if self.Tooltip:IsOwned(self) then
				self.Tooltip:Hide()
			end
			self:SetScript('OnUpdate', nil)
		end
	end
end

----------------------------------
-- Button data
----------------------------------
function ConsolePortRingButtonMixin:SetCooldown(time, cooldown, enable)
	if time and cooldown then
		self.onCooldown = true
		self.Cooldown:SetCooldown(time, cooldown, enable)
	else
		self.onCooldown = false
		self.Cooldown:SetCooldown(0, 0)
	end
end

function ConsolePortRingButtonMixin:SetCharges(charges)
	self.Count:SetText(charges)
end

function ConsolePortRingButtonMixin:SetUsable(isUsable)
	local vxc = isUsable and 1 or 0.5
	self.Icon:SetVertexColor(vxc, vxc, vxc)
end

function ConsolePortRingButtonMixin:UpdateState()
	local action = self:GetAttribute('type')
	self:UpdateTexture(action)

	if action == 'item' then
		local item = self:GetAttribute('item')
		if item then
			local count = GetItemCount(item)
			local _, _, maxStack = select(6, GetItemInfo(item))
			self:SetCooldown(GetItemCooldown(self:GetAttribute('cursorID')))
			self:SetUsable(IsUsableItem(item))
			self:SetCharges(maxStack and maxStack > 1 and (count or 0))
		end
	elseif action == 'spell' then
		local spellID = self:GetAttribute('spell')
		self:SetCharges(GetSpellCharges(spellID))
		if spellID then
			self:SetUsable(IsUsableSpell(spellID))
			self:SetCooldown(GetSpellCooldown(spellID))
		end
	elseif action == 'action' then
		local actionID = self:GetAttribute('action')
		if actionID then
			self:SetUsable(IsUsableAction(actionID))
			self:SetCooldown(GetActionCooldown(actionID))
		end
	end
end

function ConsolePortRingButtonMixin:GetAutoAssigned()
	return self:GetAttribute('item') and self:GetAttribute('autoassigned')
end

----------------------------------
-- Icon and quest icon
----------------------------------
function ConsolePortRingButtonMixin:SetTexture(actionType, actionValue)
	local texture, isQuest = TEXTURE_GETS[actionType](actionValue)
	if texture then
		self.Icon.texture = texture
		self.Icon:SetTexture(texture)
		self:SetAlpha(1)
		self.Icon:SetVertexColor(1, 1, 1)
	else
		self.Icon.texture = nil
		self.Icon:SetTexture(nil)
		self:SetAlpha(0.5)
	end
	self.isQuest = isQuest
	self.Quest:SetShown(isQuest)
end

function ConsolePortRingButtonMixin:UpdateTexture(action, val)
	action = action or self:GetAttribute('type')
	val = val or (action and self:GetAttribute(action))
	self:SetTexture(action, val)
end

----------------------------------
-- Callback overrides
----------------------------------
function ConsolePortRingButtonMixin:OnContentChanged()
	-- replace with callback
end

function ConsolePortRingButtonMixin:OnContentRemoved()
	-- replace with callback
end