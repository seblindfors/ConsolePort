local _, db = ...;
---------------------------------------------------------------
local Utility = Mixin(CPAPI.EventHandler(ConsolePortUtilityToggle, {
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
}), CPAPI.AdvancedSecureMixin)
local Button = CreateFromMixins(CPActionButton);
local ActionButton = LibStub('ConsolePortActionButton')
---------------------------------------------------------------
local DEFAULT_SET, EXTRA_ACTION_ID = CPAPI.DefaultRingSetID, CPAPI.ExtraActionButtonID;
---------------------------------------------------------------
Utility.Data = {[DEFAULT_SET] = {}};
Utility:Execute(([[
	DATA = newtable()
	TYPE = '%s';
]]):format(CPAPI.ActionTypeRelease))
---------------------------------------------------------------
db:Register('Utility', Utility)
db:Save('Utility/Data', 'ConsolePortUtility')

---------------------------------------------------------------
-- Secure environment
---------------------------------------------------------------
Utility:CreateEnvironment({
	-----------------------------------------------------------
	-- Draw current ring
	-----------------------------------------------------------
	DrawSelectedRing = [[
		local set = ...;
		RING = DATA[set];
		if not RING then
			return
		end

		local numActive = #RING;
		local radius = self::SetDynamicRadius(numActive)
		local invertY = self:GetAttribute('axisInversion')

		self:SetAttribute('trigger', self::GetButtonsHeld())
		self:SetAttribute('state', set)
		control:ChildUpdate('state', set)

		for i, action in ipairs(RING) do
			local x, y = radial::GetPointForIndex(i, numActive, radius)
			local widget = self:GetFrameRef(set..':'..i)

			widget:CallMethod('SetRotation', -math.atan2(x, y))
			widget:Show()
			widget:ClearAllPoints()
			widget:SetPoint('CENTER', '$parent', 'CENTER', x, invertY * y)
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

		self:CallMethod('OnSelection', true)
		for attribute, value in pairs(RING[index]) do
			local convertedAttribute = (attribute == 'type') and TYPE or attribute;
			self:SetAttribute(convertedAttribute, value)
			self:CallMethod('OnSelectionAttributeAdded', convertedAttribute, value)
		end
		self:CallMethod('OnSelection', false)
	]];
	GetRingSetFromButton = ([[
		local button = ...;
		if DATA[button] then
			return button;
		end
		return tostring(%s);
	]]):format(DEFAULT_SET);
	-----------------------------------------------------------
	-- Set pre-defined remove binding
	-----------------------------------------------------------
	SetRemoveBinding = [[
		local enabled = ...;
		if enabled then
			local binding, trigger = self:GetAttribute('removeButton'), self:GetAttribute('trigger')
			if trigger and binding and trigger:match(binding) then
				self:SetAttribute('removeButtonBlocked', true)
				return self:ClearBindings()
			end

			self:SetAttribute('removeButtonBlocked', false)
			local mods = {self::GetModifiersHeld()}
			table.sort(mods)
			mods[#mods+1] = table.concat(mods)

			local removeWidget = self:GetFrameRef('Remove')
			for _, mod in ipairs(mods) do
				self:SetBindingClick(true, mod..binding, removeWidget)
			end
			self:SetBindingClick(true, binding, removeWidget)
		else
			self:ClearBindings()
		end
	]];
	-----------------------------------------------------------
	ClearStickyIndex = ([[
		if self:GetAttribute('stickyIndex') then
			self:SetAttribute('stickyIndex', nil)
			self:SetAttribute('backup', nil)
			self:SetAttribute('TYPE', nil)
			self:CallMethod('OnStickyIndexChanged')
		end
	]]):gsub('TYPE', CPAPI.ActionTypeRelease);
});

---------------------------------------------------------------
-- Trigger script
---------------------------------------------------------------
Utility:SetAttribute('pressAndHoldAction', true)
Utility:Wrap('PreClick', ([[
	local stickySelect = self:GetAttribute('stickySelect')

	if stickySelect then
		if down then
			self:SetAttribute('backup', self:GetAttribute('TYPE'))
			self:SetAttribute('TYPE', nil)
		else
			self:SetAttribute('TYPE', self:GetAttribute('backup'))
			self:SetAttribute('backup', nil)
		end
	else
		self:SetAttribute('TYPE', nil)
	end

	if down then
		local set = self::GetRingSetFromButton(button)
		self:CallMethod('CheckCursorInfo', set)
		self::DrawSelectedRing(set)
		self::SetRemoveBinding(true)
		self:Show()
		if stickySelect then
			if ( set ~= self:GetAttribute('stickyState') ) then
				self:SetAttribute('stickyIndex', nil)
				self:SetAttribute('stickyState', set)
			end
		end
	else
		local index = self::GetIndex()
		self::CopySelectedIndex(index)
		self:ClearBindings()
		self:Hide()
		if stickySelect then
			self:SetAttribute('stickyIndex', index or self:GetAttribute('stickyIndex'))
		end
	end
]]):gsub('TYPE', CPAPI.ActionTypeRelease))


---------------------------------------------------------------
-- Secure removal
---------------------------------------------------------------
Utility:SetFrameRef('Remove', Utility.Remove)
Utility:WrapScript(Utility.Remove, 'OnClick', [[
	local index = control:Run(GetIndex)
	local set = control:GetAttribute('state')
	if set and index then
		control:CallMethod('SafeRemoveAction', set, index)
		control:Run(DrawSelectedRing, set)
		control:CallMethod('OnPostShow')
		return control:CallMethod('OnStickySelectChanged')
	end
	return control:Run(ClearStickyIndex)
]])

---------------------------------------------------------------
-- Data handling
---------------------------------------------------------------
function Utility:OnDataLoaded()
	self:SetAttribute('size', 0)

	self:CreateObjectPool(ActionButton:NewPool({
		name   = self:GetName()..'Button';
		header = self;
		mixin  = Button;
		config = {
			showGrid = true;
			hideElements = {
				macro = true;
			};
		};
	}))
	db:Load('Utility/Data', 'ConsolePortUtility')

	local sticks = db.Radial:GetStickStruct(db('radialPrimaryStick'))
	db.Radial:Register(self, 'UtilityRing', {
		sticks = sticks;
		target = {sticks[1]};
		sizer  = [[
			local size = self:GetAttribute('size');
		]];
	});
	CPAPI.Proxy(self.Data, function(data, key)
		self:Parse([[
			DATA[{ring}] = newtable();
		]], {ring = tostring(key)})
		return rawset(data, key, {})[key];
	end)
	self:OnAutoAssignedChanged()
	self:OnRemoveButtonChanged()
	self:OnAxisInversionChanged()
	self:OnStickySelectChanged()
	if CPAPI.IsRetailVersion then
		self.BgRunes:SetAtlas('heartofazeroth-orb-activated')
	else
		self.BgRunes:SetAtlas('ChallengeMode-RuneBG')
	end
end

function Utility:OnAutoAssignedChanged()
	self.autoAssignExtras = db('autoExtra')
end

function Utility:OnAxisInversionChanged()
	self.axisInversion = db('radialCosineDelta')
	self:SetAttribute('axisInversion', self.axisInversion)
end

function Utility:OnRemoveButtonChanged()
	self:SetAttribute('removeButton', db('radialRemoveButton'))
end

function Utility:OnPrimaryStickChanged()
	local sticks = db.Radial:GetStickStruct(db('radialPrimaryStick'))
	self:SetInterrupt(sticks)
	self:SetIntercept({sticks[1]})
end

function Utility:OnStickySelectChanged()
	self:SetAttribute('stickySelect', db('radialStickySelect'))
	self:SetAttribute(CPAPI.ActionTypeRelease, nil)
	self:SetAttribute('backup', nil)
	self:SetAttribute('stickyIndex', nil)
	self:SetAttribute('stickyState', nil)
	self.StickySlice:Hide()
end

function Utility:OnSizeChanged()
	local width, height = self:GetSize()
	self.BgRunes:SetSize(width * 0.8, height * 0.8)
	self.StickySlice:UpdateSize(width, height)
end

function Utility:OnStickyIndexChanged()
	local hasStickySelection = self:GetAttribute('stickyIndex')
	self.StickySlice:SetShown(hasStickySelection)
	if hasStickySelection then
		self.StickySlice:SetAlpha(1)
		self.StickySlice:SetIndex(hasStickySelection)
	end
end

db:RegisterSafeCallback('Settings/autoExtra', Utility.OnAutoAssignedChanged, Utility)
db:RegisterSafeCallback('Settings/radialCosineDelta', Utility.OnAxisInversionChanged, Utility)
db:RegisterSafeCallback('Settings/radialRemoveButton', Utility.OnRemoveButtonChanged, Utility)
db:RegisterSafeCallback('Settings/radialPrimaryStick', Utility.OnPrimaryStickChanged, Utility)
db:RegisterSafeCallback('Settings/radialStickySelect', Utility.OnStickySelectChanged, Utility)
Utility:SetScript('OnSizeChanged', Utility.OnSizeChanged)
Utility:HookScript('OnShow', Utility.OnStickyIndexChanged)

---------------------------------------------------------------
-- Widget handling
---------------------------------------------------------------
function Utility:QueueRefresh()
	if self.isDataReady then
		db:RunSafe(self.RefreshAll, self)
	end
end

function Utility:RefreshAll()
	self:ClearAllActions()
	local numButtons = 0;
	for setID, set in pairs(self:ValidateData()) do
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
		button:SetFrameLevel(idx + 2)
		button:SetID(idx)
		button:OnLoad()
		button:DisableDragNDrop(true)
		button:SetSize(64, 64)
		self:SetFrameRef(tostring(idx), button)
	end

	self:SetFrameRef(set..':'..idx, button)
	local kind, action = self:GetKindAndAction(info)
	if not kind or not action then
		return -- TODO: not good, we end up with missing indices.
	end
	button:SetState(set, kind, action)

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

db:RegisterSafeCallback('OnRingCleared', Utility.RefreshAll, Utility)
db:RegisterSafeCallback('OnRingRemoved', Utility.RefreshAll, Utility)

---------------------------------------------------------------
-- Frontend
---------------------------------------------------------------
function Utility:OnInput(x, y, len)
	local size = self:GetAttribute('size')
	local obj = self:SetFocusByIndex(self:GetIndexForPos(x, y, len, size))
	local valid = self:IsValidThreshold(len)
	local rot = self:ReflectStickPosition(self.axisInversion * x, self.axisInversion * y, len, valid)
	self:SetAnimations(obj, rot, len)

	if self:GetAttribute('stickyIndex') then
		self.StickySlice:SetAlpha(Clamp(1 - len, 0, 1))
	end
end

function Utility:GetSetID(rawSetID)
	return tonumber(rawSetID) or rawSetID;
end

function Utility:ConvertBindingToDisplayName(binding)
	if ( type(binding) == 'string' ) then
		local name = binding:gsub('CLICK ConsolePortUtilityToggle:(.*)', '%1')
		return ( name ~= binding ) and
			((tonumber(name) and ('Ring |cFF00FFFF%s|r'):format(name) or name)) or nil;
	end
end

function Utility:ConvertSetIDToDisplayName(setID)
	local L = db.Locale;
	return (setID == DEFAULT_SET and L'Utility Ring')
		or (tonumber(setID) and L('Ring |cFF00FFFF%s|r', setID))
		or (tostring(setID));
end

function Utility:GetBindingForSet(setID)
	return ('CLICK ConsolePortUtilityToggle:%s'):format(self:GetBindingSuffixForSet(setID));
end

function Utility:GetBindingSuffixForSet(setID)
	return (tonumber(setID) == DEFAULT_SET and 'LeftButton' or tostring(setID));
end

function Utility:GetButtonSlugForSet(setID)
	return db.Hotkeys:GetButtonSlugForBinding(self:GetBindingForSet(setID));
end

function Utility:GetBindingDisplayNameForSet(setID)
	return self:ConvertBindingToDisplayName(self:GetBindingForSet(setID));
end

function Utility:GetTooltipRemovePrompt()
	local removeButton = not self:GetAttribute('removeButtonBlocked') and self:GetAttribute('removeButton')
	local device = db('Gamepad/Active')
	if removeButton and device then
		return device:GetTooltipButtonPrompt(removeButton, REMOVE, 64)
	end
end

function Utility:GetTooltipUsePrompt()
	local useButton = self:GetAttribute('trigger')
	local device = db('Gamepad/Active')
	if useButton and device then
		return device:GetTooltipButtonPrompt(useButton, USE, 64)
	end
end

function Utility:OnSelection(running)
	if running then
		self.ReportData = {};
	else
		db:TriggerEvent('OnUtilityRingSelectionChanged', self.ReportData)
		self.ReportData = nil;
	end
end

function Utility:OnSelectionAttributeAdded(attribute, value)
	self.ReportData[attribute] = value;
end

---------------------------------------------------------------
-- Animations
---------------------------------------------------------------
do
	local Clamp = Clamp;

	function Utility:SetAnimations(obj, rot, len)
		local pulse = Clamp(len, 0.05, 0.25)

		self.PulseAnim.PulseIn:SetFromAlpha(pulse / 2)
		self.PulseAnim.PulseIn:SetToAlpha(pulse)
		self.PulseAnim.PulseOut:SetToAlpha(pulse / 2)
		self.PulseAnim.PulseOut:SetFromAlpha(pulse)
	end

	Utility:HookScript('OnHide', function(self)
		self:SetAnimations(nil, 0, 0)
	end)
end

---------------------------------------------------------------
-- Set manager
---------------------------------------------------------------
function Utility:AddSavedVar(setID, idx, info)
	setID = setID or DEFAULT_SET;
	local set = self.Data[setID];
	local maxIndex = #set + 1;
	idx = Clamp(idx or maxIndex, 1, maxIndex)
	tinsert(set, idx, info)
end

function Utility:RemoveSavedVar(setID, idx)
	return tremove(self.Data[setID], idx)
end

function Utility:AddAction(setID, idx, info)
	self:AddSavedVar(setID, idx, info)
	self:RefreshAll()
	return true;
end

function Utility:RemoveAction(setID, idx)
	local action = self:RemoveSavedVar(setID, idx)
	self:RefreshAll()
	return action;
end

function Utility:SafeAddAction(setID, idx, ...)
	local info = {};
	for i=1, select('#', ...), 2 do
		info[select(i, ...)] = select(i + 1, ...);
	end
	self:AddSavedVar(self:GetSetID(setID), tonumber(idx), info)
end

function Utility:SafeRemoveAction(setID, idx)
	if not InCombatLockdown() then
		self:RemoveAction(self:GetSetID(setID), tonumber(idx))
	end
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

---------------------------------------------------------------
-- Announcements
---------------------------------------------------------------
Utility.Messages, Utility.MessageCount = {}, 0;

function Utility:AnnounceAddition(link, set, force)
	local slug = self:GetButtonSlugForSet(set or 'LeftButton')
	if self.MessageCount > 10 then
		wipe(self.Messages)
		self.MessageCount = 0;
	end
	local messageID = self:GetBindingSuffixForSet(set) .. link;
	local messageIsNew = not self.Messages[messageID]; 
	if force or messageIsNew then
		CPAPI.Log('%s was added to your utility ring. Use: %s', link, slug or NOT_BOUND)
		self.Messages[messageID] = true;
		if messageIsNew then
			self.MessageCount = self.MessageCount + 1;
		end
	end
end

function Utility:AnnounceRemoval(link, set)
	CPAPI.Log('%s was removed from your utility ring.', link)
	local messageID = self:GetBindingSuffixForSet(set) .. link;
	if self.Messages[messageID] then
		self.Messages[messageID] = nil;
		self.MessageCount = self.MessageCount - 1;
	end
end

---------------------------------------------------------------
-- Data validation
---------------------------------------------------------------
Utility.ValidationMap = {
	macro = function(data)
		local macroID = data.macro;
		local info = CPAPI.GetMacroInfo(macroID)
		if not data.body and info then
			return CreateFromMixins(data, info)
		elseif ( not info or ( data.body ~= info.body) ) then
			local bestMatchID, bestMatchScore = nil, math.huge;
			local test = { body = data.body, name = data.name, icon = data.icon }

			for id, other in pairs(CPAPI.GetAllMacroInfo()) do
				local score = 0;
				if other.body and test.body then
					score = score + CPAPI.MinEditDistance(other.body, test.body)
				end
				if other.name and test.name then
					score = score + CPAPI.MinEditDistance(other.name, test.name)
				end
				if other.icon == test.icon then
					score = score - 1 -- Matching icon reduces the score
				end
				if score < bestMatchScore then
					bestMatchScore, bestMatchID = score, id;
				end
			end

			if bestMatchID then
				return CreateFromMixins(data, CPAPI.GetMacroInfo(bestMatchID), {
					macro = bestMatchID;
				})
			end
		end
		return data;
	end;
	item = function(data, setID, idx)
		local item = data.item;
		local link = data.link;
		if not item and not link then
			return CPAPI.Log('Invalid item removed from %s in slot %d.',
				Utility:ConvertSetIDToDisplayName(setID),
				idx
			);
		end
		if ( type(item) == 'number' ) then
			item = CPAPI.GetItemInfo(item).itemLink;
			link = item;
		end
		if not item then
			item = link;
		end
		if not tostring(item):match('item:%d+') then
			-- NOTE: This check is to make sure LAB:getItemId receives a valid item link.
			return CPAPI.Log('Invalid item removed from %s:\nID: %s\nLink: %s',
				Utility:ConvertSetIDToDisplayName(setID),
				tostring(item),
				tostring(link)
			);
		end
		return CreateFromMixins(data, { item = item, link = link });
	end;
	--[[spell = function(data, setID, idx)
		local spell = data.spell;
		local link  = data.link;
		if not spell and not link then
			return CPAPI.Log('Invalid spell removed from %s in slot %d.',
				Utility:ConvertSetIDToDisplayName(setID),
				idx
			);
		end
		if not spell then
			spell = link;
		end
		local info = CPAPI.GetSpellInfo(spell)
		if not info.spellID and not CPAPI.GetSpellLink(spell) then
			-- NOTE: if the spellID is not found, the spell is invalid,
			-- at least for the current character.
			return CPAPI.Log('Invalid spell removed from %s:\nID: %s\nLink: %s',
				Utility:ConvertSetIDToDisplayName(setID),
				tostring(spell),
				tostring(link)
			);
		end
		return data;
	end;]]
};

function Utility:ValidateAction(action, setID, idx)
	if not action then return end;
	local validator = self.ValidationMap[action.type];
	if validator then
		return validator(action, setID, idx);
	end
	return action;
end

function Utility:ValidateData()
	for setID, set in pairs(self.Data) do
		local validSet = {};
		for i = 1, #set do
			local validAction = self:ValidateAction(set[i], setID, i);
			if validAction then
				tinsert(validSet, validAction)
			end
		end
		wipe(set)
		tAppendAll(set, validSet)
	end
	return self.Data;
end

---------------------------------------------------------------
-- Mapping from type to usable attributes
---------------------------------------------------------------
local function GetUsableSpellID(data)
	return ( data.link and data.link:match('spell:(%d+)') )
		or CPAPI.GetSpellInfo(data.spell).spellID or data.spell;
end

Utility.KindAndActionMap = {
	action = function(data) return data.action end;
	item   = function(data) return data.item end;
	pet    = function(data) return data.action end;
	macro  = function(data) return data.macro end;
	spell  = function(data) return GetUsableSpellID(data) end;
	equipmentset = function(data) return data.equipmentset end;
}

function Utility:GetKindAndAction(info)
	return info.type, self.KindAndActionMap[info.type](info);
end

---------------------------------------------------------------
-- Link map
---------------------------------------------------------------
Utility.LinkMap = {
	spell = function(spell, ...)
		local args = select('#', ...)
		if (args > 1) then
			local bookType = ...;
			return CPAPI.GetSpellBookItemLink(spell, bookType)
		end
		return CPAPI.GetSpellLink(spell)
	end;
	item = function(...)
		return select(2, ...)
	end;
}

function Utility:GetLinkFromInfo(type, ...)
	local func = self.LinkMap[type];
	if func then
		return func(...)
	end
end

---------------------------------------------------------------
-- Mapping from cursor info
---------------------------------------------------------------
Utility.SecureHandlerMap = {
	action = function(action)
		return {type = 'action', action = action};
	end;
	item = function(itemID, itemLink)
		return {type = 'item', item = itemLink or itemID, link = itemLink};
	end;
	spell = function(spellIndex, bookType, spellID)
		return {type = 'spell', spell = spellID, link = CPAPI.GetSpellLink(spellID)};
	end;
	macro = function(index)
		local info = CPAPI.GetMacroInfo(index)
		info.type, info.macro = 'macro', index;
		return info;
	end;
	mount = function(mountID)
		local spellID = select(2, CPAPI.GetMountInfoByID(mountID));
		local spellName = spellID and CPAPI.GetSpellInfo(spellID).name;
		if spellName then
			return {type = 'spell', spell = spellName, link = CPAPI.GetSpellLink(spellName)};
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
	companion = function(companionID, companionType)
		if ( companionType == 'MOUNT' and CPAPI.GetMountInfoByID(companionID) ) then
			return Utility.SecureHandlerMap.mount(companionID)
		end
		local _, spellName = GetCompanionInfo(companionType, companionID)
		if spellName then
			return {type = 'spell', spell = spellName, link = CPAPI.GetSpellLink(spellName)}
		end
	end;
}

function Utility:AddActionFromInfo(setID, idx, infoType, ...)
	local infoHandler = self.SecureHandlerMap[infoType]
	if infoHandler then
		local info = infoHandler(...)
		if info then
			return self:AddUniqueAction(setID, idx, info)
		end
	end
end

---------------------------------------------------------------
-- Special content handlers
---------------------------------------------------------------
function Utility:AddFromCursorInfo(setID, idx)
	return self:AddActionFromInfo(setID, idx, GetCursorInfo())
end

function Utility:AddUniqueAction(setID, preferredIndex, info)
	if self:IsUniqueAction(setID, info) then
		return self:AddAction(setID, preferredIndex, info)
	end
end

function Utility:AutoAssignAction(info, preferredIndex)
	info.autoassigned = true;
	return self:AddUniqueAction(DEFAULT_SET, preferredIndex, info)
end

function Utility:GetItemForQuestID(questID)
	local logIndex = CPAPI.GetQuestLogIndexForQuestID(questID)
	return logIndex and GetQuestLogSpecialItemInfo(logIndex)
end

function Utility:AddQuestWatchItem(questID)
	local item = self:GetItemForQuestID(questID)
	if item then
		local info = self.SecureHandlerMap.item(item)
		info.questID = questID;

		local wasAdded = self:AutoAssignAction(info)
		if wasAdded then
			self:AnnounceAddition(item)
		end
		return wasAdded;
	end
end

function Utility:RemoveQuestWatchItem(questID)
	local wasRemoved = self:ClearActionByAttribute(DEFAULT_SET, 'questID', questID)
	if wasRemoved then
		self:RefreshAll()
	end
end

function Utility:ToggleQuestWatchItem(questID, added)
	if added then
		self:AddQuestWatchItem(questID)
	else
		self:RemoveQuestWatchItem(questID)
	end
end

function Utility:ToggleQuestWatchItemInline(questID)
	local item = self:GetItemForQuestID(questID)
	if item then
		local info = self.SecureHandlerMap.item(item)
		info.questID = questID;

		local wasAdded = self:AutoAssignAction(info)
		if wasAdded then
			self:AnnounceAddition(item)
		end
	else
		self:RemoveQuestWatchItem(questID)
	end
end

function Utility:SetObserveQuestID(questID)
	self.observedQuestIDs = self.observedQuestIDs or {};
	self.observedQuestIDs[questID] = true;
end

function Utility:ParseObservedQuestIDs()
	local observedQuestIDs = self.observedQuestIDs;
	if observedQuestIDs then
		self.observedQuestIDs = nil;
		for questID in pairs(observedQuestIDs) do
			self:ToggleQuestWatchItemInline(questID)
		end
	end
end

function Utility:AddAllQuestWatchItems()
	for i=1, CPAPI.GetNumQuestWatches() do
		local questID = C_QuestLog.GetQuestIDForQuestWatchIndex(i)
		self:ToggleQuestWatchItem(questID, true)
	end
end

function Utility:RefreshQuestWatchItems()
	self:ClearActionByKey(DEFAULT_SET, 'questID')
	self:AddAllQuestWatchItems()
end

function Utility:ToggleExtraActionButton(enabled)
	if not CPAPI.IsRetailVersion then return end

	if enabled then
		self:AutoAssignAction(self.SecureHandlerMap.action(EXTRA_ACTION_ID), 1)
	else
		self:ClearActionByAttribute(DEFAULT_SET, 'action', EXTRA_ACTION_ID)
	end
end

function Utility:ToggleZoneAbilities()
	local zoneAbilities = CPAPI.GetActiveZoneAbilities()
	table.sort(zoneAbilities, function(lhs, rhs)
		return lhs.uiPriority < rhs.uiPriority;
	end)

	for i, zoneAbility in ipairs(zoneAbilities) do
		local spellID = zoneAbility.spellID;
		if not C_ActionBar.FindSpellActionButtons(spellID) then
			local wasAdded = self:AutoAssignAction(self.SecureHandlerMap.spellID(spellID))
			if wasAdded then
				self:AnnounceAddition((CPAPI.GetSpellLink(spellID)))
			end
		else
			local index, set = self:SearchActionByAttribute(DEFAULT_SET, 'spell', spellID)
			if index and set then
				local action = set[index];
				if action and action.autoassigned then
					self:RemoveAction(DEFAULT_SET, index)
				end
			end
		end
	end
end

function Utility:ToggleInventoryQuestItems(hideAnnouncement)
	if CPAPI.IsRetailVersion then return end
	local function getItemID(input) return input:match('item:(%d+)') end;

	local set, exists = self.Data[DEFAULT_SET], {};
	for i = #set, 1, -1 do
		local info = set[i];
		if info.autoqitem then
			local itemID = getItemID(info.item);
			if GetItemCount(info.item) < 1 or exists[itemID] then
				self:RemoveAction(DEFAULT_SET, i)
			else
				exists[itemID] = true;
			end
		end
	end

	CPAPI.IteratePlayerInventory(function(item)
		local link = CPAPI.GetContainerItemInfo(item:GetBagAndSlot()).hyperlink;
		local isQuestItem = link and select(6, GetItemInfoInstant(link)) == LE_ITEM_CLASS_QUESTITEM;
		if isQuestItem and IsUsableItem(link) and not exists[getItemID(link)] then
			local info = self.SecureHandlerMap.item(link)
			info.autoqitem = true;

			local wasAdded = self:AutoAssignAction(info)
			if wasAdded and not hideAnnouncement then
				self:AnnounceAddition(link)
			end
		end
	end)
end

function Utility:CheckCursorInfo(setID, silent)
	if not InCombatLockdown() then
		setID = self:GetSetID(setID);
		if GetCursorInfo() then
			if self:AddFromCursorInfo(setID) then
				if not silent then
					-- TODO: map returns to links
					self:AnnounceAddition(
						GetCursorInfo():gsub('^%l', strupper),
						self:GetBindingSuffixForSet(setID), true
					);
				end
				ClearCursor()
				db:TriggerEvent('OnRingContentChanged', setID)
			end
		end
	end
end

---------------------------------------------------------------
-- Pending action
---------------------------------------------------------------
local function CreatePendingAction(setID, info, enabled)
	return {
		setID = setID;
		info  = info;
		add   = enabled;
	};
end

function Utility:SetPendingAction(setID, info, force)
	if force or self:IsUniqueAction(setID, info) then
		self.pendingAction = CreatePendingAction(setID, info, true)
		return true;
	end
end

function Utility:SetPendingRemove(setID, info)
	self.pendingAction = CreatePendingAction(setID, info, false)
	return true;
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
				self:AnnounceAddition(action.info.link, self:GetBindingSuffixForSet(action.setID), true)
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
	if self.autoAssignExtras then
		if questID then
			db:RunSafe(self.ToggleQuestWatchItem, self, questID, added)
		else
			db:RunSafe(self.RefreshQuestWatchItems, self)
		end
	end
end

function Utility:QUEST_WATCH_UPDATE(questID)
	if self.autoAssignExtras then
		self:SetObserveQuestID(questID)
	end
end

function Utility:QUEST_DATA_LOAD_RESULT(questID, success)
	if success and self.autoAssignExtras then
		db:RunSafe(self.ToggleQuestWatchItemInline, self, questID)
	end
end

function Utility:UPDATE_BINDINGS()
	if self.autoAssignExtras and not db.Gamepad:GetBindingKey('EXTRAACTIONBUTTON1') then
		self.hasExtraActionButton = true;
		db:RunSafe(self.ToggleExtraActionButton, self, true)
	else
		self.hasExtraActionButton = false;
		db:RunSafe(self.ToggleExtraActionButton, self, false)
	end
end

function Utility:UPDATE_EXTRA_ACTIONBAR()
	if self.hasExtraActionButton and HasExtraActionBar() then
		local link = self:GetLinkFromInfo(GetActionInfo(EXTRA_ACTION_ID))
		self:AnnounceAddition(link or BINDING_NAME_EXTRAACTIONBUTTON1, nil, true)
	end
end

-- NOTE: Register unit event instead of QUEST_LOG_UPDATE
-- to get around spam issue with certain addons.
Utility:RegisterUnitEvent('UNIT_QUEST_LOG_CHANGED', 'player')
function Utility:UNIT_QUEST_LOG_CHANGED()
	if self.autoAssignExtras then
		db:RunSafe(self.ParseObservedQuestIDs, self)
		db:RunSafe(self.RefreshQuestWatchItems, self)
	end
end

function Utility:SPELLS_CHANGED()
	if self.autoAssignExtras then
		db:RunSafe(self.ToggleZoneAbilities, self)
	end
	self:QueueRefresh()
end

function Utility:ACTIONBAR_SLOT_CHANGED()
	if self.autoAssignExtras then
		db:RunSafe(self.ToggleZoneAbilities, self)
	end
end

function Utility:BAG_UPDATE_DELAYED()
	if self.autoAssignExtras then
		db:RunSafe(self.ToggleInventoryQuestItems, self, not self.announceBagAdditions)
		self.announceBagAdditions = true;
	end
end

function Utility:UPDATE_MACROS()
	for button in self:EnumerateActive() do
		button:UpdateAction(true)
	end
	self:QueueRefresh()
end

function Utility:PLAYER_ENTERING_WORLD(isInitialLogin, isReloadingUi)
	if isInitialLogin or isReloadingUi then
		self.isDataReady = true;
		self:QueueRefresh()
		self:UnregisterEvent('PLAYER_ENTERING_WORLD')
	end
end

---------------------------------------------------------------
-- Button mixin
---------------------------------------------------------------
function Button:OnLoad()
	self:SetPreventSkinning(true)
	self:Initialize()
	self:SetScript('OnHide', self.OnClear)
	self:SetScript('OnShow', self.UpdateLocal)
	self:SetRotation(self.rotation or 0)
	ActionButton.Skin.UtilityRingButton(self)
end

function Button:OnFocus()
	self:LockHighlight()
	self:GetParent():SetActiveSliceText(self.Name:GetText())
	if GameTooltip:IsOwned(self) then
		return;
	end
	GameTooltip_SetDefaultAnchor(GameTooltip, self)
	self:SetTooltip()
	local use = Utility:GetTooltipUsePrompt()
	local remove = Utility:GetTooltipRemovePrompt()
	if use then
		GameTooltip:AddLine(use)
	end
	if ( remove and remove ~= use ) then
		GameTooltip:AddLine(remove)
	end
	GameTooltip:Show()
end

function Button:OnClear()
	self:UnlockHighlight()
	if GameTooltip:IsOwned(self) then
		GameTooltip:Hide()
	end
	self:GetParent():SetActiveSliceText(nil)
end

function Button:UpdateLocal()
	self:SetRotation(self.rotation or 0)
	ActionButton.Skin.UtilityRingButton(self)
	RunNextFrame(function()
		self:GetParent():SetSliceText(self:GetID(), self.Name:GetText())
		local spellId = self:GetSpellId()
		if spellId and CPAPI.IsSpellOverlayed(spellId) then
			self:ShowOverlayGlow()
		else
			self:HideOverlayGlow()
		end
	end)
end