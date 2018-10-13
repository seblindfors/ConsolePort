---------------------------------------------------------------
local db = ConsolePort:GetData()
---------------------------------------------------------------
local _, ab = ...
---------------------------------------------------------------
local cfg

local Bar = ConsolePortBar
local WrapperLib = ab.libs.wrapper
local state, now = ConsolePort:GetActionPageDriver()

local BAR_MIN_WIDTH = 1105
local BAR_MAX_SCALE = 1.6
local BAR_FIXED_HEIGHT = 140

-- Set up action bar
---------------------------------------------------------------
ab.bar = Bar
ab.data = db
---------------------------------------------------------------

Bar:SetAttribute('actionpage', now)
Bar:SetFrameRef('Cursor', ConsolePortRaidCursor)
Bar:SetFrameRef('Mouse', ConsolePortMouseHandle)

Bar:Execute([[
	bindings = newtable()
	reticleSpellManifest = newtable()
	reticleMacroString = '/stopspelltarget\n/cast [@cursor] %s'
	bar = self
	cursor = self:GetFrameRef('Cursor')
	mouse = self:GetFrameRef('Mouse')
	self:SetAttribute('state', '')
]])

function Bar:FadeIn(alpha)
	db.UIFrameFadeIn(self, .25, alpha or 0, 1)
end

function Bar:FadeOut(alpha)
	db.UIFrameFadeOut(self, 1, alpha or 1, 0)
end

function Bar:StopCamera()
	ConsolePortCamera:Stop()
end

function Bar:UnregisterOverrides()
	self:Execute([[
		bindings = wipe(bindings)
		self:ClearBindings()
	]])
end

function Bar:UpdateOverrides()
	self:Execute([[
		for key, button in pairs(bindings) do
			self:SetBindingClick(true, key, button, 'ControllerInput')
		end
	]])
end

function Bar:RegisterOverride(key, button)
	self:Execute(format([[
		bindings['%s'] = '%s'
	]], key, button))
end

function Bar:OnNewBindings(...)
	if not InCombatLockdown() then
		self:UnregisterOverrides()
		WrapperLib:UpdateAllBindings(...)
		self:UpdateOverrides()
	end
end

ConsolePort:RegisterCallback('OnNewBindings', Bar.OnNewBindings, Bar)
ConsolePort:RegisterSpellHeader(Bar, true)

function Bar:OnEvent(event, ...)
	if self[event] then
		self[event](self, ...)
	end
end

function Bar:PLAYER_REGEN_ENABLED()
	self:FadeOut(self:GetAlpha())
end

function Bar:PLAYER_REGEN_DISABLED()
	self:FadeIn(self:GetAlpha())
end

function Bar:LoadReticleSpells()
	Bar:Execute('wipe(reticleSpellManifest)')
	local reticleSpells = ab.manifest and ab.manifest.ReticleSpells
	if type(reticleSpells) == 'table' then
		local classSpecific = reticleSpells[select(2, UnitClass('player'))]
		if type(classSpecific) == 'table' then
			for spellID, name in pairs(classSpecific) do
				Bar:Execute(format('reticleSpellManifest[%d] = "%s"', spellID, name))
			end
		end
	end
	self.LoadReticleSpells = nil
end

function Bar:ADDON_LOADED(name)
	if name == _ then
		if not ConsolePortBarSetup then
			ConsolePortBarSetup = ab:GetDefaultSettings()
		-------------------------------
		-- compat: binding ID fix for grip buttons , remove later on
		else local layout = ConsolePortBarSetup.layout
			if layout then
				layout.CP_T3 = layout.CP_T3 or layout.CP_L_GRIP -- translate Lgrip to t3
				layout.CP_T4 = layout.CP_T4 or layout.CP_R_GRIP -- translate Rgrip to t4
				layout.CP_L_GRIP = nil layout.CP_R_GRIP = nil
			end
		-------------------------------
		end
		ab:CreateManifest()
		self:LoadReticleSpells()
		self:OnLoad(ConsolePortBarSetup)
		self:UnregisterEvent('ADDON_LOADED')
		self.ADDON_LOADED = nil
	end
end

function Bar:OnMouseWheel(delta)
	if not InCombatLockdown() then
		local cfg = ab.cfg
		if IsShiftKeyDown() then
			local newWidth = self:GetWidth() + ( delta * 10 )
			cfg.width = newWidth > BAR_MIN_WIDTH and newWidth or BAR_MIN_WIDTH
			self:SetWidth(cfg.width)
		else
			local newScale = self:GetScale() + ( delta * 0.1 )
			if newScale > BAR_MAX_SCALE then cfg.scale = BAR_MAX_SCALE
			elseif newScale <= 0 then cfg.scale = 0.1
			else cfg.scale = newScale end
			self:SetScale(cfg.scale)
		end
	end
