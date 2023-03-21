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

	Bindings.Proxied = {
		ExtraActionButton = 'EXTRAACTIONBUTTON1';
		InteractTarget    = 'INTERACTTARGET';
		LeftMouseButton   = 'CAMERAORSELECTORMOVE';
		RightMouseButton  = 'TURNORACTION';
		ToggleGameMenu    = 'TOGGLEGAMEMENU';
	};
end

---------------------------------------------------------------
-- Special bindings provider
---------------------------------------------------------------
do local function hold(binding) return ('%s (Hold)'):format(binding) end;
	local EXTRA_ACTION_BUTTON = BINDING_NAME_EXTRAACTIONBUTTON1:gsub('%d', ''):trim()

	Bindings.Special = {
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
		{	binding = Bindings.Proxied.ExtraActionButton;
			name    = EXTRA_ACTION_BUTTON;
			desc    = [[
				The extra action button houses a temporary ability used in
				various quests, scenarios and boss encounters.

				When this binding is unset, the extra action button is always
				available on the utility ring.

				This button appears on your gamepad action bar as a normal
				action button, but you cannot change its content.
			]];
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
-- Handle custom rings
---------------------------------------------------------------
local CUSTOM_RING_DESC = [[
	A ring menu where you can add your items, spells, macros and
	mounts that you do not want to sacrifice action bar space for.

	To use, hold the binding down, tilt your stick in the direction
	of the item you want to select, then release the binding.

	To remove items from the ring, follow the tooltip prompt when you
	have the item in question focused.
]]
local CUSTOM_RING_ICON = [[Interface\AddOns\ConsolePort_Bar\Textures\Icons\Ring]]

---------------------------------------------------------------
-- Get description for custom bindings
---------------------------------------------------------------
function Bindings:GetDescriptionForBinding(binding, useTooltipFormat)
	for i, set in ipairs(self.Special) do
		if (set.binding == binding) then
			local desc = set.desc;
			if desc and useTooltipFormat then
				desc = desc
					:gsub('\t+', '')	-- (1) replace tabs
					:gsub('\n\n', '\t') -- (2) replace double newline with tabs
					:gsub('\n', ' ')	-- (3) replace newline with space
					:gsub('\t', '\n\n') -- (4) replace tab with double newline
			end
			return desc, set.image, set.name, set.texture;
		end
	end

	local customRingName = db.Utility:ConvertBindingToDisplayName(binding)
	if customRingName then
		return CUSTOM_RING_DESC, nil, customRingName, CUSTOM_RING_ICON, customRingName;
	end
end

---------------------------------------------------------------
-- Binding icon management
---------------------------------------------------------------
do local function custom(id) return ([[Interface\AddOns\ConsolePort_Bar\Textures\Icons\%s]]):format(id) end;

	Bindings.CustomIcons = {
		Bags   = custom 'Bags';
		Group  = custom 'Group';
		Jump   = custom 'Jump';
		Map    = custom 'Map';
		Menu   = custom 'Menu';
		Ring   = custom 'Ring';
		Run    = custom 'Run';
		Target = custom 'Target';
	};

	Bindings.DefaultIcons = {
		---------------------------------------------------------------
		JUMP                               = Bindings.CustomIcons.Jump;
		TOGGLERUN                          = Bindings.CustomIcons.Run;
		OPENALLBAGS                        = Bindings.CustomIcons.Bags;
		TOGGLEGAMEMENU                     = Bindings.CustomIcons.Menu;
		TOGGLEWORLDMAP                     = Bindings.CustomIcons.Map;
		---------------------------------------------------------------
		INTERACTTARGET                     = Bindings.CustomIcons.Target;
		---------------------------------------------------------------
		TARGETNEARESTENEMY                 = Bindings.CustomIcons.Target;
		TARGETPREVIOUSENEMY                = Bindings.CustomIcons.Target;
		TARGETSCANENEMY                    = Bindings.CustomIcons.Target;
		TARGETNEARESTFRIEND                = Bindings.CustomIcons.Target;
		TARGETPREVIOUSFRIEND               = Bindings.CustomIcons.Target;
		TARGETNEARESTENEMYPLAYER           = Bindings.CustomIcons.Target;
		TARGETPREVIOUSENEMYPLAYER          = Bindings.CustomIcons.Target;
		TARGETNEARESTFRIENDPLAYER          = Bindings.CustomIcons.Target;
		TARGETPREVIOUSFRIENDPLAYER         = Bindings.CustomIcons.Target;
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
		[Bindings.Custom.EasyMotion]       = Bindings.CustomIcons.Group;
		[Bindings.Custom.RaidCursorToggle] = Bindings.CustomIcons.Group;
		[Bindings.Custom.RaidCursorFocus]  = Bindings.CustomIcons.Group;
		[Bindings.Custom.RaidCursorTarget] = Bindings.CustomIcons.Group;
		[Bindings.Custom.UtilityRing]      = Bindings.CustomIcons.Ring;
		--[Bindings.Custom.FocusButton]    = client 'VAS_RaceChange';
		---------------------------------------------------------------
	};
end

function Bindings:OnDataLoaded()
	self.Icons = CPAPI.Proxy(ConsolePortBindingIcons or {}, self.DefaultIcons)
	db:Save('Bindings/Icons', 'ConsolePortBindingIcons')
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