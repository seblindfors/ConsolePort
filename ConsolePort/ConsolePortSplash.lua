local _, G = ...;

function ConsolePort:CheckUnassignedBindings()
	local ButtonUnassigned = false;
	local buttons = self:GetBindingNames();
	local unassigned = {};
	for i, button in pairs(buttons) do
		local key1, key2 = GetBindingKey(button);
		if not key1 and not key2 then
			ButtonUnassigned = true;
			table.insert(unassigned, button);
		end
	end
	if not ButtonUnassigned then unassigned = nil; end;
	return unassigned;
end

function ConsolePort:CreateBindingWizard()
	if not ConsolePortWizardFrame then
		local A = "TOPLEFT";
		local B = "TOPRIGHT";
		local C = "TOP";
		-- Frames
		local Wizard = CreateFrame("Frame", "ConsolePortWizardFrame", UIParent);
		local WizardCloseButton = CreateFrame("Button", nil, Wizard, "UIPanelCloseButtonNoScripts");
		-- Textures
		local WizardBG 	= Wizard:CreateTexture(nil, "BACKGROUND");
		local WizardBGOverlay = Wizard:CreateTexture(nil, "ARTWORK");
		local WizardWrapper = Wizard:CreateTexture(nil, "OVERLAY");
		local WizardButtonGraphic = Wizard:CreateTexture(nil, "ARTWORK");
		-- Fontstrings
		local WizardHeader = Wizard:CreateFontString(nil, "OVERLAY", "SplashHeaderFont");
		local WizardButtonPress = Wizard:CreateFontString(nil, "OVERLAY", "SplashHeaderFont");
		local WizardDescription = Wizard:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge2");
		local WizardConfirmText = Wizard:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge2");
		-- Set up sizes and inputs
		Wizard:SetFrameStrata("DIALOG");
		Wizard:SetSize(512,512);
		Wizard:EnableMouse(true);
		Wizard:EnableKeyboard(true);
		WizardWrapper:SetSize(512, 128);
		WizardButtonGraphic:SetSize(50, 50);
		-- SetTextures
		WizardBG:SetTexture("Interface\\AddOns\\ConsolePort\\Graphic\\WizardBG");
		WizardWrapper:SetTexture("Interface\\AddOns\\ConsolePort\\Graphic\\WizardWrapper");
		WizardBGOverlay:SetTexture("Interface\\AddOns\\ConsolePort\\Graphic\\Wizard"..ConsolePortSettings.type);
		-- Points
		Wizard:SetPoint("CENTER", 0,0);
		WizardBG:SetAllPoints(Wizard);
		WizardBGOverlay:SetAllPoints(Wizard);
		WizardHeader:SetPoint(C, 0, -10);
		WizardWrapper:SetPoint("CENTER", Wizard, 0, 0);
		WizardButtonPress:SetPoint("CENTER", WizardWrapper, 10, 0);
		WizardButtonGraphic:SetPoint("CENTER", WizardWrapper, -142, -4);
		WizardDescription:SetPoint(C, 0, -100);
		WizardConfirmText:SetPoint(C, 0, -400);
		WizardCloseButton:SetPoint(B, -50, -10);
		-- Alpha
		WizardBGOverlay:SetAlpha(0.1);
		WizardConfirmText:SetAlpha(0);
		-- Text values
		WizardHeader:SetText("Assign Buttons");
		WizardButtonPress:SetText("<Empty>")
		WizardDescription:SetText("Your controller bindings are incomplete.\nPress the requested button to map it.");
		-- Bind to frame
		Wizard.BTN = nil;
		Wizard.VAL = nil;
		Wizard.SET = false;
		Wizard.BG = WizardBG;
		Wizard.Close = WizardCloseButton;
		Wizard.Header = WizardHeader;
		Wizard.Wrapper = WizardWrapper;
		Wizard.Confirm = WizardConfirmText;
		Wizard.Binding = WizardButtonPress;
		Wizard.Graphic = WizardButtonGraphic;
		Wizard.Description = WizardDescription;
		-- Scripts
		WizardCloseButton:SetScript("OnClick", function(...)
			Wizard:Hide();
			PlaySound("SPELLBOOKCLOSE");
		end);
		Wizard:SetScript("OnKeyUp", function(self, key)
			if self.VAL and self.VAL == key and self.SET then
				if not InCombatLockdown() then
					if not SetBinding(key, self.BTN) then
						self.VAL = nil;
						self.Confirm:SetText("Invalid binding.\nDid you press the correct button?");
					else
						SaveBindings(GetCurrentBindingSet());
						self.Binding:SetText("<Empty>");
						self.Confirm:SetText("");
						self.VAL = nil;
						return;
					end
				else
					self.Confirm:SetText("You are in combat!");
				end
			elseif self.VAL and self.VAL == key then
				self.SET = true;
				if self.BTN then
					self.Confirm:SetText("Press "..G["NAME_"..self.BTN].." again to confirm.");
				end
			else
				self.SET = false;
			end
			self.Binding:SetText(key);
			self.VAL = key;
		end);
		Wizard:SetScript("OnUpdate", function(self, elapsed)
			if 	ConsolePortSplashFrame and
				ConsolePortSplashFrame:IsVisible() then
				self:Hide();
			else
				local unassigned = ConsolePort:CheckUnassignedBindings();
				if unassigned then
					self.BTN = unassigned[1];
					if self.BTN then
						if self.BTN == "CP_TR1" then
							self.Graphic:SetTexture(G.TEXTURE_RONE);
						elseif self.BTN == "CP_TR2" then
							self.Graphic:SetTexture(G.TEXTURE_RTWO);
						else
							self.Graphic:SetTexture(G["TEXTURE_"..string.upper(G["NAME_"..self.BTN])]);
						end
					end
					if self.SET then
						self.Confirm:SetAlpha(1);
					else
						self.Confirm:SetAlpha(0);
					end
				else
					self:SetScript("OnUpdate", nil);
					ConsolePortWizardFrame.Close:Click();
				end
			end
		end);
	elseif self:CheckUnassignedBindings() then
		ConsolePortWizardFrame:Show();
		PlaySound("SPELLBOOKOPEN");
	end
