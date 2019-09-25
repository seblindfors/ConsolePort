---------------------------------------------------------------
-- Events.lua: Event management and event-specific functions
---------------------------------------------------------------
-- Collection of functions related to event management.
-- Manages mouse look triggering from events.
---------------------------------------------------------------
local Events, _, db = {}, ...
---------------------------------------------------------------
local After, WorldFrame, MouseEvents = C_Timer.After, WorldFrame
---------------------------------------------------------------

function ConsolePort:LoadEvents()
	MouseEvents = db('Mouse/Events')
	self:UnregisterAllEvents()
	-- Register union of handlers and mouse look events
	for event in pairs(Mixin({}, Events, MouseEvents)) do
		pcall(self.RegisterEvent, self, event)
	end
end

local function IsMouselookEvent(event)
	return MouseEvents[event]
end

function ConsolePort:StartCameraOnEvent(event)
	if 	( IsMouselookEvent(event) ) and
		( GetMouseFocus() == WorldFrame ) and
		( not SpellIsTargeting() ) and
		( not IsMouseButtonDown(1) ) then
		self:StartCamera(event)
	end
end

---------------------------------------------------------------
-- Event specific functions
---------------------------------------------------------------
function Events:PLAYER_TARGET_CHANGED()
	if UnitExists('target') then
		After(0.02, function()
			if IsMouselookEvent('PLAYER_TARGET_CHANGED') and
				GetMouseFocus() == WorldFrame and
				not SpellIsTargeting() and
				not IsMouseButtonDown(1) then
				self:StartCamera('PLAYER_TARGET_CHANGED')
			end
		end)
	end
end

function Events:MERCHANT_SHOW()
	-- Automatically sell junk
	if db('autoSellJunk') then
		local quality
		for i=1, 2 do
			for bag=0, 4 do
				for slot=1, GetContainerNumSlots(bag) do
					quality = select(4, GetContainerItemInfo(bag, slot))
					if quality and quality == 0 then
						UseContainerItem(bag, slot)
					end
				end
			end
		end
	end
end

function Events:WORLD_MAP_UPDATE()
	-- Add clickable nodes to the world map
	-- self:GetMapNodes()
end

function Events:QUEST_AUTOCOMPLETE(...)
	ShowQuestComplete(GetQuestLogIndexByID(...))
end

function Events:UNIT_SPELLCAST_SENT()
	if 	GetMouseFocus() == WorldFrame and
		IsMouselookEvent('UNIT_SPELLCAST_SENT') then
		self:StartCamera('UNIT_SPELLCAST_SENT')
	end
end

function Events:CURRENT_SPELL_CAST_CHANGED()
	if SpellIsTargeting() then
		self:StopCamera()
	end
end

function Events:UNIT_SPELLCAST_FAILED()
	if 	GetMouseFocus() == WorldFrame and
		IsMouselookEvent('UNIT_SPELLCAST_FAILED') then
		self:StartCamera('UNIT_SPELLCAST_FAILED')
	end
end

function Events:UNIT_ENTERING_VEHICLE(unit)
	if unit == 'player' then
		for i=1, NUM_OVERRIDE_BUTTONS do
			local button = _G['OverrideActionBarButton'..i]
			if 	button and button.HotKey then
				button.HotKey:Hide()
			end
		end
	end
end

function Events:PLAYER_REGEN_ENABLED()
	self:UpdateCVars(false)
	if self.newBindingsQueued then
		self.newBindingsQueued = nil
		Events.ACTIVE_TALENT_GROUP_CHANGED(self)
	end
	After(db('UIleaveCombatDelay'), function()
		if not InCombatLockdown() then
			self:LockUICore(false)
			self:UpdateFrames()
		end
	end)
end

function Events:PLAYER_REGEN_DISABLED()
	self:ClearCursor()
	self:SetUIFocus(false)
	self:LockUICore(true)
	self:UpdateCVars(true)
