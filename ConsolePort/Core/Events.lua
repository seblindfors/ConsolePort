---------------------------------------------------------------
-- Events.lua: Event management and event-specific functions
---------------------------------------------------------------
-- Collection of functions related to event management.
-- Manages mouse look triggering from events.
---------------------------------------------------------------
local _, db = ...
---------------------------------------------------------------
local Callback = C_Timer.After
---------------------------------------------------------------
local MouseEvents
---------------------------------------------------------------

function ConsolePort:LoadEvents()
	MouseEvents = db.Mouse.Events
	-- Default events
	local Events = {
		["ADDON_LOADED"] 			= false,
		["CVAR_UPDATE"]				= false,
		["PLAYER_LOGOUT"] 			= false,
		["PLAYER_STARTED_MOVING"] 	= false,
		["PLAYER_REGEN_DISABLED"] 	= false,
		["PLAYER_REGEN_ENABLED"] 	= false,
		["SPELLS_CHANGED"] 			= false,
		["UPDATE_BINDINGS"] 		= false,
		["VARIABLES_LOADED"] 		= false,
		["QUEST_AUTOCOMPLETE"] 		= false,
		["WORLD_MAP_UPDATE"] 		= false,
		["UNIT_ENTERING_VEHICLE"] 	= false,
	}
	-- Union of general events and mouse look events
	for event, val in pairs(MouseEvents) do
		Events[event] = val
	end
	self:UnregisterAllEvents()
	for event in pairs(Events) do
		self:RegisterEvent(event)
	end
end

local function IsMouselookEvent(event)
	return MouseEvents[event]
end

function ConsolePort:CheckMouselookEvent(event, ...)
	if 	IsMouselookEvent(event) and
		GetMouseFocus() == WorldFrame and
		not SpellIsTargeting() and
		not IsMouseButtonDown(1) then
		self:StartMouse()
	end
end

---------------------------------------------------------------
-- Event specific functions
---------------------------------------------------------------
local Events = {}
local Loaded = false

function Events:PLAYER_TARGET_CHANGED(...)
	Callback(0.02, function()
		if IsMouselookEvent("PLAYER_TARGET_CHANGED") and
			UnitExists("target") and
			GetMouseFocus() == WorldFrame and
			not SpellIsTargeting() and
			not IsMouseButtonDown(1) then
			self:StartMouse()
		end
	end)
end

function Events:MERCHANT_SHOW(...)
	-- Automatically sell junk
	local quality
	for bag=0, 4 do
		for slot=1, GetContainerNumSlots(bag) do
			quality = select(4, GetContainerItemInfo(bag, slot))
			if quality and quality == 0 then
				UseContainerItem(bag, slot)
			end
		end
	end
end

function Events:WORLD_MAP_UPDATE(...)
	self:GetMapNodes()
end

function Events:QUEST_AUTOCOMPLETE(...)
	local id = ...
	ShowQuestComplete(GetQuestLogIndexByID(id))
end

function Events:CURRENT_SPELL_CAST_CHANGED(...)
	if SpellIsTargeting() then
		self:StopMouse()
	elseif 	GetMouseFocus() == WorldFrame and
		IsMouselookEvent("CURRENT_SPELL_CAST_CHANGED") then
		self:StartMouse()
	end
end

function Events:UNIT_ENTERING_VEHICLE(...)
	local unit = ...
	if unit == "player" then
		for i=1, NUM_OVERRIDE_BUTTONS do
			if 	_G["OverrideActionBarButton"..i].HotKey then
				_G["OverrideActionBarButton"..i].HotKey:Hide()
			end
		end
	end
end

function Events:PLAYER_REGEN_ENABLED(...)
	self:UpdateCVars(false)
	self:SetButtonActionsDefault()
	Callback(0.5, function()
		if not InCombatLockdown() then
			self:UpdateFrames()
		end
	end)
end

function Events:PLAYER_REGEN_DISABLED(...)
	self:SetUIFocus(false)
	self:SetButtonActionsDefault()
	self:UpdateCVars(true)
end

function Events:PLAYER_LOGOUT(...)
	self:ResetCVars()
end

function Events:CVAR_UPDATE(...)
	self:UpdateCVars(nil, ...)
end

function Events:UPDATE_BINDINGS(...)
	self:AddUpdateSnippet(self.LoadBindingSet)
end

function Events:SPELLS_CHANGED(...)
	self:SetupRaidCursor()
	self:UpdateSmartMouse()
	self:AddUpdateSnippet(self.UpdateStateDriver)
	self:AddUpdateSnippet(self.SetupUtilityBelt)
	if InCombatLockdown() then
		print(db.TUTORIAL.SLASH.WARNINGCOMBATLOGIN)
	end
	self:UnregisterEvent("SPELLS_CHANGED")
	Events.SPELLS_CHANGED = nil
end

function Events:ADDON_LOADED(...)
	local name = ...
	if name == "ConsolePort" then
		self:CreateButtonHandler()
		self:LoadSettings()
		self:LoadControllerTheme()
		self:LoadEvents()
		self:LoadHookScripts()
		self:LoadBindingSet()
		self:CreateConfigPanel()
		self:CreateActionButtons()
		self:LoadInterfaceBindings()
		self:SetupCursor()
		self:CheckLoadedAddons()
		self:CheckLoadedSettings()
		self:UpdateCVars()
		-- Delay hotkeys and cvars.
		Callback(2, function()
			Loaded = true
			self:LoadDefaultCVars()
			self:LoadHotKeyTextures()
		end)
	end
	if ConsolePortUIFrames and ConsolePortUIFrames[name] then
		for i, frame in pairs(ConsolePortUIFrames[name]) do
			self:AddFrame(frame)
		end
	end
	self:UpdateFrames()
	if Loaded then
		self:LoadHotKeyTextures()
	end
end

local function OnEvent (self, event, ...)
	if 	Events[event] then
		Events[event](self, ...)
		return
	end
	self:CheckMouselookEvent(event)
end

ConsolePort:RegisterEvent("ADDON_LOADED")
ConsolePort:SetScript("OnEvent", OnEvent)