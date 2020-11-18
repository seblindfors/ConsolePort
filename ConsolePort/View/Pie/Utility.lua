local _, db = ...;
---------------------------------------------------------------
local Utility = Mixin(CPAPI.EventHandler(ConsolePortUtilityToggle, {
	'QUEST_WATCH_LIST_CHANGED';
}), CPAPI.AdvancedSecureMixin)
local Button = CreateFromMixins(CPActionButton);
---------------------------------------------------------------
local DEFAULT_SET = 1;
---------------------------------------------------------------
Utility.Data = {[DEFAULT_SET] = {}};
Utility:Execute([[DATA = newtable()]])
Utility:SetAttribute('ignoregamepadhotkey', true)
db:Register('Utility', Utility)
db:Save('Utility/Data', 'ConsolePortUtility')

---------------------------------------------------------------
-- Secure environment
---------------------------------------------------------------
Utility:CreateEnvironment({
	DrawSelectedRing = [[
		local set = ...;
		RING = DATA[set];
		if not RING then
			return
		end

		local radius = math.sqrt(self:GetWidth() * self:GetHeight()) / 2;
		local numActive = #RING;

		control:ChildUpdate('state', set)

		for i, action in ipairs(RING) do
			local x, y = radial:RunAttribute('GetPointForIndex', i, numActive, radius)
			local widget = self:GetFrameRef(set..':'..i)

			widget:Show()
			widget:ClearAllPoints()
			widget:SetPoint('CENTER', '$parent', 'CENTER', x, y)
		end
		for i=numActive+1, self:GetAttribute('numButtons') do
			self:GetFrameRef(tostring(i)):Hide()
		end
		self:SetAttribute('size', numActive)
	]];
	CopySelectedIndex = [[
		local index = ...;
		if not RING or not index then
			return self:CallMethod('ClearInstantly')
		end
		for attribute, value in pairs(RING[index]) do
			self:SetAttribute(attribute, value)
		end
	]];
	GetRingIndexFromButton = ([[
		local button = ...;
		if DATA[button] then
			return button;
		end
		return tostring(%s);
	]]):format(DEFAULT_SET);
});

Utility:WrapScript(Utility, 'PreClick', [[
	self:SetAttribute('type', nil)

	if down then
		local set = self:Run(GetRingIndexFromButton, button)
		self:CallMethod('CheckCursorInfo', set)
		self:Run(DrawSelectedRing, set)
		self:Show()
	else
		self:Run(CopySelectedIndex, self:Run(GetIndex))
		self:Hide()
	end
]])

---------------------------------------------------------------
-- Widget and data handling
---------------------------------------------------------------
function Utility:OnDataLoaded() --SecureActionButtonTemplate, SecureHandlerEnterLeaveTemplate, CPUIActionButtonTemplate
	self:SetAttribute('size', 0)
	self:CreateFramePool('SecureActionButtonTemplate, SecureHandlerEnterLeaveTemplate, CPUIActionButtonTemplate', Button)
	local sticks = db('radialPrimaryStick')
	db:Load('Utility/Data', 'ConsolePortUtility')
	db.Radial:Register(self, 'UtiliyRing', {
		sticks = sticks;
		target = {sticks[1]};
		sizer  = [[
			local size = self:GetAttribute('size');
		]];
	});
	self:RefreshAll()

	setmetatable(self.Data, {__index = function(tbl, key) tbl[key] = {} return tbl[key] end})
end

function Utility:RefreshAll()
	self:ClearAllActions()
	local numButtons = 0;
	for setID, set in pairs(self.Data) do
		for i, action in ipairs(set) do
			self:AddSecureAction(setID, i, action)
		end
		numButtons = #set > numButtons and #set or numButtons;
	end
	self:SetAttribute('numButtons', numButtons)
end

function Utility:ClearAllActions()
	self:Execute('wipe(DATA)')
	for button in self:EnumerateActive() do
		button:ClearStates()
	end
	self:ReleaseAll()
end

