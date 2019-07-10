---------------------------------------------------------------
local db = ConsolePort:GetData()
local HANDLE, WrapperMixin = {}, {}
---------------------------------------------------------------
local an, ab = ...
local acb = ab.libs.acb
---------------------------------------------------------------
ab.libs.wrapper = HANDLE
---------------------------------------------------------------
local Wrappers = {}
ab.libs.registry = Wrappers
---------------------------------------------------------------
local TEX_PATH = [[Interface\AddOns\]]..an..[[\Textures\%s]]
local NOT_BOUND_TOOLTIP = NOT_BOUND .. '\n' .. db.TUTORIAL.BIND.TOOLTIPCLICK
---------------------------------------------------------------
local size, smallSize, tSize = 64, 46, 58
local ofs, ofsB, fixA = 38, 21, 4
---------------------------------------------------------------
local mods = {
	[''] = {size = {size, size}},
	['SHIFT-'] 	= {size = {smallSize, tSize}, 
		down 	= {'TOPRIGHT', 'BOTTOMLEFT',  ofs - fixA,  ofs + fixA},
		up 		= {'BOTTOMRIGHT', 'TOPLEFT',  ofs - fixA, -ofs - fixA},
		left 	= {'BOTTOMRIGHT', 'TOPLEFT',  ofs + fixA, -ofs + fixA},
		right 	= {'BOTTOMLEFT', 'TOPRIGHT', -ofs - fixA, -ofs + fixA},
	},
	['CTRL-'] 	= {size = {smallSize, tSize}, 
		down 	= {'TOPLEFT', 'BOTTOMRIGHT', -ofs + fixA,  ofs + fixA},
		up 		= {'BOTTOMLEFT', 'TOPRIGHT', -ofs + fixA, -ofs - fixA},
		left 	= {'TOPRIGHT', 'BOTTOMLEFT',  ofs + fixA,  ofs - fixA},
		right 	= {'TOPLEFT', 'BOTTOMRIGHT', -ofs - fixA,  ofs - fixA},
	},
	['CTRL-SHIFT-'] = {size = {smallSize, tSize},
		down 	= {'TOP', 'BOTTOM', 0, ofsB},
		up 		= {'BOTTOM', 'TOP', 0, -ofsB},
		left 	= {'RIGHT', 'LEFT', ofsB, 0},
		right 	= {'LEFT', 'RIGHT', -ofsB, 0},
	},
}

local modcoords = { -- ULx, ULy, LLx, LLy, URx, URy, LRx, LRy
	['SHIFT-'] = {
		down 	= {0, 0, 	1, 0, 	0, 1, 	1, 1},
		up 		= {1, 0,	0, 0,	1, 1,	0, 1},
		left 	= {1, 0,	1, 1,	0, 0,	0, 1},
		right 	= {0, 0, 	0, 1, 	1, 0,	1, 1},
	},
	['CTRL-'] = {
		down 	= {0, 1,	1, 1,	0, 0,	1, 0},
		up 		= {1, 1,	0, 1,	1, 0,	0, 0},
		left 	= {1, 1, 	1, 0,	0, 1,	0, 0},
		right 	= {0, 1,	0, 0,	1, 1,	1, 0},
	},
	['CTRL-SHIFT-'] = {
		down 	= {0, 1,	1, 1,	0, 0,	1, 0},
		up 		= {1, 0,	0, 0, 	1, 1,	0, 1},
		left 	= {1, 0,	1, 1,	0, 0,	0, 1},
		right 	= {0, 0,	0, 1, 	1, 0,	1, 1},
	},
}

local masks = { -- SHIFT-: M1, CTRL-: M2, CTRL-SHIFT-: M3
	['SHIFT-'] = {
		down 	= TEX_PATH:format([[Masks\M1_down]]),
		up 		= TEX_PATH:format([[Masks\M1_up]]),
		left 	= TEX_PATH:format([[Masks\M1_left]]),
		right 	= TEX_PATH:format([[Masks\M1_right]]),
	},
	['CTRL-'] = {
		down 	= TEX_PATH:format([[Masks\M2_down]]),
		up 		= TEX_PATH:format([[Masks\M2_up]]),
		left 	= TEX_PATH:format([[Masks\M2_left]]),
		right 	= TEX_PATH:format([[Masks\M2_right]]),
	},
	['CTRL-SHIFT-'] = {
		down 	= TEX_PATH:format([[Masks\M3_down]]),
		up 		= TEX_PATH:format([[Masks\M3_up]]),
		left 	= TEX_PATH:format([[Masks\M3_left]]),
		right 	= TEX_PATH:format([[Masks\M3_right]]),
	},
}

