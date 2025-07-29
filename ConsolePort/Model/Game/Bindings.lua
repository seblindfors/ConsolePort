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
		UnitMenuPlayer    = click ('Unit', 'player');
		UnitMenuTarget    = click ('Unit', 'target');
		CustomRing        = click ('UtilityToggle', '(.*)');
		--FocusButton     = click 'FocusButton';
	};

	Bindings.Macroable = { -- enumID, inheritDesc
		MenuRing          = true;
		RaidCursorFocus   = true;
		RaidCursorTarget  = true;
		RaidCursorToggle  = true;
		UICursorToggle    = true;
		UnitMenu          = true;
		UnitMenuPlayer    = true;
		UnitMenuTarget    = true;
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
			name    = ('%s: %s'):format(PLAYER_OPTIONS_LABEL, DYNAMIC);
			unit    = function() return db.UnitMenuSecure:GetPreferredUnit() end;
			texture = [[Interface\TARGETINGFRAME\targetdead]];
		};
		{	binding = Bindings.Custom.UnitMenuPlayer;
			name    = ('%s: %s'):format(PLAYER_OPTIONS_LABEL, PLAYER);
			unit    = function() return 'player' end;
			texture = [[Interface\TARGETINGFRAME\targetdead]];
		};
		{	binding = Bindings.Custom.UnitMenuTarget;
			name    = ('%s: %s'):format(PLAYER_OPTIONS_LABEL, TARGET);
			unit    = function() return 'target' end;
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
	LeftMouseButton   = db.Gamepad.Mouse.Binding.LeftClick;
	RightMouseButton  = db.Gamepad.Mouse.Binding.RightClick;
	ExtraActionButton = 'EXTRAACTIONBUTTON1';
	InteractTarget    = 'INTERACTTARGET';
	Jump              = 'JUMP';
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
		readonly = function()
			if GetCVar('GamePadCursorLeftClick') ~= 'none' then
				return L.DISC_KEY_BUTTON1;
			end
		end;
	};
	{	binding = Bindings.Proxied.RightMouseButton;
		name    = KEY_BUTTON2;
		desc    = L.DESC_KEY_BUTTON2;
		readonly = function()
			if GetCVar('GamePadCursorRightClick') ~= 'none' then
				return L.DISC_KEY_BUTTON2;
			end
		end;
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
		desc    = L.DESC_CAMERAZOOMOUT;
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
	local CUSTOM_RING_ICON = [[Interface\AddOns\ConsolePort_Bar\Assets\Textures\Icons\Ring.png]];

	function Bindings:ConvertRingBindingToDisplayName(binding)
		if ( type(binding) == 'string' ) then
			local name = binding:gsub(self.Custom.CustomRing, '%1')
			return ( name ~= binding ) and
				((tonumber(name) and L.FORMAT_RING_NUMERICAL:format(name) or name)) or nil;
		end
	end

	function Bindings:ConvertRingSetIDToDisplayName(setID)
		return (tonumber(setID) == CPAPI.DefaultRingSetID and L.NAME_RING_UTILITY)
			or (tonumber(setID) and L.FORMAT_RING_NUMERICAL:format(setID))
			or (tostring(setID));
	end

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

	function Bindings:IsReadOnlyBinding(binding)
		local set = self:GetCustomBindingInfo(binding)
		if set and set.readonly then
			return set.readonly()
		end
		return false;
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
				texture = function(self)
					local getUnit = type(unit) == 'function' and unit or CPAPI.Static(unit);
					local timer   = C_Timer.NewTicker(0.25, function()
						local unitID = getUnit()
						if UnitExists(unitID) then
							return SetPortraitTexture(self, unitID)
						end
						CPAPI.Index(self).SetTexture(self, default)
					end)
					timer:Invoke()
					return function()
						timer:Cancel()
					end;
				end;
				set.texture = texture;
			end
			return desc, image, set.name, texture or self:GetIcon(binding);
		end

		local customRingName = self:ConvertRingBindingToDisplayName(binding)
		if customRingName then
			local desc = useTooltipFormat and CPAPI.FormatLongText(L.DESC_RING_CUSTOM, tooltipLineLength) or L.DESC_RING_CUSTOM;
			return desc, nil, customRingName, self:GetIcon(binding) or CUSTOM_RING_ICON, customRingName;
		end
	end
end

---------------------------------------------------------------
-- Binding icon management
---------------------------------------------------------------
do local function custom(id) return ([[Interface\AddOns\ConsolePort_Bar\Assets\Textures\Icons\%s]]):format(id) end;

	local CustomIcons = {
		Bags      = custom 'Bags.png';
		Chat      = custom 'Chat.blp';
		Group     = custom 'Group.png';
		Jump      = custom 'Jump.png';
		Map       = custom 'Map.png';
		MBLeft    = custom 'LMB.blp';
		MBRight   = custom 'RMB.blp';
		Menu      = custom 'Menu.png';
		Ring      = custom 'Ring.png';
		Run       = custom 'Run.png';
		Target    = custom 'Target';
		TNEnemy   = custom 'Target_Narrow_Enemy.png';
		TNFriend  = custom 'Target_Narrow_Friend.png';
		TWEnemy   = custom 'Target_Wide_Enemy.png';
		TWFriend  = custom 'Target_Wide_Friend.png';
		TWNeutral = custom 'Target_Wide_Neutral.png';
		ZoomIn    = custom 'ZoomIn.blp';
		ZoomOut   = custom 'ZoomOut.blp';
		SHIFT     = custom 'M1.blp';
		CTRL      = custom 'M2.blp';
		ALT       = custom 'M3.blp';
	}; Bindings.CustomIcons = CustomIcons;

	Bindings.DefaultIcons = {
		---------------------------------------------------------------
		CAMERAORSELECTORMOVE               = CustomIcons.MBLeft;
		TURNORACTION                       = CustomIcons.MBRight;
		---------------------------------------------------------------
		CAMERAZOOMIN                       = CustomIcons.ZoomIn;
		CAMERAZOOMOUT                      = CustomIcons.ZoomOut;
		MINIMAPZOOMIN                      = CustomIcons.ZoomIn;
		MINIMAPZOOMOUT                     = CustomIcons.ZoomOut;
		OPENCHAT                           = CustomIcons.Chat;
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
		TOGGLECHARACTER0                   = client 'Ability_Warrior_DefensiveStance';
		TOGGLETALENTS                      = client 'INV_Misc_Book_07';
		TOGGLESPELLBOOK                    = [[Interface\SPELLBOOK\Spellbook-Icon]];
		---------------------------------------------------------------
		[Bindings.Custom.EasyMotion]       = CustomIcons.Group;
		[Bindings.Custom.RaidCursorToggle] = CustomIcons.Group;
		[Bindings.Custom.RaidCursorFocus]  = CustomIcons.Group;
		[Bindings.Custom.RaidCursorTarget] = CustomIcons.Group;
		[Bindings.Custom.UtilityRing]      = CustomIcons.Ring;
		[Bindings.Custom.MenuRing]         = CustomIcons.Menu;
		[Bindings.Custom.UICursorToggle]   = CustomIcons.Menu;
		--[Bindings.Custom.FocusButton]    = client 'VAS_RaceChange';
		---------------------------------------------------------------
	};
end

function Bindings:OnDataLoaded()
	self.Icons = CPAPI.Proxy(ConsolePortBindingIcons or {}, self.DefaultIcons)
	db:Save('Bindings/Icons', 'ConsolePortBindingIcons')
	return CPAPI.BurnAfterReading;
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
		self.IconProvider = self:CreateIconDataProvider()
	end
	return self.IconProvider;
end

function Bindings:ReleaseIconProvider()
	if self.IconProvider then
		self.IconProvider:Release();
		self.IconProvider = nil;
		collectgarbage()
	end
end

---------------------------------------------------------------
do -- Icon provider (see FrameXML\IconDataProvider.lua)
---------------------------------------------------------------
	local IconDataProvider = CreateFromMixins(IconDataProviderMixin);

	local function FillOutExtraIconsWithCustomIcons(extraIcons)
		for _, customTexture in db.table.spairs(Bindings.CustomIcons) do
			tinsert(extraIcons, customTexture)
		end
		return extraIcons;
	end

	function IconDataProvider:Init(type, extraIconsOnly, requestedIconTypes)
		type = type or IconDataProviderExtraType.None;

		local extraSpells = {}; IconDataProviderMixin.Init(extraSpells, IconDataProviderExtraType.Spellbook, true, true)
		local extraItems  = {}; IconDataProviderMixin.Init(extraItems,  IconDataProviderExtraType.Equipment, true, true)
		local extraAll    = FillOutExtraIconsWithCustomIcons({});
		tAppendAll(extraAll, extraSpells.extraIcons)
		tAppendAll(extraAll, extraItems.extraIcons)

		self.extraIconsExt = {
			[IconDataProviderIconType.Spell] = extraSpells.extraIcons;
			[IconDataProviderIconType.Item]  = extraItems.extraIcons;
			[IconDataProviderIconType.Spell + IconDataProviderIconType.Item] = extraAll;
		};

		IconDataProviderMixin.Init(self, type, extraIconsOnly, requestedIconTypes)
		self:SetIconTypes(self.requestedIconTypes)
	end

	function IconDataProvider:ShouldShowExtraIcons()
		return self.extraIconType == IconDataProviderExtraType.None
			or IconDataProviderMixin.ShouldShowExtraIcons(self)
	end

	function IconDataProvider:SetIconTypes(iconTypes)
		IconDataProviderMixin.SetIconTypes(self, iconTypes)
		self.extraIcons = self.extraIconsExt[Accumulate(self.requestedIconTypes)]
	end

	function IconDataProvider:SetSearchQuery(query)
		self.searchQuery = query and tostring(query):lower() or nil;
		self.searchCache = {};
	end

	function IconDataProvider:GetNumIcons()
		local numIcons = IconDataProviderMixin.GetNumIcons(self)
		if not self.searchQuery then
			return numIcons;
		end
		return #self:GetSearchCache(numIcons);
	end

	function IconDataProvider:GetSearchCache(numIcons)
		if not next(self.searchCache) then
			for i = 1, numIcons do
				local icon = tostring(IconDataProviderMixin.GetIconByIndex(self, i))
				if icon:lower():find(self.searchQuery, 1, true) then
					tinsert(self.searchCache, icon)
				end
			end
		end
		return self.searchCache;
	end

	function IconDataProvider:GetIconByIndex(index)
		if self.searchQuery then
			return self:GetSearchCache(self:GetNumIcons())[index];
		end
		return IconDataProviderMixin.GetIconByIndex(self, index);
	end

	function Bindings:CreateIconDataProvider(...)
		return CreateAndInitFromMixin(IconDataProvider, ...);
	end
end