if not CPAPI.IsCamelotVersion then return end;
---------------------------------------------------------------
-- Gamepad action storage provider (Forever)
---------------------------------------------------------------
-- Binding names and click targets for the gamepad slot range,
-- so a gamepad bar slot can be bound like ACTIONBUTTON1.

local an, db = ...;
local ActionBarAPI = db.Actionbar;
local gp = ActionBarAPI.Gamepad;
local BINDING_MATCH = gp.Format:gsub('%%d', '(%%d+)');
local Buttons = {};

local function GetStanceDriver(index)
	local parts = {};
	for n = 1, gp.Stance.Count do
		local stanceBar = gp.BarOffset + gp.Stance.Bar + n - 1;
		parts[#parts + 1] = ('[bonusbar:%d] %d'):format(n, ActionBarAPI:GetSlotID(stanceBar, index));
	end
	parts[#parts + 1] = tostring(ActionBarAPI:GetSlotID(ActionBarAPI:GetGamepadPagedBar(), index));
	return table.concat(parts, '; ');
end

local function UpdatePaging(button, barID, index)
	if ( barID == ActionBarAPI:GetGamepadPagedBar() ) then
		RegisterAttributeDriver(button, 'action', GetStanceDriver(index))
	else
		UnregisterAttributeDriver(button, 'action')
		button:SetAttribute('action', ActionBarAPI:GetSlotID(barID, index))
	end
end

local function CreateActionSlotHandler(bar, index)
	local barID  = gp.BarOffset + bar;
	local button = CreateFrame('Button', gp.Widget:format(bar, index), _G[an], 'SecureActionButtonTemplate');
	button:SetAttribute(CPAPI.ActionTypePress, 'action')
	button:RegisterForClicks('AnyDown')
	UpdatePaging(button, barID, index)
	return button;
end

db:RegisterSafeCallback('OnNewBindings', function(_, bindings)
	for _, set in pairs(bindings) do
		for _, binding in pairs(set) do
			local bar, index = binding:match(BINDING_MATCH)
			if bar and index then
				bar, index = tonumber(bar), tonumber(index);
				local slot = ActionBarAPI:GetSlotID(gp.BarOffset + bar, index);
				if not Buttons[slot] then
					Buttons[slot] = CreateActionSlotHandler(bar, index);
				end
			end
		end
	end
end, Buttons)

db:RegisterSafeCallback('Settings/gamepadPagedBar', function()
	for slot, button in pairs(Buttons) do
		UpdatePaging(button, ActionBarAPI:GetFormattedIDs(slot))
	end
	db.Pager:SetAttribute('gamepadpagedfirst', ActionBarAPI:GetSlotID(ActionBarAPI:GetGamepadPagedBar(), 1))
end, Buttons)

---------------------------------------------------------------
do -- Set up the action bar API to use the gamepad slots
---------------------------------------------------------------
	local bindPrefix = CPAPI.BindingPrefix;
	local bindName   = db.Locale('Gamepad Bar %d Button %d');

	for bar = 1, gp.Bars do
		local barID = gp.BarOffset + bar;
		ActionBarAPI.Action[tostring(barID)] = gp.Format:format(bar, 0):gsub('Slot0', 'Slot%%d');
		ActionBarAPI.Widget[tostring(barID)] = gp.Widget:format(bar, 0):gsub('Slot0', 'Slot%%d');
		for index = 1, gp.Width do
			local binding = gp.Format:format(bar, index);
			ActionBarAPI.Binding[binding] = ActionBarAPI:GetSlotID(barID, index);
			_G[bindPrefix:format(binding)] = bindName:format(bar, index);
		end
	end
end
