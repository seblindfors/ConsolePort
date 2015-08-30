local addOn, db = ...
local UIControls = db.UI.Controls

local function IsMouselookEvent(event)
	if 	ConsolePortMouseSettings then
		return ConsolePortMouseSettings[event]
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
		MouselookStart()
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
	self:MapGetZones()
end

function ConsolePort:QUEST_AUTOCOMPLETE(...)
	local id = ...
	ShowQuestComplete(GetQuestLogIndexByID(id))
end

function ConsolePort:CURRENT_SPELL_CAST_CHANGED(...)
	if SpellIsTargeting() then
		MouselookStop()
	elseif 	GetMouseFocus() == WorldFrame and
		IsMouselookEvent(event) then
		MouselookStart()
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
	for i, UIControl in pairs(UIControls) do
		if UIControl.frame:IsVisible() then
			UIFrameFadeIn(UIControl.frame, 0.2, 0.75, 1)
		else
			UIControl.frame:SetAlpha(1)
		end
	end
end

function ConsolePort:PLAYER_REGEN_DISABLED(...)
	for i, UIControl in pairs(UIControls) do
		if UIControl.frame:IsVisible() then
			UIFrameFadeOut(UIControl.frame, 0.2, 1, 0.75)
		else
			UIControl.frame:SetAlpha(0.75)
		end
	end
end

function ConsolePort:UPDATE_BINDINGS(...)
	if not InCombatLockdown() then
		self:LoadBindingSet()
	end
end
