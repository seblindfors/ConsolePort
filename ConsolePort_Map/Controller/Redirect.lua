local env, db, _, L = CPAPI.GetEnv(...);
local InCombatLockdown = InCombatLockdown;
---------------------------------------------------------------
-- Redirect: bindings and Blizzard's own map opens
---------------------------------------------------------------
-- The world map binding is overridden to our toggle while the module
-- is enabled. Blizzard's own opens of WorldMapFrame (tracker clicks)
-- can optionally be turned into ours; HideUIPanel is dispatched through
-- FramePositionDelegate attributes and is safe from insecure code, but
-- refuses in combat, so the default map stays a working fallback.
local Redirect = CPAPI.CreateEventHandler({'Frame', '$parentMapRedirect', ConsolePort}, {
	'PLAYER_REGEN_ENABLED';
}); env.Redirect = Redirect;

local Toggle = ConsolePortMapToggle;
local TOGGLE_CLICK = ('CLICK %s:LeftButton'):format(Toggle:GetName());

---------------------------------------------------------------
-- Binding override
---------------------------------------------------------------
function Redirect:UpdateBindings()
	if InCombatLockdown() then
		self.pendingBindings = true;
		return
	end
	self.pendingBindings = nil;
	ClearOverrideBindings(Toggle)
	if not (db('mapEnable') and db('mapReplaceBinding')) then return end
	for _, key in ipairs(db.Gamepad:GetBindingKey('TOGGLEWORLDMAP', true)) do
		SetOverrideBinding(Toggle, false, key, TOGGLE_CLICK)
	end
end

function Redirect:PLAYER_REGEN_ENABLED()
	if self.pendingBindings then
		self:UpdateBindings()
	end
end

---------------------------------------------------------------
-- Blizzard map opens
---------------------------------------------------------------
local function OnWorldMapShown()
	local Map = env.Map;
	if not db('mapEnable') then return end
	if db('mapRedirectBlizzard') and not InCombatLockdown() then
		C_Timer.After(0, function()
			if not WorldMapFrame:IsShown() or InCombatLockdown() then return end
			HideUIPanel(WorldMapFrame)
			if not WorldMapFrame:IsShown() then
				Map:OpenPlayerMap()
			end
		end)
	elseif Map:IsShown() then
		Map:Hide()
	end
end

if WorldMapFrame then
	WorldMapFrame:HookScript('OnShow', OnWorldMapShown)
end

---------------------------------------------------------------
-- Data
---------------------------------------------------------------
function Redirect:OnDataLoaded()
	db:RegisterCallbacks(self.UpdateBindings, self,
		'OnNewBindings',
		'Settings/mapEnable',
		'Settings/mapReplaceBinding'
	);
	self:UpdateBindings()
	return CPAPI.BurnAfterReading;
end

if RegisterNewSlashCommand then
	RegisterNewSlashCommand(function() env:TaintProbe() end, 'cpmaptaint')
end
