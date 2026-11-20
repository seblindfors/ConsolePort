---------------------------------------------------------------
-- Targeting
---------------------------------------------------------------
-- Handles targeting settings.

local _, db = ...;
local Targeting = db:Register('Targeting', CPAPI.CreateEventHandler({'Frame', '$parentTargetingHandler', ConsolePort}, {
	'PLAYER_TARGET_CHANGED';
	'PLAYER_SOFT_ENEMY_CHANGED';
	'PLAYER_SOFT_FRIEND_CHANGED';
	'PLAYER_SOFT_INTERACT_CHANGED';
	'NAME_PLATE_UNIT_ADDED';
}, {
	DirectProxy = {
		trgtEnemy                 = db.Data.Cvar('SoftTargetEnemy');
		trgtEnemyIcon             = db.Data.Cvar('SoftTargetIconEnemy');
		trgtEnemyNameplate        = db.Data.Cvar('SoftTargetNameplateEnemy');
		trgtEnemyTooltip          = db.Data.Cvar('SoftTargetTooltipEnemy');
		trgtFriend                = db.Data.Cvar('SoftTargetFriend');
		trgtFriendIcon            = db.Data.Cvar('SoftTargetIconFriend');
		trgtFriendNameplate       = db.Data.Cvar('SoftTargetNameplateFriend');
		trgtFriendTooltip         = db.Data.Cvar('SoftTargetTooltipFriend');
		trgtInteractTooltip       = db.Data.Cvar('SoftTargetTooltipInteract');
	};
}))

---------------------------------------------------------------
-- Tooltip handling
---------------------------------------------------------------
local GameTooltip, UIParent, After, UnitGUID = GameTooltip, UIParent, C_Timer.After, UnitGUID;
local GetNamePlateForUnit = C_NamePlate.GetNamePlateForUnit;
local PLATE_REMOVED = 'NAME_PLATE_UNIT_REMOVED';

local function GetUnitGUID(unit)
	return CPAPI.Scrub(UnitGUID(unit))
end

---------------------------------------------------------------
-- Name plate decoration
---------------------------------------------------------------
local Decorate, Undecorate = nop, nop;
if CPAPI.IsRetailVersion then
	local GET, SET, UNSET, modified, elements = 1, 2, 3, {}, {
		{ -- Hide name text
			function(np, _) return np.UnitFrame and np.UnitFrame.name end;
			function(f) f:Hide() end;
			function(f) f:Show() end;
		};
		{ -- Hide health bar container
			function(np, _) return np.UnitFrame and np.UnitFrame.HealthBarsContainer end;
			function(f) f:Hide() end;
			function(f) f:Show() end;
		};
		{ -- Hide background on tooltip with minimal nameplate style
			function(_, gt) return db('trgtShowMinimalInteractNamePlate') and gt.NineSlice end;
			function(f) f:Hide() end;
			function(f) f:Show() end;
		};
		{ -- Change tooltip strata to match with world frame
			function(_, gt) return gt end;
			function(f) f:SetFrameStrata('BACKGROUND') end;
			function(f) f:SetFrameStrata('TOOLTIP') end;
		};
	};

	function Undecorate()
		for i = #elements, 1, -1 do
			local frame = modified[i];
			if frame then elements[i][UNSET](frame) end;
			modified[i] = nil;
		end
	end

	function Decorate(nameplate)
		Undecorate()
		for i, element in ipairs(elements) do
			local frame = element[GET](nameplate, GameTooltip)
			if frame then
				element[SET](frame)
				modified[i] = frame;
			end
		end
	end
end

---------------------------------------------------------------
-- Placement
---------------------------------------------------------------
-- @param plate : { anchor, offset, decorate }, nil for the default anchor
local PlateAnchors = {
	Frame = function(nameplate)
		return nameplate.UnitFrame or nameplate;
	end;
	Icon = function(nameplate)
		return nameplate.UnitFrame
			and nameplate.UnitFrame.SoftTargetFrame
			and nameplate.UnitFrame.SoftTargetFrame.Icon;
	end;
};

local UNIT_PLATE = { anchor = 'Frame'; offset = 28 };
local Shown, isMounted, isPlacing = { owner = UIParent };