function Utility:AddSecureAction(set, idx, info)
	local button, newObj = self:TryAcquireRegistered(idx)
	if newObj then
		button:SetFrameLevel(idx)
		button:SetID(idx)
		button:OnLoad()
		self:SetFrameRef(tostring(idx), button)
	end

	self:SetFrameRef(set..':'..idx, button)
	button:SetState(set, self:GetKindAndAction(info))

	local args, body = { ring = tostring(set), slot = idx }, [[
		local ring = DATA[{ring}];
		if not ring then
			DATA[{ring}] = newtable();
			ring = DATA[{ring}];
		end

		local slot = ring[{slot}];
		if not slot then
			ring[{slot}] = newtable();
			slot = ring[{slot}];
		end
	]];
	for key, value in pairs(info) do
		body = ('%s\n slot.%s = {%s}'):format(body, key, key)
		args[key] = value;
	end
	return self:Parse(body, args)
end

function Utility:OnInput(x, y, len, stick)
	self:SetFocusByIndex(self:GetIndexForPos(x, y, len, self:GetAttribute('size')))
	self:ReflectStickPosition(x, y, len, len > self:GetValidThreshold())
end

function Utility:GetButtonSlugForSet(setID)
	return db.Hotkeys:GetButtonSlugForBinding(('CLICK ConsolePortUtilityToggle:%s'):format(setID));
end

function Utility:GetBindingSuffixForSet(setID)
	return (setID == DEFAULT_SET and 'LeftButton' or tostring(setID));
end

---------------------------------------------------------------
-- Set manager
---------------------------------------------------------------
function Utility:AddAction(setID, idx, info)
	setID = setID or DEFAULT_SET;
	local set = self.Data[setID];
	local maxIndex = #set + 1;
	idx = Clamp(idx or maxIndex, 1, maxIndex)
	tinsert(set, idx, info)
	self:RefreshAll()
	return true;
end

function Utility:RemoveAction(setID, idx)
	local action = tremove(self.Data[setID], idx)
	self:RefreshAll()
	return action;
end

function Utility:ClearActionByAttribute(setID, key, value)
	local index = self:SearchActionByAttribute(setID, key, value)
	if index then
		return self:RemoveAction(setID, index)
	end
end

function Utility:ClearActionByKey(setID, key)
	local index = self:SearchActionByKey(setID, key)
	if index then
		return self:RemoveAction(setID, index)
	end
end

function Utility:SearchActionByAttribute(setID, key, value)
	local set = self.Data[setID];
	for i, action in ipairs(set) do
		for attribute, content in pairs(action) do
			if (attribute == key and content == value) then
				return i, set;
			end
		end
	end
end

function Utility:SearchActionByKey(setID, key)
	local set = self.Data[setID];
	for i, action in ipairs(set) do
		for attribute in pairs(action) do
			if (attribute == key) then
				return i, set;
			end
		end
	end
end

function Utility:IsUniqueAction(setID, info)
	local set = self.Data[setID];
	local cmp = db.table.compare;
	-- check if already existing on ring
	for i, action in ipairs(set) do
		if cmp(action, info) then
			return false, i;
		end
	end
	return true;
end

function Utility:AnnounceAddition(link, set)
	local slug = self:GetButtonSlugForSet(set)
	CPAPI.Log('%s was added to your utility ring. Use: %s', link, slug or NOT_BOUND)
end

function Utility:AnnounceRemoval(link, set)
	CPAPI.Log('%s was removed from your utility ring.', link)
end

---------------------------------------------------------------
-- Mapping from type to usable attributes
---------------------------------------------------------------
Utility.KindAndActionMap = {
	action = function(data) return data.action end;
	item   = function(data) return data.item end;
	pet    = function(data) return data.action end;
	spell  = function(data) return data.spell end;
	macro  = function(data) return data.macro end;
	equipmentset = function(data) return data.equipmentset end;
}

function Utility:GetKindAndAction(info)
	return info.type, self.KindAndActionMap[info.type](info);
end

---------------------------------------------------------------
-- Mapping from cursor info
---------------------------------------------------------------
Utility.SecureHandlerMap = {
	action = function(action)
		return {type = 'action', action = action};
	end;
	item = function(itemID, itemLink)
		return {type = 'item', item = itemLink or itemID};
	end;
	spell = function(spellIndex, bookType, spellID)
		return {type = 'spell', spell = spellID};
	end;
	macro = function(index)
		return {type = 'macro', macro = index};
	end;
	mount = function(mountID)
		local spellID = select(2, C_MountJournal.GetMountInfoByID(mountID));
		print('spellID', spellID)
		if spellID then
			return {type = 'spell', spell = spellID};
		end
	end;
	petaction = function(spellID, indexIsOffset)
		if indexIsOffset then
			return {type = 'spell', spell = spellID};
		end
	end;
	equipmentset = function(name)
		return {type = 'equipmentset', equipmentset = name};
	end;
	spellID = function(spellID)
		return {type = 'spell', spell = spellID}
	end;
}

