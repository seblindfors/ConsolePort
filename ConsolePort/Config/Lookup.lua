---------------------------------------------------------------
-- Lookup.lua: Lookup tables for all intents and purposes
---------------------------------------------------------------
-- Tables/functions in this file are used to get information
-- used when generating settings and game state data.

local addOn, db = ...
---------------------------------------------------------------
local tonumber, ipairs, pairs = tonumber, ipairs, pairs
local spairs, copy = db.table.spairs, db.table.copy
---------------------------------------------------------------
local Controller
---------------------------------------------------------------
function ConsolePort:LoadLookup()
    Controller = db.Controllers[db('type')]
    self.LoadLookup = nil
end
---------------------------------------------------------------
-- Plug-in access to addon table
---------------------------------------------------------------
function ConsolePort:GetData(...) 
    if select('#', ...) > 0 then
        return db(...)
    end
    return db
end

---------------------------------------------------------------
-- Integer keys for UI operations
---------------------------------------------------------------
local KEY, KEY_INV, KEY_TO_BIND, BIND_TO_KEY
---------------------------------------------------------------
db.KEY = {
    CROSS    = 1,
    TRIANGLE = 2,
    CIRCLE   = 3,
    SQUARE   = 4,
    UP       = 5,
    DOWN     = 6,
    LEFT     = 7,
    RIGHT    = 8,
    SHARE    = 9,
    OPTIONS  = 10,
    CENTER   = 11,
    T1       = 12,
    T2       = 13,
    M1       = 14,
    M2       = 15,
    STATE_UP    = 'up',
    STATE_DOWN  = 'down',
}
setmetatable(db.KEY, {__newindex = function() end})
---------------------------------------------------------------
KEY, KEY_INV = db.KEY, db.table.flip(db.KEY)
---------------------------------------------------------------
BIND_TO_KEY = {
    -- Right side
    CP_R_UP     = KEY.TRIANGLE,
    CP_R_DOWN   = KEY.CROSS,
    CP_R_LEFT   = KEY.SQUARE,
    CP_R_RIGHT  = KEY.CIRCLE,
    -- Left side
    CP_L_UP     = KEY.UP,
    CP_L_DOWN   = KEY.DOWN,
    CP_L_LEFT   = KEY.LEFT,
    CP_L_RIGHT  = KEY.RIGHT,
    -- Option buttons
    CP_X_LEFT   = KEY.SHARE,
    CP_X_CENTER = KEY.CENTER,
    CP_X_RIGHT  = KEY.OPTIONS,
    -- Triggers
    CP_T1       = KEY.T1,
    CP_T2       = KEY.T2,
    -- Modifiers
    CP_M1       = KEY.M1,
    CP_M2       = KEY.M2,
}
KEY_TO_BIND = db.table.flip(BIND_TO_KEY)
---------------------------------------------------------------
-- Get the binding/integer key used to perform UI operations
---------------------------------------------------------------
function ConsolePort:IterateUIControlKeys()
    return ipairs(KEY_INV)
end

function ConsolePort:GetUIControlKey(binding)
    return BIND_TO_KEY[binding]
end

function ConsolePort:GetUIControlBinding(key)
    return KEY_TO_BIND[key]
end

function ConsolePort:GetUIControlKeyFromInput(binding)
    local action = GetBindingAction(binding or '')
    return self:GetUIControlKey(action)
end

