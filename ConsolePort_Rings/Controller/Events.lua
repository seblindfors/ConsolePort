local env, db = CPAPI.GetEnv(...)
---------------------------------------------------------------
local Events = CPAPI.EventHandler(env.Frame, {
---------------------------------------------------------------
	'ACTIONBAR_SLOT_CHANGED';
	'BAG_UPDATE_DELAYED';
	'PLAYER_ENTERING_WORLD';
	'QUEST_DATA_LOAD_RESULT';
	'QUEST_WATCH_LIST_CHANGED';
	'QUEST_WATCH_UPDATE';
	'SPELLS_CHANGED';
	'UPDATE_BINDINGS';
	'UPDATE_EXTRA_ACTIONBAR';
	'UPDATE_MACROS';
});

---------------------------------------------------------------
-- Events
---------------------------------------------------------------
function Events:QUEST_WATCH_LIST_CHANGED(questID, added)
	if self:IsAutoEnabled() then
		if questID then
			db:RunSafe(self.ToggleQuestWatchItem, self, questID, added)
		else
			db:RunSafe(self.RefreshQuestWatchItems, self)
		end
	end
end

function Events:QUEST_WATCH_UPDATE(questID)
	if not self:IsAutoEnabled() then return end;
	self:SetObserveQuestID(questID)
end

function Events:QUEST_DATA_LOAD_RESULT(questID, success)
	if not success or not self:IsAutoEnabled() then return end;
	db:RunSafe(self.ToggleQuestWatchItemInline, self, questID)
end

function Events:UPDATE_BINDINGS()
	if self:IsAutoEnabled() and not db.Gamepad:GetBindingKey('EXTRAACTIONBUTTON1') then
		db:RunSafe(self.ToggleExtraActionButton, self, true)
	else
		db:RunSafe(self.ToggleExtraActionButton, self, false)
	end
end

function Events:UPDATE_EXTRA_ACTIONBAR()
	if self:HasExtraActionButton() and HasExtraActionBar() then
		local link = env:GetLinkFromActionInfo(GetActionInfo(CPAPI.ExtraActionButtonID))
		self:AnnounceAddition(link or BINDING_NAME_EXTRAACTIONBUTTON1, nil, true)
	end
end

-- NOTE: Register unit event instead of QUEST_LOG_UPDATE
-- to get around spam issue with certain addons.
Events:RegisterUnitEvent('UNIT_QUEST_LOG_CHANGED', 'player')
function Events:UNIT_QUEST_LOG_CHANGED()
	if not self:IsAutoEnabled() then return end;
	db:RunSafe(self.ParseObservedQuestIDs, self)
	db:RunSafe(self.RefreshQuestWatchItems, self)
end

function Events:SPELLS_CHANGED()
	env.IsSpellValidationReady = true;
	if self:IsAutoEnabled() then
		db:RunSafe(self.ToggleZoneAbilities, self)
	end
	self:QueueRefresh()
end

function Events:ACTIONBAR_SLOT_CHANGED()
	if not self:IsAutoEnabled() then return end;
	db:RunSafe(self.ToggleZoneAbilities, self)
end

function Events:BAG_UPDATE_DELAYED()
	if not self:IsAutoEnabled() then return end;
	db:RunSafe(self.ToggleInventoryQuestItems, self, not self.announcedBagAdditions)
	self.announcedBagAdditions = true; -- Only announce once per session
end

function Events:UPDATE_MACROS()
	for button in self:EnumerateActive() do
		button:UpdateAction(true)
	end
	self:QueueRefresh()
end

function Events:PLAYER_ENTERING_WORLD(isInitialLogin, isReloadingUi)
	if isInitialLogin or isReloadingUi then
		env.IsDataReady = true;
		self:QueueRefresh()
		self:UnregisterEvent('PLAYER_ENTERING_WORLD')
	end
end