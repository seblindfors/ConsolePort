local _, db = ...; local ActionBarAPI = {
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
	Lookup = {
		Buttons = {};
		Ignore = {};
		Types = {	
			Button = true;
			CheckButton = true;
		};
	};
};
db:Register('Actionbar', ActionBarAPI)

---------------------------------------------------------------
-- Action buttons, IDs, and bindings
---------------------------------------------------------------
function ActionBarAPI:GetFormattedIDs(id)
	local barID = math.ceil(id / NUM_ACTIONBAR_BUTTONS)
	local modID = id % NUM_ACTIONBAR_BUTTONS
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
-- Action bar page map (and evaluator whether pages are shown)
---------------------------------------------------------------
ActionBarAPI.Pages = {
	CPAPI.Callable({01, 06, 05, 03, 04}, function() return true end);
	CPAPI.Callable({13, 14, 15        }, function() return CPAPI.IsRetailVersion end);
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
	[ActionBarAPI.Pages[1]] = ACTIONBARS_LABEL or 'Action Bars';
	[ActionBarAPI.Pages[2]] = BINDING_HEADER_MULTIACTIONBAR or 'Extra Action Bars';
	[ActionBarAPI.Pages[3]] = ('%s | %s'):format(TUTORIAL_TITLE61_WARRIOR or 'Combat Stances', TUTORIAL_TITLE61_DRUID or 'Shapeshifting');
	[ActionBarAPI.Pages[4]] = MOUNT_JOURNAL_FILTER_DRAGONRIDING or 'Dragonriding';
	[ActionBarAPI.Pages[5]] = BINDING_NAME_ACTIONPAGE2 or 'Action Page 2';
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
	if self.Pages[id] then
		return db.Locale(self.Pages[id]);
	end
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