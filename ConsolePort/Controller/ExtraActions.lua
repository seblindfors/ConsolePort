if CPAPI.IsRetailVersion then return end;
---------------------------------------------------------------
-- Extra action provider for bars 13, 14, and 15 on Classic
---------------------------------------------------------------
-- On Retail, these extra slots have their own buttons,
-- but on Classic they just exist in the action bar space.

local an, db = ...;
local WIDGET_FORMAT  = '%sPage%sSlot%s';
local BINDING_FORMAT = ('CLICK %s:LeftButton'):format(WIDGET_FORMAT:format(an, '%s', '%s'));
local BINDING_MATCH  = BINDING_FORMAT:format('(%d+)', '(%d+)');

local function CalculateActionID(pageID, slotID)
	return ((pageID - 1) * NUM_ACTIONBAR_BUTTONS) + slotID;
end

local function CreateActionSlotHandler(pageID, slotID, actionID)
	local name   = WIDGET_FORMAT:format('$parent', pageID, slotID)
	local sabt   = 'SecureActionButtonTemplate';
	local button = CreateFrame('Button', name, _G[an], sabt);
	button:SetAttribute(CPAPI.ActionTypePress, 'action')
	button:SetAttribute('action', actionID)
	button:RegisterForClicks('AnyDown')
	return button;
end

db:RegisterSafeCallback('OnNewBindings', function(self, bindings)
	for _, set in pairs(bindings) do
		for _, binding in pairs(set) do
			local pageID, slotID = binding:match(BINDING_MATCH)
			if pageID and slotID then
				pageID, slotID = tonumber(pageID), tonumber(slotID);
				local actionID = CalculateActionID(pageID, slotID);
				if self[actionID] then return end;
				self[actionID] = CreateActionSlotHandler(pageID, slotID, actionID);
			end
		end
	end
end, {})

---------------------------------------------------------------
do -- Set up the action bar API to use the replacements
---------------------------------------------------------------
	local ActionBarAPI = db.Actionbar;
	local bindPrefix   = db.Loadout.BindingPrefix;
	local bindParse    = BINDING_FORMAT:format('%d', '%d');

	local function TrySetBindingName(pageID, slotID)
		_G[bindPrefix:format(bindParse:format(pageID, slotID))] =
		_G[bindPrefix:format('MULTIACTIONBAR1BUTTON%d'):format(slotID)]:gsub('%d+', pageID, 1);
	end

	for _, pageID in ipairs(ActionBarAPI.PageExt) do
		local pageFormat = BINDING_FORMAT:format(pageID, '%d');
		ActionBarAPI.Action[tostring(pageID)] = pageFormat;
		for slotID = 1, NUM_ACTIONBAR_BUTTONS do
			ActionBarAPI.Binding[pageFormat:format(slotID)] = CalculateActionID(pageID, slotID);
			-- We create the global strings even if the buttons don't exist,
			-- so that the config and other doodads will display the correct names.
			securecallfunction(TrySetBindingName, pageID, slotID)
		end
	end
end