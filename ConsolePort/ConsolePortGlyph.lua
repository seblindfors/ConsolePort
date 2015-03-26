local _, G = ...
local glyph_iterator = 2;
local GuideGlyphs = {};
local GlyphButtons = {};

-- Due to the special nature of the GlyphFrame, bindings for up/down need to be
-- temporarily overridden. This is because programmatically clicking the scrollbuttons
-- on this particular frame will taint the execution path. 
function ConsolePort:InitializeGlyphs()
	EnterGlyph = GlyphFrameScrollFrameButton1:GetScript("OnEnter");
	local ScrollUp = GlyphFrameScrollFrameScrollBarScrollUpButton;
	local ScrollDown = GlyphFrameScrollFrameScrollBarScrollDownButton;
	for i=1, 6 do
		local Glyph = _G["GlyphFrameGlyph"..i];
		tinsert(GuideGlyphs,
			ConsolePort:CreateIndicator(
				Glyph,
				"SMALL",
				"BOTTOM",
				"LTHREE"));
		GuideGlyphs[i]:Hide();
		Glyph:HookScript("OnEnter", function(self)
			local id = self:GetID();
			if 	GlyphMatchesSocket(id) and
				not GuideGlyphs[i]:IsVisible() then
				GuideGlyphs[i]:Show();
			end
		end);
		Glyph:HookScript("OnLeave", function(self)
			GuideGlyphs[i]:Hide();
		end);
	end
	for i=1, 10 do
		local GlyphButton = _G["GlyphFrameScrollFrameButton"..i];
		tinsert(GlyphButtons, GlyphButton);
		GlyphButton:HookScript("OnClick", function(self, button, down)
			if self.selectedTex:IsVisible() then
				GlyphFrame_PulseGlow();
			end
		end);
	end
	GlyphFrame:RegisterEvent("PLAYER_REGEN_ENABLED");
	GlyphFrame:HookScript("OnUpdate", function(self, elapsed)
		if 	GlyphFrame:IsVisible() then
			local GlyphButton = GlyphButtons[glyph_iterator];
			if 	GlyphButton then
				GlyphButton:GetScript("OnEnter")(GlyphButton);
				if not StaticPopup1:IsVisible() then
					ConsolePort:SetClickButton(CP_R_RIGHT_NOMOD, GlyphButton);
				end
				if not GlyphButton.disabledBG:IsVisible() then
					GameTooltip:AddLine(G.CLICK.GLYPH_CAST, 1,1,1);
					GameTooltip:Show();
				end
				ConsolePort:Highlight(glyph_iterator, GlyphButtons);
			end
			if 	glyph_iterator == 5 and
				not InCombatLockdown() then
				if 	ScrollUp:GetButtonState() ~= "DISABLED" and CP_L_UP_NOMOD.state == "up" then
					ConsolePort:OverrideBindingClick(ScrollUp, "CP_L_UP", "GlyphFrameScrollFrameScrollBarScrollUpButton", "LeftButton");
				else
					ClearOverrideBindings(ScrollUp);
				end
				if 	ScrollDown:GetButtonState() ~= "DISABLED" and CP_L_DOWN_NOMOD.state == "up" then
					ConsolePort:OverrideBindingClick(ScrollDown, "CP_L_DOWN", "GlyphFrameScrollFrameScrollBarScrollDownButton", "LeftButton");
				else
					ClearOverrideBindings(ScrollDown);
				end
			elseif not InCombatLockdown() then
				ClearOverrideBindings(ScrollUp);
				ClearOverrideBindings(ScrollDown);
			end
		end
	end);
	GlyphFrame:HookScript("OnHide", function(self)
		if not InCombatLockdown() then
			ClearOverrideBindings(ScrollUp);
			ClearOverrideBindings(ScrollDown);
		end
	end);
	-- If in combat when the frame is closed, reset bindings when combat ends.
	GlyphFrame:HookScript("OnEvent", function(self, event, ...)
		if 	event == "PLAYER_REGEN_ENABLED" and
			not self:IsVisible() then
			ClearOverrideBindings(ScrollUp);
			ClearOverrideBindings(ScrollDown);
		end
	end);
end

function ConsolePort:GlyphTab(key, state)
	local scrollFrame = GlyphFrameScrollFrame;
	local scroll = 0;
	if glyph_iterator == 1 and not GlyphButtons[glyph_iterator]:IsVisible() then glyph_iterator = 2; end;
	local GlyphButton = GlyphButtons[glyph_iterator];
	if GlyphButton then
		if 		key == G.DOWN and
				state == G.STATE_DOWN and
				glyph_iterator < 9 then
			glyph_iterator = glyph_iterator + 1;
		elseif 	key == G.UP and
				state == G.STATE_DOWN and
				glyph_iterator > 1 and
				GlyphButtons[glyph_iterator-1]:IsVisible() then
			glyph_iterator = glyph_iterator - 1;
		end
	end
end