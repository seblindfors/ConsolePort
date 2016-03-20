---------------------------------------------------------------
local db = ConsolePort:DB()
local Wrapper = {}
---------------------------------------------------------------
local an, ab = ...
local lib = ab.libs.acb
---------------------------------------------------------------
ab.libs.button = Wrapper

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

function Wrapper:CreateButton(parent, id, name, size, texSize, config, template)
	local button = lib:CreateButton(id, name, parent, config, template)

	button.icon:SetMask("Interface\\Minimap\\UI-Minimap-Background")

	button.NormalTexture:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Normal")
	button.NormalTexture:SetAlpha(0.75)
	button.NormalTexture:ClearAllPoints()
	button.NormalTexture:SetPoint("CENTER", 0, 0)

	button.PushedTexture = button:GetPushedTexture()
	button.PushedTexture:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Pushed")

	button:GetHighlightTexture():SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Hilite")
	button:GetCheckedTexture():SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Hilite")

	button.cooldown:SetSwipeTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Normal")
	button.cooldown:SetBlingTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Bling")

	button:SetSize(size, size)
	button.NormalTexture:SetSize(texSize, texSize)
	button.PushedTexture:SetSize(texSize, texSize)

	return button
end

function Wrapper:SetPoint(...)
	return self.action and self.action:SetPoint(...)
end

function Wrapper:SetSize(width, height)
	self.action:SetSize(width, height)
	self.action.NormalTexture:SetSize(width * (74 / 64), height * (74 / 64))

	self.shift:SetSize(width / divisor, height / divisor)
	self.shift.NormalTexture:SetSize((width / divisor) * (74 / 64), (height / divisor) * (74 / 64))

	self.ctrl:SetSize(width / divisor, height / divisor)
	self.ctrl.NormalTexture:SetSize((width / divisor) * (74 / 64), (height / divisor) * (74 / 64))

	self.ctrlsh:SetSize(width / divisor, height / divisor)
	self.ctrlsh.NormalTexture:SetSize((width / divisor) * (74 / 64), (height / divisor) * (74 / 64))
end

function Wrapper:Create(parent, id)
	local wrapper = {}

	for mod, info in pairs(mods) do
		local bSize, tSize = unpack(info.size)
		local button = Wrapper:CreateButton(parent, id..mod, id.."_"..mod, bSize, tSize, mod == "action" and config)
		wrapper[mod] = button
	end

	for mod, button in pairs(wrapper) do
		local point = mods[mod].point
		if point then
			local point, relativePoint, xoffset, yoffset = unpack(point)
			button:SetPoint(point, wrapper.action, relativePoint, xoffset, yoffset)
		end
	end

	wrapper.action:SetFrameLevel(4)

	wrapper.action.hotkey = CreateFrame("Frame", "$parent_HOTKEY", wrapper.action)
	wrapper.action.hotkey:SetPoint("TOP", 0, 12)
	wrapper.action.hotkey:SetSize(32, 32)
	wrapper.action.hotkey.texture = wrapper.action.hotkey:CreateTexture("$parent_HOTKEY", "OVERLAY", nil, 7)
	wrapper.action.hotkey.texture:SetTexture(gsub(db.TEXTURE[id], "Icons64x64", "Icons32x32"))
	wrapper.action.hotkey.texture:SetAllPoints()

	wrapper.SetSize = Wrapper.SetSize
	wrapper.SetPoint = Wrapper.SetPoint

	return wrapper
end

--- Temporary stuff
local swapTypes = {
	["noswap"] = function(wrapper, id, button, stateType, stateID)
		if id ~= "action" then
			button:SetState("action", stateType, stateID)
			button:SetState("shift", stateType, stateID)
			button:SetState("ctrl", stateType, stateID)
			button:SetState("ctrlsh", stateType, stateID)
		end
		wrapper.action:SetState(id, stateType, stateID)
	end,
	["swaphide"] = function(wrapper, id, button, stateType, stateID)
		if id ~= "action" then
			button:SetState("action", stateType, stateID)
			button:SetState("shift", stateType, stateID)
			button:SetState("ctrl", stateType, stateID)
			button:SetState("ctrlsh", stateType, stateID)
			button:SetState(id, "empty")
		end
		wrapper.action:SetState(id, stateType, stateID)
	end,
	["swapmain"] = function(wrapper, id, button, stateType, stateID)
		if id == "action" then
			wrapper.ctrlsh:SetState("ctrlsh", stateType, stateID)
			wrapper.ctrlsh:SetState("shift", stateType, stateID)
			wrapper.ctrlsh:SetState("ctrl", stateType, stateID)
		end
		wrapper.action:SetState(id, stateType, stateID)
	end,
	["onlymain"] = function(wrapper, id, button, stateType, stateID)
		wrapper.action:SetState(id, stateType, stateID)
	end,
}

function Wrapper:SetState(wrapper, bindings)
	local main = wrapper.action

	if bindings then
		for id, button in pairs(wrapper) do
			if type(button) == "table" then
				local binding = bindings[id]
				local actionID = binding and ConsolePort:GetActionID(binding)
				local stateType, stateID
				if actionID then
					stateType, stateID = "action", actionID
				elseif binding then
					stateType = "custom"
					stateID = {
						tooltip = _G["BINDING_NAME_"..binding] or binding,
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
				swapTypes["noswap"](wrapper, id, button, stateType, stateID)
				if id == "action" then
					button:SetAttribute("mainbutton", true)
					button.isMainButton = true
				end
				button:SetAttribute("mainstate", id)
				button:Show()
			end
		end
	else
		for id, button in pairs(wrapper) do
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