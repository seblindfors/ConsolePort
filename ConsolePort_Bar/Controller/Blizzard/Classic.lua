-- Credit: https://github.com/Nevcairiel/Bartender4/blob/master/HideBlizzardClassic.lua
if CPAPI.IsRetailVersion then return end;
local _, env = ...;

local function reparent(frame)
	if frame then
		frame:SetParent(env.UIHandler)
	end
end

local function hideHUDFrame(frame, clearEvents, reanchor, noAnchorChanges)
	if frame then
		if clearEvents then
			frame:UnregisterAllEvents()
		end

		frame:Hide()
		reparent(frame)

		-- setup faux anchors so the frame position data returns valid
		if reanchor and not noAnchorChanges then
			local left, right, top, bottom = frame:GetLeft(), frame:GetRight(), frame:GetTop(), frame:GetBottom()
			frame:ClearAllPoints()
			if left and right and top and bottom then
				frame:SetPoint('TOPLEFT', UIParent, 'BOTTOMLEFT', left, top)
				frame:SetPoint('BOTTOMRIGHT', UIParent, 'BOTTOMLEFT', right, bottom)
			else
				frame:SetPoint('TOPLEFT', UIParent, 'BOTTOMLEFT', 10, 10)
				frame:SetPoint('BOTTOMRIGHT', UIParent, 'BOTTOMLEFT', 20, 20)
			end
		elseif not noAnchorChanges then
			frame:ClearAllPoints()
		end
	end
end

local function hideActionButton(button)
	if not button then return end
	button:Hide()
	button:UnregisterAllEvents()
	button:SetAttribute('statehidden', true)
end

function env.UIHandler:HideBlizzard()
	---------------------------------------------------------------
	-- Main action bar
	MainMenuBar:EnableMouse(false)
	MainMenuBar:UnregisterEvent('DISPLAY_SIZE_CHANGED')
	MainMenuBar:UnregisterEvent('UI_SCALE_CHANGED')

	for i = 1, 12 do
		hideActionButton(_G['ActionButton' .. i])
	end

	---------------------------------------------------------------
	-- Action bars
	for bar in pairs({	
		MultiBarBottomLeft = true;
		MultiBarBottomRight = true;
	--	MultiBarLeft = true;
	--	MultiBarRight = true;
	}) do
		reparent(_G[bar])
		for i = 1, 12 do -- Hide MultiBar Buttons, but keep the bars alive
			hideActionButton(_G[bar .. 'Button' .. i])
		end
	end

	---------------------------------------------------------------
	-- Managed frame positions (prevent re-anchoring/re-enabling)
	for frame in pairs({
		MainMenuBar             = true;
		StanceBarFrame          = true;
		PossessBarFrame         = true;
		MultiCastActionBarFrame = true;
		PETACTIONBAR_YPOS       = true;
		ExtraAbilityContainer   = true;
	}) do
		CPAPI.Purge(UIPARENT_MANAGED_FRAME_POSITIONS, frame)
	end

	---------------------------------------------------------------
	-- HUD frames
	for frame, settings in pairs({     -- clearEvents, reanchor, noAnchorChanges
		MainMenuBarArtFrame            = {false,       true};
		MainMenuBarArtFrameBackground  = {};
	--	StanceBarFrame                 = {true,        true};
		PossessBarFrame                = {false,       true};
	--	MultiCastActionBarFrame        = {false,       true};
		PetActionBarFrame              = {true,        true};
		MainMenuBarPerformanceBarFrame = {false,       false,    true};
		MainMenuExpBar                 = {false,       false,    true};
		ReputationWatchBar             = {false,       false,    true};
		MainMenuBarMaxLevelBar         = {false,       false,    true};
		OverrideActionBar              = {true,        false,    true};
	}) do
		hideHUDFrame(_G[frame], unpack(settings))
	end

	---------------------------------------------------------------
	-- Misc

	-- when blizzard vehicle is turned off, we need to manually fix the state since the OverrideActionBar animation wont run
	local animations = {MainMenuBar.slideOut:GetAnimations()}
	animations[1]:SetOffset(0,0)

	if OverrideActionBar then -- classic doesn't have this
		animations = {OverrideActionBar.slideOut:GetAnimations()}
		animations[1]:SetOffset(0,0)

		-- when blizzard vehicle is turned off, we need to manually fix the state since the OverrideActionBar animation wont run
		hooksecurefunc('BeginActionBarTransition', function(bar, animIn)
			--if bar == OverrideActionBar then --and not self.db.profile.blizzardVehicle then
			--	OverrideActionBar.slideOut:Stop()
			--	MainMenuBar:Show()
			--end
		end)
	end

	ShowPetActionBar = nop;
end