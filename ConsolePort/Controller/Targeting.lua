---------------------------------------------------------------
-- Targeting
---------------------------------------------------------------

local _, db = ...;
local Targeting = db:Register('Targeting', CPAPI.CreateEventHandler({'Frame', '$parentTargetingHandler', ConsolePort}, {
	'PLAYER_ENTERING_WORLD';
	'PLAYER_TARGET_CHANGED';
	'UPDATE_MOUSEOVER_UNIT';
	'CVAR_UPDATE';
	'NAME_PLATE_UNIT_REMOVED';
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
	};
}))

---------------------------------------------------------------
-- World tooltip sources
---------------------------------------------------------------
local GameTooltip, UnitGUID = GameTooltip, UnitGUID;
local worldTooltip;
local interact = { unit = 'anyinteract'; cvar = 'SoftTargetTooltipInteract' };
local enemy = { unit = 'softenemy'; cvar = 'SoftTargetTooltipEnemy' };
local friend = { unit = 'softfriend'; cvar = 'SoftTargetTooltipFriend' };
local softTargets, timedSources = {enemy, friend}, {interact, enemy, friend};
local interactPlate = db.Data.Cvar('SoftTargetNameplateInteract');
local activeUnit, activeIdentity, timer, wasLocked, refreshDisplay;
local fadeOut, nativeHoverGUID, sharedFading;
local aimHeld, aimReleasedAt; -- aimHeld is false during release and nil after the final pick.
local targetRevision, hoverRevision = 0, 0;

local function Acquire(source, guid)
	source.dataUnavailable = nil;
	if source.guid ~= guid then
		source.guid = guid;
		source.acquiredAt = GetTime();
	end
end

local function GetTimeRemaining(source, now, duration, locked)
	if source.guid and db:GetCVar(source.cvar, false) then
		return locked and math.huge or (source.acquiredAt + duration - now);
	end
	return 0;
end

local function InInteractRange(guid)
	if guid:match('GameObject') then return true end; -- No range API for world objects.
	return CPAPI.Scrub(select(2, CanLootUnit(guid)));
end

---------------------------------------------------------------
-- Retail nameplate presentation
---------------------------------------------------------------
local mountedPlate, previousStrata, requestedPlate;
local hiddenRegions = {};

local function RestoreNameplate()
	if not mountedPlate then return end;
	for i, region in ipairs(hiddenRegions) do
		if not CPAPI.IsObjectRestricted(region) then region:Show() end;
	end
	wipe(hiddenRegions)
	worldTooltip:SetFrameStrata(previousStrata)
	mountedPlate, previousStrata = nil, nil;
end

