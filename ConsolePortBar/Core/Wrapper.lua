---------------------------------------------------------------
local db = ConsolePort:GetData()
local Lib, Wrapper = {}, {}
---------------------------------------------------------------
local an, ab = ...
local acb = ab.libs.acb
---------------------------------------------------------------
ab.libs.wrapper = Lib
---------------------------------------------------------------
local LibRegistry = {}
ab.libs.registry = LibRegistry
---------------------------------------------------------------
local TEX_PATH = [[Interface\AddOns\]]..an..[[\Textures\%s]]
local NOT_BOUND_TOOLTIP = NOT_BOUND .. '\n' .. db.TUTORIAL.BIND.TOOLTIPCLICK
---------------------------------------------------------------
local size, smallSize, tSize, ofs, ofsB = 64, 50, 90, 25, 4
local mods = {
	[''] = {size = {size, size}},
	['SHIFT-'] 	= {size = {smallSize, tSize}, 
		down 	= {rad(-180), {'TOPRIGHT', 'BOTTOMLEFT', ofs, ofs}},
		up 		= {rad(90), {'BOTTOMRIGHT', 'TOPLEFT', ofs, -ofs}},
		left 	= {rad(90), {'BOTTOMRIGHT', 'TOPLEFT', ofs, -ofs}},
		right 	= {0, {'BOTTOMLEFT', 'TOPRIGHT', -ofs, -ofs}},
	},
	['CTRL-'] 	= {size = {smallSize, tSize}, 
		down 	= {0, {'TOPLEFT', 'BOTTOMRIGHT', -ofs, ofs}},
		up 		= {rad(90), {'BOTTOMLEFT', 'TOPRIGHT', -ofs, -ofs}},
		left 	= {rad(-90), {'TOPRIGHT', 'BOTTOMLEFT', ofs, ofs}},
		right 	= {0, {'TOPLEFT', 'BOTTOMRIGHT', -ofs, ofs}},
	},
	['CTRL-SHIFT-'] = {size = {smallSize, tSize},
		down 	= {rad(-90), {'TOP', 'BOTTOM', 0, ofsB}},
		up 		= {rad(90), {'BOTTOM', 'TOP', 0, -ofsB}},
		left 	= {rad(180), {'RIGHT', 'LEFT', ofsB, 0}},
		right 	= {0, {'LEFT', 'RIGHT', -ofsB, 0}},
	},
}
local adjustTextures = {
	'Border',
	'NormalTexture',
	'HighlightTexture',
	'PushedTexture',
	'CheckedTexture',
	'NewActionTexture',
}
---------------------------------------------------------------
local hotkeyConfig = {
	['SHIFT-'] = {{{'CENTER', 0, 0}, {24, 24}, 'CP_M1'}},
	['CTRL-'] = {{{'CENTER', 0, 0}, {24, 24}, 'CP_M2'}},
	['CTRL-SHIFT-'] = {{{'CENTER', -6, 0}, {24, 24}, 'CP_M1'}, {{'CENTER', 6, 0}, {24, 24}, 'CP_M2'}},
}

