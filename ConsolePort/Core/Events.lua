local addOn, db = ...
local UIControls = db.UIControls

function ConsolePort:LoadEvents()
	-- Default events
	local Events = {
		["ADDON_LOADED"] 			= false,
		["PLAYER_STARTED_MOVING"] 	= false,
		["PLAYER_REGEN_DISABLED"] 	= false,
		["PLAYER_REGEN_ENABLED"] 	= false,
		["UPDATE_BINDINGS"] 		= false,
		["QUEST_AUTOCOMPLETE"] 		= false,
		["QUEST_LOG_UPDATE"] 		= false,
		["WORLD_MAP_UPDATE"] 		= false,
		["UNIT_ENTERING_VEHICLE"] 	= false,
	}
	-- Mouse look events
	for event, val in pairs(ConsolePortMouse.Events) do
		Events[event] = val
	end
	self:UnregisterAllEvents()
	for event, _ in pairs(Events) do
		self:RegisterEvent(event)
	end
	return Events
end


local function IsMouselookEvent(event)
	if 	ConsolePortMouse.Events then
		return ConsolePortMouse.Events[event]
	end
	return true
end

function ConsolePort:CheckMouselookEvent(event, ...)
	if ( (	event == "PLAYER_TARGET_CHANGED"
			and IsMouselookEvent(event)
			and UnitName("target"))
			or IsMouselookEvent(event) ) and
		GetMouseFocus() == WorldFrame and
		not SpellIsTargeting() and
		not IsMouseButtonDown(1) then
		self:StartMouse()
	end
end

function ConsolePort:MERCHANT_SHOW(...)
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

function ConsolePort:WORLD_MAP_UPDATE(...)
	self:GetMapNodes()
end

function ConsolePort:QUEST_AUTOCOMPLETE(...)
	local id = ...
	ShowQuestComplete(GetQuestLogIndexByID(id))
end

function ConsolePort:CURRENT_SPELL_CAST_CHANGED(...)
	if SpellIsTargeting() then
		self:StopMouse()
	elseif 	GetMouseFocus() == WorldFrame and
		IsMouselookEvent("CURRENT_SPELL_CAST_CHANGED") then
		self:StartMouse()
	end
end

function ConsolePort:UNIT_ENTERING_VEHICLE(...)
	local unit = ...
	if unit == "player" then
		for i=1, NUM_OVERRIDE_BUTTONS do
			if 	_G["OverrideActionBarButton"..i].HotKey then
				_G["OverrideActionBarButton"..i].HotKey:Hide()
			end
		end
	end
end

function ConsolePort:PLAYER_REGEN_ENABLED(...)
	self:SetButtonActionsDefault()
	self:UpdateFrames()
	if self.Cursor:IsVisible() then
		db.UIFrameFadeIn(self.Cursor, 0.2, self.Cursor:GetAlpha(), 1)
	else
		self.Cursor:SetAlpha(1)
	end
end

function ConsolePort:PLAYER_REGEN_DISABLED(...)
	self:SetUIFocus(false)
	self:SetButtonActionsDefault()
	if self.Cursor:IsVisible() then
		db.UIFrameFadeOut(self.Cursor, 0.2, self.Cursor:GetAlpha(), 0)
	else
		self.Cursor:SetAlpha(0)
	end
end

function ConsolePort:UPDATE_BINDINGS(...)
	if not InCombatLockdown() then
		self:LoadBindingSet()
	end
end

function ConsolePort:ADDON_LOADED(...)
	local name = ...
	if name == addOn then
		self:CreateButtonHandler()
		self:LoadControllerTheme()
		self:LoadSettings()
		self:LoadEvents()
		self:UpdateExtraButton()
		self:LoadHookScripts()
		self:LoadBindingSet()
		self:CreateConfigPanel()
		self:CreateActionButtons()
		self:LoadBindingActions()
		self:SetupCursor()
		self:CheckLoadedAddons()
		self:CheckLoadedSettings()
		self:CreateRaidCursor()
	end
	if ConsolePortUIFrames and ConsolePortUIFrames[name] then
		for i, frame in pairs(ConsolePortUIFrames[name]) do
			self:AddFrame(frame)
		end
	end
	self:UpdateFrames()
	self:LoadHotKeyTextures()
end