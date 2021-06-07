---------------------------------------------------------------
local HANDLE, Cluster, Registry = {}, {}, {};
---------------------------------------------------------------
local name, env = ...
local db, acb = env.db, env.libs.acb;
---------------------------------------------------------------
env.libs.clusters = HANDLE;
env.libs.registry = Registry;
---------------------------------------------------------------
local TEX_PATH = [[Interface\AddOns\]]..name..[[\Textures\%s]]
---------------------------------------------------------------
local size, smallSize, tSize = 64, 46, 58;
local ofs, ofsB, fixA = 38, 21, 4;
local nomod = '';
---------------------------------------------------------------
local mods = {
	[nomod] = {size = {size, size}},
	['SHIFT-']  = {size = {smallSize, tSize}, 
		down    = {'TOPRIGHT', 'BOTTOMLEFT',  ofs - fixA,  ofs + fixA},
		up      = {'BOTTOMRIGHT', 'TOPLEFT',  ofs - fixA, -ofs - fixA},
		left    = {'BOTTOMRIGHT', 'TOPLEFT',  ofs + fixA, -ofs + fixA},
		right   = {'BOTTOMLEFT', 'TOPRIGHT', -ofs - fixA, -ofs + fixA},
	},
	['CTRL-']   = {size = {smallSize, tSize}, 
		down    = {'TOPLEFT', 'BOTTOMRIGHT', -ofs + fixA,  ofs + fixA},
		up      = {'BOTTOMLEFT', 'TOPRIGHT', -ofs + fixA, -ofs - fixA},
		left    = {'TOPRIGHT', 'BOTTOMLEFT',  ofs + fixA,  ofs - fixA},
		right   = {'TOPLEFT', 'BOTTOMRIGHT', -ofs - fixA,  ofs - fixA},
	},
	['CTRL-SHIFT-'] = {size = {smallSize, tSize},
		down    = {'TOP', 'BOTTOM', 0, ofsB},
		up      = {'BOTTOM', 'TOP', 0, -ofsB},
		left    = {'RIGHT', 'LEFT', ofsB, 0},
		right   = {'LEFT', 'RIGHT', -ofsB, 0},
	},
}

local modcoords = { -- ULx, ULy, LLx, LLy, URx, URy, LRx, LRy
	['SHIFT-'] = {
		down    = {0, 0,    1, 0,   0, 1,   1, 1},
		up      = {1, 0,    0, 0,   1, 1,   0, 1},
		left    = {1, 0,    1, 1,   0, 0,   0, 1},
		right   = {0, 0,    0, 1,   1, 0,   1, 1},
	},
	['CTRL-'] = {
		down    = {0, 1,    1, 1,   0, 0,   1, 0},
		up      = {1, 1,    0, 1,   1, 0,   0, 0},
		left    = {1, 1,    1, 0,   0, 1,   0, 0},
		right   = {0, 1,    0, 0,   1, 1,   1, 0},
	},
	['CTRL-SHIFT-'] = {
		down    = {0, 1,    1, 1,   0, 0,   1, 0},
		up      = {1, 0,    0, 0,   1, 1,   0, 1},
		left    = {1, 0,    1, 1,   0, 0,   0, 1},
		right   = {0, 0,    0, 1,   1, 0,   1, 1},
	},
}

local masks = { -- SHIFT-: M1, CTRL-: M2, CTRL-SHIFT-: M3
	['SHIFT-'] = {
		down    = TEX_PATH:format([[Masks\M1_down]]),
		up      = TEX_PATH:format([[Masks\M1_up]]),
		left    = TEX_PATH:format([[Masks\M1_left]]),
		right   = TEX_PATH:format([[Masks\M1_right]]),
	},
	['CTRL-'] = {
		down    = TEX_PATH:format([[Masks\M2_down]]),
		up      = TEX_PATH:format([[Masks\M2_up]]),
		left    = TEX_PATH:format([[Masks\M2_left]]),
		right   = TEX_PATH:format([[Masks\M2_right]]),
	},
	['CTRL-SHIFT-'] = {
		down    = TEX_PATH:format([[Masks\M3_down]]),
		up      = TEX_PATH:format([[Masks\M3_up]]),
		left    = TEX_PATH:format([[Masks\M3_left]]),
		right   = TEX_PATH:format([[Masks\M3_right]]),
	},
}

