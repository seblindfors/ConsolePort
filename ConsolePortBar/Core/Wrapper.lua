---------------------------------------------------------------
local db = ConsolePort:GetData()
local Wrapper = {}
---------------------------------------------------------------
local an, ab = ...
local lib = ab.libs.acb
---------------------------------------------------------------
ab.libs.wrapper = Wrapper
---------------------------------------------------------------
local WrapperRegistry = {}
ab.libs.registry = WrapperRegistry
---------------------------------------------------------------
local TEX_PATH = [[Interface\AddOns\]]..an..[[\Textures\%s]]
---------------------------------------------------------------
local size, smallSize = 64, 50
local mods = {
	[""] = {size = {size, size}},
	["SHIFT-"] 	= {size = {smallSize, size}, 
		down 	= {"TOPRIGHT", "BOTTOMLEFT", 28, 28},
		up 		= {"BOTTOMRIGHT", "TOPLEFT", 28, -28},
		left 	= {"BOTTOMRIGHT", "TOPLEFT", 28, -28},
		right 	= {"BOTTOMLEFT", "TOPRIGHT", -28, -28},
	},
	["CTRL-"] 	= {size = {smallSize, size}, 
		down 	= {"TOPLEFT", "BOTTOMRIGHT", -28, 28},
		up 		= {"BOTTOMLEFT", "TOPRIGHT", -28, -28},
		left 	= {"TOPRIGHT", "BOTTOMLEFT", 28, 28},
		right 	= {"TOPLEFT", "BOTTOMRIGHT", -28, 28},
	},
	["CTRL-SHIFT-"] = {size = {smallSize, size },
		down = {"TOP", "BOTTOM", 0, 8},
		up = {"BOTTOM", "TOP", 0, -8},
		left = {"RIGHT", "LEFT", 8, 0},
		right = {"LEFT", "RIGHT", -8, 0},
	},
}
---------------------------------------------------------------
local hotkeyConfig = {
	["SHIFT-"] = {{{"CENTER", 0, 0}, {24, 24}, "CP_M1"}},
	["CTRL-"] = {{{"CENTER", 0, 0}, {24, 24}, "CP_M2"}},
	["CTRL-SHIFT-"] = {{{"CENTER", -6, 0}, {24, 24}, "CP_M1"}, {{"CENTER", 6, 0}, {24, 24}, "CP_M2"}},
}
---------------------------------------------------------------
local buttonTextures = {
	big = {
		normal = format(TEX_PATH, [[Button\BigNormal]]),
		pushed = format(TEX_PATH, [[Button\BigPushed]]),
		hilite = format(TEX_PATH, [[Button\BigHilite]]),
		checkd = format(TEX_PATH, [[Button\BigHilite]]),
		border = format(TEX_PATH, [[Button\BigHilite]]),
		new_action 	= format(TEX_PATH, [[Button\BigHilite]]),
		cool_swipe 	= format(TEX_PATH, [[Cooldown\Swipe]]),
		cool_edge 	= format(TEX_PATH, [[Cooldown\Edge]]),
		cool_charge = format(TEX_PATH, [[Cooldown\Charge]]),
		cool_bling 	= format(TEX_PATH, [[Cooldown\Bling]]),
	},
	small = {
		normal = format(TEX_PATH, [[Button\SmallNormal]]),
		pushed = format(TEX_PATH, [[Button\SmallNormal]]),
		hilite = format(TEX_PATH, [[Button\SmallHilite]]),
		checkd = format(TEX_PATH, [[Button\SmallHilite]]),
		border = format(TEX_PATH, [[Button\SmallHilite]]),
		new_action 	= format(TEX_PATH, [[Button\SmallHilite]]),
		cool_swipe 	= format(TEX_PATH, [[Cooldown\SwipeSmall]]),
	--	cool_edge 	= format(TEX_PATH, [[Cooldown\Edge]]),
		cool_charge = format(TEX_PATH, [[Cooldown\SwipeSmall]]),
		cool_bling 	= format(TEX_PATH, [[Cooldown\Bling]]),
	},
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
	clickOnDown = true,
	flyoutDirection = "UP",
}
---------------------------------------------------------------
local function CreateHotkeyWrapper(self, num)
	local hotkey = CreateFrame("Frame", "$parent_HOTKEY"..( num or "" ), self)
	hotkey.texture = hotkey:CreateTexture("$parent_TEXTURE", "OVERLAY", nil, 7)
	hotkey.texture:SetTexture(db.ICONS[id])
	hotkey.texture:SetAllPoints()
	return hotkey
end

