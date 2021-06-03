local function hold(binding) return ('%s (Hold)'):format(binding) end;
local extra = BINDING_NAME_EXTRAACTIONBUTTON1:gsub('%d', ''):trim()
local Bindings = {};
select(2, ...):Register('Bindings', setmetatable({
	-------------
	-- Mouse
	-------------
	{	name = KEY_BUTTON1;
		binding = 'CAMERAORSELECTORMOVE';
		readonly = function() return GetCVar('GamePadCursorLeftClick') ~= 'none' end;
		desc = [[
			Used to toggle free cursor, allowing you to use your camera stick as a mouse pointer.

			While one of your buttons is set to emulate left click, this binding cannot be changed.
		]];
	};
	{	name = KEY_BUTTON2;
		binding = 'TURNORACTION';
		readonly = function() return GetCVar('GamePadCursorRightClick') ~= 'none' end;
		desc = [[
			Used to toggle center cursor, allowing you to interact with objects and characters
			in the game world, at a center-fixed mouse position.

			While one of your buttons is set to emulate right click, this binding cannot be changed.
		]];
	};
	-------------
	-- Targeting
	-------------
	{	name    = hold'Target Unit Frames';
		binding = 'CLICK ConsolePortEasyMotionButton:LeftButton';
		desc = [[
			Generates unit hotkeys for your on-screen unit frames,
			allowing you to swap between friendly targets quickly.

			To use, hold the binding down, then tap the prompted
			keys you see on your target of choice, then release 
			the binding to change your target.

			This binding is highly recommended for healers in 5-man
			game content, as it provides an extremely fast method of
			targeting in smaller groups.

			In raids, the complexity of necessary input
			to single out your preferred target can be daunting.
			See Toggle Raid Cursor for a different choice.
		]];
		image = {
			file  = CPAPI.GetAsset([[Tutorial\UnitHotkey]]);
			width = 256;
			height = 256;
		};
	};
	{	name    = 'Toggle Raid Cursor';
		binding = 'CLICK ConsolePortRaidCursorToggle:LeftButton';
		desc = [[
			Toggles a cursor that clamps to your on-screen
			unit frames, allowing you to heal friendly players
			while maintaining another target.

			The raid cursor can also be set to target directly,
			where moving the cursor will swap your current target.

			While in use, the raid cursor occupies one set of
			directional pad combinations to control the cursor position.

			When in routing mode, the cursor does not re-route macros or 
			ambiguous spells, such as a priest's Penance.

			See Target Unit Frames for a different choice.
		]];
		image = {
			file  = CPAPI.GetAsset([[Tutorial\RaidCursor]]);
			width = 256;
			height = 256;
		};
	};
	{	name    = 'Focus Raid Cursor';
		binding = 'CLICK ConsolePortRaidCursorFocus:LeftButton';
	};
	{	name    = 'Target Raid Cursor';
		binding = 'CLICK ConsolePortRaidCursorTarget:LeftButton';
	};
	{	name    = hold(FOCUS_CAST_KEY_TEXT);
		binding = 'CLICK ConsolePortFocusButton:LeftButton';
	};
	-------------
	-- Utility
	-------------
	{	name = 'Toggle Interface Cursor';
		binding = 'CLICK ConsolePortCursor:LeftButton';
	};
	{	name = 'Utility Ring';
		binding = 'CLICK ConsolePortUtilityToggle:LeftButton';
		desc = [[
			A ring menu where you can add your items, spells, macros and
			mounts that you do not want to sacrifice action bar space for.

			To use, hold the binding down, tilt your stick in the direction
			of the item you want to select, then release the binding.

			To add items to the ring, follow the prompt from the interface
			cursor, or alternatively, pick something up on your mouse cursor,
			and press the binding to drop it in the ring.

			To remove items from the ring, follow the tooltip prompt when you
			have the item in question focused.

			The utility ring automatically adds quest items and temporary
			abilities that you have not placed on your action bar.
		]];
	};
	{	name = 'Pet Ring';
		binding = 'CLICK ConsolePortPetRing:LeftButton';
		texture = function(self)
			if UnitExists('pet') then
				SetPortraitTexture(self, 'pet')
			else
				self:SetTexture([[Interface\ICONS\INV_Box_PetCarrier_01]])
			end
		end;
		desc = [[
			A ring menu that lets you control your current pet.
		]];
	};
	{	name    = extra;
		binding = 'EXTRAACTIONBUTTON1';
		desc = [[
			The extra action button houses a temporary ability used in
			various quests, scenarios and boss encounters.

			When this binding is unset, the extra action button is always
			available on the utility ring.

			This button appears on your gamepad action bar as a normal
			action button, but you cannot change its content.
		]];
	};
	-------------
	-- Pager
	-------------
	{	name    = hold(BINDING_NAME_ACTIONPAGE2);
		binding = 'CLICK ConsolePortPager:2';
	};
	{	name    = hold(BINDING_NAME_ACTIONPAGE3);
		binding = 'CLICK ConsolePortPager:3';
	};
	{	name    = hold(BINDING_NAME_ACTIONPAGE4);
		binding = 'CLICK ConsolePortPager:4';
	};
	{	name    = hold(BINDING_NAME_ACTIONPAGE5);
		binding = 'CLICK ConsolePortPager:5';
	};
	{	name    = hold(BINDING_NAME_ACTIONPAGE6);
		binding = 'CLICK ConsolePortPager:6';
	};
}, {
	__index = Bindings;
}))

function Bindings:GetDescriptionForBinding(binding)
	for i, set in ipairs(self) do
		if (set.binding == binding) then
			return set.desc, set.image, set.name, set.texture;
		end
	end
end