---------------------------------------------------------------
-- Action IDs and their corresponding binding
---------------------------------------------------------------
local actionIDs = {
    -- Main bar                             -- Second page
    [1]     = 'ACTIONBUTTON1',              [13]    = 'ACTIONBUTTON1',
    [2]     = 'ACTIONBUTTON2',              [14]    = 'ACTIONBUTTON2',
    [3]     = 'ACTIONBUTTON3',              [15]    = 'ACTIONBUTTON3',
    [4]     = 'ACTIONBUTTON4',              [16]    = 'ACTIONBUTTON4',
    [5]     = 'ACTIONBUTTON5',              [17]    = 'ACTIONBUTTON5',
    [6]     = 'ACTIONBUTTON6',              [18]    = 'ACTIONBUTTON6',
    [7]     = 'ACTIONBUTTON7',              [19]    = 'ACTIONBUTTON7',
    [8]     = 'ACTIONBUTTON8',              [20]    = 'ACTIONBUTTON8',
    [9]     = 'ACTIONBUTTON9',              [21]    = 'ACTIONBUTTON9',
    [10]    = 'ACTIONBUTTON10',             [22]    = 'ACTIONBUTTON10',
    [11]    = 'ACTIONBUTTON11',             [23]    = 'ACTIONBUTTON11',
    [12]    = 'ACTIONBUTTON12',             [24]    = 'ACTIONBUTTON12',
    -- Right                                -- Left
    [25]    = 'MULTIACTIONBAR3BUTTON1',     [37]    = 'MULTIACTIONBAR4BUTTON1',
    [26]    = 'MULTIACTIONBAR3BUTTON2',     [38]    = 'MULTIACTIONBAR4BUTTON2',
    [27]    = 'MULTIACTIONBAR3BUTTON3',     [39]    = 'MULTIACTIONBAR4BUTTON3',
    [28]    = 'MULTIACTIONBAR3BUTTON4',     [40]    = 'MULTIACTIONBAR4BUTTON4',
    [29]    = 'MULTIACTIONBAR3BUTTON5',     [41]    = 'MULTIACTIONBAR4BUTTON5',
    [30]    = 'MULTIACTIONBAR3BUTTON6',     [42]    = 'MULTIACTIONBAR4BUTTON6',
    [31]    = 'MULTIACTIONBAR3BUTTON7',     [43]    = 'MULTIACTIONBAR4BUTTON7',
    [32]    = 'MULTIACTIONBAR3BUTTON8',     [44]    = 'MULTIACTIONBAR4BUTTON8',
    [33]    = 'MULTIACTIONBAR3BUTTON9',     [45]    = 'MULTIACTIONBAR4BUTTON9',
    [34]    = 'MULTIACTIONBAR3BUTTON10',    [46]    = 'MULTIACTIONBAR4BUTTON10',
    [35]    = 'MULTIACTIONBAR3BUTTON11',    [47]    = 'MULTIACTIONBAR4BUTTON11',
    [36]    = 'MULTIACTIONBAR3BUTTON12',    [48]    = 'MULTIACTIONBAR4BUTTON12',
    -- Bottom Right                         -- Bottom Left
    [49]    = 'MULTIACTIONBAR2BUTTON1',     [61]    = 'MULTIACTIONBAR1BUTTON1',
    [50]    = 'MULTIACTIONBAR2BUTTON2',     [62]    = 'MULTIACTIONBAR1BUTTON2',
    [51]    = 'MULTIACTIONBAR2BUTTON3',     [63]    = 'MULTIACTIONBAR1BUTTON3',
    [52]    = 'MULTIACTIONBAR2BUTTON4',     [64]    = 'MULTIACTIONBAR1BUTTON4',
    [53]    = 'MULTIACTIONBAR2BUTTON5',     [65]    = 'MULTIACTIONBAR1BUTTON5',
    [54]    = 'MULTIACTIONBAR2BUTTON6',     [66]    = 'MULTIACTIONBAR1BUTTON6',
    [55]    = 'MULTIACTIONBAR2BUTTON7',     [67]    = 'MULTIACTIONBAR1BUTTON7',
    [56]    = 'MULTIACTIONBAR2BUTTON8',     [68]    = 'MULTIACTIONBAR1BUTTON8',
    [57]    = 'MULTIACTIONBAR2BUTTON9',     [69]    = 'MULTIACTIONBAR1BUTTON9',
    [58]    = 'MULTIACTIONBAR2BUTTON10',    [70]    = 'MULTIACTIONBAR1BUTTON10',
    [59]    = 'MULTIACTIONBAR2BUTTON11',    [71]    = 'MULTIACTIONBAR1BUTTON11',
    [60]    = 'MULTIACTIONBAR2BUTTON12',    [72]    = 'MULTIACTIONBAR1BUTTON12',
    -- Bonusbar 7                           -- Bonusbar 8
    [73]    = 'ACTIONBUTTON1',              [85]    = 'ACTIONBUTTON1',
    [74]    = 'ACTIONBUTTON2',              [86]    = 'ACTIONBUTTON2',
    [75]    = 'ACTIONBUTTON3',              [87]    = 'ACTIONBUTTON3',
    [76]    = 'ACTIONBUTTON4',              [88]    = 'ACTIONBUTTON4',
    [77]    = 'ACTIONBUTTON5',              [89]    = 'ACTIONBUTTON5',
    [78]    = 'ACTIONBUTTON6',              [90]    = 'ACTIONBUTTON6',
    [79]    = 'ACTIONBUTTON7',              [91]    = 'ACTIONBUTTON7',
    [80]    = 'ACTIONBUTTON8',              [92]    = 'ACTIONBUTTON8',
    [81]    = 'ACTIONBUTTON9',              [93]    = 'ACTIONBUTTON9',
    [82]    = 'ACTIONBUTTON10',             [94]    = 'ACTIONBUTTON10',
    [83]    = 'ACTIONBUTTON11',             [95]    = 'ACTIONBUTTON11',
    [84]    = 'ACTIONBUTTON12',             [96]    = 'ACTIONBUTTON12',
    -- Bonusbar 9 (druid / monk only)       -- Bonusbar 10 (druid only)
    [97]    = 'ACTIONBUTTON1',              [109]   = 'ACTIONBUTTON1',
    [98]    = 'ACTIONBUTTON2',              [110]   = 'ACTIONBUTTON2',
    [99]    = 'ACTIONBUTTON3',              [111]   = 'ACTIONBUTTON3',
    [100]   = 'ACTIONBUTTON4',              [112]   = 'ACTIONBUTTON4',
    [101]   = 'ACTIONBUTTON5',              [113]   = 'ACTIONBUTTON5',
    [102]   = 'ACTIONBUTTON6',              [114]   = 'ACTIONBUTTON6',
    [103]   = 'ACTIONBUTTON7',              [115]   = 'ACTIONBUTTON7',
    [104]   = 'ACTIONBUTTON8',              [116]   = 'ACTIONBUTTON8',
    [105]   = 'ACTIONBUTTON9',              [117]   = 'ACTIONBUTTON9',
    [106]   = 'ACTIONBUTTON10',             [118]   = 'ACTIONBUTTON10',
    [107]   = 'ACTIONBUTTON11',             [119]   = 'ACTIONBUTTON11',
    [108]   = 'ACTIONBUTTON12',             [120]   = 'ACTIONBUTTON12',

    -- OverrideBar
    [133]   = 'ACTIONBUTTON1',
    [134]   = 'ACTIONBUTTON2',
    [135]   = 'ACTIONBUTTON3',
    [136]   = 'ACTIONBUTTON4',
    [137]   = 'ACTIONBUTTON5',
    [138]   = 'ACTIONBUTTON6',

    [169]   = 'EXTRAACTIONBUTTON1',
}