local swipes = { -- SHIFT-: M1, CTRL-: M2, CTRL-SHIFT-: M3
	['SHIFT-'] = {
		down    = TEX_PATH:format([[Swipes\M1_down]]),
		up      = TEX_PATH:format([[Swipes\M1_up]]),
		left    = TEX_PATH:format([[Swipes\M1_left]]),
		right   = TEX_PATH:format([[Swipes\M1_right]]),
	},
	['CTRL-'] = {
		down    = TEX_PATH:format([[Swipes\M2_down]]),
		up      = TEX_PATH:format([[Swipes\M2_up]]),
		left    = TEX_PATH:format([[Swipes\M2_left]]),
		right   = TEX_PATH:format([[Swipes\M2_right]]),
	},
	['CTRL-SHIFT-'] = {
		down    = TEX_PATH:format([[Swipes\M3_down]]),
		up      = TEX_PATH:format([[Swipes\M3_up]]),
		left    = TEX_PATH:format([[Swipes\M3_left]]),
		right   = TEX_PATH:format([[Swipes\M3_right]]),
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
	['SHIFT-'] = {{{'CENTER', 0, 0}, {20, 20}, 'M1'}},
	['CTRL-'] = {{{'CENTER', 0, 0}, {20, 20}, 'M2'}},
	['CTRL-SHIFT-'] = {{{'CENTER', -4, 0}, {20, 20}, 'M1'}, {{'CENTER', 4, 0}, {20, 20}, 'M2'}},
}

---------------------------------------------------------------
local buttonTextures = {
	[nomod] = {
		normal = TEX_PATH:format([[Button\BigNormal]]),
		pushed = TEX_PATH:format([[Button\BigHilite]]),
		hilite = TEX_PATH:format([[Button\BigHilite]]),
		checkd = TEX_PATH:format([[Button\BigHilite]]),
		border = TEX_PATH:format([[Button\BigHilite]]),
		new_action  = TEX_PATH:format([[Button\BigHilite]]),
		cool_swipe  = TEX_PATH:format([[Cooldown\Swipe]]),
		cool_edge   = TEX_PATH:format([[Cooldown\Edge]]),
		cool_bling  = TEX_PATH:format([[Cooldown\Bling]]),
	},
	['SHIFT-'] = {
		normal = TEX_PATH:format([[Button\M1]]),
		pushed = TEX_PATH:format([[Button\M1]]),
		border = TEX_PATH:format([[Button\M1]]),
		hilite = TEX_PATH:format([[Button\M1Hilite]]),
		checkd = TEX_PATH:format([[Button\M1Hilite]]),
		new_action  = TEX_PATH:format([[Button\M1Hilite]]),
		cool_swipe  = TEX_PATH:format([[Cooldown\SwipeSmall]]),
	--  cool_edge   = TEX_PATH:format([[Cooldown\Edge]]),
		cool_charge = TEX_PATH:format([[Cooldown\SwipeSmall]]),
		cool_bling  = TEX_PATH:format([[Cooldown\Bling]]),
	},
	['CTRL-'] = {
		normal = TEX_PATH:format([[Button\M1]]),
		pushed = TEX_PATH:format([[Button\M1]]),
		border = TEX_PATH:format([[Button\M1]]),
		hilite = TEX_PATH:format([[Button\M1Hilite]]),
		checkd = TEX_PATH:format([[Button\M1Hilite]]),
		new_action  = TEX_PATH:format([[Button\M1Hilite]]),
		cool_swipe  = TEX_PATH:format([[Cooldown\SwipeSmall]]),
	--  cool_edge   = TEX_PATH:format([[Cooldown\Edge]]),
		cool_bling  = TEX_PATH:format([[Cooldown\Bling]]),
	},
	['CTRL-SHIFT-'] = {
		normal = TEX_PATH:format([[Button\M3]]),
		pushed = TEX_PATH:format([[Button\M3]]),
		border = TEX_PATH:format([[Button\M3]]),
		hilite = TEX_PATH:format([[Button\M3Hilite]]),
		checkd = TEX_PATH:format([[Button\M3Hilite]]),
		new_action  = TEX_PATH:format([[Button\M3Hilite]]),
		cool_swipe  = TEX_PATH:format([[Cooldown\SwipeSmall]]),
	--  cool_edge   = TEX_PATH:format([[Cooldown\Edge]]),
		cool_bling  = TEX_PATH:format([[Cooldown\Bling]]),
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
	clickOnDown = true,
	flyoutDirection = 'UP',
}

---------------------------------------------------------------
-- Cluster methods
---------------------------------------------------------------
-- Acts upon the cluster of buttons as a unified entitiy.

function Cluster:Show()
	for _, button in pairs(self.Buttons) do
		button:Show()
	end
	self[nomod].shadow:Show()
end

function Cluster:Hide()
	for _, button in pairs(self.Buttons) do
		button:Hide()
	end
	self[nomod].shadow:Hide()
end

function Cluster:SetPoint(...)
	local main = self[nomod]
	local p, x, y = ...
	main:ClearAllPoints()
	if p and x and y then
		return main:SetPoint(...)
	end
end

function Cluster:SetSize(new)
	local main = self[nomod]
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

function Cluster:UpdateOrientation(orientation)
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
	self:SetSize(self[nomod]:GetSize())
end

function Cluster:SetSwipeColor(r, g, b, a)
	self[nomod].cooldown:SetSwipeColor(r, g, b, a)
end

function Cluster:ToggleIcon(enabled)
	self[nomod].hotkey:SetShown(enabled)
end

function Cluster:ToggleModifiers(enabled)
	for mod, button in pairs(self.Buttons) do
		local hotkey1, hotkey2 = button.hotkey1, button.hotkey2
		if hotkey1 then hotkey1:SetShown(enabled) end
		if hotkey2 then hotkey2:SetShown(enabled) end
	end
end

function Cluster:SetClassicBorders(enabled)
	local normal = enabled and CPAPI.GetAsset([[Textures\Button\Normal]])
	local pushed = enabled and CPAPI.GetAsset([[Textures\Button\Pushed]])
	self[nomod].NormalTexture:SetTexture(normal or buttonTextures[nomod].normal)
	self[nomod].PushedTexture:SetTexture(pushed or buttonTextures[nomod].pushed)
end

function Cluster:SetBorderColor(r, g, b, a)
	for mod, button in pairs(self.Buttons) do
		button.NormalTexture:SetVertexColor(r, g, b, a)
	end
end

function Cluster:ConfigureSwapStates(modifier, button, stateType, stateID)
	-- swap entire set for ALT combinations (for now)
	if modifier:match('ALT') then
		button:SetState(modifier, stateType, stateID)
	-- modifier buttons should stay the same regardless of state
	elseif modifier ~= '' then
		button:SetState('', stateType, stateID)
		button:SetState('SHIFT-', stateType, stateID)
		button:SetState('CTRL-', stateType, stateID)
		button:SetState('CTRL-SHIFT-', stateType, stateID)
	end
	-- set up main button to swap to current state
	self[nomod]:SetState(modifier, stateType, stateID)
end

function Cluster:SetRebindButton()
	-- Messy code to focus this button in the rebinder
	-- TODO: Update for new config
end

---------------------------------------------------------------
-- Cluster piece configuration
---------------------------------------------------------------
local function CreateButton(parent, id, name, modifier, size, texSize, config)
	local button = acb:CreateButton(id, name, parent, config)

	button:SetAttribute('ignoregamepadhotkey', true)
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
	local hotkey = CreateFrame('Frame', nil, self, 'CPUIActionButtonMainHotkeyTemplate')
	hotkey.texture:SetTexture(db('Icons/32/'..id))
	return hotkey
end

local function CreateMainShadowFrame(self)
	-- create this as a separate frame so that drop shadow doesn't overlay modifiers
	-- note: shadow is child of bar, not of button
	local shadow = CreateFrame('Frame', nil, env.bar, 'CPUIActionButtonMainShadowTemplate')
	shadow:SetPoint('CENTER', self, 'CENTER', 0, -6)
	return shadow
end

---------------------------------------------------------------
-- External handle
---------------------------------------------------------------
function HANDLE:Get(id)
	return Registry[id];
end

function HANDLE:Create(parent, id)
	local cluster = { Buttons = {} };

	for mod, info in pairs(mods) do
		local name = 'CPB_' .. (id) .. (mod == '' and mod or ('_' .. (mod:sub(1, #mod -1))))
		local bSize, tSize = unpack(info.size)
		local button = CreateButton(parent, id..mod, name, mod, bSize, tSize, mod == '' and config)
		button.plainID = id
		button.mod = mod
		-- dispatch to header
		button:SetAttribute('plainID', id)
		button:SetAttribute('modifier', mod)
		-- store button in the cluster
		cluster[mod] = button
		cluster.Buttons[mod] = button
		-- for modifiers only
		if hotkeyConfig[mod] then
			for i, modHotkey in pairs(hotkeyConfig[mod]) do
				local hotkey = CreateModifierHotkeyFrame(button, i)
				local iconID = db.UIHandle:GetUIControlBinding(modHotkey[3])
				hotkey:SetPoint(unpack(modHotkey[1]))
				hotkey:SetSize(unpack(modHotkey[2]))
				hotkey.texture:SetTexture(iconID and db('Icons/32/'..iconID))
				hotkey:SetAlpha(0.75)
				button['hotkey'..i] = hotkey
			end
		end
	end

	local main = cluster[nomod]
	main.isMainButton = true

	main:SetFrameLevel(4)
	main:SetAlpha(1)
	main.hotkey = CreateMainHotkeyFrame(main, id)
	main.shadow = CreateMainShadowFrame(main)
	db.Alpha.FadeIn(main, 1, 0, 1)

	Mixin(cluster, Cluster)

	Registry[id] = cluster;

	return cluster;
end

function HANDLE:UpdateAllBindings(bindings)
	if bindings then
		ClearOverrideBindings(env.bar)
		if type(bindings) == 'table' then
			for binding, cluster in pairs(Registry) do
				self:UpdateClusterBindings(cluster, bindings[binding])
			end
		end
	end
end

function HANDLE:UpdateAllHotkeys()
	-- TODO!
end

function HANDLE:SetEligbleForRebind(button, modifier, main)
	local emulation = db.Console:GetEmulationForButton(button.plainID)
	local texture = db('Icons/64/'..button.plainID) or [[Interface\AddOns\ConsolePortBar\Textures\Icons\Unbound]]
	if emulation then
		return 'custom', {
			texture = texture;
			tooltip = ('|cFFFFFFFF%s|r\n%s'):format(emulation.name, emulation.desc);
			func = nop;
		}
	end
	if main then
		env.bar:RegisterOverride(modifier..button.plainID, main:GetName())
	end
	local disableQuickAssign = db('bindingDisableQuickAssign')
	return 'custom', {
		texture = texture,
		tooltip = ('|cFFFFFFFF%s|r\n%s'):format(NOT_BOUND,
			'To use this combination, you must first connect it to a binding or an action bar slot.' ..
			(not disableQuickAssign and '\nClick here to access the quick binding menu.' or '')
		),
		func = disableQuickAssign and nop or function() env:OpenBindingDropdown(button) end,
	}
end

function HANDLE:SetXMLBinding(button, modifier, binding)
	local desc, _, name, texture = db.Bindings:GetDescriptionForBinding(binding)
	local tooltip = desc and ('|cFFFFFFFF%s|r\n%s'):format(name, desc:gsub('\t+', ''))
	return 'custom', {
		tooltip = tooltip or _G['BINDING_NAME_'..binding] or binding,
		texture = texture or env:GetBindingIcon(binding) or
			db('Icons/64/'..button.plainID) or
			[[Interface\AddOns\ConsolePortBar\Textures\Icons\Unbound]],
		func = function() end,
	}
end

function HANDLE:SetActionBinding(button, modifier, actionID, main)
	env.bar:RegisterOverride(modifier..button.plainID, main:GetName())
	return 'action', actionID
end

function HANDLE:RefreshBinding(binding, cluster, button, modifier, main)
	local actionID = binding and db('Actionbar/Binding/'..binding)
	local stateType, stateID;
	if actionID then
		stateType, stateID = self:SetActionBinding(button, modifier, actionID, main)
	elseif binding then
		stateType, stateID = self:SetXMLBinding(button, modifier, binding)
	else
		stateType, stateID = self:SetEligbleForRebind(button, modifier, main)
	end

	cluster:ConfigureSwapStates(modifier, button, stateType, stateID)
	-- call an update on the button to reflect new binding
	button:DisableDragNDrop(env:Get('disablednd'))
	button:Execute(format([[
		self:RunAttribute('UpdateState', '%s')
		self:CallMethod('UpdateAction')
	]], modifier))
end

function HANDLE:UpdateClusterBindings(cluster, bindings)
	local main = cluster[nomod];

	if bindings then
		for modifier, button in pairs(cluster.Buttons) do
			local modifierAlt = 'ALT-'..modifier;
			local binding, bindingAlt = bindings[modifier], bindings[modifierAlt]
			self:RefreshBinding(binding, cluster, button, modifier, main)
			self:RefreshBinding(bindingAlt, cluster, button, modifierAlt, main)
		end
	else
		for modifier, button in pairs(cluster.Buttons) do
			self:SetEligbleForRebind(button, modifier)
		end
	end
end