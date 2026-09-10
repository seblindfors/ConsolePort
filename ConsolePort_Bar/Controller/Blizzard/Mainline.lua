-- Credit: https://github.com/Nevcairiel/Bartender4/blob/master/HideBlizzard.lua
local _, env = ...;
local Frame = GetFrameMetatable().__index;
local Purge = CPAPI.Purge;

local function purgeFromDispatchers(button)
	if ActionBarActionEventsFrame then
		Purge(ActionBarActionEventsFrame.frames, button)
	end
	if ActionBarButtonUpdateFrame then
		Purge(ActionBarButtonUpdateFrame.frames, button)
	end
end

local function hideEditModeFrame(frame, clearEvents)
	if not frame then return end;
	if clearEvents then
		Frame.UnregisterAllEvents(frame)
	end
	Purge(frame, 'isShownExternal')
	Frame.Hide(frame)
	Frame.SetParent(frame, env.UIHandler)
end

local function hideActionButton(button)
	if not button then return end;
	Frame.Hide(button)
	Frame.UnregisterAllEvents(button)
	Frame.SetAttributeNoHandler(button, 'statehidden', true)
	purgeFromDispatchers(button)
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
	-- these events drive visibility, we want the MainActionBar to remain invisible
	for _, event in ipairs({
		'PLAYER_REGEN_ENABLED';
		'PLAYER_REGEN_DISABLED';
		'ACTIONBAR_SHOWGRID';
		'ACTIONBAR_HIDEGRID';
	}) do
		Frame.UnregisterEvent(MainActionBar, event)
	end

	---------------------------------------------------------------
	-- Action bars
	for bar, clearEvents in pairs({
		MultiBarBottomLeft  = true;
		MultiBarBottomRight = true;
	--	MultiBarLeft        = true;
	--	MultiBarRight       = true;
	--	MultiBar5           = true;
	--	MultiBar6           = true;
	--	MultiBar7           = true;
	}) do
		hideEditModeFrame(_G[bar], clearEvents)
		for i = 1, 12 do -- Hide MultiBar Buttons
			hideActionButton(_G[bar .. 'Button' .. i])
		end
	end

	---------------------------------------------------------------
	-- HUD frames
	for frame, clearEvents in pairs({
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
		hideEditModeFrame(_G[frame], clearEvents)
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