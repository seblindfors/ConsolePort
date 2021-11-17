---------------------------------------------------------------
local _, env = ...; local db = env.db;
---------------------------------------------------------------
local cfg

local Bar = Mixin(env.bar, CPAPI.SecureEnvironmentMixin)
local Clusters = env.libs.clusters;
local state, now = ConsolePort:GetActionPageDriver()

local BAR_MIN_WIDTH    = 1105
local BAR_MAX_SCALE    = 1.6
local BAR_FIXED_HEIGHT = 140

-- Set up action bar
---------------------------------------------------------------

Bar:SetAttribute('actionpage', now)
Bar:SetFrameRef('Cursor', ConsolePortRaidCursor)
Bar:SetFrameRef('Mouse', ConsolePortInteract)

Bar:Execute([[
	bindings = newtable()
	bar = self
	cursor = self:GetFrameRef('Cursor')
	mouse  = self:GetFrameRef('Mouse')
]])

-- Opacity handling
---------------------------------------------------------------
function Bar:FadeIn(alpha, time)
	if self.forceFadeOut then return end;
	db.Alpha.FadeIn(self, time or .25, alpha or 0, 1)
end

function Bar:FadeOut(alpha, time)
	db.Alpha.FadeOut(self, time or 1, alpha or 1, 0)
end

db:RegisterCallback('OnHintsClear', function(self)
	self.forceFadeOut = false;
	if not env:Get('hidebar') or InCombatLockdown() then
		self:FadeIn(self:GetAlpha())
	end
end, Bar)

db:RegisterCallback('OnHintsFocus', function(self)
	self.forceFadeOut = true;
	self:FadeOut(self:GetAlpha(), .1)
end, Bar)

-- Global movement
---------------------------------------------------------------
function Bar:ToggleMovable(enableMouseDrag, enableMouseWheel)
	self:RegisterForDrag(enableMouseDrag and 'LeftButton')
	self:EnableMouse(enableMouseDrag)
	self:EnableMouseWheel(enableMouseWheel)
end

-- Override bindings
---------------------------------------------------------------
function Bar:UnregisterOverrides()
	self:Execute([[
		bindings = wipe(bindings)
		self:ClearBindings()
	]])
end

function Bar:UpdateOverrides()
	self:Execute([[
		self:RunAttribute('ApplyBindings')
		local state = self:GetAttribute('state') or '';
		self:SetAttribute('state', state)
		control:ChildUpdate('state', state)
		mouse:RunAttribute('OnBindingsChanged')
	]])
end

function Bar:RegisterOverride(key, button)
	self:Execute(format([[
		bindings['%s'] = '%s'
	]], key, button))
end

function Bar:OnOverrideSet(key)
	db.Input:HandleConflict(self, false, key)
end

function Bar:OnNewBindings(bindings)
	self:UnregisterOverrides()
	Clusters:UpdateAllBindings(bindings)
	self:UpdateOverrides()
end

env.db:RegisterSafeCallback('OnNewBindings', Bar.OnNewBindings, Bar)
env.db.Pager:RegisterHeader(Bar, true)

-- Event handler
---------------------------------------------------------------
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

function Bar:PLAYER_LOGIN()
	self:OnLoad(env.cfg)
end

function Bar:ADDON_LOADED(name)
	if name == _ then
		if not ConsolePort_BarSetup then
			ConsolePort_BarSetup = env:GetDefaultSettings()
		end
		env:CreateManifest()
		env:SetConfig(ConsolePort_BarSetup, false)
		self:UnregisterEvent('ADDON_LOADED')
		self.ADDON_LOADED = nil
	end
end

-- Script handlers
---------------------------------------------------------------
function Bar:OnMouseWheel(delta)
	if not InCombatLockdown() then
		local cfg = env.cfg
		if IsShiftKeyDown() then
			local newWidth = self:GetWidth() + ( delta * 10 )
			cfg.width = newWidth > BAR_MIN_WIDTH and newWidth or BAR_MIN_WIDTH
			self:SetWidth(cfg.width)
		else
			local newScale = self:GetScale() + ( delta * 0.1 )
			cfg.scale = Clamp(newScale, 0.1, BAR_MAX_SCALE)
			self:SetScale(cfg.scale)
		end
	end
end