local function GetUnitPlate()
	return db('trgtTooltipOnPlate') and UNIT_PLATE or nil;
end

local function Detach()
	Undecorate()
	if isMounted then
		isMounted = nil;
		GameTooltip:ClearAllPoints()
		Targeting:UnregisterEvent(PLATE_REMOVED)
	end
end

local function Mount()
	local plate = Shown.plate;
	local nameplate = plate and GetNamePlateForUnit(Shown.unit);
	local frame = nameplate and PlateAnchors[plate.anchor](nameplate);
	if not frame then return end;
	GameTooltip:ClearAllPoints()
	GameTooltip:SetPoint('LEFT', frame, 'RIGHT', plate.offset, 0)
	Targeting:RegisterEvent(PLATE_REMOVED)
	isMounted = true;
	if plate.decorate then
		Decorate(nameplate)
	end
end

local function SetDefaultAnchor()
	Detach()
	isPlacing = true;
	GameTooltip_SetDefaultAnchor(GameTooltip, Shown.owner)
	isPlacing = nil;
end

local function Place(unit, guid, plate)
	Shown.unit, Shown.guid, Shown.plate = unit, guid, plate;
	SetDefaultAnchor()
	Mount()
end

local function ShowUnit(unit, guid, plate)
	Place(unit, guid, plate)
	return GameTooltip:SetUnit(unit)
end

local function IsShownUnit(unitID)
	local guid = Shown.guid;
	return guid and GetUnitGUID(unitID) == guid;
end


function Targeting:OnTooltipPlateAdded(unitID)
	if ( not isMounted and Shown.plate
		and IsShownUnit(unitID)
		and IsShownUnit(Shown.unit)
		and GameTooltip:IsOwned(Shown.owner)
		and GameTooltip:IsShown() ) then
		Mount()
	end
end

function Targeting:NAME_PLATE_UNIT_REMOVED(unitID)
	if ( isMounted and IsShownUnit(unitID) ) then
		local unit, isStillShown = Shown.unit, IsShownUnit(Shown.unit);
		SetDefaultAnchor()
		if isStillShown then
			GameTooltip:SetUnit(unit)
		end
	end
end

---------------------------------------------------------------
-- Sources
---------------------------------------------------------------
local Active, isWaiting, focusTimer, expiryTimer = {};

local function IsTooltipAvailable()
	return not ConsolePort:IsCursorActive()
		and ( GameTooltip:IsOwned(UIParent)
		or not GameTooltip:IsVisible()
		or GameTooltip:GetAlpha() < 1 );
end

local function IsShowingActive()
	return Active.source and GameTooltip:IsOwned(UIParent) and GameTooltip:IsShown();
end

local function ShowUnitWhenFocused(unit, guid)
	local plate = GetUnitPlate()
	local delay = plate and db('trgtTooltipDelay') or 0;
	if ( delay <= 0 ) then
		return ShowUnit(unit, guid, plate)
	end
	if GameTooltip:IsOwned(UIParent) then
		GameTooltip:Hide()
	end
	focusTimer = C_Timer.NewTimer(delay, function()
		focusTimer = nil;
		if ( GetUnitGUID(unit) == guid and IsTooltipAvailable() ) then
			ShowUnit(unit, guid, plate)
		end
	end)
end

local function GetExpiry(since)
	if db:GetCVar('SoftTargetTooltipLocked', false) then
		return math.huge;
	end
	return since + db:GetCVar('SoftTargetTooltipDurationMs', 2000) / 1000;
end

local function Acquire(source, guid)
	if ( source.guid ~= guid ) then
		source.guid, source.since = guid, GetTime();
	end
end

-- @return guid   : unit to show for this source, nil when not eligible
-- @return expiry : time at which the source stops being eligible, if any
local Aim      = { unit = 'target' };
local Interact = { unit = 'anyinteract' };
local Reticle  = { unit = 'mouseover';  option = 'mouseShowCenterTooltip' };
local Hard     = { unit = 'target' };
local Aimed    = { unit = 'target';     option = 'trgtAimTooltip'    };
local Enemy    = { unit = 'softenemy';  option = 'trgtEnemyTooltip'  };
local Friend   = { unit = 'softfriend'; option = 'trgtFriendTooltip' };
local Sources  = { Aim, Interact, Reticle, Hard, Aimed, Enemy, Friend };

