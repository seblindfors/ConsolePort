---------------------------------------------------------------
-- Targeting
---------------------------------------------------------------
-- Handles targeting settings.

local _, db = ...;
local Targeting = db:Register('Targeting', CPAPI.CreateEventHandler({'Frame', '$parentTargetingHandler', ConsolePort}, {
	'PLAYER_SOFT_ENEMY_CHANGED';
	'PLAYER_SOFT_FRIEND_CHANGED';
	'PLAYER_SOFT_INTERACT_CHANGED';
}, {
	Proxy = {
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
local SetDefaultAnchor, plate = GameTooltip_SetDefaultAnchor;

local function IsTooltipAvailable()
	return not ConsolePort:IsCursorActive()
		and (( GameTooltip:IsOwned(UIParent) or plate and GameTooltip:IsOwned(plate) )
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
	SetDefaultAnchor(GameTooltip, UIParent)
	return GameTooltip:SetUnit(unit)
end

local function SetTooltipToUnitName(unit)
	local name = UnitName(unit)
	if not name then return false end;
	plate = C_NamePlate.GetNamePlateForUnit(unit)
	if plate then
		if db('trgtShowInteractHint') then
			GameTooltip:SetOwner(plate, 'ANCHOR_NONE')
			GameTooltip:SetPoint('BOTTOMLEFT', plate, 'CENTER', 20, 10)
		else
			GameTooltip:SetOwner(plate, 'ANCHOR_NONE')
			GameTooltip:SetPoint('CENTER', plate, 'CENTER', 0, 0)
		end
		if GameTooltip.NineSlice then
			GameTooltip.NineSlice:Hide()
		end
	else
		SetDefaultAnchor(GameTooltip, UIParent)
	end
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
-- Proxy updates
---------------------------------------------------------------
for varID, proxy in pairs(Targeting.Proxy) do
	db:RegisterCallback('Settings/'..varID, function(_, ...) proxy:Set(...) end, Targeting)
end

---------------------------------------------------------------
-- Data loading
---------------------------------------------------------------
function Targeting:OnDataLoaded()
	for varID, proxy in pairs(self.Proxy) do
		proxy:Set(db(varID))
	end
end

---------------------------------------------------------------
-- Events
---------------------------------------------------------------
Targeting.PLAYER_SOFT_ENEMY_CHANGED  = GenerateClosure(TrySetUnitTooltip, 'trgtEnemyTooltip',  'softenemy')
Targeting.PLAYER_SOFT_FRIEND_CHANGED = GenerateClosure(TrySetUnitTooltip, 'trgtFriendTooltip', 'softfriend')

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
	if not CanInteractWithObject(guid) then return end;
	if ( db:GetCVar('SoftTargetTooltipInteract', false) and IsTooltipAvailable() ) then
		self.tooltipGUID = guid;
		if not SetTooltipToUnit('anyinteract') and not SetTooltipToUnitName('anyinteract') then
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