function Utility:AddActionFromInfo(setID, idx, infoType, ...)
	local infoHandler = self.SecureHandlerMap[infoType]
	if infoHandler then
		local info = infoHandler(...)
		if info then
			return self:AddAction(setID, idx, info)
		end
	end
end

---------------------------------------------------------------
-- Special content handlers
---------------------------------------------------------------
function Utility:AddFromCursorInfo(setID, idx)
	return self:AddActionFromInfo(setID, idx, GetCursorInfo())
end

function Utility:AddUniqueAction(setID, info, preferredIndex)
	if self:IsUniqueAction(setID, info) then
		return self:AddAction(setID, preferredIndex, info)
	end
end

function Utility:AutoAssignAction(info)
	info.autoassigned = true;
	return self:AddUniqueAction(DEFAULT_SET, info)
end

function Utility:ToggleQuestWatchItem(questID, added)
	if added then
		local logIndex = C_QuestLog.GetLogIndexForQuestID(questID)
		local item = logIndex and GetQuestLogSpecialItemInfo(logIndex)
		if item then
			local info = self.SecureHandlerMap.item(item)
			info.questID = questID;

			local wasAdded = self:AutoAssignAction(info)
			if wasAdded then
				self:AnnounceAddition(item, 'LeftButton')
			end
		end
	else
		local wasRemoved = self:ClearActionByAttribute(DEFAULT_SET, 'questID', questID)
		if wasRemoved then
			self:RefreshAll()
		end
	end
end

function Utility:AddAllQuestWatchItems()
	for i=1, C_QuestLog.GetNumQuestWatches() do
		local questID = C_QuestLog.GetQuestIDForQuestWatchIndex(i)
		db:RunSafe(self.ToggleQuestWatchItem, self, questID, true)
	end
end

function Utility:CheckCursorInfo(setID)
	if not InCombatLockdown() then
		setID = tonumber(setID) or setID;
		if GetCursorInfo() then
			if self:AddFromCursorInfo(setID) then
				self:AnnounceAddition(GetCursorInfo(), self:GetBindingSuffixForSet(setID))
				ClearCursor()
			end
		end
	end
end

---------------------------------------------------------------
-- Pending action
---------------------------------------------------------------
function Utility:SetPendingAction(setID, info, force)
	if force or self:IsUniqueAction(setID, info) then
		self.pendingAction = {
			setID = setID;
			info = info;
			add = true;
		};
		return true;
	end
end

function Utility:SetPendingRemove(setID, info)
	self.pendingAction = {
		setID = setID;
		info = info;
		add = false;
	};
end

function Utility:HasPendingAction()
	return self.pendingAction;
end

function Utility:ClearPendingAction()
	self.pendingAction = nil;
end

function Utility:PostPendingAction(preferredIndex)
	local action = self.pendingAction;
	if action then
		if action.add then
			if self:AddAction(action.setID, preferredIndex, action.info) then
				self:AnnounceAddition(action.info.link, self:GetBindingSuffixForSet(action.setID))
			end
		else
			if self:ClearActionByAttribute(action.setID, 'link', action.info.link) then
				self:AnnounceRemoval(action.info.link)
			end
		end
		self.pendingAction = nil;
	end
end

---------------------------------------------------------------
-- Events
---------------------------------------------------------------
function Utility:QUEST_WATCH_LIST_CHANGED(questID, added)
	if db('autoExtra') then
		if questID then
			db:RunSafe(self.ToggleQuestWatchItem, self, questID, added)
		else
			db:RunSafe(self.ClearActionByKey, self, DEFAULT_SET, 'questID')
			self:AddAllQuestWatchItems()
		end
	end
end

---------------------------------------------------------------
-- Button mixin
---------------------------------------------------------------
function Button:OnLoad()
	self:Initialize()
	self:SetScript('OnHide', self.OnClear)
end

function Button:OnFocus()
	self:SetChecked(true)
	GameTooltip_SetDefaultAnchor(GameTooltip, self)
	self:SetTooltip()
end

function Button:OnClear()
	self:SetChecked(false)
	if GameTooltip:IsOwned(self) then
		GameTooltip:Hide()
	end
end