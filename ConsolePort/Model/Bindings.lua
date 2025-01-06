local Bindings, _, db, L = CPAPI.CreateDataHandler(), ...; L = db.Locale; db:Register('Bindings', Bindings)
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
		MenuRing          = click 'MenuTrigger';
		UnitMenu          = click 'Unit';
		--FocusButton     = click 'FocusButton';
	};
end

---------------------------------------------------------------
-- Special bindings provider
---------------------------------------------------------------
do local function hold(binding) return L.FORMAT_HOLD_BINDING:format(binding) end;

	Bindings.Special = {
		---------------------------------------------------------------
		-- Targeting
		---------------------------------------------------------------
		{	binding = Bindings.Custom.EasyMotion;
			name    = L.NAME_EASY_MOTION;
			desc    = L.DESC_EASY_MOTION;
			image = {
				file  = CPAPI.GetAsset([[Tutorial\UnitHotkey]]);
				width = 256;
				height = 256;
			};
		};
		{	binding = Bindings.Custom.RaidCursorToggle;
			name    = L.NAME_RAID_CURSOR_TOGGLE;
			desc    = L.DESC_RAID_CURSOR;
			image = {
				file  = CPAPI.GetAsset([[Tutorial\RaidCursor]]);
				width = 256;
				height = 256;
			};
		};
		{	binding = Bindings.Custom.RaidCursorFocus;
			name    = L.NAME_RAID_CURSOR_FOCUS;
		};
		{	binding = Bindings.Custom.RaidCursorTarget;
			name    = L.NAME_RAID_CURSOR_TARGET;
		};
		{	binding = Bindings.Custom.UnitMenu;
			name    = PLAYER_OPTIONS_LABEL;
			unit    = function() return db.UnitMenuSecure:GetPreferredUnit() end;
			texture = [[Interface\TARGETINGFRAME\targetdead]];
		};
		--[[{	name    = hold(FOCUS_CAST_KEY_TEXT);
			binding = Bindings.Custom.FocusButton;
		};]]
		---------------------------------------------------------------
		-- Utility
		---------------------------------------------------------------
		{	binding = Bindings.Custom.UICursorToggle;
			name    = L.NAME_UI_CURSOR_TOGGLE;
		};
		{	binding = Bindings.Custom.UtilityRing;
			name    = L.NAME_RING_UTILITY;
			desc    = L.DESC_RING_UTILITY;
		};
		{	binding = Bindings.Custom.PetRing;
			name    = L.NAME_RING_PET;
			unit    = 'pet';
			desc    = L.DESC_RING_PET;
			texture = [[Interface\ICONS\INV_Box_PetCarrier_01]];
		};
		{	binding = Bindings.Custom.MenuRing;
			name    = L.NAME_RING_MENU;
			desc    = L.DESC_RING_MENU;
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
		desc    = L.DESC_KEY_BUTTON1;
		readonly = function() return GetCVar('GamePadCursorLeftClick') ~= 'none' end;
	};
	{	binding = Bindings.Proxied.RightMouseButton;
		name    = KEY_BUTTON2;
		desc    = L.DESC_KEY_BUTTON2;
		readonly = function() return GetCVar('GamePadCursorRightClick') ~= 'none' end;
	};
	---------------------------------------------------------------
	-- Targeting
	---------------------------------------------------------------
	{	binding = Bindings.Proxied.InteractTarget;
		desc    = L.DESC_INTERACTTARGET;
	};
	{	binding = Bindings.Proxied.TargetScan;
		desc    = L.DESC_TARGETSCANENEMY;
		image = {
			file  = CPAPI.GetAsset([[Tutorial\TargetScan]]);
			width = 512 * 0.65;
			height = 256 * 0.65;
		};
	};
	{	binding = Bindings.Proxied.TargetNearest;
		desc    = L.DESC_TARGETNEARESTENEMY;
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
		desc    = L.DESC_JUMP;
	};
	{ 	binding = Bindings.Proxied.ToggleAutoRun;
		desc    = L.DESC_TOGGLEAUTORUN;
	};
	---------------------------------------------------------------
	-- Interface
	---------------------------------------------------------------
	{	binding = Bindings.Proxied.ToggleGameMenu;
		desc    = L.DESC_TOGGLEGAMEMENU;
	};
	{	binding = Bindings.Proxied.ToggleAllBags;
		desc    = L.DESC_OPENALLBAGS;
	};
	{	binding = Bindings.Proxied.ToggleWorldMap;
		desc = CPAPI.IsRetailVersion and L.DESC_TOGGLEWORLDMAP_RETAIL or L.DESC_TOGGLEWORLDMAP_CLASSIC;
	};
	---------------------------------------------------------------
	-- Camera
	---------------------------------------------------------------
	{	binding = 'CAMERAZOOMIN';
		desc    = L.DESC_CAMERAZOOMIN;
	};
	{	binding = 'CAMERAZOOMOUT';
		desc    = DESC_CAMERAZOOMOUT;
	};
	---------------------------------------------------------------
	-- Misc
	---------------------------------------------------------------
	{	binding = Bindings.Proxied.ExtraActionButton;
		name    = BINDING_NAME_EXTRAACTIONBUTTON1:gsub('%d', ''):trim();
		desc    = L.DESC_EXTRAACTIONBUTTON1;
	};
};