function Bar:OnLoad(cfg, benign)
	local r, g, b = CPAPI.NormalizeColor(CPAPI.GetClassColor())
	env:SetConfig(cfg, false)
	self:SetScale(Clamp(cfg.scale or 1, 0.1, BAR_MAX_SCALE))

	-- Fade out of combat
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

	-- Show class tint line
	if cfg.showline then
		self.BG:Show()
		self.BottomLine:Show()
	else
		self.BG:Hide()
		self.BottomLine:Hide()
	end

	-- Set action bar art
	env:SetArtUnderlay(cfg.showart or cfg.flashart, cfg.flashart)

	-- Rainbow sine wave color script, cuz shiny
	env:SetRainbowScript(cfg.rainbow)

	-- Tint RGB for background textures	
	if cfg.tintRGB then
		self.BG:SetGradientAlpha(env:GetColorGradient(unpack(cfg.tintRGB)))
		self.BottomLine:SetVertexColor(unpack(cfg.tintRGB))
	else
		self.BG:SetGradientAlpha(env:GetColorGradient(r, g, b))
		self.BottomLine:SetVertexColor(r, g, b, 1)
	end

	-- Show 'the eye'
	self.Eye:SetShown(cfg.eye)

	-- Lock/unlock pet ring
	self.Pet:RegisterForDrag(not cfg.lockpet and 'LeftButton')
	if cfg.disablepetfade then
		self.Pet:FadeIn()
	else
		self.Pet:FadeOut()
	end

	-- Lock/unlock bar
	self:ToggleMovable(not cfg.lock, cfg.mousewheel)

	cfg.layout = cfg.layout or env:GetDefaultButtonLayout()

	-- Configure individual buttons
	local layout = cfg.layout

	local swipeRGB = cfg.swipeRGB
	local borderRGB = cfg.borderRGB

	local hideIcons = cfg.hideIcons
	local hideModifiers = cfg.hideModifiers
	local classicBorders = cfg.classicBorders

	wipe(self.Buttons)
	local activeDevice = db('Gamepad/Active')

	if activeDevice then
		for binding in ConsolePort:GetBindings() do
			local positionData = layout[db.UIHandle:GetUIControlBinding(binding)]
			local isUsableBinding = activeDevice:IsButtonValidForBinding(binding)
			local cluster = Clusters:Get(binding)

			if not cluster and positionData and isUsableBinding then
				cluster = Clusters:Create(self, binding)
			end

			if cluster then
				if positionData and isUsableBinding then
					cluster:Show()
					cluster:SetPoint(unpack(positionData.point))
					if positionData.dir then
						cluster:UpdateOrientation(positionData.dir)
					end
					if positionData.size then
						cluster:SetSize(positionData.size)
					end
				else
					cluster:Hide()
				end

				cluster:ToggleIcon(not hideIcons)
				cluster:ToggleModifiers(not hideModifiers)
				cluster:SetClassicBorders(classicBorders)

				if swipeRGB then cluster:SetSwipeColor(unpack(swipeRGB))
				else cluster:SetSwipeColor(r, g, b, 1) end

				if borderRGB then cluster:SetBorderColor(unpack(borderRGB))
				else cluster:SetBorderColor(1, 1, 1, 1) end

				self.Buttons[#self.Buttons + 1] = cluster
			end
		end
	end

	self.WatchBarContainer:Hide() -- hide so it updates OnShow, if set.
	self.WatchBarContainer:SetShown(not cfg.hidewatchbars)

	-- Don't run this when updating simple cvars
	if not benign then
		Clusters:UpdateAllBindings(db.Gamepad:GetBindings())
		self:UpdateOverrides()
		-- states have been reparsed, set back to current state
		self:Execute([[
			control:ChildUpdate('state', self:GetAttribute('state'))
			self:RunAttribute('_onstate-page', self:GetAttribute('actionpage'))
		]])
		self:MoveMicroButtons()
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

db:RegisterSafeCallback('Gamepad/Active', function(self) self:OnLoad(env.cfg) end, Bar)
db:RegisterSafeCallback('OnActionBarConfigChanged', Bar.OnLoad, Bar)

--------------------------
---- Secure functions ----
--------------------------
for name, script in pairs({
	['_onhide'] = [[
		self:ClearBindings()
	]],
	['_onshow'] = [[
		self:RunAttribute('ApplyBindings')
		if PlayerInCombat() or ( not self:GetAttribute('hidesafe') ) then
			self:CallMethod('FadeIn')
		end
		mouse:RunAttribute('OnBindingsChanged')
	]],
	['_onstate-modifier'] = [[
		self:SetAttribute('state', newstate)
		control:ChildUpdate('state', newstate)
		cursor:RunAttribute('ActionPageChanged')
	]],
	['_onstate-page'] = [[
		if HasVehicleActionBar and HasVehicleActionBar() then
			newstate = GetVehicleBarIndex()
		elseif HasOverrideActionBar and HasOverrideActionBar() then
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
	['ApplyBindings'] = [[
		for key, button in pairs(bindings) do
			self:SetBindingClick(false, key, button, 'ControllerInput')
			self:CallMethod('OnOverrideSet', key)
		end
	]];
--------------------------
}) do Bar:SetAttribute(name, script) end
--------------------------

Bar:SetScript('OnEvent', Bar.OnEvent)
Bar:SetScript('OnMouseWheel', Bar.OnMouseWheel)
for _, event in ipairs({
	'SPELLS_CHANGED',
	'PLAYER_LOGIN',
	'ADDON_LOADED',
	'PLAYER_TALENT_UPDATE',
}) do pcall(Bar.RegisterEvent, Bar, event) end

-- Registry
---------------------------------------------------------------
Bar.Buttons = {}
Bar.Elements = {}

-- State drivers
---------------------------------------------------------------
RegisterStateDriver(Bar, 'page', state)
RegisterStateDriver(Bar, 'modifier',
	'[mod:alt,mod:ctrl,mod:shift] ALT-CTRL-SHIFT-;' ..
	'[mod:alt,mod:ctrl] ALT-CTRL-;' ..
	'[mod:alt,mod:shift] ALT-SHIFT-;' ..
	'[mod:ctrl,mod:shift] CTRL-SHIFT-;' ..
	'[mod:alt] ALT-; [mod:ctrl] CTRL-; [mod:shift] SHIFT-; ')