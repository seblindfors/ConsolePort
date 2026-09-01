-- Credit: https://github.com/Nevcairiel/Bartender4/blob/master/HideBlizzard.lua
if not CPAPI.IsRetailVersion then return end;
local _, env = ...;

local function hideEditModeFrame(frame)
	if frame then
		-- Do not Hide, reparent, unregister, or mutate Edit Mode state on
		-- Blizzard-owned bars. Those operations invoke Blizzard lifecycle code
		-- from an addon-tainted stack and can poison action-button fields that
		-- are later consumed with secret cooldown values in combat.
		frame:SetAlpha(0)
		frame:EnableMouse(false)
	end
end

local function hideActionButton(button)
	if not button then return end
	-- Keep the stock button fully owned and updated by Blizzard. In
	-- particular, do not set statehidden or remove it from shared dispatchers:
	-- both approaches leave Blizzard iterating tainted button state.
	button:SetAlpha(0)
	button:EnableMouse(false)
end

local function NPE_LoadUI()
	if not (Tutorials and Tutorials.AddSpellToActionBar) then return end

	-- Action Bar drag tutorials
	Tutorials.AddSpellToActionBar:Disable()
	Tutorials.AddClassSpellToActionBar:Disable()

	-- these tutorials rely on finding valid action bar buttons, and error otherwise
	Tutorials.Intro_CombatTactics:Disable()

	-- enable spell pushing because the drag tutorial is turned off
	Tutorials.AutoPushSpellWatcher:Complete()
end


function env.UIHandler:HideBlizzard()
	---------------------------------------------------------------
	-- Main action bar
	hideEditModeFrame(MainActionBar, false)
	for i = 1, 12 do
		hideActionButton(_G['ActionButton' .. i])
	end
	---------------------------------------------------------------
	-- Action bars
	for bar in pairs({
		MultiBarBottomLeft  = true;
		MultiBarBottomRight = true;
	--	MultiBarLeft        = true;
	--	MultiBarRight       = true;
	--	MultiBar5           = true;
	--	MultiBar6           = true;
	--	MultiBar7           = true;
	}) do
		hideEditModeFrame(_G[bar])
		for i = 1, 12 do -- Hide MultiBar Buttons
			hideActionButton(_G[bar .. 'Button' .. i])
		end
	end

	---------------------------------------------------------------
	-- HUD frames
	for frame in pairs({
	--	BagsBar                  = true;
	--	MicroButtonAndBagsBar    = false;
	--	MicroMenu                = true;
	--	MultiCastActionBarFrame  = false;
		PetActionBar             = true;
		PossessActionBar         = true;
	--	StanceBar                = true;
		StatusTrackingBarManager = false;
		OverrideActionBar        = true;
	}) do
		hideEditModeFrame(_G[frame])
	end
	for i = 1, NUM_OVERRIDE_BUTTONS or 6 do
		hideActionButton(_G['OverrideActionBarButton' .. i])
	end
	for i = 1, NUM_PET_ACTION_SLOTS or 10 do
		hideActionButton(_G['PetActionButton' .. i])
	end
	for i = 1, NUM_POSSESS_SLOTS or 2 do
		hideActionButton(_G['PossessButton' .. i])
	end

	---------------------------------------------------------------
	-- Misc
	if CPAPI.IsAddOnLoaded('Blizzard_NewPlayerExperience') then
		NPE_LoadUI()
	elseif _G.NPE_LoadUI ~= nil then
		hooksecurefunc('NPE_LoadUI', NPE_LoadUI)
	end
end