for i, set in ipairs(Bindings.Primary) do
	set.name = set.name or GetBindingName(set.binding)
end

Bindings.Dynamic = {
	{	binding = 'TARGETSELF';
		unit    = 'player';
	};
};
for i=1, (MAX_PARTY_MEMBERS or 4) do tinsert(Bindings.Dynamic,
	{	binding = 'TARGETPARTYMEMBER'..i;
		unit    = 'party'..i;
		texture = client('Achievement_PVP_A_0'..i);
	}
) end;

for _, set in ipairs(Bindings.Dynamic) do
	set.name = set.name or GetBindingName(set.binding)
end

---------------------------------------------------------------
-- Get description for custom bindings
---------------------------------------------------------------
do -- Handle custom rings
	local CUSTOM_RING_ICON = [[Interface\AddOns\ConsolePort_Bar\Assets\Textures\Icons\Ring]]

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
			or FindBindingInCollection(binding, self.Dynamic)
	end

	function Bindings:GetDescriptionForBinding(binding, useTooltipFormat, tooltipLineLength)
		local set = self:GetCustomBindingInfo(binding)

		if set then
			local desc, image, texture, unit = set.desc, set.image, set.texture, set.unit;
			if ( desc and useTooltipFormat ) then
				desc = CPAPI.FormatLongText(desc, tooltipLineLength)
			end
			if ( image and useTooltipFormat ) then
				image = CPAPI.CreateSimpleTextureMarkup(image.file, image.width, image.height)
			end
			if ( unit and type(texture) ~= 'function' ) then
				local default = texture;
				local get = type(unit) == 'function' and unit or function() return unit end;
				texture = function(self)
					local unitID = get()
					if UnitExists(unitID) then
						return SetPortraitTexture(self, unitID)
					end
					self:SetTexture(default)
				end;
				set.texture = texture;
			end
			return desc, image, set.name, texture;
		end

		local customRingName = db.Utility:ConvertBindingToDisplayName(binding)
		if customRingName then
			return L.DESC_RING_CUSTOM, nil, customRingName, self:GetIcon(binding) or CUSTOM_RING_ICON, customRingName;
		end
	end
end

---------------------------------------------------------------
-- Binding icon management
---------------------------------------------------------------
do local function custom(id) return ([[Interface\AddOns\ConsolePort_Bar\Assets\Textures\Icons\%s]]):format(id) end;

	local CustomIcons = {
		Bags      = custom 'Bags.png';
		Group     = custom 'Group.png';
		Jump      = custom 'Jump.png';
		Map       = custom 'Map.png';
		Menu      = custom 'Menu.png';
		Ring      = custom 'Ring.png';
		Run       = custom 'Run.png';
		Target    = custom 'Target';
		TNEnemy   = custom 'Target_Narrow_Enemy.png';
		TNFriend  = custom 'Target_Narrow_Friend.png';
		TWEnemy   = custom 'Target_Wide_Enemy.png';
		TWFriend  = custom 'Target_Wide_Friend.png';
		TWNeutral = custom 'Target_Wide_Neutral.png';
	}; Bindings.CustomIcons = CustomIcons;

	Bindings.DefaultIcons = {
		---------------------------------------------------------------
		JUMP                               = CustomIcons.Jump;
		TOGGLERUN                          = CustomIcons.Run;
		OPENALLBAGS                        = CustomIcons.Bags;
		TOGGLEGAMEMENU                     = CustomIcons.Menu;
		TOGGLEWORLDMAP                     = CustomIcons.Map;
		---------------------------------------------------------------
		INTERACTTARGET                     = CustomIcons.TWNeutral;
		---------------------------------------------------------------
		TARGETNEARESTENEMY                 = CustomIcons.TWEnemy;
		TARGETPREVIOUSENEMY                = CustomIcons.TWEnemy;
		TARGETSCANENEMY                    = CustomIcons.TNEnemy;
		TARGETNEARESTFRIEND                = CustomIcons.TWFriend;
		TARGETPREVIOUSFRIEND               = CustomIcons.TWFriend;
		TARGETNEARESTENEMYPLAYER           = CustomIcons.TNEnemy;
		TARGETPREVIOUSENEMYPLAYER          = CustomIcons.TNEnemy;
		TARGETNEARESTFRIENDPLAYER          = CustomIcons.TNFriend;
		TARGETPREVIOUSFRIENDPLAYER         = CustomIcons.TNFriend;
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
		[Bindings.Custom.MenuRing]         = CustomIcons.Menu;
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