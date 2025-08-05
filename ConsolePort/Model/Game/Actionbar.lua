local ActionBarAPI, _, db = {
---------------------------------------------------------------
	Binding = {};
	Action = {
		['3']   = 'MULTIACTIONBAR3BUTTON%d';
		['4']   = 'MULTIACTIONBAR4BUTTON%d';
		['5']   = 'MULTIACTIONBAR2BUTTON%d';
		['6']   = 'MULTIACTIONBAR1BUTTON%d';
		['13']  = 'MULTIACTIONBAR5BUTTON%d';
		['14']  = 'MULTIACTIONBAR6BUTTON%d';
		['15']  = 'MULTIACTIONBAR7BUTTON%d';
		Default = 'ACTIONBUTTON%d';
		Abnormal = {
			[133] = 'ACTIONBUTTON1';
			[134] = 'ACTIONBUTTON2';
			[135] = 'ACTIONBUTTON3';
			[136] = 'ACTIONBUTTON4';
			[137] = 'ACTIONBUTTON5';
			[138] = 'ACTIONBUTTON6';
			[CPAPI.ExtraActionButtonID] = 'EXTRAACTIONBUTTON1';
		};
	};
	Widget = {
		['3']   = 'MultiBarRightButton%d';
		['4']   = 'MultiBarLeftButton%d';
		['5']   = 'MultiBarBottomRightButton%d';
		['6']   = 'MultiBarBottomLeftButton%d';
		['13']  = 'MultiBar5Button%d';
		['14']  = 'MultiBar6Button%d';
		['15']  = 'MultiBar7Button%d';
		Default = 'ActionButton%d';
		Abnormal = {
			[133] = 'OverrideActionBarButton1';
			[134] = 'OverrideActionBarButton2';
			[135] = 'OverrideActionBarButton3';
			[136] = 'OverrideActionBarButton4';
			[137] = 'OverrideActionBarButton5';
			[138] = 'OverrideActionBarButton6';
			[CPAPI.ExtraActionButtonID] = 'ExtraActionButton1';
		};
	};
	PageExt = { 13, 14, 15 };
	Lookup = {
		Buttons = {};
		Ignore  = {};
		Stances = {};
		Types   = {
			Button = true;
			CheckButton = true;
		};
	};
}, ...;
db:Register('Actionbar', ActionBarAPI)

---------------------------------------------------------------
-- Action buttons, IDs, and bindings
---------------------------------------------------------------
function ActionBarAPI:GetFormattedIDs(id, transpose)
	local barID = math.ceil(id / NUM_ACTIONBAR_BUTTONS)
	local modID = id % NUM_ACTIONBAR_BUTTONS
	if ( barID == 1 ) and transpose then
		barID = db.Pager:GetCurrentPage()
	end
	return barID, (modID == 0 and NUM_ACTIONBAR_BUTTONS) or modID
end

function ActionBarAPI:GetMappedValue(id, map)
	local barID, btnID = self:GetFormattedIDs(id)
	local binding = rawget(map, tostring(barID))
	if binding then
		return binding:format(btnID)
	end
	return rawget(map, 'Abnormal')[id] or rawget(map, 'Default'):format(btnID)
end

CPAPI.Proxy(ActionBarAPI.Action, function(self, id)
	return ActionBarAPI:GetMappedValue(id, self)
end)

CPAPI.Proxy(ActionBarAPI.Widget, function(self, id)
	return _G[ActionBarAPI:GetMappedValue(id, self)]
end)

-- Give default UI action buttons their correct action IDs.
-- This is to make it easier to distinguish action buttons,
-- since action bar addons use this attribute to perform actions.
-- Blizzard's own system does not use the attribute by default,
-- instead resorting to table keys/:GetID() to determine correct action.
-- Assigning the attribute manually unifies default UI with addons.
for i=CPAPI.ExtraActionButtonID, 1, -1 do
	local button = ActionBarAPI.Widget[i]
	if button then
		ActionBarAPI.Binding[ActionBarAPI.Action[i]] = i
		button:SetAttribute('action', i)
	end
end