end

function Bar:OnLoad(cfg, benign)
	local r, g, b = db.Atlas.GetNormalizedCC()
	ab.cfg = cfg
	ConsolePortBarSetup = cfg
	self:SetScale(cfg.scale or 1)

	self:SetAttribute('hidesafe', cfg.hidebar)
	if cfg.hidebar then
		self:RegisterEvent('PLAYER_REGEN_ENABLED')
		self:RegisterEvent('PLAYER_REGEN_DISABLED')
		self:FadeOut(self:GetAlpha())
	else
		self:UnregisterEvent('PLAYER_REGEN_ENABLED')
		self:UnregisterEvent('PLAYER_REGEN_DISABLED')
		self:FadeIn(self:GetAlpha())
	end

	-- Bar vis driver
	local visDriver = '[petbattle][vehicleui][overridebar] hide; show'
	if cfg.combathide then
		visDriver = '[combat]' .. visDriver
	end

	RegisterStateDriver(Bar, 'visibility', visDriver)

	-- Pet driver
	if cfg.hidepet then
		UnregisterStateDriver(Bar.Pet, 'visibility')
		Bar.Pet:Hide()
	elseif cfg.combatpethide then
		RegisterStateDriver(Bar.Pet, 'visibility', '[pet,nocombat] show; hide')
	else
		RegisterStateDriver(Bar.Pet, 'visibility', '[pet] show; hide')
	end
	
	-- Set action bar art
	if cfg.showart or cfg.flashart then
		local art, coords = ab:GetCover()
		if art and coords then
			local artScale = cfg.smallart and .75 or 1
			self.CoverArt:SetTexture(art)
			self.CoverArt:SetTexCoord(unpack(coords))
			self.CoverArt:SetVertexColor(unpack(cfg.artRGB or {1,1,1}))
			self.CoverArt:SetBlendMode(cfg.blendart and 'ADD' or 'BLEND')
			self.CoverArt:SetSize(768 * artScale, 192 * artScale)
			if cfg.showart then
				self.CoverArt:Show()
			else
				self.CoverArt:Hide()
			end
		end
	else
		self.CoverArt:SetTexture(nil)
		self.CoverArt:Hide()
	end
	self.CoverArt.flashOnProc = cfg.flashart

	-- Show class tint line
	if cfg.showline then
		self.BG:Show()
		self.BottomLine:Show()
	else
		self.BG:Hide()
		self.BottomLine:Hide()
	end

	-- Rainbow sine wave color script, cuz shiny
	ab:SetRainbowScript(cfg.rainbow)

	-- Tint RGB for background textures	
	if cfg.tintRGB then
		self.BG:SetGradientAlpha(ab:GetColorGradient(unpack(cfg.tintRGB)))
		self.BottomLine:SetVertexColor(unpack(cfg.tintRGB))
	else
		self.BG:SetGradientAlpha(ab:GetColorGradient(r, g, b))
		self.BottomLine:SetVertexColor(r, g, b, 1)
	end

	-- Show quick menu buttons
	self.Menu:SetShown(cfg.quickMenu)

	if cfg.lockpet then
		self.Pet:RegisterForDrag()
	else
		self.Pet:RegisterForDrag('LeftButton')
	end

	if cfg.lock then
		self:RegisterForDrag()
		self:EnableMouse(false)
	else
		self:EnableMouse(true)
		self:RegisterForDrag('LeftButton')
	end

	self:EnableMouseWheel(cfg.mousewheel)

	cfg.layout = cfg.layout or ab:GetDefaultButtonLayout()

	-- Configure individual buttons
	local layout = cfg.layout

	local swipeRGB = cfg.swipeRGB
	local borderRGB = cfg.borderRGB

	local hideIcons = cfg.hideIcons
	local hideBorders = cfg.hideBorders
	local classicBorders = cfg.classicBorders

	for binding in ConsolePort:GetBindings() do
		local position = layout[binding]
		local wrapper = WrapperLib:Get(binding) or WrapperLib:Create(self, binding, position and position.dir)

		if position then
			wrapper:SetPoint(unpack(position.point))
			if position.size then
				wrapper:SetSize(position.size)
			end
		else
			wrapper:Hide()
		end

		wrapper:ToggleIcon(not hideIcons)
		wrapper:ToggleModifiers(not hideModifiers)
		wrapper:SetClassicBorders(classicBorders)

		if swipeRGB then wrapper:SetSwipeColor(unpack(swipeRGB))
		else wrapper:SetSwipeColor(r, g, b, 1) end

		if borderRGB then wrapper:SetBorderColor(unpack(borderRGB))
		else wrapper:SetBorderColor(1, 1, 1, 1) end

		self.Buttons[#self.Buttons + 1] = wrapper
	end

	self.WatchBarContainer:Hide() -- hide so it updates OnShow, if set.
	self.WatchBarContainer:SetShown(not cfg.hidewatchbars)

	-- Don't run this when updating simple cvars
	if not benign then
		WrapperLib:UpdateAllBindings()
		self:Hide()
		self:SetShown(not cfg.hidebar)

		self:SetAttribute('disableCastOnRelease', cfg.disablecastonrelease)
		self:SetAttribute('page', 1)
		self:Execute(format([[
			disableCastOnRelease = self:GetAttribute('disableCastOnRelease')
			control:ChildUpdate('state', '')
			self:RunAttribute('_onstate-page', '%s')
		]], now or 1))
	end

	-- Always show modifiers
	if cfg.showbuttons then
		self.Eye:SetAttribute('showbuttons', true)
		self:Execute([[
			control:ChildUpdate('hover', true)
		]])
	else
		self.Eye:SetAttribute('showbuttons', false)
		self:Execute([[
			control:ChildUpdate('hover', false)
		]])
	end

	local width = cfg.width or ( #self.Buttons > 10 and (10 * 110) + 55 or (#self.Buttons * 110) + 55 )
	self:SetSize(width, BAR_FIXED_HEIGHT)
end

--------------------------
---- Secure functions ----
--------------------------
for name, script in pairs({
	['_onhide'] = [[
		self:ClearBindings()
	]],
	['_onshow'] = [[
		for key, button in pairs(bindings) do
			self:SetBindingClick(true, key, button, 'ControllerInput')
		end
		mouse:RunAttribute('UpdateTarget', mouse:GetAttribute('current'))
		if PlayerInCombat() or ( not self:GetAttribute('hidesafe') ) then
			self:CallMethod('FadeIn')
		end
	]],
	['_onstate-modifier'] = [[
		self:SetAttribute('state', newstate)
		control:ChildUpdate('state', newstate)
		cursor:RunAttribute('pageupdate')
	]],
	['_onstate-page'] = [[
		if HasVehicleActionBar() then
			newstate = GetVehicleBarIndex()
		elseif HasOverrideActionBar() then
			newstate = GetOverrideBarIndex()
		elseif HasTempShapeshiftActionBar() then
			newstate = GetTempShapeshiftBarIndex()
		elseif GetBonusBarOffset() > 0 then
			newstate = GetBonusBarOffset()+6
		else
			newstate = GetActionBarPage()
		end
		self:SetAttribute('actionpage', newstate)
		control:ChildUpdate('actionpage', newstate)
	]],
	['GetReticleMacro'] = [[
		if disableCastOnRelease then return end
		local actionID, buttonID, down, macro = ...

		if down then
			if not storedSpellID then
				storedSpellID = self:RunAttribute('GetSpellID', actionID)
				storedButtonID = buttonID
				if reticleSpellManifest[storedSpellID] then
					self:CallMethod('StopCamera')
				end
			end
		else
			if storedSpellID and (storedButtonID == buttonID) then
				local spellName = reticleSpellManifest[storedSpellID]
				if spellName then
					macro = reticleMacroString:format(spellName)
				end
			end
			storedSpellID, storedButtonID = nil, nil
		end

		return macro
	]]
--------------------------
}) do Bar:SetAttribute(name, script) end
--------------------------

Bar:SetScript('OnEvent', Bar.OnEvent)
Bar:SetScript('OnMouseWheel', Bar.OnMouseWheel)
Bar:RegisterEvent('SPELLS_CHANGED')
Bar:RegisterEvent('PLAYER_LOGIN')
Bar:RegisterEvent('ADDON_LOADED')
Bar:RegisterEvent('PLAYER_TALENT_UPDATE') 

Bar.ignoreNode = true
Bar.Buttons = {}
Bar.Elements = {}
Bar.isForbidden = true
RegisterStateDriver(Bar, 'page', state)
RegisterStateDriver(Bar, 'modifier', '[mod:ctrl,mod:shift] CTRL-SHIFT-; [mod:ctrl] CTRL-; [mod:shift] SHIFT-; ')