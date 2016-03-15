---------------------------------------------------------------
local db = ConsolePort:DB()
local Button = {}
---------------------------------------------------------------
local an, ab = ...
local lib = ab.libs.acb
---------------------------------------------------------------
ab.libs.button = Button

local divisor = 1.5
local size = 64
local mods = {
	["action"] 	= {size = {size, size * (74 / 64)}},
	["shift"] 	= {size = {size / divisor, size * (74 / 64) / divisor }, point = {"TOP", "BOTTOM", -32, 24}}, 
	["ctrl"] 	= {size = {size / divisor, size * (74 / 64) / divisor }, point = {"TOP", "BOTTOM", 32, 24}}, 
	["ctrlsh"] 	= {size = {size / divisor, size * (74 / 64) / divisor }, point = {"TOP", "BOTTOM", 0, 8}},
}

local config = {
	outOfRangeColoring = "button",
	tooltip = "enabled",
	showGrid = true,
	colors = {
		range = { 0.8, 0.1, 0.1 },
		mana = { 0.5, 0.5, 1.0 }
	},
	hideElements = {
		macro = false,
		hotkey = true,
		equipped = false,
	},
	keyBoundTarget = false,
	clickOnDown = false,
	flyoutDirection = "UP",
}

local function ClusterSetPoint(self, ...)
	return self.action and self.action:SetPoint(...)
end

local function ClusterSetSize(self, width, height)
	self.action:SetSize(width, height)
	self.action.NormalTexture:SetSize(width * (74 / 64), height * (74 / 64))

	self.shift:SetSize(width / divisor, height / divisor)
	self.shift.NormalTexture:SetSize((width / divisor) * (74 / 64), (height / divisor) * (74 / 64))

	self.ctrl:SetSize(width / divisor, height / divisor)
	self.ctrl.NormalTexture:SetSize((width / divisor) * (74 / 64), (height / divisor) * (74 / 64))

	self.ctrlsh:SetSize(width / divisor, height / divisor)
	self.ctrlsh.NormalTexture:SetSize((width / divisor) * (74 / 64), (height / divisor) * (74 / 64))
end

function Button:Create(parent, id)
	local cluster = {}

	for mod, info in pairs(mods) do
		local button = lib:CreateButton(id..mod, id.."_"..mod, parent, mod == "action" and config)

		button.icon:SetMask("Interface\\Minimap\\UI-Minimap-Background")

		button.NormalTexture:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Normal")
		button.NormalTexture:SetAlpha(0.75)
		button.NormalTexture:ClearAllPoints()
		button.NormalTexture:SetPoint("CENTER", 0, 0)

		button:GetHighlightTexture():SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Hilite")
		button:GetCheckedTexture():SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Hilite")
		button:GetPushedTexture():SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Pushed")

		button.cooldown:SetSwipeTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Normal")
		button.cooldown:SetBlingTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Bling")

		local bSize, tSize = unpack(info.size)

		button:SetSize(bSize, bSize)
		button.NormalTexture:SetSize(tSize, tSize)

		cluster[mod] = button
	end

	for mod, button in pairs(cluster) do
		local point = mods[mod].point
		if point then
			local point, relativePoint, xoffset, yoffset = unpack(point)
			button:SetPoint(point, cluster.action, relativePoint, xoffset, yoffset)
		end
	end

	cluster.action:SetFrameLevel(4)

	cluster.action.hotkey = CreateFrame("Frame", "$parent_HOTKEY", cluster.action)
	cluster.action.hotkey:SetPoint("TOP", 0, 12)
	cluster.action.hotkey:SetSize(32, 32)
	cluster.action.hotkey.texture = cluster.action.hotkey:CreateTexture("$parent_HOTKEY", "OVERLAY", nil, 7)
	cluster.action.hotkey.texture:SetTexture(gsub(db.TEXTURE[id], "Icons64x64", "Icons32x32"))
	cluster.action.hotkey.texture:SetAllPoints()

	cluster.SetSize = ClusterSetSize
	cluster.SetPoint = ClusterSetPoint

	return cluster
end

function Button:SetState(cluster, bindings)
	local main = cluster.action
	if bindings then
		for id, button in pairs(cluster) do
			if type(button) == "table" then
				local binding = bindings[id]
				local actionID = binding and ConsolePort:GetActionID(binding)
				local stateType, stateID
				if actionID then
					stateType, stateID = "action", actionID
				elseif binding then
					stateType = "custom"
					stateID = {
						tooltip = binding,
						texture = ConsolePort:GetBindingIcon(binding) or "Interface\\ICONS\\Temp",
						func = function() end,
					}
				else
					stateType = "custom"
					stateID = {
						tooltip = "NOTBOUND",
						texture = "Interface\\ICONS\\Temp",
						func = function() end,
					}
				end
				button:SetState("action", stateType, stateID)
				button:SetState(id, stateType, stateID)
				main:SetState(id, stateType, stateID)
				button:Show()
			end
		end
	else
		for id, button in pairs(cluster) do
			if type(button) == "table" then
				button:SetState(id, "custom", {
					tooltip = "NOTBOUND",
					texture = "Interface\\ICONS\\Temp",
					func = function() end,
				})
			end
		end
	end
	local maintype, mainaction = main:GetAttribute("labtype-action"), main:GetAttribute("labaction-action")
	if maintype == "action" and mainaction > 0 and mainaction <= 12 then
		main:SetID(mainaction)
	end
end

-- for btn=1, 12 do
-- 	local button = Lib:CreateButton(1, "LABTest"..btn, Bar)
-- 	button:SetPoint("LEFT", Bar, (btn-1)*70, 0)
-- 	button:Show()
-- 	button:SetState(1, "action", btn)
-- 	button:SetState(2, "action", btn)
-- 	button:SetSize(64, 64)

-- 	button.icon:SetMask("Interface\\Minimap\\UI-Minimap-Background")

-- 	button.NormalTexture:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Normal")
-- 	button.NormalTexture:SetAlpha(0.75)
-- 	button.NormalTexture:ClearAllPoints()
-- 	button.NormalTexture:SetPoint("CENTER", 0, 0)
-- 	button.NormalTexture:SetSize(74, 74)
-- 	button:HookScript("OnAttributeChanged", function(self, ...)
-- 	--	print(...)
-- 	end)

-- 	button:GetHighlightTexture():SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Hilite")
-- 	button:GetPushedTexture():SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Pushed")
-- 	button:GetCheckedTexture():SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Hilite")

-- 	button.cooldown:SetSwipeTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Normal")
-- 	button.cooldown:SetBlingTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Bling")
-- end