---------------------------------------------------------------
local buttonTextures = {
	[''] = {
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
	['SHIFT-'] = {
		normal = format(TEX_PATH, [[Button\M1]]),
		pushed = format(TEX_PATH, [[Button\M1]]),
		border = format(TEX_PATH, [[Button\M1]]),
		hilite = format(TEX_PATH, [[Button\M1Hilite]]),
		checkd = format(TEX_PATH, [[Button\M1Hilite]]),
		new_action 	= format(TEX_PATH, [[Button\M1Hilite]]),
		cool_swipe 	= format(TEX_PATH, [[Cooldown\SwipeSmall]]),
	--	cool_edge 	= format(TEX_PATH, [[Cooldown\Edge]]),
		cool_charge = format(TEX_PATH, [[Cooldown\SwipeSmall]]),
		cool_bling 	= format(TEX_PATH, [[Cooldown\Bling]]),
	},
	['CTRL-'] = {
		normal = format(TEX_PATH, [[Button\M2]]),
		pushed = format(TEX_PATH, [[Button\M2]]),
		border = format(TEX_PATH, [[Button\M2]]),
		hilite = format(TEX_PATH, [[Button\M2Hilite]]),
		checkd = format(TEX_PATH, [[Button\M2Hilite]]),
		new_action 	= format(TEX_PATH, [[Button\M2Hilite]]),
		cool_swipe 	= format(TEX_PATH, [[Cooldown\SwipeSmall]]),
	--	cool_edge 	= format(TEX_PATH, [[Cooldown\Edge]]),
		cool_charge = format(TEX_PATH, [[Cooldown\SwipeSmall]]),
		cool_bling 	= format(TEX_PATH, [[Cooldown\Bling]]),
	},
	['CTRL-SHIFT-'] = {
		normal = format(TEX_PATH, [[Button\M3]]),
		pushed = format(TEX_PATH, [[Button\M3]]),
		border = format(TEX_PATH, [[Button\M3]]),
		hilite = format(TEX_PATH, [[Button\M3Hilite]]),
		checkd = format(TEX_PATH, [[Button\M3Hilite]]),
		new_action 	= format(TEX_PATH, [[Button\M3Hilite]]),
		cool_swipe 	= format(TEX_PATH, [[Cooldown\SwipeSmall]]),
	--	cool_edge 	= format(TEX_PATH, [[Cooldown\Edge]]),
		cool_charge = format(TEX_PATH, [[Cooldown\SwipeSmall]]),
		cool_bling 	= format(TEX_PATH, [[Cooldown\Bling]]),
	},
}

---------------------------------------------------------------
local config = {
	tooltip = 'enabled',
	showGrid = true,
	colors = {
		range = { 0.8, 0.1, 0.1 },
		mana = { 0.5, 0.5, 1.0 }
	},
	hideElements = {
		macro = false,
		equipped = false,
	},
	keyBoundTarget = false,
	clickOnDown = true,
	flyoutDirection = 'UP',
}
---------------------------------------------------------------
local function CreateHotkeyFrame(self, num)
	local hotkey = CreateFrame('Frame', '$parent_HOTKEY'..( num or '' ), self)
	hotkey.texture = hotkey:CreateTexture('$parent_TEXTURE', 'OVERLAY', nil, 7)
	hotkey.texture:SetTexture(db.ICONS[id])
	hotkey.texture:SetAllPoints()
	return hotkey
end

function Lib:CreateButton(parent, id, name, modifier, size, texSize, config, template)
	local button = acb:CreateButton(id, name, parent, config, template)

	button.PushedTexture = button:GetPushedTexture()
	button.HighlightTexture = button:GetHighlightTexture()
	button.CheckedTexture = button:GetCheckedTexture()

	local textures = buttonTextures[modifier]

	-- Big button
	if modifier == '' then
		button.icon:SetMask('Interface\\Minimap\\UI-Minimap-Background')
	else -- Small button
		button.icon:SetMask('Interface\\RAIDFRAME\\UI-RaidFrame-Threat')
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

	for _, name in pairs(adjustTextures) do
		local texture = button[name]
		texture:ClearAllPoints()
		texture:SetPoint('CENTER', 0, 0)
		texture:SetSize(texSize, texSize)
	end

	button:SetSize(size, size)
	button:SetAlpha(0)

	return button
end

function Wrapper:Show()
	for _, button in pairs(self.Buttons) do
		button:Show()
	end
	self[''].shadow:Show()
end

function Wrapper:Hide()
	for _, button in pairs(self.Buttons) do
		button:Hide()
	end
	self[''].shadow:Hide()
end

function Wrapper:SetPoint(...)
	local main = self['']
	local p, x, y = ...
	main:ClearAllPoints()
	if p and x and y then
		return main:SetPoint(...)
	end
end

function Wrapper:SetSize(new)
	-- NYI
	local main = self['']
	for mod, button in pairs(self.Buttons) do
		local b, t, o
		if mod == '' then
			b = new -- 64
			t = new
			o = new * ( 82 / size )
			button.shadow:SetSize(o, o)
		else
			b = new * ( smallSize / size )
			t = new * ( tSize / size )
			o = new * ( ( (mod == 'CTRL-SHIFT-') and ofsB or ofs ) / size )
			local pT = mods[mod][button.orientation]
			if pT then
				local p, rel, x, y = unpack(pT[2])
				local nX = x < 0 and -o or x == 0 and 0 or o
				local nY = y < 0 and -o or y == 0 and 0 or o
				button:SetPoint(p, main, rel, nX, nY)
				button:Show()
			end
		end
		for _, name in pairs(adjustTextures) do
			local texture = button[name]
			texture:ClearAllPoints()
			texture:SetPoint('CENTER', 0, 0)
			texture:SetSize(t, t)
		end
		button:SetSize(b, b)
	end
end

function Wrapper:UpdateOrientation(orientation)
	local main = self['']
	for mod, button in pairs(self.Buttons) do
		if not button.isMainButton then
			button:ClearAllPoints()
			button:Hide()
			button.orientation = orientation
			local point, rotation
			local setup = mods[mod][orientation]
			if setup then
				rotation = setup[1]
			end
			if rotation then
				for _, name in pairs(adjustTextures) do
					local texture = button[name]
					texture:SetRotation(rotation)
				end
			end
		end
	end
	self:SetSize(self['']:GetSize())
end

function Wrapper:SetSwipeColor(r, g, b, a)
	self.SwipeColor = {r, g, b, a}
	local main = self['']
	main.cooldown:SetSwipeColor(r, g, b, a)
end

function Wrapper:GetSwipeColor()
	if self.SwipeColor then
		return unpack(self.SwipeColor)
	end
end

function Wrapper:SetBorderColor(r, g, b, a)
	self.BorderColor = {r, g, b, a}
	for mod, button in pairs(self.Buttons) do
		button.NormalTexture:SetVertexColor(r, g, b, a)
	end
end

function Wrapper:GetBorderColor()
	if self.BorderColor then
		return unpack(self.BorderColor)
	end
end


function Wrapper:SetRebindButton()
	-- Messy code to focus this button in the rebinder
	if not InCombatLockdown() then
		ConsolePortConfig:OpenCategory('Binds')
		if ConsolePortConfigContainerBinds.Display:GetID() ~= 2 then
			db.Settings.bindView = 2
			ConsolePortConfigContainerBinds.Display:SetID(2)
			ConsolePortConfigContainerBinds:OnShow()
		end
		local bindingBtn = _G[self.confRef]
		C_Timer.After(0.1, function()
			if not InCombatLockdown() then
				ConsolePort:ScrollToNode(bindingBtn, ConsolePortRebindFrame)
			end
		end)
	end
end

function Lib:Get(id)
	return LibRegistry[id]
end

function Lib:Create(parent, id, orientation)
	local wrapper = {}
	wrapper.Buttons = {}

	for mod, info in pairs(mods) do
		local bSize, tSize = unpack(info.size)
		local button = Lib:CreateButton(parent, id..mod, 'CPB_'..id..mod, mod, bSize, tSize, mod == '' and config)
		button.plainID = id
		wrapper[mod] = button
		wrapper.Buttons[mod] = button
		if hotkeyConfig[mod] then
			for i, modHotkey in pairs(hotkeyConfig[mod]) do
				local hotkey = CreateHotkeyFrame(button, i)
				hotkey:SetPoint(unpack(modHotkey[1]))
				hotkey:SetSize(unpack(modHotkey[2]))
				hotkey.texture:SetTexture(db.ICONS[modHotkey[3]])
				hotkey:SetAlpha(0.75)
				button['hotkey'..i] = hotkey
			end
		end
	end

	local main = wrapper['']
	main.isMainButton = true
	main.icons = {}

	for mod, button in pairs(wrapper.Buttons) do
		if not button.isMainButton then
			-- Set this button to not update on modifier state
			button:SetAttribute('_childupdate-state', nil)
			-- Add extra icons to reduce redunant icon updates when holding modifiers
			local modIcon = main:CreateTexture('$parentIcon'..mod, 'BACKGROUND', nil, 2)
			modIcon:SetAllPoints()
			modIcon:SetMask('Interface\\Minimap\\UI-Minimap-Background')
			modIcon:SetAlpha(0)
			button.mainIcon = modIcon
			main.icons[mod] = modIcon
		end
	end

	main:SetFrameLevel(4)
	main:SetAlpha(1)

	db.UIFrameFadeIn(main, 1, 0, 1)

	main.hotkey = CreateFrame('Frame', '$parent_HOTKEY', main)
	main.hotkey:SetPoint('TOP', 0, 12)
	main.hotkey:SetSize(32, 32)
	main.hotkey.texture = main.hotkey:CreateTexture('$parent_HOTKEY', 'OVERLAY', nil, 7)
	main.hotkey.texture:SetTexture(db.ICONS[id])
	main.hotkey.texture:SetAllPoints()

	main.hotkey:SetFrameLevel(20)

	-- create this as a separate frame so that drop shadow doesn't overlay modifiers
	main.shadow = CreateFrame('Frame', main:GetName()..'_SHADOW', ab.bar)
	main.shadow:SetPoint('CENTER', main, 'CENTER', 0, -6)
	main.shadow:SetSize(82, 82)
	main.shadow.texture = main.shadow:CreateTexture('$parent_shadow', 'OVERLAY', nil, 7)
	main.shadow.texture:SetTexture(format(TEX_PATH, 'Button\\BigShadow'))
	main.shadow.texture:SetAllPoints()
	main.shadow:SetFrameLevel(1)
	main.shadow:SetAlpha(0.75)

	Mixin(wrapper, Wrapper)

	wrapper:UpdateOrientation(orientation)

	LibRegistry[id] = wrapper

	return wrapper
end

--- Temporary stuff
local swapTypes = {
	swapmain = function(wrapper, id, button, stateType, stateID)
		if id ~= '' then
			button:SetState('', stateType, stateID)
			button:SetState('SHIFT-', stateType, stateID)
			button:SetState('CTRL-', stateType, stateID)
			button:SetState('CTRL-SHIFT-', stateType, stateID)
		end
		wrapper['']:SetState(id, stateType, stateID)
	end,
	noswap = function(wrapper, id, button, stateType, stateID)
		button:SetState('', stateType, stateID)
		button:SetState('SHIFT-', stateType, stateID)
		button:SetState('CTRL-', stateType, stateID)
		button:SetState('CTRL-SHIFT-', stateType, stateID)
	end,
}

function Lib:UpdateAllBindings(newBindings)
	local bindings = newBindings or db.Bindings
	ClearOverrideBindings(ab.bar)
	if type(bindings) == 'table' then
		for binding, wrapper in pairs(LibRegistry) do
			self:SetState(wrapper, bindings[binding])
		end
	end
end

function Lib:SetEligbleForRebind(button, id)
	button.confRef = button.plainID..id..'_CONF'
	button:SetAttribute('disableDragNDrop', true)
	button:SetState(id, 'custom', {
		tooltip = NOT_BOUND_TOOLTIP,
		texture = 'Interface\\Icons\\Pet_Type_Mechanical',
		func = Wrapper.SetRebindButton,
	})
end

function Lib:SetArbitraryBinding(button, binding)
	button:SetAttribute('disableDragNDrop', true)
	return 'custom', {
		tooltip = _G['BINDING_NAME_'..binding] or binding,
		texture = ab:GetBindingIcon(binding) or 'Interface\\MacroFrame\\MacroFrame-Icon',
		func = function() end,
	}
end

function Lib:SetActionBinding(button, main, id, actionID)
	local key = GetBindingKey(button.plainID)
	if key then
		ab.bar:RegisterOverride(id..key, main:GetName())
	end
	button:SetAttribute('disableDragNDrop', (ab.cfg and ab.cfg.disablednd and true) or false)
	return 'action', actionID
end

function Lib:SetState(wrapper, bindings)
	local main = wrapper['']

	if bindings then
		for id, button in pairs(wrapper.Buttons) do
			local binding = bindings[id]
			local actionID = binding and ConsolePort:GetActionID(binding)
			local stateType, stateID
			if actionID then
				stateType, stateID = self:SetActionBinding(button, main, id, actionID)
			elseif binding then
				stateType, stateID = self:SetArbitraryBinding(button, binding)
			else
				self:SetEligbleForRebind(button, id)
			end
			swapTypes['swapmain'](wrapper, id, button, stateType, stateID)
			button:Execute(format([[
				self:RunAttribute('UpdateState', '%s')
				self:CallMethod('UpdateAction')
			]], id))
		end
	else
		for id, button in pairs(wrapper.Buttons) do
			self:SetEligbleForRebind(button, id)
		end
	end
end