---------------------------------------------------------------
local class = select(2, UnitClass('player'))
-- action ID thresholds
local classReserved = {
    ['WARRIOR'] = 96,
    ['ROGUE']   = 84,
    ['DRUID']   = 120,
    ['MONK']    = 108,
    ['PRIEST']  = 84,
}

---------------------------------------------------------------
local customRange = classReserved[class]
local ACTION_ID_RANGE = 72
local ACTION_ID_STANCE_RANGE = 120
local ACTION_ID_MAX_THRESHOLD = 169
---------------------------------------------------------------

---------------------------------------------------------------
-- Functions for grabbing action button data
---------------------------------------------------------------
function ConsolePort:GetActionPageDriver()
    -- generate a macro condition with generic values to ensure any change pushes an update.
    -- the actual bar ID check is done in the pager (Drivers\Pager) instead.
    -- this method seems to work regardless of API changes that cause
    -- some of these macro conditions to shift around on certain specs.
    -- add any new / extra macro conditions to the list below. (as if there aren't enough already)
    local conditionFormat = '[%s] %d; '
    local count, driver = 0, ''
    for i, macroCondition in ipairs({
        ----------------------------------
        'vehicleui', 'possessbar', 'overridebar', 'shapeshift',
        'bar:2', 'bar:3', 'bar:4', 'bar:5', 'bar:6',
        'bonusbar:1', 'bonusbar:2', 'bonusbar:3', 'bonusbar:4'
        ----------------------------------
    }) do  driver = driver .. conditionFormat:format(macroCondition, i) count = i end
    driver = driver .. (count + 1) -- append the list for the default bar (1) when none of the conditions apply.
    ----------------------------------
    return driver, self:GetActionPage()
end

function ConsolePort:GetActionPageResponse()
    return ([[
        if HasVehicleActionBar and HasVehicleActionBar() then
            newstate = GetVehicleBarIndex()
        elseif HasOverrideActionBar and HasOverrideActionBar() then
            newstate = GetOverrideBarIndex()
        elseif HasTempShapeshiftActionBar() then
            newstate = GetTempShapeshiftBarIndex()
        elseif GetBonusBarOffset() > 0 then
            newstate = GetBonusBarOffset() + %s
        else
            newstate = GetActionBarPage()
        end
        for header in pairs(headers) do
            header:SetAttribute('actionpage', newstate)
            if header:GetAttribute('pageupdate') then
                header:RunAttribute('pageupdate', newstate)
            end
        end
    ]]):format(NUM_ACTIONBAR_PAGES)
end

function ConsolePort:GetActionPage()
    local newstate
    if db('pagedriver') then
        newstate = SecureCmdOptionParse(db('pagedriver'))
    elseif HasVehicleActionBar and HasVehicleActionBar() then
        newstate = GetVehicleBarIndex()
    elseif HasOverrideActionBar and HasOverrideActionBar() then
        newstate = GetOverrideBarIndex()
    elseif HasTempShapeshiftActionBar() then
        newstate = GetTempShapeshiftBarIndex()
    elseif GetBonusBarOffset() > 0 then
        newstate = GetBonusBarOffset() + NUM_ACTIONBAR_PAGES
    else
        newstate = GetActionBarPage()
    end
    return newstate
end

function ConsolePort:GetOffsetActionID(actionID)
    if actionID <= NUM_ACTIONBAR_BUTTONS then
        local page = self:GetActionPage()
        return ((page-1) * NUM_ACTIONBAR_BUTTONS) + actionID
    else
        return actionID
    end
end

function ConsolePort:GetActionBinding(id)
    local idType = type(id)
    if idType == 'number' then
        -- reserve bars for classes with stances
        if customRange then
            if (id <= customRange or id > ACTION_ID_STANCE_RANGE) then
                return actionIDs[id]
            end
        -- let other classes use bars 7-10 
        elseif (id <= ACTION_ID_RANGE or id > ACTION_ID_STANCE_RANGE) then
            return actionIDs[id]
        end
    elseif idType == 'string' then
        return actionIDs[id]
    end
end

function ConsolePort:GetActionID(bindName)
    if bindName ~= nil then
        for ID=1, ACTION_ID_MAX_THRESHOLD do
            if actionIDs[ID] == bindName then
                return tonumber(ID)
            end
        end
    end
end

function ConsolePort:GetActionTexture(bindName)
    local ID = self:GetActionID(bindName)
    if ID then
        local actionpage = self:GetActionPage()
        return ID < 73 and GetActionTexture(ID + (actionpage - 1) * 12) or GetActionTexture(ID)
    end
end

---------------------------------------------------------------
-- Get the clean bindings for various uses
---------------------------------------------------------------
function ConsolePort:GetBindings(tbl) return tbl and copy(Controller.Bindings) or spairs(Controller.Bindings) end

---------------------------------------------------------------
-- Default faux binding settings
---------------------------------------------------------------
function ConsolePort:GetDefaultBinding(key) return copy(Controller.Bindings[key]) end

---------------------------------------------------------------
-- Get the currently deployed binding set (can be manipulated)
---------------------------------------------------------------
function ConsolePort:GetCurrentBindings() return copy(self:GetBindingSet()) end

---------------------------------------------------------------
-- Get the button that's currently bound to a defined ID
---------------------------------------------------------------
function ConsolePort:GetCurrentBindingOwner(bindingID, set)
    local set = set or db.Bindings
    if set then
        for key, subSet in pairs(set) do
            for mod, value in pairs(subSet) do
                if value == bindingID then
                    return key, mod
                end
            end
        end
    end
end

function ConsolePort:GetFormattedButtonCombination(key, mod, size, useLargeIcons)
    if key and mod then
        local texture_esc = '|T%s:'..format('%d:%d:0:0|t', size or 24, size or 24)
        local texTable = useLargeIcons and db.TEXTURE or db.ICONS
        local icon = texTable[key]
        if icon then
            local formattedKeys = {
                [''] = format(texture_esc, icon),
                ['SHIFT-'] = format(texture_esc, texTable.CP_M1) .. format(texture_esc, icon),
                ['CTRL-'] = format(texture_esc, texTable.CP_M2) .. format(texture_esc, icon),
                ['CTRL-SHIFT-'] = format(texture_esc, texTable.CP_M1) .. format(texture_esc, texTable.CP_M2) .. format(texture_esc, icon),
            }
            return formattedKeys[mod]
        end
    end
end

function ConsolePort:GetFormattedBindingOwner(bindingID, set, size, useLargeIcons)
    local key, mod = self:GetCurrentBindingOwner(bindingID, set)
    if key and mod then
        return self:GetFormattedButtonCombination(key, mod, size, useLargeIcons)
    end
end

---------------------------------------------------------------
-- Get the modifiers currently used by ConsolePort
---------------------------------------------------------------
local IsShiftKeyDown, IsControlKeyDown = IsShiftKeyDown, IsControlKeyDown
local modifiers = {
    ['']        = function() return ( not IsShiftKeyDown() and not IsControlKeyDown() ) end,
    ['SHIFT-']  = function() return ( IsShiftKeyDown() and not IsControlKeyDown() ) end,
    ['CTRL-']   = function() return ( IsControlKeyDown() and not IsShiftKeyDown() ) end,
    ['CTRL-SHIFT-'] = function() return ( IsShiftKeyDown() and IsControlKeyDown() ) end,
}

function ConsolePort:GetModifiers() return pairs(modifiers) end

function ConsolePort:GetCurrentModifier()
    for modifier, isCurrent in self:GetModifiers() do
        if isCurrent() then
            return modifier
        end
    end
end

---------------------------------------------------------------
-- Binding set / buttons for faux binding system
---------------------------------------------------------------
function ConsolePort:GetDefaultBindingSet()
    local bindingSet = {}
    for button in self:GetBindings() do
        bindingSet[button] = self:GetDefaultBinding(button)
    end
    return bindingSet
end

---------------------------------------------------------------
-- Default addon settings (client wide)
---------------------------------------------------------------
function ConsolePort:GetDefaultAddonSettings(setting)
    local settings = {
        ['type'] = 'PS4',
        ['UIdropDownFix'] = true,
        -------------------------------
        ['CP_M1'] = 'CP_TL1',
        ['CP_M2'] = 'CP_TL2',
        ['CP_T1'] = 'CP_TR1',
        ['CP_T2'] = 'CP_TR2',
        -------------------------------
        ['lootWith'] = 'CP_R_DOWN',
        ['interactCache'] = true,
        ['interactScrape'] = true,
        ['nameplateNameOnly'] = true,
        -------------------------------
        ['actionBarStyle'] = 4,
        -------------------------------
        ['autoExtra'] = true,
        ['autoSellJunk'] = true,
        ['autoInteract'] = false,
        ['disableSmartMouse'] = false,
        ['preventMouseDrift'] = false,
        ['turnCharacter'] = false,
        -------------------------------
        ['mouseOnJump'] = false,
        -------------------------------
        ['unitHotkeyPool'] = 'player$;party%d$;raid%d+$',
        -------------------------------
    }
    if Controller then
        for key, value in pairs(Controller.Settings) do
            settings[key] = value
        end
    end
    if setting then
        return settings[setting]
    else
        return settings
    end
end

---------------------------------------------------------------
-- Mouse events and default cursor handler
---------------------------------------------------------------
function ConsolePort:GetDefaultMouseEvents()
    return {
        ['PLAYER_STARTED_MOVING'] = true,
        ['PLAYER_TARGET_CHANGED'] = true,
        ['GOSSIP_SHOW'] = true,
        ['GOSSIP_CLOSED'] = true,
        ['MERCHANT_SHOW'] = true,
        ['MERCHANT_CLOSED'] = true,
        ['TAXIMAP_OPENED'] = true,
        ['TAXIMAP_CLOSED'] = true,
        ['QUEST_GREETING'] = true,
        ['QUEST_DETAIL'] = true,
        ['QUEST_PROGRESS'] = true,
        ['QUEST_COMPLETE'] = true,
        ['QUEST_FINISHED'] = true,
        ['QUEST_AUTOCOMPLETE'] = true,
        ['SHIPMENT_CRAFTER_OPENED'] = true,
        ['SHIPMENT_CRAFTER_CLOSED'] = true,
        ['LOOT_OPENED'] = true,
        ['LOOT_CLOSED'] = true,
        ['UNIT_SPELLCAST_SENT'] = true,
        ['UNIT_SPELLCAST_FAILED'] = true,
    }
end

function ConsolePort:GetDefaultMouseCursor()
    return {
        Left    = 'CP_R_DOWN',
        Right   = 'CP_R_RIGHT',
        Special = 'CP_R_UP',
        Scroll  = 'CP_M1',
    }
end

---------------------------------------------------------------
-- Get all hidden customly created convenience bindings 
---------------------------------------------------------------
function ConsolePort:GetCustomBindings()
    local L = db.CUSTOMBINDS
    return {
        -- Mouse bindings
        {name = L.CP_MOUSE},
        {name = L.CAMERAORSELECTORMOVE, binding = 'CAMERAORSELECTORMOVE'},
        {name = L.TURNORACTION, binding = 'TURNORACTION'},
        -- Targeting
        {name = L.CP_TARGETING},
        {name = L.CP_FOCUSCAST, binding = 'CLICK ConsolePortFocusButton:LeftButton'},
        {name = L.CP_EM_FRAMES, binding = 'CLICK ConsolePortEasyMotionButton:LeftButton'},
        {name = L.CP_RAIDCURSOR, binding = 'CLICK ConsolePortRaidCursorToggle:LeftButton'},
        {name = L.CP_RAIDCURSOR_F, binding = 'CLICK ConsolePortRaidCursorFocus:LeftButton'},
        {name = L.CP_RAIDCURSOR_T, binding = 'CLICK ConsolePortRaidCursorTarget:LeftButton'},
        -- Utility
        {name = L.CP_UTILITY},
        {name = L.CP_UTILITYBELT, binding = 'CLICK ConsolePortUtilityToggle:LeftButton'},
        {name = L.CP_PETRING, binding = 'CLICK ConsolePortBarPet:MiddleButton'},
        {name = L.CP_TOGGLEADDON, binding = 'CLICK ConsolePortLoader:LeftButton'},
        -- Pager
        {name = L.CP_PAGER},
        {name = L.CP_PAGE2, binding = 'CLICK ConsolePortPager:2'},
        {name = L.CP_PAGE3, binding = 'CLICK ConsolePortPager:3'},
        {name = L.CP_PAGE4, binding = 'CLICK ConsolePortPager:4'},
        {name = L.CP_PAGE5, binding = 'CLICK ConsolePortPager:5'},
        {name = L.CP_PAGE6, binding = 'CLICK ConsolePortPager:6'},
        -- Camera
        {name = L.CP_CAMERA},
        {name = L.CP_CAMZOOMIN, binding = 'CP_CAMZOOMIN'},
        {name = L.CP_ZOOMIN_HOLD, binding = 'CP_ZOOMIN_HOLD'},
        {name = L.CP_CAMZOOMOUT, binding = 'CP_CAMZOOMOUT'},
        {name = L.CP_ZOOMOUT_HOLD, binding = 'CP_ZOOMOUT_HOLD'},
        {name = L.CP_TOGGLEMOUSE, binding = 'CP_TOGGLEMOUSE'},
        {name = L.CP_CAMLOOKBEHIND, binding = 'CP_CAMLOOKBEHIND'},
    }
end


---------------------------------------------------------------
-- UI cursor frames to be handled with D-pad
---------------------------------------------------------------
function ConsolePort:GetDefaultUIFrames()
    local IsClassic, IsRetail = CPAPI:IsClassicVersion(), CPAPI:IsRetailVersion()
    return {
        Blizzard_AchievementUI      = {
            'AchievementFrame' },
        Blizzard_AlliedRacesUI      = {
            'AlliedRacesFrame' },
        Blizzard_ArchaeologyUI      = {
            'ArchaeologyFrame' },
        Blizzard_ArtifactUI         = {
            'ArtifactFrame',
            'ArtifactRelicForgeFrame'},
        Blizzard_AuctionUI          = {
            'AuctionFrame' },
        Blizzard_AzeriteUI          = {
            'AzeriteEmpoweredItemUI' },
        Blizzard_BarbershopUI       = {
            'BarberShopFrame' },
        Blizzard_Calendar           = {
            'CalendarFrame' },
        Blizzard_ChallengesUI       = {
            'ChallengesKeystoneFrame' },
        Blizzard_Collections        = {
            'CollectionsJournal',
            'WardrobeFrame', },
        Blizzard_Communities        = {
            'CommunitiesFrame', },
        Blizzard_DeathRecap         = {
            'DeathRecapFrame' },
        Blizzard_EncounterJournal   = {
            'EncounterJournal' },
        Blizzard_GarrisonUI         = {
            'GarrisonBuildingFrame',
            'GarrisonCapacitiveDisplayFrame',
            'GarrisonLandingPage',
            'GarrisonMissionFrame',
            'GarrisonMonumentFrame',
            'GarrisonRecruiterFrame',
            'GarrisonShipyardFrame',
            'OrderHallMissionFrame',
            'OrderHallTalentFrame', },
        Blizzard_GuildUI            = {
            'GuildFrame' },
        Blizzard_InspectUI          = {
            'InspectFrame' },
        Blizzard_ItemAlterationUI   = {
            'TransmogrifyFrame' },
        Blizzard_LookingForGuildUI  = {
            'LookingForGuildFrame' },
        Blizzard_MacroUI            = {
            'MacroFrame' },
        Blizzard_ObliterumUI        = {
            'ObliterumForgeFrame' },
        Blizzard_QuestChoice        = {
            'QuestChoiceFrame' },
        Blizzard_TalentUI           = {
            IsRetail and 'PlayerTalentFrame',
            IsClassic and 'TalentFrame'},
        Blizzard_TradeSkillUI       = {
            'TradeSkillFrame' },
        Blizzard_TrainerUI          = {
            'ClassTrainerFrame' },
        Blizzard_VoidStorageUI      = {
            'VoidStorageFrame' },
        Blizzard_WarboardUI = {
            'WarboardQuestChoiceFrame' },
        ConsolePort                 = {
            'AddonList',
            'BagHelpBox',
            'BankFrame',
            'BasicScriptErrors',
            'CharacterFrame',
            'ChatConfigFrame',
            'ChatMenu',
            'CinematicFrameCloseDialog',
            'ContainerFrame1',
            'ContainerFrame2',
            'ContainerFrame3',
            'ContainerFrame4',
            'ContainerFrame5',
            'ContainerFrame6',
            'ContainerFrame7',
            'ContainerFrame8',
            'ContainerFrame9',
            'ContainerFrame10',
            'ContainerFrame11',
            'ContainerFrame12',
            'ContainerFrame13',
            'DressUpFrame',
            'DropDownList1',
            'DropDownList2',
            'FriendsFrame', 
            'GameMenuFrame',
            'GossipFrame',
            'GuildInviteFrame',
            'InterfaceOptionsFrame',
            'ItemRefTooltip',
            'ItemTextFrame',
            'LFDRoleCheckPopup',
            'LFGDungeonReadyDialog',
            'LFGInvitePopup',
            'LootFrame',
            'MailFrame',
            'MerchantFrame',
            'OpenMailFrame',
            'PetBattleFrame',
            'PetitionFrame',
            'PVEFrame',
            'PVPReadyDialog',
            'QuestFrame',
            IsClassic and 'QuestLogFrame',
            'QuestLogPopupDetailFrame',
            'RecruitAFriendFrame',
            'ReadyCheckFrame',
            'SpellBookFrame',
            'SplashFrame',
            'StackSplitFrame',
            'StaticPopup1',
            'StaticPopup2',
            'StaticPopup3',
            'StaticPopup4',
            'TaxiFrame',
            'TimeManagerFrame',
            'TradeFrame',
            'TutorialFrame',
            'VideoOptionsFrame',
            'WorldMapFrame',
            'GroupLootFrame1',
            'GroupLootFrame2',
            'GroupLootFrame3',
            'GroupLootFrame4'
        },
    }
end

function ConsolePort:GetDefaultFadeFrames()
    return { 
        ignore = {
            'AlertFrame';
            'ArtifactLevelUpToast';
            'ChatFrame1';
            'CastingBarFrame';
            'GameTooltip';
            'QuickJoinToastButton';
            'StaticPopup1';
            'StaticPopup2';
            'StaticPopup3';
            'StaticPopup4';
            'SubZoneTextFrame';
            'ShoppingTooltip1';
            'ShoppingTooltip2';
            'OverrideActionBar';
            'UIErrorsFrame';
            'ZoneTextFrame';
            'TalkingHeadFrame';
        };
        force = {
            'ConsolePortBar';
            'MainMenuBar';
            'Minimap';
            'MinimapCluster';
        };
    }
end

------------------------------------------------------------------------------------------------------------
-- Cvar list and getter/setter functions
------------------------------------------------------------------------------------------------------------
local cvars = { -- value = default
    --------------------------------------------------------------------------------------------------------
    actionBarStyle          = {4        ; 'Action button hotkey style for regular action bars (1-5)'};
    allowSaveBindings       = {false    ; 'Allow binding data uploads (overwrites kb/m bindings)'};
    alwaysHighlight         = {0        ; 'Always highlight tab target (0, 1, 2)'};
    autoExtra               = {true     ; 'Automatically bind Qitems to utility ring'};
    autoInteract            = {false    ; 'Automatically moves to and interacts with NPCs (deprecated)'};
    autoLootDefault         = {true     ; 'Force auto-loot in combat'};
    autoSellJunk            = {true     ; 'Automatically sell junk'};
    cursorTrailGhost        = {false    ; 'Show cursor trail ghost'};
    cursorTrailGhostVis     = {.25      ; 'Cursor trail ghost alpha (0-1)'};
    disableCursorTrail      = {false    ; 'Disable Rclick/interact icon trailing cursor'};
    disableCvarReset        = {false    ; 'Disable console variable reset on exit/logout'};
    disableHints            = {false    ; 'Disable hint display on how certain things work'};
    disableSmartBind        = {false    ; 'Disable action/bag placement helper'};
    disableSmartMouse       = {false    ; 'Disable smart cursor show/hide'};
    disableStickMouse       = {false    ; 'Disable override bindings for stick buttons'};
    doubleModTap            = {true     ; 'Toggle mouselook by double tapping a modifier'};
    doubleModTapWindow      = {.25      ; 'How fast a modifier has to be tapped (seconds)'};
    enableCenterPanels      = {false    ; 'Put large panels in the center of the screen'};
    lookAround              = {false    ; 'Look around on L3 while in mouselook'};
    mouseInvertPitch        = {false    ; 'Invert mouse pitch'};
    mouseOnJump             = {false    ; 'Camera mode on jump'};
    turnCharacter           = {false    ; 'Turn instead of strafe out of mouselook'};
    preventMouseDrift       = {false    ; 'Lock mouse when drifting to screen edge'};
    raidCursorDirect        = {false    ; 'Target directly with raid cursor'};
    skipCalibration         = {false    ; 'Disable calibration check on login'};
    skipGuideBtn            = {false    ; 'Disable calibration check for the center button'};
    --------------------------------------------------------------------------------------------------------
    -- Radial properties:
    stickRadialType         = {0        ; 'Set left stick radial type (0, 1, 2)'};
    stickRadialLocal        = {false    ; 'Set left stick radial to inherit local movement keys'};
    stickRadialBindHorz     = {'H'      ; 'Default axis-dominant binding (horizontal)'};
    stickRadialBindVert     = {'V'      ; 'Default axis-dominant binding (vertical)'};
    utilityRingScale        = {1        ; 'Scale of the utility ring'};
    --------------------------------------------------------------------------------------------------------
    -- Interact button:
    interactNPC             = {false    ; 'Interact with already targeted NPCs'};
    interactPushback        = {1        ; 'Pushback after cast to avoid cursor toggle (seconds)'};
    interactHintPosition    = {200      ; 'Interact frame Y-offset from UIParent bottom (px)'};
    interactHintLineVis     = {.5       ; 'Interact frame line texture alpha (0-1)'};
    interactHintNoLine      = {false    ; 'Disable interact frame line texture'};
    interactWith            = {false    ; 'Full interact button ID'};
    lootWith                = {'CP_R_DOWN'; 'Lite interact button ID'};
    --------------------------------------------------------------------------------------------------------
    -- Nameplate scraping properties
    nameplateCC             = {true     ; 'Show class colors on name-only nameplates'};
    nameplateFadeIn         = {0.5      ; 'Fade in timer when using name-only nameplates'};
    nameplateNameOnly       = {false    ; 'Show only names when nameplate interaction is on'};
    nameplateTextScale      = {1        ; 'Fade in timer when using name-only nameplates'};
    nameplateExperimental   = {false    ; 'Scrape plates periodically (causes name flicker)'};
    nameplateExperimentalT  = {2        ; 'Periodic scrape timer (lower increases flickering)'};
    nameplateShowAllEnemies = {false    ; 'Show nameplates for all enemies (OFF: combat only)'};
    --------------------------------------------------------------------------------------------------------
    -- Camera yaw script specs:
    cameraYawDeadzone       = {.8       ; 'Yaw script deadzone (fraction of half of screen width)'};
    cameraYawSmoothOut      = {.085     ; 'Yaw script smooth pan out'};
    cameraYawSmoothIn       = {.155     ; 'Yaw script smooth pan in'};
    cameraYawMaxAngle       = {30       ; 'Max angle to pan before stopping'};
    --------------------------------------------------------------------------------------------------------
    -- Interface cursor:
    disableUI               = {false    ; 'Disable interface cursor'};
    UIleaveCombatDelay      = {.5       ; 'Delay before re-activating UI core after combat'};
    UIholdRepeatDelay       = {.125     ; 'Delay until a D-pad input is repeated (interface)'};
    UIdisableHoldRepeat     = {false    ; 'Disable D-pad input repeater'};
    UIdisableTooltipFix     = {false    ; 'Disable mouse cursor anchor workaround'};
    UIdropDownFix           = {true     ; 'Fix interface cursor on dropdowns'};
    --------------------------------------------------------------------------------------------------------
    -- Mouse on center lock:
    centerLockRangeX        = {70       ; 'Center mouse lock width (px)'};
    centerLockRangeY        = {180      ; 'Center mouse lock height (px)'};
    centerLockDeadzoneX     = {4        ; 'Center mouse lock deadzone width (px)'};
    centerLockDeadzoneY     = {4        ; 'Center mouse lock deadzone height (px)'};
    mouseOnCenter           = {true     ; 'Camera mode when mouseover center of UI'};
    --------------------------------------------------------------------------------------------------------
    -- Unit hotkey specific:
    unitHotkeySize          = {32       ; 'Size of unit hotkeys (px)'};
    unitHotkeyOffsetX       = {0        ; 'Offset X-placement on unit frames (px)'};
    unitHotkeyOffsetY       = {0        ; 'Offset Y-placement on unit frames (px)'};
    unitHotkeyGhostMode     = {false    ; 'Restore calculated combinations after targeting'};
    unitHotkeyIgnorePlayer  = {false    ; 'Always ignore player regardless of pool'};
    --------------------------------------------------------------------------------------------------------
    -- Texture remaps for back buttons:
    CP_M1                   = {'CP_TL1' ; 'Texture ID for modifier 1 (SHIFT)'};
    CP_M2                   = {'CP_TL2' ; 'Texture ID for modifier 2 (CTRL)'};
    CP_T1                   = {'CP_TR1' ; 'Texture ID for trigger 1'};
    CP_T2                   = {'CP_TR2' ; 'Texture ID for trigger 2'};
    --------------------------------------------------------------------------------------------------------
    -- String entries (CAUTION):
    cursorTrailGhostTex     = {[[Interface\CURSOR\Item]]    ; 'Cursor trail ghost texture'};
    exitVehicleBinding      = {'ACTIONBUTTON7'              ; 'Override vehicle exit binding from set'};
    explicitProfile         = {''                           ; 'Explicit profile ID to use for data export'};
    raidCursorModifier      = {''                           ; 'Modifier to combine with D-pad for cursor control'};
    unitHotkeyAnchor        = {'CENTER'                     ; 'Anchor point on unit frames'};
    unitHotkeyPool          = {'player;party%d$;raid%d+$'   ; 'Match criteria for unit hotkey pool, separated by semicolon'};
    unitHotkeySet           = {''                           ; 'Force button set for unit hotkey filtering. Valid: left, right'};
}   --------------------------------------------------------------------------------------------------------

---------------------------------------
-- DB Usage:
--	@set db('[pathto/]cvar', value)
--	@get db('[pathto/]cvar')
---------------------------------------
setmetatable(db, {
    __call = function(self, cvar, value)
        -- set:
        if (value ~= nil) and (cvar ~= nil) then
            return self:Set(cvar, value)
        end
        -- get:
        return self:Get(cvar)
    end;
})

local function __cd(root, default, raw)
	local path = {strsplit('/', raw)}
	local depth = #path
	if (depth == 1) then
		return default, raw
	else
		local dest = root
		for i=1, (depth - 1) do
			dest = dest[path[i]]
			if (dest == nil) then
				return
			end
		end
		return dest, path[depth]
	end
end

function db:Set(raw, value)
	local repo, cvar = __cd(self, self.Settings, raw)
	if repo and cvar then
		repo[cvar] = value
		ConsolePort:FireVarCallback(cvar, value)
		return true 
	end
end

function db:Get(raw)
	local repo, cvar = __cd(self, self.Settings, raw)
	if repo and cvar then
		local value = repo[cvar]
		if (value == nil) then
			local cvarDefault = cvars[cvar]
			return cvarDefault and cvarDefault[1]
		end
		return value
	end
end

---------------------------------------

function ConsolePort:RefreshCVars()
    for cvar in pairs(cvars) do
        self:FireVarCallback(cvar, db:Get(cvar))
    end
end

function ConsolePort:GetCompleteCVarList()
    local cvars = copy(cvars)
    for cvar, value in pairs(db.Settings) do
        if type(value) ~= 'table' then
            if cvars[cvar] then
                cvars[cvar][1] = value
            else
                cvars[cvar] = {value}
            end
        end
    end
    return cvars
end