---------------------------------------------------------------
-- Targeting
---------------------------------------------------------------
-- Handles targeting settings.

local _, db = ...;
local Targeting = db:Register('Targeting', CPAPI.CreateEventHandler({'Frame', '$parentTargetingHandler', ConsolePort}, {
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
local Shown, isMounted = { owner = UIParent };

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
	GameTooltip_SetDefaultAnchor(GameTooltip, Shown.owner)
end

local function Place(unit, guid, plate, owner)
	Shown.unit, Shown.guid, Shown.plate, Shown.owner = unit, guid, plate, owner or UIParent;
	SetDefaultAnchor()
	Mount()
end

local function ShowUnit(unit, guid, plate, owner)
	Place(unit, guid, plate, owner)
	return GameTooltip:SetUnit(unit)
end

local function IsShownUnit(unitID)
	local guid = Shown.guid;
	return guid and GetUnitGUID(unitID) == guid;
end

GameTooltip:HookScript('OnHide', Detach)
hooksecurefunc(GameTooltip, 'SetOwner', Detach)

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
-- Ownership and fading
---------------------------------------------------------------
local function IsTooltipAvailable(owner)
	return not ConsolePort:IsCursorActive()
		and ( GameTooltip:IsOwned(owner or UIParent)
		or not GameTooltip:IsVisible()
		or GameTooltip:GetAlpha() < 1 );
end

local focusTimer;
local function ShowUnitWhenFocused(unit, guid, owner)
	local plate = GetUnitPlate()
	local delay = plate and db('trgtTooltipDelay') or 0;
	if focusTimer then
		focusTimer = focusTimer:Cancel()
	end
	if ( delay <= 0 ) then
		return ShowUnit(unit, guid, plate, owner)
	end
	if ( Shown.guid ~= guid and GameTooltip:IsOwned(Shown.owner) ) then
		GameTooltip:Hide()
	end
	focusTimer = C_Timer.NewTimer(delay, function()
		focusTimer = nil;
		if ( GetUnitGUID(unit) == guid and IsTooltipAvailable(owner) ) then
			ShowUnit(unit, guid, plate, owner)
		end
	end)
end

function Targeting:ShowUnitTooltip(unit, guid, owner)
	return ShowUnitWhenFocused(unit, guid, owner)
end

local function IsUnitTooltipOwned(unit, guid)
	return GameTooltip:IsOwned(UIParent)
		and CPAPI.Scrub(GameTooltip:GetUnit()) == unit
		and GetUnitGUID(unit) == guid;
end

local function FadeLater(isStillOwned)
	if db:GetCVar('SoftTargetTooltipLocked', false) then return end;
	After(db:GetCVar('SoftTargetTooltipDurationMs', 2000) / 1000, function()
		if isStillOwned() then
			GameTooltip:FadeOut()
		end
	end)
end

local function TrySetUnitTooltip(option, unit, self)
	local guid = GetUnitGUID(unit)
	if ( guid and self.tooltipGUID ~= guid and db(option) and IsTooltipAvailable() ) then
		self.tooltipGUID = guid;
		ShowUnitWhenFocused(unit, guid)
		FadeLater(GenerateClosure(IsUnitTooltipOwned, unit, guid))
	end
end

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
Targeting.PLAYER_SOFT_ENEMY_CHANGED  = GenerateClosure(TrySetUnitTooltip, 'trgtEnemyTooltip',  'softenemy')
Targeting.PLAYER_SOFT_FRIEND_CHANGED = GenerateClosure(TrySetUnitTooltip, 'trgtFriendTooltip', 'softfriend')

---------------------------------------------------------------
do -- Aim hold tooltip
---------------------------------------------------------------
	local AIM_UNIT, AIM_EVENT = 'target', 'PLAYER_TARGET_CHANGED';

	local function IsAimTooltipOwned(self, guid)
		return not self.aimHeld
			and self.tooltipGUID == guid
			and GameTooltip:IsOwned(UIParent);
	end

	local function OnAimReleased()
		local self, guid = Targeting, Targeting.aimTooltipGUID;
		if self.aimHeld then return end;
		self:UnregisterEvent(AIM_EVENT)
		self.aimTooltipGUID = nil;
		if guid then
			FadeLater(GenerateClosure(IsAimTooltipOwned, self, guid))
		end
	end

	function Targeting:PLAYER_TARGET_CHANGED()
		local guid = GetUnitGUID(AIM_UNIT)
		if ( guid and self.tooltipGUID ~= guid and IsTooltipAvailable() ) then
			self.tooltipGUID, self.aimTooltipGUID = guid, guid;
			ShowUnitWhenFocused(AIM_UNIT, guid)
		end
	end

	function Targeting:OnAimHold(held)
		self.aimHeld = held;
		if not held then
			return RunNextFrame(OnAimReleased);
		end
		if db('trgtAimTooltip') then
			self.tooltipGUID = nil;
			self:RegisterEvent(AIM_EVENT)
		end
	end

	db:RegisterCallback('OnAimHold', Targeting.OnAimHold, Targeting)
end

---------------------------------------------------------------
do -- Interact tooltip and nameplate handling
---------------------------------------------------------------
	local InteractNamePlate, interactID, currentGUID = db.Data.Cvar('SoftTargetNameplateInteract'), 'anyinteract';
	local UNIT_PLATE = { anchor = 'Icon'; offset = 10; decorate = true };
	local NAME_PLATE = { anchor = 'Icon'; offset = 0;  decorate = true };

	local function GetInteractPlate(plate)
		return CPAPI.IsRetailVersion and not UnitCanAttack('player', interactID) and plate or nil;
	end

	local function SetTooltipToInteractUnit()
		return ShowUnit(interactID, currentGUID, GetInteractPlate(UNIT_PLATE))
	end

	local function SetTooltipToUnitName()
		local name = UnitName(interactID)
		if not name then return false end;
		Place(interactID, currentGUID, GetInteractPlate(NAME_PLATE))
		GameTooltip:SetText(name, NORMAL_FONT_COLOR:GetRGB())
		GameTooltip:Show()
		return true;
	end

	local function CanInteractWithObject(guid)
		if not CPAPI.Scrub(guid) then return end;
		if guid:match('GameObject') then
			-- Can't determine interaction range for objects,
			-- so we just assume it's in range.
			return true;
		end
		-- HACK: CanLootUnit returns whether interaction is in range for all NPCs.
		return select(2, CanLootUnit(guid))
	end

	Targeting.UpdateInteractTooltip = CPAPI.Debounce(function(self)
		Undecorate()
		if not CanInteractWithObject(currentGUID) then
			return CPAPI.IsRetailVersion and db('trgtShowInteractNameplate') and InteractNamePlate:Set(false)
		end
		if ( db:GetCVar('SoftTargetTooltipInteract', false) and IsTooltipAvailable() ) then
			self.tooltipGUID = currentGUID;
			if CPAPI.IsRetailVersion and db('trgtShowInteractNameplate') then
				InteractNamePlate:Set(true)
			end
			if not UnitIsPlayer(interactID) and not SetTooltipToInteractUnit() and not SetTooltipToUnitName() then
				return;
			end
			FadeLater(GenerateClosure(IsUnitTooltipOwned, interactID, currentGUID))

			-- Show interact hint
			if not db('trgtShowInteractHint') or UnitCanAttack('player', interactID) then return end;

			local slug = db.Hotkeys:GetButtonSlugForBinding('INTERACTTARGET', false, true)
			if not slug then return end;

			local hint = ('%s %s'):format(slug, UNIT_FRAME_DROPDOWN_SUBSECTION_TITLE_INTERACT)
			GameTooltip:AddLine(hint, WHITE_FONT_COLOR:GetRGB())
			GameTooltip:Show()
		end
	end, Targeting)

	function Targeting:PLAYER_SOFT_INTERACT_CHANGED(_, guid)
		currentGUID = CPAPI.Scrub(guid)
		self:UpdateInteractTooltip()
	end

	function Targeting:NAME_PLATE_UNIT_ADDED(unitID)
		self:OnTooltipPlateAdded(unitID)
		if CPAPI.Scrub(UnitIsUnit(unitID, interactID)) then
			currentGUID = UnitGUID(unitID)
			self:UpdateInteractTooltip()
		end
	end
end
