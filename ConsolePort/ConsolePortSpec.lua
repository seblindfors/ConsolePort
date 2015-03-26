local _, G = ...;
local NUM_SPECS;
local _, _, class = UnitClass("player");
if class == 11 then NUM_SPECS = 4; else NUM_SPECS = 3; end;

local ACTIVE_TAB;
local ACTIVE_SPEC;

local SPECTAB = 1;
local TALENTS = 2;
local GLYPHS  = 3;

local spec_iterator = 1;
local GuideSpec1;
local GuideSpec2;

local talents = {};
local talent_iterator = 1;
local EnterTalent = nil;
local LeaveTalent = nil;
local TalentInUse = false;

--button.highlight:SetAlpha(1);

function ConsolePort:InitializeTalents()
	-- Indicators
	self:CreateIndicator(PlayerTalentFrameActivateButton, "SMALL", "RIGHT", G.NAME.CP_R_RIGHT);
	self:CreateIndicator(PlayerTalentFrameSpecializationLearnButton, "SMALL", "LEFT", G.NAME.CP_R_LEFT);
	self:CreateIndicator(PlayerTalentFrameTalentsLearnButton, "SMALL", "LEFT", G.NAME.CP_R_LEFT);
	-- Spec stuff
	GuideSpec1 = self:CreateIndicator(PlayerSpecTab1, "SMALL", "RIGHT", G.NAME.CP_R_UP);
	GuideSpec2 = self:CreateIndicator(PlayerSpecTab2, "SMALL", "RIGHT", G.NAME.CP_R_UP);
	if PlayerTalentFrame.selectedPlayerSpec == "spec1" then GuideSpec2:Hide(); else GuideSpec1:Hide(); end;
	PlayerSpecTab1:HookScript("OnClick", function(self)
		GuideSpec1:Hide();
		GuideSpec2:Show();
		ConsolePort:Spec(G.PREPARE, G.STATE_UP);
	end);
	PlayerSpecTab2:HookScript("OnClick", function(self)
		GuideSpec2:Hide();
		GuideSpec1:Show();
		ConsolePort:Spec(G.PREPARE, G.STATE_UP);
	end);
	-- Talent stuff
	EnterTalent	= PlayerTalentFrameTalentsTalentRow1Talent1:GetScript("OnEnter");
	LeaveTalent = PlayerTalentFrameTalentsTalentRow1Talent1:GetScript("OnLeave");
	PlayerTalentFrame:HookScript("OnUpdate", function(self, elapsed)
		if self:IsVisible() then
			local target = talents[talent_iterator].knownSelection;
--			local target = _G[talents[talent_iterator]:GetName().."Selection"];
			for i, talent in pairs(talents) do
				local selection = talent.knownSelection;
				if selection ~= target and selection:IsVisible() then selection:SetAlpha(0.40); end;
			end
			target:SetAlpha(1);
			target:Show();
			if IsShiftKeyDown() then
				EnterTalent(talents[talent_iterator]);
				GameTooltip:AddLine(G.CLICK.TALENT, 1,1,1);
				GameTooltip:Show();
			else
				LeaveTalent(talents[talent_iterator]);
			end
		end
	end);
	for y=1, 7 do
		for x=1, 3 do
			tinsert(
				talents,
				_G["PlayerTalentFrameTalentsTalentRow"..y.."Talent"..x]
			);
		end
	end
end

function ConsolePort:SpecTab(key, state)
	local SpecButtons = {};
	for i=1, NUM_SPECS do
		tinsert(SpecButtons, _G["PlayerTalentFrameSpecializationSpecButton"..i]);
	end
	if key == G.PREPARE then
		for i, spec in pairs(SpecButtons) do
			if 	spec.selected then spec_iterator = i; break; end;
		end
	elseif key == G.UP and state == G.STATE_DOWN then
		if 	 spec_iterator == 1 then spec_iterator = NUM_SPECS;
		else spec_iterator = spec_iterator - 1; end;
	elseif key == G.DOWN and state == G.STATE_DOWN then
		if 	 spec_iterator == NUM_SPECS then spec_iterator = 1;
		else spec_iterator = spec_iterator + 1; end;
	elseif key == G.SQUARE then
		ConsolePort:Button(PlayerTalentFrameSpecializationLearnButton, state);
	end
	SpecButtons[spec_iterator]:Click();
end

function ConsolePort:TalentTab(key, state)
	if key == G.SQUARE then 
		ConsolePort:Button(PlayerTalentFrameTalentsLearnButton, state);
		if state == G.STATE_UP and talents[talent_iterator].learnSelection:IsVisible() then TalentInUse = true; end;
	elseif key ~= G.PREPARE and state == G.STATE_DOWN then
		if not TalentInUse then talents[talent_iterator].knownSelection:Hide(); end;
		if 		key == G.UP 	then if talent_iterator > 3 then talent_iterator = talent_iterator - 3; else talent_iterator = talent_iterator + 18; end;
		elseif 	key == G.DOWN 	then if talent_iterator < 19 then talent_iterator = talent_iterator + 3; else talent_iterator = talent_iterator - 18; end;
		elseif 	key == G.LEFT 	then if talent_iterator > 1 then talent_iterator = talent_iterator - 1; else talent_iterator = 21; end;
		elseif 	key == G.RIGHT 	then if talent_iterator < 21 then talent_iterator = talent_iterator + 1; else talent_iterator = 1; end;
		end;
		if talents[talent_iterator].knownSelection:IsVisible() then TalentInUse = true; else TalentInUse = false; end;
	end
	if not PlayerTalentFrameActivateButton:IsVisible() then
		ConsolePort:SetClickButton(CP_R_RIGHT_NOMOD, talents[talent_iterator]);
	end
end

-- GlyphFrame_PulseGlow();
function ConsolePort:Spec(key, state)
	ACTIVE_TAB = PlayerTalentFrame.selectedTab;
	if 	ACTIVE_SPEC ~= PlayerTalentFrame.selectedPlayerSpec then
		ACTIVE_SPEC = PlayerTalentFrame.selectedPlayerSpec;
		ConsolePort:Spec(G.PREPARE, G.STATE_UP);
	end
	if PlayerSpecTab2:IsVisible() then
		if ACTIVE_SPEC == "spec1" then
			ConsolePort:SetClickButton(CP_R_UP_NOMOD, PlayerSpecTab2);
		else
			ConsolePort:SetClickButton(CP_R_UP_NOMOD, PlayerSpecTab1);
		end
	end
	if PlayerTalentFrameActivateButton:IsVisible() then
		ConsolePort:SetClickButton(CP_R_RIGHT_NOMOD, PlayerTalentFrameActivateButton);
	end
	if ACTIVE_TAB == SPECTAB then
		ConsolePort:SpecTab(key, state);
	elseif ACTIVE_TAB == TALENTS then
		ConsolePort:TalentTab(key, state);
	elseif ACTIVE_TAB == GLYPHS then
		ConsolePort:GlyphTab(key, state);
	end
end