function Aim:Poll()
	return self.held and db('trgtAimTooltip') and GetUnitGUID(self.unit);
end

local function PollTimed(self, now)
	local guid = self.guid;
	if not ( guid and db(self.option) and GetUnitGUID(self.unit) == guid ) then return end;
	local expiry = GetExpiry(self.since)
	if ( expiry > now ) then
		return guid, expiry;
	end
end

Aimed.Poll, Enemy.Poll, Friend.Poll = PollTimed, PollTimed, PollTimed;

function Reticle:Poll(now)
	local guid = db.Mouse.mouseOverGUID;
	Acquire(self, guid and GetUnitGUID(self.unit) == guid and guid or nil)
	return PollTimed(self, now)
end

function Hard:Poll()
	return db('trgtHardTooltip') and GetUnitGUID(self.unit);
end

for _, source in ipairs({ Aim, Reticle, Hard, Aimed, Enemy, Friend }) do
	function source:Show(guid)
		ShowUnitWhenFocused(self.unit, guid)
	end
end

function Targeting:UpdateTooltip()
	if expiryTimer then
		expiryTimer = expiryTimer:Cancel()
	end
	local now, source, guid, expiry = GetTime();
	for _, candidate in ipairs(Sources) do
		guid, expiry = candidate:Poll(now)
		if guid then
			source = candidate;
			break;
		end
	end
	Interact:SetNamePlateShown(source == Interact)
	isWaiting = source and not IsTooltipAvailable() or nil;
	if isWaiting then return end;

	if ( expiry and expiry < math.huge ) then
		expiryTimer = C_Timer.NewTimer(expiry - now, function()
			expiryTimer = nil;
			self:RequestTooltipUpdate()
		end)
	end
	local shown = Active.source;
	if ( source and shown and source.unit == shown.unit and guid == Active.guid ) then
		Active.source = source;
		return;
	end
	if ( source == shown and guid == Active.guid ) then return end;
	if focusTimer then
		focusTimer = focusTimer:Cancel()
	end
	if not source then
		if IsShowingActive() then
			GameTooltip:FadeOut()
		end
		Active.source, Active.guid = nil, nil;
		return;
	end
	Active.source, Active.guid = source, guid;
	if ( source:Show(guid) == false ) then
		Active.source, Active.guid = nil, nil;
	end
end

Targeting.RequestTooltipUpdate = CPAPI.Debounce(Targeting.UpdateTooltip, Targeting)

function Targeting:OnTooltipSourceChanged()
	self:RequestTooltipUpdate()
end

hooksecurefunc(GameTooltip, 'SetOwner', function()
	if isPlacing then return end;
	Detach()
	if Active.source then
		Active.source, Active.guid, isWaiting = nil, nil, true;
	end
end)

GameTooltip:HookScript('OnHide', function()
	if isPlacing then return end;
	Detach()
	if isWaiting then
		Targeting:RequestTooltipUpdate()
	end
end)

---------------------------------------------------------------
-- Direct proxy updates
---------------------------------------------------------------
for varID, proxy in pairs(Targeting.DirectProxy) do
	db:RegisterCallback('Settings/'..varID, function(_, ...) proxy:Set(...) end, Targeting)
end

---------------------------------------------------------------
-- Data loading
---------------------------------------------------------------
function Targeting:OnDataLoaded()
	for varID, proxy in pairs(self.DirectProxy) do
		proxy:Set(db(varID))
	end
	return CPAPI.BurnAfterReading;
end

---------------------------------------------------------------
-- Events
---------------------------------------------------------------
function Targeting:PLAYER_SOFT_ENEMY_CHANGED()
	Acquire(Enemy, GetUnitGUID(Enemy.unit))
	self:RequestTooltipUpdate()
end

function Targeting:PLAYER_SOFT_FRIEND_CHANGED()
	Acquire(Friend, GetUnitGUID(Friend.unit))
	self:RequestTooltipUpdate()
end

function Targeting:PLAYER_TARGET_CHANGED()
	Aimed.guid = nil;
	self:RequestTooltipUpdate()
end

