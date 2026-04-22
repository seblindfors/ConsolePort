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
		trgtEnemyPlate            = db.Data.Cvar('SoftTargetNameplateEnemy');
		trgtEnemyTooltip          = db.Data.Cvar('SoftTargetTooltipEnemy');
		trgtFriend                = db.Data.Cvar('SoftTargetFriend');
		trgtFriendIcon            = db.Data.Cvar('SoftTargetIconFriend');
		trgtFriendPlate           = db.Data.Cvar('SoftTargetNameplateFriend');
		trgtFriendTooltip         = db.Data.Cvar('SoftTargetTooltipFriend');
	};
}))

---------------------------------------------------------------
-- Tooltip handling
---------------------------------------------------------------
local GameTooltip, UIParent, After, UnitGUID = GameTooltip, UIParent, C_Timer.After, UnitGUID;
local SetDefaultAnchor = GenerateClosure(GameTooltip_SetDefaultAnchor, GameTooltip, UIParent);
local GetNamePlateForUnit, anchor = C_NamePlate.GetNamePlateForUnit;

local function GetSoftTargetIcon(nameplate)
	return  nameplate
		and nameplate.UnitFrame
		and nameplate.UnitFrame.SoftTargetFrame
		and nameplate.UnitFrame.SoftTargetFrame.Icon;
end

local function IsTooltipAvailable()
	return not ConsolePort:IsCursorActive()
		and (( GameTooltip:IsOwned(UIParent) or anchor and GameTooltip:IsOwned(anchor) )
		or not GameTooltip:IsVisible());
end

local function IsTooltipOwned(unit, guid)
	return GameTooltip:IsOwned(UIParent)
		and CPAPI.Scrub(GameTooltip:GetUnit()) == unit
		and CPAPI.Scrub(UnitGUID(unit)) == guid;
end

local function AddResetUnitTooltipCallback(unit, guid)
	if db:GetCVar('SoftTargetTooltipLocked', false) then return end;
	After(db:GetCVar('SoftTargetTooltipDurationMs', 2000) / 1000, function()
		if IsTooltipOwned(unit, guid) then
			GameTooltip:FadeOut()
		end
	end)
end

local function SetTooltipToUnit(unit)
	SetDefaultAnchor()
	return GameTooltip:SetUnit(unit)
end

local SetTooltipPosition, TooltipDismount;
if CPAPI.IsRetailVersion then -- interact tooltip nameplate mount
	local GET, SET, UNSET, modifiedFrames, framesToModify = 1, 2, 3, {}, {
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

	function TooltipDismount()
		for i = #modifiedFrames, 1, -1 do
			local frame = modifiedFrames[i];
			if frame then framesToModify[i][UNSET](frame) end;
			modifiedFrames[i] = nil;
		end
	end

	local function TooltipMount(nameplate, tooltip)
		TooltipDismount()
		for i, element in ipairs(framesToModify) do
			local frame = element[GET](nameplate, tooltip)
			if frame then
				element[SET](frame)
				modifiedFrames[i] = frame;
			end
		end
	end

	function SetTooltipPosition(unit, offsetX)
		if UnitCanAttack('player', unit) then return SetDefaultAnchor() end;
		local nameplate, tooltip = GetNamePlateForUnit(unit), GameTooltip;
		anchor = GetSoftTargetIcon(nameplate)
		if anchor then
			tooltip:SetOwner(anchor, 'ANCHOR_NONE')
			tooltip:ClearAllPoints()
			tooltip:SetPoint('LEFT', anchor, 'RIGHT', offsetX, 0)
			return TooltipMount(nameplate, tooltip)
		end
		SetDefaultAnchor()
	end

	GameTooltip:HookScript('OnHide', TooltipDismount)
else
	TooltipDismount, SetTooltipPosition = nop, SetDefaultAnchor;
end

local function SetTooltipToInteractUnit(unit)
	SetTooltipPosition(unit, 10)
	return GameTooltip:SetUnit(unit)
end

local function SetTooltipToUnitName(unit)
	local name = UnitName(unit)
	if not name then return false end;
	SetTooltipPosition(unit, 0)
	GameTooltip:SetText(name, NORMAL_FONT_COLOR:GetRGB())
	GameTooltip:Show()
	return true;
end

local function TrySetUnitTooltip(option, unit, self)
	local guid = CPAPI.Scrub(UnitGUID(unit))
	if ( guid and self.tooltipGUID ~= guid and db(option) and IsTooltipAvailable() ) then
		self.tooltipGUID = guid;
		SetTooltipToUnit(unit)
		AddResetUnitTooltipCallback(unit, guid)
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
do -- Interact tooltip and nameplate handling
---------------------------------------------------------------
	local InteractNamePlate, interactID, currentGUID = db.Data.Cvar('SoftTargetNameplateInteract'), 'anyinteract';

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
		TooltipDismount()
		if not CanInteractWithObject(currentGUID) then
			return CPAPI.IsRetailVersion and db('trgtShowInteractNameplate') and InteractNamePlate:Set(false)
		end
		if ( db:GetCVar('SoftTargetTooltipInteract', false) and IsTooltipAvailable() ) then
			self.tooltipGUID = currentGUID;
			if CPAPI.IsRetailVersion and db('trgtShowInteractNameplate') then
				InteractNamePlate:Set(true)
			end
			if not UnitIsPlayer(interactID) and not SetTooltipToInteractUnit(interactID) and not SetTooltipToUnitName(interactID) then
				return;
			end
			AddResetUnitTooltipCallback(interactID, currentGUID)

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
		if CPAPI.Scrub(UnitIsUnit(unitID, interactID)) then
			currentGUID = UnitGUID(unitID)
			self:UpdateInteractTooltip()
		end
	end
end