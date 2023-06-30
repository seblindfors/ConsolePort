local Bindings, _, db = CPAPI.CreateDataHandler(), ...; db:Register('Bindings', Bindings)
local function client(id) return [[Interface\Icons\]]..id end;
---------------------------------------------------------------
-- Binding handler
---------------------------------------------------------------
do local function click(id, btn) return ('CLICK %s%s:%s'):format(_, id, btn or 'LeftButton') end;

	Bindings.Custom = {
		EasyMotion        = click 'EasyMotionButton';
		Page2             = click('Pager', 2);
		Page3             = click('Pager', 3);
		Page4             = click('Pager', 4);
		Page5             = click('Pager', 5);
		Page6             = click('Pager', 6);
		PetRing           = click 'PetRing';
		RaidCursorFocus   = click 'RaidCursorFocus';
		RaidCursorTarget  = click 'RaidCursorTarget';
		RaidCursorToggle  = click 'RaidCursorToggle';
		UICursorToggle    = click 'Cursor';
		UtilityRing       = click 'UtilityToggle';
		--FocusButton     = click 'FocusButton';
	};
end

---------------------------------------------------------------
-- Special bindings provider
---------------------------------------------------------------
do local function hold(binding) return ('%s (Hold)'):format(binding) end;

	Bindings.Special = {
		---------------------------------------------------------------
		-- Targeting
		---------------------------------------------------------------
		{	binding = Bindings.Custom.EasyMotion;
			name    = hold'Target Unit Frames';
			desc    = [[
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
		{	binding = Bindings.Custom.RaidCursorToggle;
			name    = 'Toggle Raid Cursor';
			desc    = [[
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
		{	binding = Bindings.Custom.RaidCursorFocus;
			name    = 'Focus Raid Cursor';
		};
		{	binding = Bindings.Custom.RaidCursorTarget;
			name    = 'Target Raid Cursor';
		};
		--[[{	name    = hold(FOCUS_CAST_KEY_TEXT);
			binding = Bindings.Custom.FocusButton;
		};]]
		---------------------------------------------------------------
		-- Utility
		---------------------------------------------------------------
		{	binding = Bindings.Custom.UICursorToggle;
			name    = 'Toggle Interface Cursor';
		};
		{	binding = Bindings.Custom.UtilityRing;
			name    = 'Utility Ring';
			desc    = [[
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
		{	binding = Bindings.Custom.PetRing;
			name    = 'Pet Ring';
			desc    = [[
				A ring menu that lets you control your current pet.
			]];
			texture = function(self)
				if UnitExists('pet') then
					SetPortraitTexture(self, 'pet')
				else
					self:SetTexture([[Interface\ICONS\INV_Box_PetCarrier_01]])
				end
			end;
		};
		---------------------------------------------------------------
		-- Pager
		---------------------------------------------------------------
		{	binding = Bindings.Custom.Page2;
			name    = hold(BINDING_NAME_ACTIONPAGE2);
		};
		{	binding = Bindings.Custom.Page3;
			name    = hold(BINDING_NAME_ACTIONPAGE3);
		};
		{	binding = Bindings.Custom.Page4;
			name    = hold(BINDING_NAME_ACTIONPAGE4);
		};
		{	binding = Bindings.Custom.Page5;
			name    = hold(BINDING_NAME_ACTIONPAGE5);
		};
		{	binding = Bindings.Custom.Page6;
			name    = hold(BINDING_NAME_ACTIONPAGE6);
		};
	};
end

---------------------------------------------------------------
-- Primary bindings provider
---------------------------------------------------------------
Bindings.Proxied = {
	ExtraActionButton = 'EXTRAACTIONBUTTON1';
	InteractTarget    = 'INTERACTTARGET';
	Jump              = 'JUMP';
	LeftMouseButton   = 'CAMERAORSELECTORMOVE';
	RightMouseButton  = 'TURNORACTION';
	TargetNearest     = 'TARGETNEARESTENEMY';
	TargetPrevious    = 'TARGETPREVIOUSENEMY';
	TargetScan		  = 'TARGETSCANENEMY';
	ToggleAllBags     = 'OPENALLBAGS';
	ToggleAutoRun     = 'TOGGLEAUTORUN';
	ToggleGameMenu    = 'TOGGLEGAMEMENU';
	ToggleWorldMap    = 'TOGGLEWORLDMAP';
};

Bindings.Primary = {
	---------------------------------------------------------------
	-- Mouse
	---------------------------------------------------------------
	{	binding = Bindings.Proxied.LeftMouseButton;
		name    = KEY_BUTTON1;
		desc    = [[
			Used to toggle free cursor, allowing you to use your camera stick as a mouse pointer.

			While one of your buttons is set to emulate left click, this binding cannot be changed.
		]];
		readonly = function() return GetCVar('GamePadCursorLeftClick') ~= 'none' end;
	};
	{	binding = Bindings.Proxied.RightMouseButton;
		name    = KEY_BUTTON2;
		desc    = [[
			Used to toggle center cursor, allowing you to interact with objects and characters
			in the game world, at a center-fixed mouse position.

			While one of your buttons is set to emulate right click, this binding cannot be changed.
		]];
		readonly = function() return GetCVar('GamePadCursorRightClick') ~= 'none' end;
	};
	---------------------------------------------------------------
	-- Targeting
	---------------------------------------------------------------
	{	binding = Bindings.Proxied.InteractTarget;
		desc    = [[
			Allows you to interact with NPCs and objects in the game world.

			Has the same capability as center cursor, but does not require you to
			aim the cursor or crosshair directly on the target.

			Interactables are highlighted when in range.
		]];
	};
	{	binding = Bindings.Proxied.TargetScan;
		desc    = [[
			Scans for enemies in a narrow cone in front of you.
			Hold down to highlight targets before making the decision
			to switch targets.

			Especially useful for quickly switching targets
			while in combat with high precision.

			The target priority is aim biased, meaning that the
			target closest to the center of the cone will be
			selected first. This may result in prioritizing a
			distant target over a closer one, if the distant
			target is closer to the center of the cone.

			Recommended as main targeting binding for most players.
		]];
		image = {
			file  = CPAPI.GetAsset([[Tutorial\TargetScan]]);
			width = 512 * 0.65;
			height = 256 * 0.65;
		};
	};
	{	binding = Bindings.Proxied.TargetNearest;
		desc    = [[
			Switch between the nearest enemy targets in front of you.
			Without a current target, the centermost enemy will be selected.
			Otherwise it will cycle through the nearest targets.

			Hold down to highlight targets before making the decision
			to switch targets.

			Recommended for use as a secondary targeting binding,
			or as main targeting binding in casual gameplay or if
			target scan requires too much precision to be comfortable.

			Not recommended for dungeons or other high precision scenarios.
		]];
		image = {
			file  = CPAPI.GetAsset([[Tutorial\TargetNearest]]);
			width = 512 * 0.65;
			height = 256 * 0.65;
		};
	};
	---------------------------------------------------------------
	-- Movement keys
	---------------------------------------------------------------
	{	binding = Bindings.Proxied.Jump;
		desc    = [[
			Can also be used to swim up while under water, ascend with
			flying mounts, and lift off or flap upward while dragonriding.

			Jump is useful to bridge gaps in movement while doing a left-handed
			action that requires your thumb.

			In a regular setup, the left stick controls your movement.
			If you need to press a directional pad combo while on the move,
			jump can be used to maintain your forward momentum, while briefly
			taking your thumb off the stick.
		]];
	};
	{ 	binding = Bindings.Proxied.ToggleAutoRun;
		desc    = [[
			Autorun will cause your character to continue moving
			in the direction you're facing without any input from you.

			Autorun is useful to alleviate thumb strain from long
			periods of movement, or to free up your thumb to do other
			things while you're on the move.
		]];
	};
	---------------------------------------------------------------
	-- Interface
	---------------------------------------------------------------
	{	binding = Bindings.Proxied.ToggleGameMenu;
		desc    = [[
			The menu binding handles all functionality which occurs by pressing
			the Escape key on a keyboard. It handles different actions based
			on the current state of the game.

			If there are any ongoing actions related to spells or targeting,
			they will be cancelled. Pressing the binding with an active target
			will clear it. Pressing the binding while casting a spell will
			interrupt the spell cast.

			The binding also handles various other cases depending on what
			is currently displayed on the screen. For example, if any panel
			is open, such as the spellbook, the binding will perform the
			necessary action to close or hide it.

			If none of the above cases apply, the game menu will open or
			close when pressed.
		]];
	};
	{	binding = Bindings.Proxied.ToggleAllBags;
		desc    = 'Opens and closes all bags.';
	};
	{	binding = Bindings.Proxied.ToggleWorldMap;
		desc = CPAPI.IsRetailVersion and 'Toggles the combined world map and quest log.' or 'Toggles the world map.';
	};
	---------------------------------------------------------------
	-- Camera
	---------------------------------------------------------------
	{	binding = 'CAMERAZOOMIN';
		desc    = 'Zooms the camera in. Hold for continuous zoom.';
	};
	{	binding = 'CAMERAZOOMOUT';
		desc    = 'Zooms the camera out. Hold for continuous zoom.';
	};
	---------------------------------------------------------------
	-- Misc
	---------------------------------------------------------------
	{	binding = Bindings.Proxied.ExtraActionButton;
		name    = BINDING_NAME_EXTRAACTIONBUTTON1:gsub('%d', ''):trim();
		desc    = [[
			The extra action button houses a temporary ability used in
			various quests, scenarios and boss encounters.

			When this binding is unset, the extra action button is always
			available on the utility ring.

			This button appears on your gamepad action bar as a normal
			action button, but you cannot change its content.
		]];
	};
};

for i, set in ipairs(Bindings.Primary) do
	set.name = set.name or GetBindingName(set.binding)
end

---------------------------------------------------------------
-- Get description for custom bindings
---------------------------------------------------------------
do -- Handle custom rings
	local CUSTOM_RING_DESC = [[
		A ring menu where you can add your items, spells, macros and
		mounts that you do not want to sacrifice action bar space for.

		To use, hold the binding down, tilt your stick in the direction
		of the item you want to select, then release the binding.

		To remove items from the ring, follow the tooltip prompt when you
		have the item in question focused.
	]]
	local CUSTOM_RING_ICON = [[Interface\AddOns\ConsolePort_Bar\Textures\Icons\Ring]]

	local function FindBindingInCollection(binding, collection)
		for i, set in ipairs(collection) do
			if (set.binding == binding) then
				return set;
			end
		end
	end

	function Bindings:GetCustomBindingInfo(binding)
		return FindBindingInCollection(binding, self.Special)
			or FindBindingInCollection(binding, self.Primary)
	end

	function Bindings:GetDescriptionForBinding(binding, useTooltipFormat)
		local set = self:GetCustomBindingInfo(binding)

		if set then
			local desc = set.desc;
			if desc and useTooltipFormat then
				desc = CPAPI.FormatLongText(desc)
			end
			return desc, set.image, set.name, set.texture;
		end

		local customRingName = db.Utility:ConvertBindingToDisplayName(binding)
		if customRingName then
			return CUSTOM_RING_DESC, nil, customRingName, self:GetIcon(binding) or CUSTOM_RING_ICON, customRingName;
		end
	end
end

---------------------------------------------------------------
-- Binding icon management
---------------------------------------------------------------
do local function custom(id) return ([[Interface\AddOns\ConsolePort_Bar\Textures\Icons\%s]]):format(id) end;

	local CustomIcons = {
		Bags   = custom 'Bags';
		Group  = custom 'Group';
		Jump   = custom 'Jump';
		Map    = custom 'Map';
		Menu   = custom 'Menu';
		Ring   = custom 'Ring';
		Run    = custom 'Run';
		Target = custom 'Target';
	}; Bindings.CustomIcons = CustomIcons;

	Bindings.DefaultIcons = {
		---------------------------------------------------------------
		JUMP                               = CustomIcons.Jump;
		TOGGLERUN                          = CustomIcons.Run;
		OPENALLBAGS                        = CustomIcons.Bags;
		TOGGLEGAMEMENU                     = CustomIcons.Menu;
		TOGGLEWORLDMAP                     = CustomIcons.Map;
		---------------------------------------------------------------
		INTERACTTARGET                     = CustomIcons.Target;
		---------------------------------------------------------------
		TARGETNEARESTENEMY                 = CustomIcons.Target;
		TARGETPREVIOUSENEMY                = CustomIcons.Target;
		TARGETSCANENEMY                    = CustomIcons.Target;
		TARGETNEARESTFRIEND                = CustomIcons.Target;
		TARGETPREVIOUSFRIEND               = CustomIcons.Target;
		TARGETNEARESTENEMYPLAYER           = CustomIcons.Target;
		TARGETPREVIOUSENEMYPLAYER          = CustomIcons.Target;
		TARGETNEARESTFRIENDPLAYER          = CustomIcons.Target;
		TARGETPREVIOUSFRIENDPLAYER         = CustomIcons.Target;
		---------------------------------------------------------------
		TARGETPARTYMEMBER1                 = CPAPI.IsRetailVersion and client 'Achievement_PVP_A_01';
		TARGETPARTYMEMBER2                 = CPAPI.IsRetailVersion and client 'Achievement_PVP_A_02';
		TARGETPARTYMEMBER3                 = CPAPI.IsRetailVersion and client 'Achievement_PVP_A_03';
		TARGETPARTYMEMBER4                 = CPAPI.IsRetailVersion and client 'Achievement_PVP_A_04';
		TARGETSELF                         = CPAPI.IsRetailVersion and client 'Achievement_PVP_A_05';
		TARGETPET                          = client 'Spell_Hunter_AspectOfTheHawk';
		---------------------------------------------------------------
		ATTACKTARGET                       = client 'Ability_SteelMelee';
		STARTATTACK                        = client 'Ability_SteelMelee';
		PETATTACK                          = client 'ABILITY_HUNTER_INVIGERATION';
		FOCUSTARGET                        = client 'Ability_Hunter_MasterMarksman';
		---------------------------------------------------------------
		[Bindings.Custom.EasyMotion]       = CustomIcons.Group;
		[Bindings.Custom.RaidCursorToggle] = CustomIcons.Group;
		[Bindings.Custom.RaidCursorFocus]  = CustomIcons.Group;
		[Bindings.Custom.RaidCursorTarget] = CustomIcons.Group;
		[Bindings.Custom.UtilityRing]      = CustomIcons.Ring;
		--[Bindings.Custom.FocusButton]    = client 'VAS_RaceChange';
		---------------------------------------------------------------
	};
end

function Bindings:OnDataLoaded()
	self.Icons = CPAPI.Proxy(ConsolePortBindingIcons or {}, self.DefaultIcons)
	db:Save('Bindings/Icons', 'ConsolePortBindingIcons')
end

function Bindings:GetIcon(bindingID)
	return self.Icons[bindingID];
end

function Bindings:SetIcon(bindingID, icon)
	self.Icons[bindingID] = icon;
	db:TriggerEvent('OnBindingIconChanged', bindingID, self.Icons[bindingID])
end

function Bindings:GetIconProvider()
	if not self.IconProvider then
		self.IconProvider = self:RefreshIconDataProvider()
	end
	return self.IconProvider;
end

function Bindings:ReleaseIconProvider()
	if self.IconProvider then
		self.IconProvider = nil;
		collectgarbage()
	end
end

---------------------------------------------------------------
do -- Icon provider (see FrameXML\IconDataProvider.lua)
---------------------------------------------------------------
	local QuestionMarkIconFileDataID = 134400;

	local function FillOutExtraIconsMapWithSpells(extraIconsMap)
		for i = 1, GetNumSpellTabs() do
			local tab, tabTex, offset, numSpells = GetSpellTabInfo(i);
			offset = offset + 1;
			local tabEnd = offset + numSpells;
			for j = offset, tabEnd - 1 do
				local spellType, ID = GetSpellBookItemInfo(j, 'player');
				if spellType ~= 'FUTURESPELL' then
					local fileID = GetSpellBookItemTexture(j, 'player');
					if fileID ~= nil then
						extraIconsMap[fileID] = true;
					end
				end

				if spellType == 'FLYOUT' then
					local _, _, numSlots, isKnown = GetFlyoutInfo(ID);
					if isKnown and (numSlots > 0) then
						for k = 1, numSlots do
							local spellID, overrideSpellID, isSlotKnown = GetFlyoutSlotInfo(ID, k)
							if isSlotKnown then
								local fileID = GetSpellTexture(spellID);
								if fileID ~= nil then
									extraIconsMap[fileID] = true;
								end
							end
						end
					end
				end
			end
		end
	end

	local function FillOutExtraIconsMapWithTalents(extraIconsMap)
		local isInspect = false;
		for specIndex = 1, GetNumSpecGroups(isInspect) do
			for tier = 1, MAX_TALENT_TIERS do
				for column = 1, NUM_TALENT_COLUMNS do
					local icon = select(3, GetTalentInfo(tier, column, specIndex));
					if icon ~= nil then
						extraIconsMap[icon] = true;
					end
				end
			end
		end

		for pvpTalentSlot = 1, 3 do
			local slotInfo = C_SpecializationInfo.GetPvpTalentSlotInfo(pvpTalentSlot);
			if slotInfo ~= nil then
				for i, pvpTalentID in ipairs(slotInfo.availableTalentIDs) do
					local icon = select(3, GetPvpTalentInfoByID(pvpTalentID));
					if icon ~= nil then
						extraIconsMap[icon] = true;
					end
				end
			end
		end
	end

	local function FillOutExtraIconsMapWithEquipment(extraIconsMap)
		for i = INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED do
			local itemTexture = GetInventoryItemTexture('player', i)
			if itemTexture ~= nil then
				extraIconsMap[itemTexture] = true;
			end
		end
	end

	local function FillOutExtraIconsWithCustomIcons(extraIcons)
		for _, customTexture in db.table.spairs(Bindings.CustomIcons) do
			tinsert(extraIcons, customTexture)
		end
	end

	function Bindings:RefreshIconDataProvider()
		local extraIconsMap = {};
		pcall(FillOutExtraIconsMapWithSpells, extraIconsMap)
		pcall(FillOutExtraIconsMapWithTalents, extraIconsMap)
		pcall(FillOutExtraIconsMapWithEquipment, extraIconsMap)

		local extraIcons = GetKeysArray(extraIconsMap)
		pcall(FillOutExtraIconsWithCustomIcons, extraIcons)

		local provider = {QuestionMarkIconFileDataID, unpack(extraIcons)};
		pcall(GetLooseMacroIcons, provider)
		pcall(GetLooseMacroItemIcons, provider)
		pcall(GetMacroIcons, provider)
		pcall(GetMacroItemIcons, provider)

		local customIconsRef = tInvert(Bindings.CustomIcons)
		for i, iconID in ipairs(provider) do
			if not tonumber(iconID) and not customIconsRef[iconID] then
				provider[i] = client(iconID)
			end
		end

		return provider;
	end
end