local function HideRegion(region)
	if region and not CPAPI.IsObjectRestricted(region) and region:IsShown() then
		hiddenRegions[#hiddenRegions + 1] = region;
		region:Hide()
	end
end

local function AnchorTooltip(tooltip, unit)
	GameTooltip_SetDefaultAnchor(tooltip, Targeting)
	if unit ~= interact.unit or not CPAPI.IsRetailVersion or not db('trgtShowInteractNameplate')
		or CPAPI.Scrub(UnitCanAttack('player', unit)) then return end;
	local plate = C_NamePlate.GetNamePlateForUnit(unit);
	if not plate or CPAPI.IsObjectRestricted(plate) then return end;
	local frame = plate.UnitFrame;
	if not frame or CPAPI.IsObjectRestricted(frame) then return end;
	local anchor = frame.SoftTargetFrame and frame.SoftTargetFrame.Icon;
	if not anchor or CPAPI.IsObjectRestricted(anchor) then return end;
	mountedPlate, previousStrata = plate, tooltip:GetFrameStrata();
	tooltip:ClearAllPoints()
	tooltip:SetPoint('LEFT', anchor, 'RIGHT', 10, 0)
	tooltip:SetFrameStrata('BACKGROUND')
	HideRegion(frame.name)
	HideRegion(frame.HealthBarsContainer)
	if db('trgtShowMinimalInteractNamePlate') then HideRegion(tooltip.NineSlice) end;
end

local function RequestNameplate(show)
	if not CPAPI.IsRetailVersion then return end;
	if show and db('trgtShowInteractNameplate') then
		if not requestedPlate and not interactPlate:Get(true) then
			requestedPlate = true;
			interactPlate:Set(true)
		end
	elseif requestedPlate then
		requestedPlate = nil;
		interactPlate:Set(false)
	end
end

-- Check the rendered GUID as well as the unit token. A tooltip post-call can
-- replace the shared tooltip while SetUnit is still running.
local function GetDisplayedGUID(tooltip)
	if tooltip.GetPrimaryTooltipData then
		local data = CPAPI.Scrub(tooltip:GetPrimaryTooltipData());
		return data and CPAPI.Scrub(data.guid);
	end
	local _, unit = tooltip:GetUnit();
	unit = CPAPI.Scrub(unit);
	return unit and CPAPI.Scrub(UnitGUID(unit));
end

local function AddInteractHint(tooltip)
	if db('trgtShowInteractHint') and not CPAPI.Scrub(UnitCanAttack('player', interact.unit)) then
		local slug = db.Hotkeys:GetButtonSlugForBinding('INTERACTTARGET', false, true)
		if slug then
			tooltip:AddLine(slug..' '..UNIT_FRAME_DROPDOWN_SUBSECTION_TITLE_INTERACT, WHITE_FONT_COLOR:GetRGB())
		end
	end
end

-- Retail clears the lines on every tooltip data rebuild, even if the owner stays the same.
local addTooltipPostCall = CPAPI.IsRetailVersion and TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall;
if addTooltipPostCall then
	local function OnWorldTooltip(frame, data)
		if (frame ~= GameTooltip and frame ~= worldTooltip) or frame:IsForbidden() then return end;
		data = CPAPI.Scrub(data);
		if not data or CPAPI.Scrub(frame:GetPrimaryTooltipData()) ~= data then return end;
		local guid = CPAPI.Scrub(data.guid);
		if not guid then return end;
		if frame == GameTooltip and frame:IsOwned(UIParent) then
			-- Blizzard can restore a soft target in the same visible tooltip after mouseout.
			if guid == interact.guid or guid == enemy.guid or guid == friend.guid then Targeting:RequestTooltipUpdate() end;
		elseif guid == interact.guid and frame:IsOwned(Targeting) and activeUnit == interact.unit
			and activeIdentity == guid and CPAPI.Scrub(UnitGUID(interact.unit)) == guid then
			AddInteractHint(frame)
		end
	end
	addTooltipPostCall(Enum.TooltipDataType.Unit, OnWorldTooltip)
	addTooltipPostCall(Enum.TooltipDataType.Object, OnWorldTooltip)
end

local function ShowUnit(tooltip, unit, identity)
	if unit == interact.unit and CPAPI.Scrub(UnitGUID(unit)) ~= identity then return false end;
	AnchorTooltip(tooltip, unit)
	tooltip:ClearLines()
	tooltip:SetUnit(unit)
	if unit ~= interact.unit then return end;

	local nameOnly = not tooltip:IsShown();
	if nameOnly then
		local name = CPAPI.Scrub(UnitName(unit));
		if not name or CPAPI.Scrub(UnitGUID(unit)) ~= identity then return false end;
		if tooltip.ClearHandlerInfo then tooltip:ClearHandlerInfo() end;
		RestoreNameplate()
		AnchorTooltip(tooltip, unit)
		tooltip:ClearLines()
		tooltip:SetText(name, NORMAL_FONT_COLOR:GetRGB())
		tooltip:Show()
	end
	if not tooltip:IsOwned(Targeting) or CPAPI.Scrub(UnitGUID(unit)) ~= identity then return end;
	local displayed = GetDisplayedGUID(tooltip);
	if displayed and displayed ~= identity then return false end;
	if not nameOnly and not displayed then return end;
	if nameOnly or not addTooltipPostCall then
		AddInteractHint(tooltip)
		tooltip:Show()
	end
end

---------------------------------------------------------------
-- Select the highest eligible source. Timed sources keep their acquisition
-- time while covered. The hard target and reticle have no expiry.
---------------------------------------------------------------
local function GetTooltipUnit(now, duration, locked)
	if aimHeld and db('trgtAimTooltip') and CPAPI.Scrub(UnitExists('target')) then return 'target', targetRevision end;
	local left = GetTimeRemaining(interact, now, duration, locked);
	local available = left > 0 and CPAPI.Scrub(UnitGUID(interact.unit)) == interact.guid and InInteractRange(interact.guid);
	-- NPCs can cross the interaction range without changing soft targets.
	local delay;
	if left > 0 and not interact.guid:match('GameObject') then delay = math.min(left, 0.2) end;
	if not available then
		interact.dataUnavailable = nil;
	elseif not interact.dataUnavailable then
		return interact.unit, interact.guid, delay or left;
	end
	if db.Mouse.mouseOverGUID and CPAPI.Scrub(UnitExists('mouseover')) then
		return 'mouseover', db.Mouse.mouseOverGUID == true and hoverRevision or db.Mouse.mouseOverGUID, delay;
	end
	if db('trgtHardTooltip') and CPAPI.Scrub(UnitExists('target')) then return 'target', targetRevision, delay end;
	if (aimHeld ~= nil or aimReleasedAt) and db('trgtAimTooltip') and CPAPI.Scrub(UnitExists('target')) then
		left = (aimHeld ~= nil or locked) and math.huge or (aimReleasedAt + duration - now);
		if left > 0 then return 'target', targetRevision, math.min(delay or math.huge, left) end;
	end
	for _, source in ipairs(softTargets) do
		left = GetTimeRemaining(source, now, duration, locked);
		if left > 0 then
			return source.unit, source.guid, math.min(delay or math.huge, left);
		end
	end
	return nil, nil, delay;
end

local function IsSoftTargetUnit(unit)
	return unit == interact.unit or unit == 'softinteract' or unit == enemy.unit or unit == friend.unit;
end

local function ShouldPreserveGameTooltip(candidate, identity)
	if not GameTooltip:IsVisible() or GameTooltip:IsOwned(Targeting) then return false end;
	-- Blizzard can also show the native soft-target tooltip on the world frame.
	if GameTooltip:IsOwned(UIParent) then
		-- The native world tooltip can take over the same NPC or object on mouse hover.
		if addTooltipPostCall then
			local info = CPAPI.Scrub(GameTooltip:GetPrimaryTooltipInfo());
			local getter = info and CPAPI.Scrub(info.getterName);
			if getter == 'GetWorldCursor' then
				if candidate == interact.unit and GetDisplayedGUID(GameTooltip) == identity then return false end;
				local data = CPAPI.Scrub(GameTooltip:GetPrimaryTooltipData());
				if not data or CPAPI.Scrub(data.type) ~= Enum.TooltipDataType.Unit then return true end;
			elseif getter == 'GetUnit' then
				local args = CPAPI.Scrub(info.getterArgs);
				local unit = args and CPAPI.Scrub(args[1]);
				if IsSoftTargetUnit(unit) then return false end;
			end
		end
		local _, unit = GameTooltip:GetUnit()
		unit = CPAPI.Scrub(unit);
		if IsGamePadFreelookEnabled() and IsSoftTargetUnit(unit) then
			return false;
		end
		-- A native tooltip can resolve a soft target to its nameplate or selected unit.
		if (IsGamePadFreelookEnabled() or WorldFrame:IsMouseMotionFocus())
			and not CPAPI.Scrub(UnitExists('mouseover')) then
			if unit and candidate and CPAPI.Scrub(UnitIsUnit(unit, candidate)) then return false end;
			if unit and db('trgtHardTooltip') and CPAPI.Scrub(UnitIsUnit(unit, 'target')) then return false end;
			local guid = GetDisplayedGUID(GameTooltip);
			if guid then
				for _, source in ipairs(timedSources) do
					if guid == source.guid or (activeUnit == source.unit and guid == activeIdentity) then return false end;
				end
			end
		end
	end
	return true;
end

function Targeting:IsShowingInteract()
	return activeUnit == interact.unit and worldTooltip and worldTooltip:IsShown() and not fadeOut:IsPlaying();
end

-- Automatic tooltips use their own frame so Blizzard's world-cursor timer
-- cannot hide them mid-fade. Stop the animation when a new source takes over.
local function GetWorldTooltip()
	if not worldTooltip then
		worldTooltip = CreateFrame('GameTooltip', 'ConsolePortHardTargetTooltip', UIParent, 'GameTooltipTemplate')
		fadeOut = worldTooltip:CreateAnimationGroup()
		local alpha = fadeOut:CreateAnimation('Alpha')
		alpha:SetFromAlpha(1)
		alpha:SetToAlpha(0)
		alpha:SetDuration(0.2)
		fadeOut:SetScript('OnFinished', function()
			Targeting:RefreshTooltip(true)
		end)
	end
	return worldTooltip;
end

-- A disappearing world tooltip fades even when its target is lost before expiry.
-- A new interaction or deliberate hover can still take over immediately.
local function ShouldFade(unit, now, duration, locked)
	if not activeUnit or activeUnit == unit then return false end;
	if not unit then return true end;
	if unit == 'mouseover' or unit == interact.unit then return false end;
	if unit == 'target' and aimHeld and db('trgtAimTooltip') then return false end;
	if activeUnit == 'target' and aimReleasedAt then return not locked and now >= aimReleasedAt + duration end;
	for _, source in ipairs(timedSources) do
		if activeUnit == source.unit then
			return source == interact or GetTimeRemaining(source, now, duration, locked) <= 0;
		end
	end
	return false;
end

local function FadeSharedTooltip()
	if not sharedFading then
		sharedFading = true;
		GameTooltip:FadeOut()
	end
end

function Targeting:RefreshTooltip(fadeFinished)
	if timer then timer:Cancel(); timer = nil end;
	local locked = db:GetCVar('SoftTargetTooltipLocked', false);
	local now = GetTime();
	local duration = db:GetCVar('SoftTargetTooltipDurationMs', 2000) / 1000;
	if wasLocked and not locked then
		if aimReleasedAt then aimReleasedAt = now end;
		for _, source in ipairs(timedSources) do
			if source.guid then source.acquiredAt = now end;
		end
	end
	wasLocked = locked;
	local unit, identity, delay;
	local cursorActive = ConsolePort:IsCursorActive();
	if not cursorActive then
		unit, identity, delay = GetTooltipUnit(now, duration, locked)
	end
	local preserveGameTooltip = ShouldPreserveGameTooltip(unit, identity);
	-- Let a real mouse hover finish fading if the same unit is also a soft target.
	if GameTooltip:IsShown() and GameTooltip:IsOwned(UIParent) then
		local guid = GetDisplayedGUID(GameTooltip);
		if guid and preserveGameTooltip and guid == CPAPI.Scrub(UnitGUID('mouseover')) then
			nativeHoverGUID, sharedFading = guid, nil;
		elseif guid and guid == nativeHoverGUID and not unit then
			FadeSharedTooltip()
			preserveGameTooltip = true;
		else
			nativeHoverGUID, sharedFading = nil, nil;
		end
	end
	if preserveGameTooltip then unit, identity, delay = nil, nil, nil end;
	if delay and delay < math.huge then
		timer = C_Timer.NewTimer(delay, function() self:RequestTooltipUpdate() end)
	end
	if not fadeFinished and not preserveGameTooltip and worldTooltip and worldTooltip:IsShown() and ShouldFade(unit, now, duration, locked) then
		if GameTooltip:IsShown() then GameTooltip:Hide() end;
		if not fadeOut:IsPlaying() then fadeOut:Play() end;
		return;
	end
	if aimReleasedAt and not locked and now >= aimReleasedAt + duration then aimReleasedAt = nil end;
	if fadeOut and fadeOut:IsPlaying() then fadeOut:Stop() end;
	RequestNameplate(unit == interact.unit)
	local display = GameTooltip;
	if unit and unit ~= 'mouseover' then
		display = GetWorldTooltip()
		if GameTooltip:IsShown() then GameTooltip:Hide() end;
	elseif worldTooltip and worldTooltip:IsShown() then
		RestoreNameplate()
		worldTooltip:Hide()
	end
	if not unit and not preserveGameTooltip and display:IsOwned(self) and display:IsShown() then
		-- The shared tooltip handles reticle hover. Start its native fade once.
		activeUnit, activeIdentity = nil, nil;
		FadeSharedTooltip()
		return;
	end
	if not refreshDisplay and unit and unit == activeUnit and identity == activeIdentity and display:IsOwned(self) and display:IsShown() then return end;
	refreshDisplay = nil;
	RestoreNameplate()
	if display:IsOwned(self) or (not preserveGameTooltip and display:IsVisible() and not cursorActive) then display:Hide() end;
	activeUnit, activeIdentity = unit, identity;
	if unit and ShowUnit(display, unit, identity) == false then
		-- Wait for fresh interact data or range re-entry before retrying this unit.
		if interact.guid == identity then interact.dataUnavailable = true end;
		activeUnit, activeIdentity = nil, nil;
		RestoreNameplate()
		if display:IsOwned(self) then display:Hide() end;
		self:RequestTooltipUpdate()
	end
end

Targeting.RequestTooltipUpdate = CPAPI.Debounce(Targeting.RefreshTooltip, Targeting);

local function Invalidate()
	interact.dataUnavailable = nil;
	refreshDisplay = true;
	Targeting:RequestTooltipUpdate()
end

GameTooltip:HookScript('OnShow', function()
	if GameTooltip:IsOwned(UIParent) or (worldTooltip and worldTooltip:IsShown()) then Targeting:RequestTooltipUpdate() end;
end)
GameTooltip:HookScript('OnHide', function()
	nativeHoverGUID, sharedFading = nil, nil;
	Targeting:RequestTooltipUpdate()
end)
hooksecurefunc(GameTooltip, 'SetOwner', function()
	nativeHoverGUID, sharedFading = nil, nil;
	if activeUnit and not GameTooltip:IsOwned(Targeting) then
		Targeting:RequestTooltipUpdate()
	end
end)

---------------------------------------------------------------
-- Target, cursor and setting changes
---------------------------------------------------------------
-- The binding can pick its final unit on release. Keep accepting picks until
-- next frame, then start the normal tooltip duration for that target only.
function Targeting:OnAimHold(held)
	if held then
		aimHeld, aimReleasedAt = true, nil;
		self:RequestTooltipUpdate()
	elseif aimHeld then
		aimHeld = false;
		RunNextFrame(function()
			if aimHeld ~= false then return end;
			aimHeld = nil;
			if db('trgtAimTooltip') and CPAPI.Scrub(UnitExists('target')) then aimReleasedAt = GetTime() end;
			self:RequestTooltipUpdate()
		end)
	end
end

function Targeting:PLAYER_TARGET_CHANGED()
	aimReleasedAt = nil;
	targetRevision = targetRevision + 1;
	self:RequestTooltipUpdate()
end

function Targeting:UPDATE_MOUSEOVER_UNIT()
	hoverRevision = hoverRevision + 1;
	db.Mouse:UpdateReticle()
	self:RequestTooltipUpdate()
end

function Targeting:PLAYER_SOFT_INTERACT_CHANGED(_, guid)
	Acquire(interact, CPAPI.Scrub(guid))
	self:RequestTooltipUpdate()
end

local function SoftTargetChanged(source)
	Acquire(source, CPAPI.Scrub(UnitGUID(source.unit)))
	Targeting:RequestTooltipUpdate()
end

Targeting.PLAYER_SOFT_ENEMY_CHANGED = GenerateClosure(SoftTargetChanged, enemy);
Targeting.PLAYER_SOFT_FRIEND_CHANGED = GenerateClosure(SoftTargetChanged, friend);

function Targeting:PLAYER_ENTERING_WORLD()
	aimHeld, aimReleasedAt = nil, nil;
	activeUnit, activeIdentity = nil, nil;
	for _, source in ipairs(timedSources) do
		-- anyinteract can resolve to the hard target even without an interaction.
		local unit = source == interact and 'softinteract' or source.unit;
		source.guid = nil;
		Acquire(source, CPAPI.Scrub(UnitGUID(unit)))
	end
	self:PLAYER_TARGET_CHANGED()
end

function Targeting:NAME_PLATE_UNIT_ADDED(unit)
	local guid = CPAPI.Scrub(UnitGUID(unit));
	if guid and (guid == interact.guid or CPAPI.Scrub(UnitIsUnit(unit, 'softinteract'))) then
		Acquire(interact, guid)
		Invalidate()
	end
end

function Targeting:NAME_PLATE_UNIT_REMOVED(unit)
	if mountedPlate and (CPAPI.Scrub(mountedPlate.namePlateUnitToken) == unit or not C_NamePlate.GetNamePlateForUnit(interact.unit)) then
		-- Detach before WoW recycles the plate. Keep the outgoing tooltip in place during its fade.
		local frame, x, y = worldTooltip;
		if not CPAPI.IsObjectRestricted(frame) and CPAPI.Scrub(frame:IsAnchoringRestricted()) == false then
			x, y = CPAPI.Scrub(frame:GetCenter());
		end
		RestoreNameplate()
		frame:ClearAllPoints()
		if x and y then
			frame:SetPoint('CENTER', UIParent, 'BOTTOMLEFT', x, y)
		else
			GameTooltip_SetDefaultAnchor(frame, self)
		end
		Invalidate()
	end
end

local function OnTooltipCVarChanged(name)
	if type(name) == 'string' and name:lower():match('^softtargettooltip') then
		Targeting:RequestTooltipUpdate()
	end
end

function Targeting:CVAR_UPDATE(name)
	OnTooltipCVarChanged(name)
end

-- Imports and other addons can write CVars directly through either Lua API.
hooksecurefunc('SetCVar', OnTooltipCVarChanged)
if C_CVar and C_CVar.SetCVar then hooksecurefunc(C_CVar, 'SetCVar', OnTooltipCVarChanged) end

for varID, proxy in pairs(Targeting.DirectProxy) do
	db:RegisterCallback('Settings/'..varID, function(_, ...)
		proxy:Set(...)
		Targeting:RequestTooltipUpdate()
	end, Targeting)
end

db:RegisterCallback('OnAimHold', Targeting.OnAimHold, Targeting)
db:RegisterCallback('Settings/trgtAimTooltip', function()
	aimReleasedAt = nil;
	Targeting:RequestTooltipUpdate()
end, Targeting)
db:RegisterCallbacks(Invalidate, Targeting, 'Settings/trgtHardTooltip', 'Settings/trgtShowInteractHint',
	'Settings/trgtShowInteractNameplate', 'Settings/trgtShowMinimalInteractNamePlate')
db:RegisterCallbacks(function() Targeting:RequestTooltipUpdate() end, Targeting,
	'OnCursorShow', 'OnCursorHide', 'OnNativeNavigationChanged', 'SoftTargetTooltipLocked',
	'SoftTargetTooltipDurationMs', 'SoftTargetTooltipInteract')

function Targeting:OnDataLoaded()
	for varID, proxy in pairs(self.DirectProxy) do
		proxy:Set(db(varID))
	end
	return CPAPI.BurnAfterReading;
end