function Wrapper:CreateButton(parent, id, name, modifier, size, texSize, config, template)
	local button = lib:CreateButton(id, name, parent, config, template)

	button.PushedTexture = button:GetPushedTexture()
	button.HighlightTexture = button:GetHighlightTexture()
	button.CheckedTexture = button:GetCheckedTexture()

	local textures

	-- Big button
	if modifier == "" then
		button.icon:SetMask("Interface\\Minimap\\UI-Minimap-Background")
		button.HighlightTexture:SetSize(62, 62)
		textures = buttonTextures.big
	else -- Small button
		button.icon:SetMask("Interface\\RAIDFRAME\\UI-RaidFrame-Threat")
		textures = buttonTextures.small
	end

	button.NewActionTexture:SetTexture(textures.new_action)
	button.NormalTexture:SetTexture(textures.normal)
	button.PushedTexture:SetTexture(textures.pushed)
	button.CheckedTexture:SetTexture(textures.checkd)
	button.HighlightTexture:SetTexture(textures.hilite)
	button.Border:SetTexture(textures.border)

	button.cooldown:SetSwipeTexture(textures.cool_swipe)
	button.cooldown:SetBlingTexture(textures.cool_bling)

	if textures.cool_edge then
		button.cooldown:SetEdgeTexture(textures.cool_edge)
		button.cooldown:SetDrawEdge(true)
	else
		button.cooldown:SetDrawEdge(false)
	end

	button.NormalTexture:ClearAllPoints()
	button.HighlightTexture:ClearAllPoints()
	button.PushedTexture:ClearAllPoints()
	button.Border:ClearAllPoints()

	button.NewActionTexture:SetAllPoints()

	button.NormalTexture:SetPoint("CENTER", 0, 0)
	button.PushedTexture:SetPoint("CENTER", 0, 0)
	button.HighlightTexture:SetPoint("CENTER", 0, 0)
	button.Border:SetPoint("CENTER", 0, 0)

	button:SetSize(size, size)
	button:SetAlpha(0)

	button.NormalTexture:SetSize(texSize, texSize)
	button.PushedTexture:SetSize(texSize * 1, texSize * 1)
	button.Border:SetSize(texSize, texSize)

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

function Wrapper:Create(parent, id, orientation)
	local wrapper = {}

	for mod, info in pairs(mods) do
		local bSize, tSize = unpack(info.size)
		local button = Wrapper:CreateButton(parent, id..mod, "CPB_"..id..mod, mod, bSize, tSize, mod == "" and config)
		button.plainID = id
		wrapper[mod] = button
		if hotkeyConfig[mod] then
			for i, modHotkey in pairs(hotkeyConfig[mod]) do
				local hotkey = CreateHotkeyWrapper(button, i)
				hotkey:SetPoint(unpack(modHotkey[1]))
				hotkey:SetSize(unpack(modHotkey[2]))
				hotkey.texture:SetTexture(db.ICONS[modHotkey[3]])
				hotkey:SetAlpha(0.75)
				button["hotkey"..i] = hotkey
			end
		end
	end

	for mod, button in pairs(wrapper) do
		local point = mods[mod][orientation]
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

	db.UIFrameFadeIn(main, 1, 0, 1)

	main.hotkey = CreateFrame("Frame", "$parent_HOTKEY", main)
	main.hotkey:SetPoint("TOP", 0, 12)
	main.hotkey:SetSize(32, 32)
	main.hotkey.texture = main.hotkey:CreateTexture("$parent_HOTKEY", "OVERLAY", nil, 7)
	main.hotkey.texture:SetTexture(db.ICONS[id])
	main.hotkey.texture:SetAllPoints()

	main.hotkey:SetFrameLevel(20)

	main.shadow = CreateFrame("Frame", "$parent_SHADOW", ab.bar)
	main.shadow:SetPoint("CENTER", main, "CENTER", 0, -6)
	main.shadow:SetSize(82, 82)
	main.shadow.texture = main.shadow:CreateTexture("$parent_shadow", "OVERLAY", nil, 7)
	main.shadow.texture:SetTexture(format(TEX_PATH, "Button\\BigShadow"))
	main.shadow.texture:SetAllPoints()
	main.shadow:SetFrameLevel(1)

	wrapper.SetSize = Wrapper.SetSize
	wrapper.SetPoint = Wrapper.SetPoint

	WrapperRegistry[id] = wrapper

	return wrapper
end

--- Temporary stuff
local swapTypes = {
	swapmain = function(wrapper, id, button, stateType, stateID)
		if id ~= "" then
			button:SetState("", stateType, stateID)
			button:SetState("SHIFT-", stateType, stateID)
			button:SetState("CTRL-", stateType, stateID)
			button:SetState("CTRL-SHIFT-", stateType, stateID)
		end
		wrapper[""]:SetState(id, stateType, stateID)
	end,
	noswap = function(wrapper, id, button, stateType, stateID)
		button:SetState("", stateType, stateID)
		button:SetState("SHIFT-", stateType, stateID)
		button:SetState("CTRL-", stateType, stateID)
		button:SetState("CTRL-SHIFT-", stateType, stateID)
	end,
}

function Wrapper:UpdateAllBindings(newBindings)
	local bindings = newBindings or db.Bindings
	ClearOverrideBindings(ab.bar)
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
					local key = GetBindingKey(button.plainID)
					if key then
						ab.bar:RegisterOverride(id..key, main:GetName())
					end
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
						texture = "Interface\\RAIDFRAME\\ReadyCheck-NotReady",
						func = function() end,
					}
				end
				swapTypes["swapmain"](wrapper, id, button, stateType, stateID)
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
					tooltip = NOT_BOUND,
					texture = "Interface\\RAIDFRAME\\ReadyCheck-NotReady",
					func = function() end,
				})
			end
		end
	end
end