end


function ConsolePort:CreateSplashFrame()
	if not ConsolePortSplashFrame then
		local A = "TOPLEFT";
		local B = "TOPRIGHT";
		local C = "TOP";
		local P = {
			off 	= { X = 512, 	Y =  -512	},
			gra		= { L = -290, 	R =  290	},
			cro		= { X = -14,	Y = -10,	},
			btn		= { L = -210, 	R =  210,	Y = -160	},
			txt 	= { Y = -16 },
			sha 	= { Y = -38 },
		}
		local S = {
			main 	= { x = 902, y = 581 },
			button 	= { x = 350, y = 390 },
		}
		local Splash = CreateFrame("Frame", "ConsolePortSplashFrame", UIParent);
		local SplashPlaystationButton = CreateFrame("Button", nil, Splash);
		local SplashXboxButton = CreateFrame("Button", nil, Splash);
		local SplashCloseButton = CreateFrame("Button", nil, Splash, "UIPanelCloseButtonNoScripts");
		SplashPlaystationButton:SetSize(S.button.x, S.button.y);
		SplashXboxButton:SetSize(S.button.x, S.button.y);
		Splash:SetFrameStrata("DIALOG");
		Splash:SetWidth(S.main.x);
		Splash:SetHeight(S.main.y);
		Splash:EnableMouse(true);
		local SplashLeftTop 	= Splash:CreateTexture(nil, "BACKGROUND");
		local SplashLeftBottom 	= Splash:CreateTexture(nil, "BACKGROUND");
		local SplashRightTop 	= Splash:CreateTexture(nil, "BACKGROUND");
		local SplashRightBottom = Splash:CreateTexture(nil, "BACKGROUND");
		local SplashPlaystation = Splash:CreateTexture(nil, "ARTWORK");
		local SplashPlaystationHighlight = Splash:CreateTexture(nil, "ARTWORK");
		local SplashXbox 		= Splash:CreateTexture(nil, "ARTWORK");
		local SplashXboxHighlight = Splash:CreateTexture(nil, "ARTWORK");
		local SplashShadow 		= Splash:CreateTexture(nil, "OVERLAY");
		local SplashHeader 		= Splash:CreateFontString(nil, "OVERLAY", "SplashHeaderFont");
		SplashLeftTop:SetTexture("Interface\\AddOns\\ConsolePort\\Graphic\\SplashLeftTop");
		SplashLeftBottom:SetTexture("Interface\\AddOns\\ConsolePort\\Graphic\\SplashLeftBottom");
		SplashRightTop:SetTexture("Interface\\AddOns\\ConsolePort\\Graphic\\SplashRightTop");
		SplashRightBottom:SetTexture("Interface\\AddOns\\ConsolePort\\Graphic\\SplashRightBottom");
		SplashShadow:SetTexture("Interface\\AddOns\\ConsolePort\\Graphic\\SplashShadow");
		SplashPlaystation:SetTexture("Interface\\AddOns\\ConsolePort\\Graphic\\SplashPlaystation");
		SplashPlaystationHighlight:SetTexture("Interface\\AddOns\\ConsolePort\\Graphic\\SplashPlaystationHighlight");
		SplashXbox:SetTexture("Interface\\AddOns\\ConsolePort\\Graphic\\SplashXbox");
		SplashXboxHighlight:SetTexture("Interface\\AddOns\\ConsolePort\\Graphic\\SplashXboxHighlight");
		SplashLeftTop:SetPoint(A);
		SplashLeftBottom:SetPoint(A, 0, P.off.Y);
		SplashRightTop:SetPoint(A, P.off.X, 0);
		SplashRightBottom:SetPoint(A, P.off.X, P.off.Y);
		SplashShadow:SetPoint(C, 0, P.sha.Y);
		SplashHeader:SetPoint(C, 0, P.txt.Y);
		SplashCloseButton:SetPoint(B, P.cro.X, P.cro.Y);
		SplashPlaystation:SetPoint(C, P.gra.R, P.btn.Y);
		SplashPlaystationHighlight:SetPoint(C, P.gra.R, P.btn.Y);
		SplashPlaystationButton:SetPoint(C, P.btn.R, P.btn.Y);
		SplashXbox:SetPoint(C, P.gra.L, P.btn.Y);
		SplashXboxHighlight:SetPoint(C, P.gra.L, P.btn.Y);
		SplashXboxButton:SetPoint(C, P.btn.L, P.btn.Y);
		Splash.SplashLeftTop 		= SplashLeftTop;
		Splash.SplashLeftBottom		= SplashLeftBottom;
		Splash.SplashRightTop 		= SplashRightTop;
		Splash.SplashRightBottom 	= SplashRightBottom;
		Splash.SplashShadow 		= SplashShadow;
		Splash.SplashPlaystation 	= SplashPlaystation;
		Splash.SplashPlaystationHighlight = SplashPlaystationHighlight;
		Splash.SplashXbox 			= SplashXbox;
		Splash.SplashXboxHighlight 	= SplashXboxHighlight;
		Splash.SplashHeader 		= SplashHeader;
		Splash.PlaystationButton 	= SplashPlaystationButton;
		Splash.XboxButton 			= SplashXboxButton;
		SplashHeader:SetText("Choose Controller");
		SplashPlaystationButton:SetScript("OnEnter", function(self)
			SplashPlaystation:Hide();
			SplashPlaystationHighlight:Show();
		end);
		SplashPlaystationButton:SetScript("OnLeave", function(self)
			SplashPlaystation:Show();
			SplashPlaystationHighlight:Hide();
		end);
		SplashPlaystationButton:SetScript("OnClick", function(...)
			ConsolePortSettings.type = "PS4";
			PlaySound("GLUEENTERWORLDBUTTON");
			ReloadUI();
		end);

		SplashXboxButton:SetScript("OnEnter", function(self)
			SplashXbox:Hide();
			SplashXboxHighlight:Show();
		end);
		SplashXboxButton:SetScript("OnLeave", function(self)
			SplashXbox:Show();
			SplashXboxHighlight:Hide();
		end);
		SplashXboxButton:SetScript("OnClick", function(...)
			ConsolePortSettings.type = "Xbox";
			PlaySound("GLUEENTERWORLDBUTTON");
			ReloadUI();
		end);
		SplashCloseButton:SetScript("OnClick", function(...)
			Splash:Hide();
			PlaySound("SPELLBOOKCLOSE");
		end);
		SplashPlaystationHighlight:Hide();
		SplashXboxHighlight:Hide();
		Splash:SetPoint("CENTER", 0,0);
	end
	ConsolePortSplashFrame:Show();
	UIFrameFadeIn(ConsolePortSplashFrame, 0.5, 0, 1);
	PlaySound("SPELLBOOKOPEN");
end