local swipes = { -- SHIFT-: M1, CTRL-: M2, CTRL-SHIFT-: M3
	['SHIFT-'] = {
		down 	= TEX_PATH:format([[Swipes\M1_down]]),
		up 		= TEX_PATH:format([[Swipes\M1_up]]),
		left 	= TEX_PATH:format([[Swipes\M1_left]]),
		right 	= TEX_PATH:format([[Swipes\M1_right]]),
	},
	['CTRL-'] = {
		down 	= TEX_PATH:format([[Swipes\M2_down]]),
		up 		= TEX_PATH:format([[Swipes\M2_up]]),
		left 	= TEX_PATH:format([[Swipes\M2_left]]),
		right 	= TEX_PATH:format([[Swipes\M2_right]]),
	},
	['CTRL-SHIFT-'] = {
		down 	= TEX_PATH:format([[Swipes\M3_down]]),
		up 		= TEX_PATH:format([[Swipes\M3_up]]),
		left 	= TEX_PATH:format([[Swipes\M3_left]]),
		right 	= TEX_PATH:format([[Swipes\M3_right]]),
	},
}
---------------------------------------------------------------
local adjustTextures = {
	'Border',
	'NormalTexture',
	'HighlightTexture',
	'PushedTexture',
	'CheckedTexture',
	'NewActionTexture',
}
---------------------------------------------------------------
local hotkeyConfig = { -- {anchor point}, modifier ID
	['SHIFT-'] = {{{'CENTER', 0, 0}, {20, 20}, 'CP_M1'}},
	['CTRL-'] = {{{'CENTER', 0, 0}, {20, 20}, 'CP_M2'}},
	['CTRL-SHIFT-'] = {{{'CENTER', -4, 0}, {20, 20}, 'CP_M1'}, {{'CENTER', 4, 0}, {20, 20}, 'CP_M2'}},
}

