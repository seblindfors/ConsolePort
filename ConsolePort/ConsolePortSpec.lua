local _
local _, G = ...;
local NUM_SPECS;
local _, _, class = UnitClass("player");
if class == 11 then NUM_SPECS = 4; else NUM_SPECS = 3; end;

local ACTIVE_TAB;
local ACTIVE_SPEC;

local SPECTAB = 1;
local spec_iterator = 1;
local GuideSpec1;
local GuideSpec2;

local TALENTS = 2;

local GLYPHS  = 3;

function ConsolePort:InitializeTalents()
	self:CreateIndicator(PlayerTalentFrameActivateButton, "SMALL", "RIGHT", G.NAME_CP_R_RIGHT);
	self:CreateIndicator(PlayerTalentFrameSpecializationLearnButton, "SMALL", "LEFT", G.NAME_CP_R_LEFT);
	self:CreateIndicator(PlayerTalentFrameTalentsLearnButton, "SMALL", "LEFT", G.NAME_CP_R_LEFT);
	GuideSpec1 = self:CreateIndicator(PlayerSpecTab1, "SMALL", "RIGHT", G.NAME_CP_R_UP);
	GuideSpec2 = self:CreateIndicator(PlayerSpecTab2, "SMALL", "RIGHT", G.NAME_CP_R_UP);
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
end

function ConsolePort:SpecTab(key, state)
	local SpecButtons = {};
	for i=1, NUM_SPECS do
		table.insert(SpecButtons, _G["PlayerTalentFrameSpecializationSpecButton"..i]);
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

-- GlyphFrame_PulseGlow();
function ConsolePort:Spec(key, state)
	ACTIVE_TAB = PlayerTalentFrame.selectedTab;
	if 	ACTIVE_SPEC ~= PlayerTalentFrame.selectedPlayerSpec then
		ACTIVE_SPEC = PlayerTalentFrame.selectedPlayerSpec;
		ConsolePort:Spec(G.PREPARE, G.STATE_UP);
	end
	if PlayerSpecTab2:IsVisible() then
		CP_R_UP_NOMOD:SetAttribute("type", "click");
		if ACTIVE_SPEC == "spec1" then
			ConsolePort:SetClickButton(CP_R_UP_NOMOD, PlayerSpecTab2);
		else
			ConsolePort:SetClickButton(CP_R_UP_NOMOD, PlayerSpecTab1);
		end
	end
	if PlayerTalentFrameActivateButton:IsVisible() then
		CP_R_RIGHT_NOMOD:SetAttribute("type", "click");
		CP_R_RIGHT_NOMOD:SetAttribute("clickbutton", PlayerTalentFrameActivateButton);
	end
	if ACTIVE_TAB == SPECTAB then
		ConsolePort:SpecTab(key, state);
	elseif ACTIVE_TAB == TALENTS then
		--
	elseif ACTIVE_TAB == GLYPHS then
		ConsolePort:GlyphTab(key, state);
	end
end