end

function Events:PLAYER_LOGOUT()
	if not db('disableCvarReset') then
		self:ResetCVars()
	end
end

function Events:CVAR_UPDATE(...)
	self:UpdateCVars(nil, ...)
end

function Events:UPDATE_BINDINGS()
	self:AddUpdateSnippet(self.LoadBindingSet, db.Bindings, true)
end

function Events:SPELLS_CHANGED()
	self:SetupRaidCursor()
	self:UpdateCameraDriver()
	self:RunOOC(self.UpdateMouseDriver)
	self:RunOOC(self.SetupUtilityRing)
	self:UnregisterEvent('SPELLS_CHANGED')
	Events.SPELLS_CHANGED = nil
	if InCombatLockdown() then
		print(db.TUTORIAL.SLASH.WARNINGCOMBATLOGIN)
	end
end

function Events:ACTIVE_TALENT_GROUP_CHANGED()
	if not InCombatLockdown() then
		local bindingSet = self:GetBindingSet()
		-- Set new bindings
		db.Bindings = bindingSet
		-- Dispatch updated bindings
		self:SetUIFocus(false)
		self:LoadBindingSet(bindingSet)
		self:OnNewBindings(bindingSet)
		self:LoadHotKeyTextures()
		self:UpdateFrames()
		-- Check whether bindings are empty
		if not next(bindingSet) then
			local popupData = StaticPopupDialogs["CONSOLEPORT_IMPORTBINDINGS"]
			popupData.text = db.TUTORIAL.SLASH.NOBINDINGS
			self:ShowPopup("CONSOLEPORT_IMPORTBINDINGS")
		end
	else
		self.newBindingsQueued = true
	end
end

function Events:PLAYER_LOGIN()
	-- Reuse spec change event to set bindings on login.
	Events.ACTIVE_TALENT_GROUP_CHANGED(self)
	Events.PLAYER_LOGIN = nil
	self:UnregisterEvent('PLAYER_LOGIN')
	-- Load CVars here (should be available at this point)
	self:LoadDefaultCVars()
end

function Events:ADDON_ACTION_FORBIDDEN(culprit, action)
	if culprit == _ then
		if action == 'FocusUnit()' then
			print(db.TUTORIAL.ERRORS.FOCUSUNIT)
		end
	end
end

function Events:ADDON_LOADED(name)
	self:LoadSettings()
	self:LoadActionPager(db('pagedriver'), db('pageresponse'))
	self:LoadControllerTheme()
	self:LoadEvents()
	self:LoadHookScripts()
	self:LoadRaidCursor()
	self:LoadCameraSettings()
	self:OnNewBindings()
	self:CreateConfigPanel()
	self:CreateSecureButtons()
	self:SetupCursor()
	self:ToggleUICore()
	self:LoadUIControl()
	self:CheckLoadedAddons()
	if not self.calibrationFrame then
		self:CheckLoadedSettings()
	end
	self:UpdateCVars()
	-----------------------------------------
	Events.ADDON_LOADED = function(self, name)
		-- Register cursor frames
		if ConsolePortUIFrames and ConsolePortUIFrames[name] then
			for i, frame in ipairs(ConsolePortUIFrames[name]) do
				self:AddFrame(frame)
			end
		end
		-- Load plugin
		self:LoadPlugin(name)
		-- Dispatch a frame update
		self:UpdateFrames()
		self:LoadHotKeyTextures()
	end
	Events.ADDON_LOADED(self, name)
end

---------------------------------------------------------------
local function OnEvent (self, event, ...)
	if 	Events[event] then
		Events[event](self, ...)
		return
	end
	self:StartCameraOnEvent(event)
end

ConsolePort:RegisterEvent('ADDON_LOADED')
ConsolePort:RegisterEvent('PLAYER_LOGIN')
ConsolePort:SetScript('OnEvent', OnEvent)