function Targeting:OnAimHold(held)
	Aim.isReleasing = not held;
	if held then
		Aim.held, Aimed.guid = true, nil;
		return self:RequestTooltipUpdate();
	end
	RunNextFrame(function()
		if not Aim.isReleasing then return end;
		Aim.held, Aim.isReleasing = false, nil;
		Acquire(Aimed, GetUnitGUID(Aimed.unit))
		Aimed.since = GetTime();
		self:RequestTooltipUpdate()
	end)
end

db:RegisterCallback('OnAimHold', Targeting.OnAimHold, Targeting)
db:RegisterCallbacks(Targeting.OnTooltipSourceChanged, Targeting,
	'OnCursorHide',
	'Settings/trgtAimTooltip',
	'Settings/trgtEnemyTooltip',
	'Settings/trgtFriendTooltip',
	'Settings/trgtHardTooltip',
	'Settings/trgtInteractTooltip',
	'Settings/trgtTooltipOnPlate'
);

---------------------------------------------------------------
do -- Interact tooltip and nameplate handling
---------------------------------------------------------------
	local InteractNamePlate = db.Data.Cvar('SoftTargetNameplateInteract');
	local UNIT_PLATE = { anchor = 'Icon'; offset = 10; decorate = true };
	local NAME_PLATE = { anchor = 'Icon'; offset = 0;  decorate = true };

	local function GetInteractPlate(plate)
		return CPAPI.IsRetailVersion and not UnitCanAttack('player', Interact.unit) and plate or nil;
	end

	local function SetTooltipToInteractUnit(guid)
		return ShowUnit(Interact.unit, guid, GetInteractPlate(UNIT_PLATE))
	end

	local function SetTooltipToUnitName(guid)
		local name = UnitName(Interact.unit)
		if not name then return false end;
		Place(Interact.unit, guid, GetInteractPlate(NAME_PLATE))
		GameTooltip:SetText(name, NORMAL_FONT_COLOR:GetRGB())
		GameTooltip:Show()
		return true;
	end

	local function CanInteractWithObject(guid)
		if guid:match('GameObject') then
			-- Can't determine interaction range for objects,
			-- so we just assume it's in range.
			return true;
		end
		-- HACK: CanLootUnit returns whether interaction is in range for all NPCs.
		return select(2, CanLootUnit(guid))
	end

	function Interact:Poll(now)
		local guid = self.guid;
		if not ( guid and db:GetCVar('SoftTargetTooltipInteract', false) ) then return end;
		if ( UnitIsPlayer(self.unit) or not CanInteractWithObject(guid) ) then return end;
		local expiry = GetExpiry(self.since)
		if ( expiry > now ) then
			return guid, expiry;
		end
	end

	function Interact:Show(guid)
		if not SetTooltipToInteractUnit(guid) and not SetTooltipToUnitName(guid) then
			return false;
		end
		if not db('trgtShowInteractHint') or UnitCanAttack('player', self.unit) then return end;

		local slug = db.Hotkeys:GetButtonSlugForBinding('INTERACTTARGET', false, true)
		if not slug then return end;

		local hint = ('%s %s'):format(slug, UNIT_FRAME_DROPDOWN_SUBSECTION_TITLE_INTERACT)
		GameTooltip:AddLine(hint, WHITE_FONT_COLOR:GetRGB())
		GameTooltip:Show()
	end

	function Interact:SetNamePlateShown(shown)
		if ( CPAPI.IsRetailVersion and db('trgtShowInteractNameplate') and self.plateShown ~= shown ) then
			self.plateShown = shown;
			InteractNamePlate:Set(shown)
		end
	end

	function Targeting:PLAYER_SOFT_INTERACT_CHANGED(_, guid)
		Acquire(Interact, CPAPI.Scrub(guid))
		self:RequestTooltipUpdate()
	end

	function Targeting:NAME_PLATE_UNIT_ADDED(unitID)
		self:OnTooltipPlateAdded(unitID)
		if CPAPI.Scrub(UnitIsUnit(unitID, Interact.unit)) then
			Acquire(Interact, GetUnitGUID(unitID))
			if ( Active.source == Interact ) then
				Active.guid = nil;
			end
			self:RequestTooltipUpdate()
		end
	end
end
