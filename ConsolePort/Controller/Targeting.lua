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
		trgtEnemy           = db.Data.Cvar('SoftTargetEnemy');
		trgtEnemyIcon       = db.Data.Cvar('SoftTargetIconEnemy');
		trgtEnemyPlate      = db.Data.Cvar('SoftTargetNameplateEnemy');
		trgtEnemyTooltip    = db.Data.Cvar('SoftTargetTooltipEnemy');
		trgtFriend          = db.Data.Cvar('SoftTargetFriend');
		trgtFriendIcon      = db.Data.Cvar('SoftTargetIconFriend');
		trgtFriendPlate     = db.Data.Cvar('SoftTargetNameplateFriend');
		trgtFriendTooltip   = db.Data.Cvar('SoftTargetTooltipFriend');
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

local function GetUnitNameFrame(nameplate)
	return  nameplate
		and nameplate.UnitFrame
		and nameplate.UnitFrame.name;
end

local function GetHealthBarContainers(nameplate)
	return  nameplate
		and nameplate.UnitFrame
		and nameplate.UnitFrame.HealthBarsContainer;
end

local function IsTooltipAvailable()
	return not ConsolePort:IsCursorActive()
		and (( GameTooltip:IsOwned(UIParent) or anchor and GameTooltip:IsOwned(anchor) )
		or not GameTooltip:IsVisible()
		or GameTooltip:GetAlpha() < 1);
end

local function IsTooltipOwned(unit, guid)
	return GameTooltip:IsOwned(UIParent) and GameTooltip:GetUnit() == unit and UnitGUID(unit) == guid;
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

local SetTooltipPosition;
if CPAPI.IsRetailVersion then
	function SetTooltipPosition(unit, offsetX)
		local nameplate = GetNamePlateForUnit(unit)
		anchor = GetSoftTargetIcon(nameplate)
		if anchor then
			local nameframe = GetUnitNameFrame(nameplate)
			if nameframe then
				nameframe:Hide()
			end
			local healthbars = GetHealthBarContainers(nameplate)
			if healthbars then
				healthbars:Hide()
			end
			GameTooltip:SetOwner(anchor, 'ANCHOR_NONE')
			GameTooltip:SetFrameStrata('BACKGROUND')
			GameTooltip:SetPoint('LEFT', anchor, 'RIGHT', offsetX, 0)
			if db('trgtShowMinimalInteractNamePlate') and GameTooltip.NineSlice then
				GameTooltip.NineSlice:Hide()
			end
		else
			SetDefaultAnchor()
		end
	end

	GameTooltip:HookScript('OnShow', function(self)
		-- NOTE: Setting the tooltip to a nameplate means anchoring to a restricted region,
		-- which inherently removes clamping to screen. Need to re-enable it once the
		-- tooltip is being used by something else.
		if anchor and not self:IsAnchoringRestricted() then
			self:SetClampedToScreen(true)
			self:SetFrameStrata('TOOLTIP')
			anchor = nil;
		end
	end)
else
	function SetTooltipPosition()
		SetDefaultAnchor()
	end
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
	local guid = UnitGUID(unit)
	if ( self.tooltipGUID ~= guid and db(option) and IsTooltipAvailable() ) then
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
end

---------------------------------------------------------------
-- Events
---------------------------------------------------------------
Targeting.PLAYER_SOFT_ENEMY_CHANGED  = GenerateClosure(TrySetUnitTooltip, 'trgtEnemyTooltip',  'softenemy')
Targeting.PLAYER_SOFT_FRIEND_CHANGED = GenerateClosure(TrySetUnitTooltip, 'trgtFriendTooltip', 'softfriend')

local InteractNamePlate = db.Data.Cvar('SoftTargetNameplateInteract')

local function CanInteractWithObject(guid)
	if not guid then return end;
	if guid:match('GameObject') then
		-- Can't determine interaction range for objects,
		-- so we just assume it's in range.
		return true;
	end
	-- HACK: CanLootUnit returns whether interaction is in range for all NPCs.
	return select(2, CanLootUnit(guid))
end

function Targeting:PLAYER_SOFT_INTERACT_CHANGED(_, guid)
	if not CanInteractWithObject(guid) then
		return CPAPI.IsRetailVersion and db('trgtShowInteractNameplate') and InteractNamePlate:Set(false)
	end
	if ( db:GetCVar('SoftTargetTooltipInteract', false) and IsTooltipAvailable() ) then
		self.tooltipGUID = guid;
		if CPAPI.IsRetailVersion and db('trgtShowInteractNameplate') then
			InteractNamePlate:Set(true)
		end
		if not SetTooltipToInteractUnit('anyinteract') and not SetTooltipToUnitName('anyinteract') then
			return;
		end
		AddResetUnitTooltipCallback('anyinteract', guid)

		-- Show interact hint
		if not db('trgtShowInteractHint') then return end;

		local slug = db.Hotkeys:GetButtonSlugForBinding('INTERACTTARGET', false, true)
		if not slug then return end;

		local hint = ('%s %s'):format(slug, UNIT_FRAME_DROPDOWN_SUBSECTION_TITLE_INTERACT)
		GameTooltip:AddLine(hint, WHITE_FONT_COLOR:GetRGB())
		GameTooltip:Show()
	end
end

function Targeting:NAME_PLATE_UNIT_ADDED(unitID)
	if UnitIsUnit(unitID, 'anyinteract') then
		self:PLAYER_SOFT_INTERACT_CHANGED(nil, UnitGUID(unitID))
	end
end