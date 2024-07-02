-- Credit: https://github.com/Nevcairiel/Bartender4/blob/master/HideBlizzard.lua
if not CPAPI.IsRetailVersion then return end;
local _, env = ...;

local function hideEditModeFrame(frame, clearEvents)
	if frame then
		if clearEvents then
			frame:UnregisterAllEvents()
		end

		-- remove some EditMode hooks
		if frame.system then
			-- purge the show state to avoid any taint concerns
			CPAPI.Purge(frame, 'isShownExternal')
		end

		-- EditMode overrides the Hide function, avoid calling it as it can taint
		if frame.HideBase then
			frame:HideBase()
		else
			frame:Hide()
		end
		frame:SetParent(env.UIHandler)
	end
end

local function hideActionButton(button)
	if not button then return end
	button:Hide()
	button:UnregisterAllEvents()
	button:SetAttribute('statehidden', true)
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
	hideEditModeFrame(MainMenuBar, false)
	for i = 1, 12 do
		hideActionButton(_G['ActionButton' .. i])
	end
	-- these events drive visibility, we want the MainMenuBar to remain invisible
	for _, event in ipairs({
		'PLAYER_REGEN_ENABLED';
		'PLAYER_REGEN_DISABLED';
		'ACTIONBAR_SHOWGRID';
		'ACTIONBAR_HIDEGRID';
	}) do
		MainMenuBar:UnregisterEvent(event)
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

	---------------------------------------------------------------
	-- Misc
	if CPAPI.IsAddOnLoaded('Blizzard_NewPlayerExperience') then
		NPE_LoadUI()
	elseif NPE_LoadUI ~= nil then
		hooksecurefunc('NPE_LoadUI', NPE_LoadUI)
	end
end