---------------------------------------------------------------
local buttonTextures = {
	[''] = {
		normal = TEX_PATH:format([[Button\BigNormal]]),
		pushed = TEX_PATH:format([[Button\BigHilite]]),
		hilite = TEX_PATH:format([[Button\BigHilite]]),
		checkd = TEX_PATH:format([[Button\BigHilite]]),
		border = TEX_PATH:format([[Button\BigHilite]]),
		new_action 	= TEX_PATH:format([[Button\BigHilite]]),
		cool_swipe 	= TEX_PATH:format([[Cooldown\Swipe]]),
		cool_edge 	= TEX_PATH:format([[Cooldown\Edge]]),
		cool_bling 	= TEX_PATH:format([[Cooldown\Bling]]),
	},
	['SHIFT-'] = {
		normal = TEX_PATH:format([[Button\M1]]),
		pushed = TEX_PATH:format([[Button\M1]]),
		border = TEX_PATH:format([[Button\M1]]),
		hilite = TEX_PATH:format([[Button\M1Hilite]]),
		checkd = TEX_PATH:format([[Button\M1Hilite]]),
		new_action 	= TEX_PATH:format([[Button\M1Hilite]]),
		cool_swipe 	= TEX_PATH:format([[Cooldown\SwipeSmall]]),
	--	cool_edge 	= TEX_PATH:format([[Cooldown\Edge]]),
		cool_charge = TEX_PATH:format([[Cooldown\SwipeSmall]]),
		cool_bling 	= TEX_PATH:format([[Cooldown\Bling]]),
	},
	['CTRL-'] = {
		normal = TEX_PATH:format([[Button\M1]]),
		pushed = TEX_PATH:format([[Button\M1]]),
		border = TEX_PATH:format([[Button\M1]]),
		hilite = TEX_PATH:format([[Button\M1Hilite]]),
		checkd = TEX_PATH:format([[Button\M1Hilite]]),
		new_action 	= TEX_PATH:format([[Button\M1Hilite]]),
		cool_swipe 	= TEX_PATH:format([[Cooldown\SwipeSmall]]),
	--	cool_edge 	= TEX_PATH:format([[Cooldown\Edge]]),
		cool_bling 	= TEX_PATH:format([[Cooldown\Bling]]),
	},
	['CTRL-SHIFT-'] = {
		normal = TEX_PATH:format([[Button\M3]]),
		pushed = TEX_PATH:format([[Button\M3]]),
		border = TEX_PATH:format([[Button\M3]]),
		hilite = TEX_PATH:format([[Button\M3Hilite]]),
		checkd = TEX_PATH:format([[Button\M3Hilite]]),
		new_action 	= TEX_PATH:format([[Button\M3Hilite]]),
		cool_swipe 	= TEX_PATH:format([[Cooldown\SwipeSmall]]),
	--	cool_edge 	= TEX_PATH:format([[Cooldown\Edge]]),
		cool_bling 	= TEX_PATH:format([[Cooldown\Bling]]),
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
function WrapperMixin:Show()
	for _, button in pairs(self.Buttons) do
		button:Show()
	end
	self[''].shadow:Show()
end

function WrapperMixin:Hide()
	for _, button in pairs(self.Buttons) do
		button:Hide()
	end
	self[''].shadow:Hide()
end

function WrapperMixin:SetPoint(...)
	local main = self['']
	local p, x, y = ...
	main:ClearAllPoints()
	if p and x and y then
		return main:SetPoint(...)
	end
end

function WrapperMixin:SetSize(new)
	local main = self['']
	for mod, button in pairs(self.Buttons) do
		local b, t, o -- button size, texture size, offset value
		if mod == '' then -- if nomod, handle separately
			b = new -- 64
			t = new
			o = new * ( 82 / size )
			button.shadow:SetSize(o, o)
		else -- calculate size for modifier buttons to maintain correct ratio
			b = new * ( smallSize / size )
			t = new * ( tSize / size ) * (mod == 'CTRL-SHIFT-' and .9 or 1)
			o = ( ( (mod == 'CTRL-SHIFT-') and ofsB or ofs ) / size )
			local pT = mods[mod][button.orientation]
			if pT then
				local p, rel, x, y = unpack(pT)
				local nX = x * o--x < 0 and -o or x == 0 and 0 or o
				local nY = y * o--y < 0 and -o or y == 0 and 0 or o
				button:SetPoint(p, main, rel, nX, nY)
				button:Show()
			end
		end
		for _, parentKey in pairs(adjustTextures) do
			local texture = button[parentKey]
			texture:ClearAllPoints()
			texture:SetPoint('CENTER', 0, 0)
			texture:SetSize(t, t)
		end
		button:SetSize(b, b)
	end
end

function WrapperMixin:UpdateOrientation(orientation)
	for mod, button in pairs(self.Buttons) do
		if not button.isMainButton then
			button:ClearAllPoints()
			button:Hide()
			button.orientation = orientation
			local coords = modcoords[mod][orientation]
			local mask   = masks[mod][orientation]
			local swipe  = swipes[mod][orientation]
			if coords and mask then
				for _, parentKey in pairs(adjustTextures) do
					button[parentKey]:SetTexCoord(unpack(coords))
				end
				button.Mask:SetTexture(mask)
				button.Flash:SetTexture(mask)
				button.cooldown:SetSwipeTexture(swipe)
			end
		end
	end
	self:SetSize(self['']:GetSize())
end

function WrapperMixin:SetSwipeColor(r, g, b, a)
	self[''].cooldown:SetSwipeColor(r, g, b, a)
end

function WrapperMixin:ToggleIcon(enabled)
	self[''].hotkey:SetShown(enabled)
end

function WrapperMixin:ToggleModifiers(enabled)
	for mod, button in pairs(self.Buttons) do
		local hotkey1, hotkey2 = button.hotkey1, button.hotkey2
		if hotkey1 then hotkey1:SetShown(enabled) end
		if hotkey2 then hotkey2:SetShown(enabled) end
	end
end

function WrapperMixin:SetClassicBorders(enabled)
	local normal = enabled and [[Interface\AddOns\ConsolePort\Textures\Button\Normal]]
	local pushed = enabled and [[Interface\AddOns\ConsolePort\Textures\Button\Pushed]]
	self[''].NormalTexture:SetTexture(normal or buttonTextures[''].normal)
	self[''].PushedTexture:SetTexture(pushed or buttonTextures[''].pushed)
end

function WrapperMixin:SetBorderColor(r, g, b, a)
	for mod, button in pairs(self.Buttons) do
		button.NormalTexture:SetVertexColor(r, g, b, a)
	end
end

function WrapperMixin:ConfigureSwapStates(modifier, button, stateType, stateID)
	-- modifier buttons should stay the same regardless of state
	if modifier ~= '' then
		button:SetState('', stateType, stateID)
		button:SetState('SHIFT-', stateType, stateID)
		button:SetState('CTRL-', stateType, stateID)
		button:SetState('CTRL-SHIFT-', stateType, stateID)
	end
	-- set up main button to swap to current state
	self['']:SetState(modifier, stateType, stateID)
end

function WrapperMixin:SetRebindButton()
	-- Messy code to focus this button in the rebinder
	-- TODO: Update for new config
	if not InCombatLockdown() then
		ConsolePortOldConfig:OpenCategory('Binds')
		if ConsolePortOldConfigContainerBinds.Display:GetID() ~= 2 then
			db.Settings.bindView = 2
			ConsolePortOldConfigContainerBinds.Display:SetID(2)
			ConsolePortOldConfigContainerBinds:OnShow()
		end
		local bindingBtn = _G[self.confRef]
		C_Timer.After(0.1, function()
			if not InCombatLockdown() then
				ConsolePort:ScrollToNode(bindingBtn, ConsolePortRebindFrame)
			end
		end)
	end
end
---------------------------------------------------------------
local function CreateButton(parent, id, name, modifier, size, texSize, config)
	local button = acb:CreateButton(id, name, parent, config)

	button.PushedTexture = button:GetPushedTexture()
	button.HighlightTexture = button:GetHighlightTexture()
	button.CheckedTexture = button:GetCheckedTexture()

	local textures = buttonTextures[modifier]

	button.NewActionTexture:SetTexture(textures.new_action)
	button.NormalTexture:SetTexture(textures.normal)
	button.PushedTexture:SetTexture(textures.pushed)
	button.CheckedTexture:SetTexture(textures.checkd)
	button.HighlightTexture:SetTexture(textures.hilite)
	button.Border:SetTexture(textures.border)

	button.cooldown:SetSwipeTexture(textures.cool_swipe)
	button.cooldown:SetBlingTexture(textures.cool_bling)
	button.cooldown.text = button.cooldown:GetRegions()

	-- Small buttons should not have drop shadow and smaller CD font
	if modifier ~= '' then
		local file, height, flags = button.cooldown.text:GetFont()
		button.cooldown.text:SetFont(file, height * 0.75, flags)
		button:ToggleShadow(false)
	end

	if textures.cool_edge then
		button.cooldown:SetEdgeTexture(textures.cool_edge)
		button.cooldown:SetDrawEdge(true)
	else
		button.cooldown:SetDrawEdge(false)
	end

	for _, parentKey in pairs(adjustTextures) do
		local texture = button[parentKey]
		texture:ClearAllPoints()
		texture:SetPoint('CENTER', 0, 0)
		texture:SetSize(texSize, texSize)
	end

	button:SetSize(size, size)
	button:SetAlpha(0)

	return button
end

local function CreateModifierHotkeyFrame(self, num)
	return CreateFrame('Frame', '$parent_HOTKEY'..( num or '' ), self, 'CPUIActionButtonTextureOverlayTemplate')
end

local function CreateMainHotkeyFrame(self, id)
	local hotkey = CreateFrame('Frame', '$parent_HOTKEY', self, 'CPUIActionButtonMainHotkeyTemplate')
	hotkey.texture:SetTexture(db.ICONS[id])
	return hotkey
end

local function CreateMainShadowFrame(self)
	-- create this as a separate frame so that drop shadow doesn't overlay modifiers
	-- note: shadow is child of bar, not of button
	local shadow = CreateFrame('Frame', self:GetName()..'_SHADOW', ab.bar, 'CPUIActionButtonMainShadowTemplate')
	shadow:SetPoint('CENTER', self, 'CENTER', 0, -6)
	return shadow
end
---------------------------------------------------------------

function HANDLE:Get(id)
	return Wrappers[id]
end

function HANDLE:Create(parent, id, orientation)
	local wrapper = {}
	wrapper.Buttons = {}

	for mod, info in pairs(mods) do
		local name = 'CPB_' .. (id:sub(4, #id)) .. (mod == '' and mod or ('_' .. (mod:sub(1, #mod -1))))
		local bSize, tSize = unpack(info.size)
		local button = CreateButton(parent, id..mod, name, mod, bSize, tSize, mod == '' and config)
		button.plainID = id
		button.mod = mod
		-- dispatch to header
		button:SetAttribute('plainID', id)
		button:SetAttribute('modifier', mod)
		-- store button in the wrapper
		wrapper[mod] = button
		wrapper.Buttons[mod] = button
		if hotkeyConfig[mod] then
			for i, modHotkey in pairs(hotkeyConfig[mod]) do
				local hotkey = CreateModifierHotkeyFrame(button, i)
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

	for mod, button in pairs(wrapper.Buttons) do
		if not button.isMainButton then
			-- Set this button to not update on modifier state
			button:SetAttribute('_childupdate-state', nil)
		end
	end

	main:SetFrameLevel(4)
	main:SetAlpha(1)
	main.hotkey = CreateMainHotkeyFrame(main, id)
	main.shadow = CreateMainShadowFrame(main)
	db.UIFrameFadeIn(main, 1, 0, 1)

	Mixin(wrapper, WrapperMixin)

	wrapper:UpdateOrientation(orientation)

	Wrappers[id] = wrapper

	return wrapper
end

function HANDLE:UpdateAllBindings(newBindings)
	local bindings = newBindings or db.Bindings
	ClearOverrideBindings(ab.bar)
	if type(bindings) == 'table' then
		for binding, wrapper in pairs(Wrappers) do
			self:UpdateWrapperBindings(wrapper, bindings[binding])
		end
	end
end

function HANDLE:SetEligbleForRebind(button, id)
	button.confRef = button.plainID..id..'_CONF'
	button:SetAttribute('disableDragNDrop', true)
	button:SetState(id, 'custom', {
		tooltip = NOT_BOUND_TOOLTIP,
		texture = [[Interface\AddOns\ConsolePortBar\Textures\Icons\Unbound]],
		func = WrapperMixin.SetRebindButton,
	})
end

function HANDLE:SetArbitraryBinding(button, binding)
	button:SetAttribute('disableDragNDrop', true)
	return 'custom', {
		tooltip = _G['BINDING_NAME_'..binding] or binding,
		texture = ab:GetBindingIcon(binding) or [[Interface\MacroFrame\MacroFrame-Icon]],
		func = function() end,
	}
end

function HANDLE:SetActionBinding(button, main, id, actionID)
	local key = GetBindingKey(button.plainID)
	if key then
		ab.bar:RegisterOverride(id..key, main:GetName())
	end
	button:SetAttribute('disableDragNDrop', (ab.cfg and ab.cfg.disablednd and true) or false)
	return 'action', actionID
end

function HANDLE:UpdateWrapperBindings(wrapper, bindings)
	local main = wrapper['']

	if bindings then
		for modifier, button in pairs(wrapper.Buttons) do
			local binding = bindings[modifier]
			local actionID = binding and ConsolePort:GetActionID(binding)
			local stateType, stateID
			if actionID then
				stateType, stateID = self:SetActionBinding(button, main, modifier, actionID)
			elseif binding then
				stateType, stateID = self:SetArbitraryBinding(button, binding)
			else
				self:SetEligbleForRebind(button, modifier)
			end

			wrapper:ConfigureSwapStates(modifier, button, stateType, stateID)
			-- call an update on the button to reflect new binding
			button:Execute(format([[
				self:RunAttribute('UpdateState', '%s')
				self:CallMethod('UpdateAction')
			]], modifier))
		end
	else
		for modifier, button in pairs(wrapper.Buttons) do
			self:SetEligbleForRebind(button, modifier)
		end
	end
end