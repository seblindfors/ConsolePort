local _, G = ...;
local PATH = "Interface\\AddOns\\ConsolePort\\Graphic\\";

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
		-- Strings
		local STRING_HEADER = "Assign Buttons";
		local STRING_HEADLINE = "Your controller bindings are incomplete.\nPress the requested button to map it.";
		local STRING_INVALID = "Invalid binding.\nDid you press the correct button?"
		local STRING_COMBAT = "You are in combat!";
		local STRING_EMPTY = "<Empty>";
		local STRING_TSIZE = ":16:16:0:0|t";
		local STRING_SUCCESS = " was successfully bound to ";
		local STRING_CONFIRM = "Press BTN again to confirm.";
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
		local WizardStatusText = Wizard:CreateFontString(nil, "OVERLAY", "SystemFont_Shadow_Med2");
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
		WizardBG:SetTexture(PATH.."WizardBG");
		WizardWrapper:SetTexture(PATH.."WizardWrapper");
		WizardBGOverlay:SetTexture(PATH.."Splash"..ConsolePortSettings.type);
		-- Points
		Wizard:SetPoint("CENTER", 0,0);
		WizardBG:SetAllPoints(Wizard);
		WizardBGOverlay:SetAllPoints(Wizard);
		WizardHeader:SetPoint(C, 0, -16);
		WizardWrapper:SetPoint("CENTER", Wizard, 0, 0);
		WizardButtonPress:SetPoint("CENTER", WizardWrapper, 10, 0);
		WizardButtonGraphic:SetPoint("CENTER", WizardWrapper, -142, -4);
		WizardStatusText:SetPoint(C, 0, -300);
		WizardDescription:SetPoint(C, 0, -100);
		WizardConfirmText:SetPoint(C, 0, -350);
		WizardCloseButton:SetPoint(B, -10, -10);
		-- Alpha
		WizardBGOverlay:SetAlpha(0.075);
		WizardStatusText:SetAlpha(0);
		WizardConfirmText:SetAlpha(0);
		-- Text values
		WizardHeader:SetText(STRING_HEADER);
		WizardButtonPress:SetText(STRING_EMPTY)
		WizardDescription:SetText(STRING_HEADLINE);
		-- Bind to frame
		Wizard.BTN = nil;
		Wizard.VAL = nil;
		Wizard.SET = false;
		Wizard.BG = WizardBG;
		Wizard.Close = WizardCloseButton;
		Wizard.Header = WizardHeader;
		Wizard.Status = WizardStatusText;
		Wizard.Overlay = WizardBGOverlay;
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
		Wizard:SetScript("OnKeyDown", function(self, key)
			self.Wrapper:SetVertexColor(1, 1, 0.5);
		end);
		Wizard:SetScript("OnKeyUp", function(self, key)
			self.Wrapper:SetVertexColor(1, 1, 1);
			self.Status:SetAlpha(0);
			if self.VAL and self.VAL == key and self.SET then
				if not InCombatLockdown() then
					if not SetBinding(key, self.BTN) then
						self.VAL = nil;
						self.Confirm:SetText("");
						self.Status:SetText(STRING_INVALID);
						self.Status:SetAlpha(1);
					else
						self.Status:SetText("|T"..self.Graphic:GetTexture()..STRING_TSIZE..STRING_SUCCESS..key..".");
						UIFrameFadeIn(self.Status, 3, 1, 0);
						SaveBindings(GetCurrentBindingSet());
						self.Binding:SetText(STRING_EMPTY);
						self.Confirm:SetText("");
						self.VAL = nil;
						return;
					end
				else
					self.Status:SetText(STRING_COMBAT);
				end
			elseif self.VAL and self.VAL == key then
				self.SET = true;
				if self.BTN then
					self.Confirm:SetText(string.gsub(STRING_CONFIRM, "BTN", G["NAME_"..self.BTN]));
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
			gra		= { L = -200, 	R =  200	},
			cro		= { X = -14,	Y = -10,	},
			btn		= { L = -210, 	R =  210,	Y = 10 },
			txt 	= { Y = -16 },
			sha 	= { Y = -38 },
			rot 	= { P = 0.523598776, N = -0.523598776 },
			size 	= { X = 710 }
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
		local SplashTop 		= Splash:CreateTexture(nil, "OVERLAY");
		local SplashLeftTop 	= Splash:CreateTexture(nil, "BACKGROUND");
		local SplashLeftBottom 	= Splash:CreateTexture(nil, "BACKGROUND");
		local SplashRightTop 	= Splash:CreateTexture(nil, "BACKGROUND");
		local SplashRightBottom = Splash:CreateTexture(nil, "BACKGROUND");
		local SplashPlaystation = Splash:CreateTexture(nil, "ARTWORK");
		local SplashPlaystationHighlight = Splash:CreateTexture(nil, "ARTWORK");
		local SplashXbox 		= Splash:CreateTexture(nil, "ARTWORK");
		local SplashXboxHighlight = Splash:CreateTexture(nil, "ARTWORK");
		local SplashHeader 		= Splash:CreateFontString(nil, "OVERLAY", "SplashHeaderFont");
		-- Textures
		SplashTop:SetTexture(PATH.."SplashTop");
		SplashLeftTop:SetTexture(PATH.."SplashLeftTop");
		SplashLeftBottom:SetTexture(PATH.."SplashLeftBottom");
		SplashRightTop:SetTexture(PATH.."SplashRightTop");
		SplashRightBottom:SetTexture(PATH.."SplashRightBottom");
		SplashPlaystation:SetTexture(PATH.."SplashPS4");
		SplashPlaystationHighlight:SetTexture(PATH.."SplashPS4Highlight");
		SplashXbox:SetTexture(PATH.."SplashXbox");
		SplashXboxHighlight:SetTexture(PATH.."SplashXboxHighlight");
		--
		SplashPlaystation:SetSize(P.size.X, P.size.X);
		SplashPlaystationHighlight:SetSize(P.size.X, P.size.X);
		SplashXbox:SetSize(P.size.X, P.size.X);
		SplashXboxHighlight:SetSize(P.size.X, P.size.X);
		SplashPlaystation:SetRotation(P.rot.N);
		SplashPlaystationHighlight:SetRotation(P.rot.N);
		SplashXbox:SetRotation(P.rot.P);
		SplashXboxHighlight:SetRotation(P.rot.P);
		--
		SplashTop:SetPoint(C, 0, 0);
		SplashLeftTop:SetPoint(A);
		SplashLeftBottom:SetPoint(A, 0, P.off.Y);
		SplashRightTop:SetPoint(B, 0, 0);
		SplashRightBottom:SetPoint(B, 0, P.off.Y);
		SplashHeader:SetPoint(C, 0, P.txt.Y);
		SplashCloseButton:SetPoint(B, P.cro.X, P.cro.Y);
		SplashPlaystation:SetPoint(C, P.gra.R, P.btn.Y);
		SplashPlaystationHighlight:SetPoint(C, P.gra.R, P.btn.Y);
		SplashPlaystationButton:SetPoint("CENTER", P.btn.R, P.btn.Y-80);
		SplashXbox:SetPoint(C, P.gra.L, P.btn.Y);
		SplashXboxHighlight:SetPoint(C, P.gra.L, P.btn.Y);
		SplashXboxButton:SetPoint("CENTER", P.btn.L, P.btn.Y-80);
		Splash.SplashLeftTop 		= SplashLeftTop;
		Splash.SplashLeftBottom		= SplashLeftBottom;
		Splash.SplashRightTop 		= SplashRightTop;
		Splash.SplashRightBottom 	= SplashRightBottom;
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