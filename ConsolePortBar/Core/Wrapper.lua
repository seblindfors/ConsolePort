---------------------------------------------------------------
local db = ConsolePort:GetData()
local Wrapper = {}
---------------------------------------------------------------
local an, ab = ...
local lib = ab.libs.acb
---------------------------------------------------------------
ab.libs.button = Wrapper
---------------------------------------------------------------
local WrapperRegistry = {}
ab.libs.registry = WrapperRegistry
---------------------------------------------------------------
local divisor = 1.5
local size = 52
local mods = {
	[""] 	= {size = {size, size * (74 / 64)}},
	["SHIFT-"] 	= {size = {size / divisor, size * (74 / 64) / divisor }, point = {"TOP", "BOTTOM", -28, 24}}, 
	["CTRL-"] 	= {size = {size / divisor, size * (74 / 64) / divisor }, point = {"TOP", "BOTTOM", 28, 24}}, 
	["CTRL-SHIFT-"] = {size = {size / divisor, size * (74 / 64) / divisor }, point = {"TOP", "BOTTOM", 0, 8}},
}
---------------------------------------------------------------
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
---------------------------------------------------------------

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

	button.Border:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Hilite")
	button.Border:ClearAllPoints()
	button.Border:SetPoint("CENTER", 0, 0)
	button.Border:SetSize(texSize, texSize)

	button.cooldown:SetSwipeTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Normal")
	button.cooldown:SetBlingTexture("Interface\\AddOns\\ConsolePort\\Textures\\Button\\Bling")

	button:SetSize(size, size)
	button:SetAlpha(0)
	button.NormalTexture:SetSize(texSize, texSize)
	button.PushedTexture:SetSize(texSize, texSize)

	return button
end

function Wrapper:SetPoint(...)
	return self[""] and self[""]:SetPoint(...)
end

function Wrapper:SetSize(width, height)
	self[""]:SetSize(width, height)
	self[""].NormalTexture:SetSize(width * (74 / 64), height * (74 / 64))

	self["SHIFT-"]:SetSize(width / divisor, height / divisor)
	self["SHIFT-"].NormalTexture:SetSize((width / divisor) * (74 / 64), (height / divisor) * (74 / 64))

	self["CTRL-"]:SetSize(width / divisor, height / divisor)
	self["CTRL-"].NormalTexture:SetSize((width / divisor) * (74 / 64), (height / divisor) * (74 / 64))

	self["CTRL-SHIFT-"]:SetSize(width / divisor, height / divisor)
	self["CTRL-SHIFT-"].NormalTexture:SetSize((width / divisor) * (74 / 64), (height / divisor) * (74 / 64))
end

function Wrapper:Create(parent, id)
	local wrapper = {}

	for mod, info in pairs(mods) do
		local bSize, tSize = unpack(info.size)
		local button = Wrapper:CreateButton(parent, id..mod, id.."_"..mod, bSize, tSize, mod == "" and config)
		wrapper[mod] = button
	end

	for mod, button in pairs(wrapper) do
		local point = mods[mod].point
		if point then
			local point, relativePoint, xoffset, yoffset = unpack(point)
			button:SetPoint(point, wrapper[""], relativePoint, xoffset, yoffset)
			button:SetAttribute("_childupdate-state", nil)
		end
	end

	local main = wrapper[""]
	main.isMainButton = true

	main:SetFrameLevel(4)
	main:SetAlpha(1)

	main.hotkey = CreateFrame("Frame", "$parent_HOTKEY", main)
	main.hotkey:SetPoint("TOP", 0, 12)
	main.hotkey:SetSize(32, 32)
	main.hotkey.texture = main.hotkey:CreateTexture("$parent_HOTKEY", "OVERLAY", nil, 7)
	main.hotkey.texture:SetTexture(db.ICONS[id])
	main.hotkey.texture:SetAllPoints()

	wrapper.SetSize = Wrapper.SetSize
	wrapper.SetPoint = Wrapper.SetPoint

	WrapperRegistry[id] = wrapper

	return wrapper
end

--- Temporary stuff
local swapTypes = {
	["noswap"] = function(wrapper, id, button, stateType, stateID)
		if id ~= "" then
			button:SetState("", stateType, stateID)
			button:SetState("SHIFT-", stateType, stateID)
			button:SetState("CTRL-", stateType, stateID)
			button:SetState("CTRL-SHIFT-", stateType, stateID)
		end
		wrapper[""]:SetState(id, stateType, stateID)
	end,
	["swaphide"] = function(wrapper, id, button, stateType, stateID)
		if id ~= "" then
			button:SetState("", stateType, stateID)
			button:SetState("SHIFT-", stateType, stateID)
			button:SetState("CTRL-", stateType, stateID)
			button:SetState("CTRL-SHIFT-", stateType, stateID)
			button:SetState(id, "empty")
		end
		wrapper[""]:SetState(id, stateType, stateID)
	end,
	["swapmain"] = function(wrapper, id, button, stateType, stateID)
		if id == "" then
			wrapper["CTRL-SHIFT-"]:SetState("CTRL-SHIFT-", stateType, stateID)
			wrapper["CTRL-SHIFT-"]:SetState("SHIFT-", stateType, stateID)
			wrapper["CTRL-SHIFT-"]:SetState("CTRL-", stateType, stateID)
		end
		wrapper[""]:SetState(id, stateType, stateID)
	end,
	["onlymain"] = function(wrapper, id, button, stateType, stateID)
		wrapper[""]:SetState(id, stateType, stateID)
	end,
}

function Wrapper:UpdateAllBindings(newBindings)
	local bindings = newBindings or db.Bindings
	if type(bindings) == "table" then
		for binding, wrapper in pairs(WrapperRegistry) do
			self:SetState(wrapper, bindings[binding])
		end
	end
end

function Wrapper:SetState(wrapper, bindings)
	local main = wrapper[""]

	if bindings then
		for id, button in pairs(wrapper) do
			if type(button) == "table" then
				local binding = bindings[id]
				local actionID = binding and ConsolePort:GetActionID(binding)
				local stateType, stateID
				if actionID then
					button:SetAttribute("LABdisableDragNDrop", false)
					stateType, stateID = "action", actionID
				elseif binding then
					button:SetAttribute("LABdisableDragNDrop", true)
					stateType = "custom"
					stateID = {
						tooltip = _G["BINDING_NAME_"..binding] or binding,
						texture = ab:GetBindingIcon(binding) or "Interface\\MacroFrame\\MacroFrame-Icon",
						func = function() end,
					}
				else
					button:SetAttribute("LABdisableDragNDrop", true)
					stateType = "custom"
					stateID = {
						tooltip = NOT_BOUND,
						texture = "Interface\\RAIDFRAME\\ReadyCheck-Waiting",
						func = function() end,
					}
				end
				swapTypes["noswap"](wrapper, id, button, stateType, stateID)
				button:Execute(format([[
					self:RunAttribute("UpdateState", "%s")
					self:CallMethod("UpdateAction")
				]], id))
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
	local maintype, mainaction = main:GetAttribute("labtype-"), main:GetAttribute("labaction-")
	if maintype == "action" and mainaction > 0 and mainaction <= 12 then
		main:SetID(mainaction)
	end
end