---------------------------------------------------------------
-- Action button / action bar caching
---------------------------------------------------------------
-- Used to find action bars and action buttons from various
-- sources, to extend their hotkey functionality or cache them
-- on handlers for later manipulation.
do
	local VALID_BUTTON_TYPE = ActionBarAPI.Lookup.Types;
	local IGNORE_FRAMES = ActionBarAPI.Lookup.Ignore;
	local IsFrameWidget = C_Widget.IsFrameWidget;

	-- Helpers:
	local function GetContainer(this)
		local parent = this:GetParent()
		return (not parent or parent == UIParent) and this or GetContainer(parent)
	end

	local function ValidateActionID(this)
		return this:IsProtected() and VALID_BUTTON_TYPE[this:GetObjectType()] and this:GetAttribute('action')
	end

	local function IsActionButton(this, action)
		return action and tonumber(action) and this:GetAttribute('type') == 'action'
	end

	-- Callbacks:
	local function CacheActionButton(cache, this, action)
		cache[this] = action
		return false -- continue when found
	end

	local function CacheActionBar(cache, this, action)
		local container = GetContainer(this)
		cache[container] = container:GetName() or tostring(container)
		return true -- break when found
	end

	-- Scanner:
	local function FindActionButtons(callback, cache, this, sibling, ...)
		if sibling then FindActionButtons(callback, cache, sibling, ...) end
		if not IsFrameWidget(this) or this:IsForbidden() or IGNORE_FRAMES[this] then return cache end
		-------------------------------------
		local action = ValidateActionID(this)
		if IsActionButton(this, action) and callback(cache, this, action) then
			return cache
		end
		FindActionButtons(callback, cache, this:GetChildren())
		return cache
	end

	---------------------------------------------------------------
	-- Get all buttons that look like action buttons
	---------------------------------------------------------------
	function ActionBarAPI:GetActionButtons(asTable, parent)
		local buttons = FindActionButtons(CacheActionButton, {}, parent or UIParent)
		if asTable then return buttons end
		return pairs(buttons)
	end

	---------------------------------------------------------------
	-- Get all container frames that look like action bars
	---------------------------------------------------------------
	function ActionBarAPI:GetActionBars(asTable, parent)
		local bars = FindActionButtons(CacheActionBar, {}, parent or UIParent)
		if asTable then return bars end
		return pairs(bars)
	end

	function ActionBarAPI:SetIgnoreFrameForActionLookup(frame, enabled)
		IGNORE_FRAMES[frame] = enabled
	end

	---------------------------------------------------------------
	-- Database proxy
	---------------------------------------------------------------
	CPAPI.Proxy(ActionBarAPI.Lookup.Buttons, function(self, id)
		local matches = {}
		for button, action in ActionBarAPI:GetActionButtons() do
			if (action == id) then -- TODO: handle paging
				matches[#matches+1] = button
			end
		end
		return matches
	end)
end

---------------------------------------------------------------
-- Stance bar info caching
---------------------------------------------------------------
-- Since there is no API to reliably map bonus bar indices to
-- shapeshift forms, we cache the spell IDs of the forms when
-- they are active, and use that to look them up later.
do
	local function MakeStanceCacheKey(bonusBarIndex, specOrClassID)
		-- Shift bonusBarIndex 16 bits left, then OR with specOrClassID (assuming both are <= 0xFFFF)
		return bit.lshift(bonusBarIndex or 0, 16) + (specOrClassID or 0)
	end

	CPAPI.Proxy(ActionBarAPI.Lookup.Stances, function(_, bonusBarIndex)
		bonusBarIndex = bonusBarIndex == 0 and GetBonusBarIndex() or bonusBarIndex;
		local key = MakeStanceCacheKey(bonusBarIndex, CPAPI.GetSpecialization())
		local spellID = db.Shared:GetData(0, key)
		if spellID and spellID > 0 then
			return CPAPI.GetSpellInfo(spellID)
		end
	end)

	db:RegisterCallback('OnUpdateShapeshiftForm', function(_, spellID, bonusBarIndex)
		if not spellID or bonusBarIndex == 0 then return end;
		local key = MakeStanceCacheKey(bonusBarIndex, CPAPI.GetSpecialization())
		if db.Shared:GetData(0, key) == spellID then return end;
		db.Shared:SaveData(0, key, spellID)
		db:TriggerEvent('OnShapeshiftFormInfoChanged', bonusBarIndex, spellID)
	end, ActionBarAPI)
end

---------------------------------------------------------------
-- Action bar page map (and evaluator whether pages are shown)
---------------------------------------------------------------
ActionBarAPI.Pages = {
	CPAPI.Callable({01, 06, 05, 03, 04}, CPAPI.Static(true));
	CPAPI.Callable(ActionBarAPI.PageExt, CPAPI.Static(true));
	CPAPI.Callable({07, 08, 09, 10    }, function() return GetNumShapeshiftForms() > 0 or db('bindingShowExtraBars') end);
	CPAPI.Callable({11                }, function() return not not next(CPAPI.GetCollectedDragonridingMounts()) end);
	CPAPI.Callable({02                }, function()
		return db('bindingShowExtraBars')
			or db.Gamepad:GetBindingKey('CLICK ConsolePortPager:2')
			or db.Gamepad:GetBindingKey('ACTIONPAGE2')
			or db.Gamepad:GetBindingKey('NEXTACTIONPAGE')
			or db.Gamepad:GetBindingKey('PREVIOUSACTIONPAGE')
	end);
};

ActionBarAPI.Names = {
	-- Sets
	[ActionBarAPI.Pages[1]] = PRIMARY;
	[ActionBarAPI.Pages[2]] = BINDING_HEADER_MULTIACTIONBAR;
	[ActionBarAPI.Pages[3]] = BINDING_HEADER_MULTIACTIONBAR;
	[ActionBarAPI.Pages[4]] = MOUNT_JOURNAL_FILTER_DRAGONRIDING or 'Dragonriding';
	[ActionBarAPI.Pages[5]] = BINDING_HEADER_MULTIACTIONBAR;
	-- Individual pages
	Pages = {
		[02] = 'Page 2';
		[07] = 'Form 1';
		[08] = 'Form 2';
		[09] = 'Form 3';
		[10] = 'Form 4';
		[11] = 'Dragon';
	};
}

CPAPI.Proxy(ActionBarAPI.Names, function(self, id)
	-- Check for stance name first
	local data = ActionBarAPI.Lookup.Stances[id];
	if data then return data.name end;
	-- Check for defined page name
	data = self.Pages[id];
	if data then return db.Locale(data) end;
	-- Arbitrary page name
	local displayID = 0;
	for _, pages in ipairs(ActionBarAPI.Pages) do
		if pages() then
			for _, page in ipairs(pages) do
				displayID = displayID + 1;
				if (page == id) then
					return ('%s %d'):format(db.Locale('Bar'), displayID)
				end
			end
		end
	end
end)