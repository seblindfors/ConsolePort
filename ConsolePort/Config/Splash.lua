local _, db = ...
local KEY = db.KEY
local SETUP = db.TUTORIAL.SETUP
local PATH = "Interface\\AddOns\\ConsolePort\\Textures\\Splash\\"

function ConsolePort:CheckUnassignedBindings()
	local ButtonUnassigned = false
	local buttons = self:GetBindingNames()
	local unassigned = {}
	for i, button in pairs(buttons) do
		local key1, key2 = GetBindingKey(button)
		if not key1 and not key2 then
			ButtonUnassigned = true
			tinsert(unassigned, button)
		end
	end
	if not ButtonUnassigned then unassigned = nil end
	return unassigned
end

function ConsolePort:CreateBindingWizard()
	if not ConsolePortWizardFrame then
		local Wizard = CreateFrame("Frame", "ConsolePortWizardFrame", UIParent)

		Wizard:SetPoint("CENTER", 0,0)
		Wizard:SetFrameStrata("DIALOG")
		Wizard:SetSize(600,544)
		Wizard:EnableMouse(true)
		Wizard:EnableKeyboard(true)

		Wizard.Close = CreateFrame("Button", nil, Wizard, "UIPanelCloseButtonNoScripts");
		-- Regions
		-- Corner
		Wizard.BottomLeftCorner 	= Wizard:CreateTexture(nil, "BORDER")
		Wizard.BottomRightCorner 	= Wizard:CreateTexture(nil, "BORDER")
		Wizard.TopLeftCorner 		= Wizard:CreateTexture(nil, "BORDER")
		Wizard.TopRightCorner 		= Wizard:CreateTexture(nil, "BORDER")
		-- Border
		Wizard.BottomBorder			= Wizard:CreateTexture(nil, "BORDER")	
		Wizard.TopBorder			= Wizard:CreateTexture(nil, "BORDER")
		Wizard.LeftBorder			= Wizard:CreateTexture(nil, "BORDER")
		Wizard.RightBorder			= Wizard:CreateTexture(nil, "BORDER")
		-- BG
		Wizard.BG					= Wizard:CreateTexture(nil, "BACKGROUND")
		Wizard.Overlay 				= Wizard:CreateTexture(nil, "ARTWORK")
		Wizard.ButtonTex 			= Wizard:CreateTexture(nil, "ARTWORK")
		Wizard.Wrapper 				= Wizard:CreateTexture(nil, "OVERLAY")
		Wizard.TopRight				= Wizard:CreateTexture(nil, "OVERLAY")
		Wizard.TopLeft				= Wizard:CreateTexture(nil, "OVERLAY")
		Wizard.TopMiddle			= Wizard:CreateTexture(nil, "OVERLAY")
		-- Text fields
		Wizard.Header 				= Wizard:CreateFontString(nil, "OVERLAY", "GameFontHighlightMedium", 1)
		Wizard.Status 				= Wizard:CreateFontString(nil, "OVERLAY", "SystemFont_Shadow_Med2")
		Wizard.Binding 				= Wizard:CreateFontString(nil, "OVERLAY", "SplashHeaderFont")
		Wizard.Description 			= Wizard:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge2")
		Wizard.Confirm 				= Wizard:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge2")

		-- Size
		Wizard.BottomLeftCorner:SetSize(209,158)
		Wizard.BottomRightCorner:SetSize(209,158)
		Wizard.TopLeftCorner:SetSize(209,158)
		Wizard.TopRightCorner:SetSize(208,158)

		Wizard.BottomBorder:SetSize(256,86)
		Wizard.TopBorder:SetSize(256,91)
		Wizard.LeftBorder:SetSize(93,256)
		Wizard.RightBorder:SetSize(94,256)	

		Wizard.ButtonTex:SetSize(50, 50)
		Wizard.Wrapper:SetSize(512, 128)
		Wizard.TopRight:SetSize(220,85)
		Wizard.TopLeft:SetSize(219,85)
		Wizard.TopMiddle:SetSize(256,85)

		-- Texture coords
		Wizard.BottomLeftCorner:SetTexCoord(0.00195313, 0.41015625, 0.30468750, 0.61328125)
		Wizard.BottomRightCorner:SetTexCoord(0.41406250, 0.82226563, 0.30468750, 0.61328125)
		Wizard.TopLeftCorner:SetTexCoord(0.00195313, 0.41015625, 0.61718750, 0.92578125)
		Wizard.TopRightCorner:SetTexCoord(0.41406250, 0.82031250, 0.61718750, 0.92578125)

		Wizard.BottomBorder:SetTexCoord(0.00000000, 1.00000000, 0.17187500, 0.33984375)
		Wizard.TopBorder:SetTexCoord(0.00000000, 1.00000000, 0.34375000, 0.52148438)
		Wizard.LeftBorder:SetTexCoord(0.00390625, 0.36718750, 0.00000000, 1.00000000)
		Wizard.RightBorder:SetTexCoord(0.37500000, 0.74218750, 0.00000000, 1.00000000)

		Wizard.TopRight:SetTexCoord(0.00195313, 0.43164063, 0.13476563, 0.30078125)
		Wizard.TopLeft:SetTexCoord(0.43554688, 0.86328125, 0.13476563, 0.30078125)
		Wizard.TopMiddle:SetTexCoord(0.00000000, 1.00000000, 0.00195313, 0.16796875)

		-- Points
		Wizard.BottomLeftCorner:SetPoint("BOTTOMLEFT")
		Wizard.BottomRightCorner:SetPoint("BOTTOMRIGHT")
		Wizard.TopLeftCorner:SetPoint("TOPLEFT")
		Wizard.TopRightCorner:SetPoint("TOPRIGHT")

		Wizard.BottomBorder:SetPoint("BOTTOMLEFT", Wizard.BottomLeftCorner, "BOTTOMRIGHT", 0, 2)
		Wizard.BottomBorder:SetPoint("BOTTOMRIGHT", Wizard.BottomRightCorner, "BOTTOMLEFT", 0, 2)
		Wizard.TopBorder:SetPoint("TOPLEFT", Wizard.TopLeftCorner, "TOPRIGHT", 0, -1)
		Wizard.TopBorder:SetPoint("TOPRIGHT", Wizard.TopRightCorner, "TOPLEFT", 0, -1)
		Wizard.LeftBorder:SetPoint("TOPLEFT", Wizard.TopLeftCorner, "BOTTOMLEFT", 2, 0)
		Wizard.LeftBorder:SetPoint("BOTTOMLEFT", Wizard.BottomLeftCorner, "TOPLEFT", 2, 0)
		Wizard.RightBorder:SetPoint("TOPRIGHT", Wizard.TopRightCorner, "BOTTOMRIGHT", 0, 0)
		Wizard.RightBorder:SetPoint("BOTTOMRIGHT", Wizard.BottomRightCorner, "TOPRIGHT", 0, 0)

		Wizard.BG:SetPoint("TOPLEFT", 20, -20)
		Wizard.BG:SetPoint("BOTTOMRIGHT", -20, 20)
		Wizard.Overlay:SetPoint("TOPLEFT")
		Wizard.Overlay:SetPoint("BOTTOMRIGHT")
		Wizard.ButtonTex:SetPoint("CENTER", Wizard.Wrapper, -142, -4)
		Wizard.Wrapper:SetPoint("CENTER", 0, -20)
		Wizard.TopRight:SetPoint("TOPRIGHT", -42, -44)
		Wizard.TopLeft:SetPoint("TOPLEFT", 42, -44)
		Wizard.TopMiddle:SetPoint("TOPLEFT", Wizard.TopLeft, "TOPRIGHT")
		Wizard.TopMiddle:SetPoint("TOPRIGHT", Wizard.TopRight, "TOPLEFT")

		Wizard.Header:SetPoint("LEFT", Wizard.TopLeft, "LEFT")
		Wizard.Header:SetPoint("RIGHT", Wizard.TopRight, "RIGHT")
		Wizard.Binding:SetPoint("CENTER", Wizard.Wrapper, 10, 0)
		Wizard.Status:SetPoint("TOP", 0, -350)
		Wizard.Description:SetPoint("TOP", 0, -175)
		Wizard.Confirm:SetPoint("TOP", 0, -400)
		Wizard.Close:SetPoint("TOPRIGHT", -10, -10)

		-- File
		local prefix = "Interface\\QuestionFrame\\Question-"
		Wizard.BottomLeftCorner:SetTexture(prefix.."Main")
		Wizard.BottomRightCorner:SetTexture(prefix.."Main")
		Wizard.TopLeftCorner:SetTexture(prefix.."Main")
		Wizard.TopRightCorner:SetTexture(prefix.."Main")

		Wizard.BottomBorder:SetTexture(prefix.."HTile")
		Wizard.TopBorder:SetTexture(prefix.."HTile")
		Wizard.LeftBorder:SetTexture(prefix.."VTile")
		Wizard.RightBorder:SetTexture(prefix.."VTile")	

		Wizard.BG:SetTexture(prefix.."Background")
		Wizard.Overlay:SetTexture(PATH.."Splash"..ConsolePortSettings.type)
		Wizard.Wrapper:SetTexture(PATH.."ButtonWrapper")
		Wizard.TopRight:SetTexture(prefix.."Main")
		Wizard.TopLeft:SetTexture(prefix.."Main")
		Wizard.TopMiddle:SetTexture(prefix.."HTile")

		-- Alpha
		Wizard.Overlay:SetAlpha(0.075)
		Wizard.Status:SetAlpha(0)
		-- Text values
		Wizard.Header:SetText(SETUP.HEADER);
		Wizard.Binding:SetText(SETUP.EMPTY)
		Wizard.Description:SetText(SETUP.HEADLINE);
		-- Bind to frame
		Wizard.BTN = nil
		Wizard.VAL = nil
		Wizard.SET = false
		-- Scripts
		Wizard.Close:SetScript("OnClick", function(...)
			Wizard:Hide();
			PlaySound("SPELLBOOKCLOSE");
		end);
		Wizard:SetScript("OnKeyDown", function(self, key)
			self.Wrapper:SetVertexColor(1, 1, 0.5)
		end);
		Wizard:SetScript("OnKeyUp", function(self, key)
			self.Wrapper:SetVertexColor(1, 1, 1)
			self.Status:SetAlpha(0)
			if self.VAL and self.VAL == key and self.SET then
				if not InCombatLockdown() then
					if not SetBinding(key, self.BTN) then
						self.VAL = nil
						self.Confirm:SetText("")
						self.Status:SetText(SETUP.INVALID)
						self.Status:SetAlpha(1)
					else
						self.Status:SetText(format(SETUP.SUCCESS, self.ButtonTex:GetTexture(), key))
						db.UIFrameFadeIn(self.Status, 3, 1, 0)
						SaveBindings(GetCurrentBindingSet())
						self.Binding:SetText(SETUP.EMPTY)
						self.Confirm:SetText("")
						self.VAL = nil
						return
					end
				else
					self.Status:SetText(SETUP.COMBAT)
				end
			elseif self.VAL and self.VAL == key then
				self.SET = true
				if self.BTN then
					self.Confirm:SetText(format(SETUP.CONFIRM, self.ButtonTex:GetTexture()))
				end
			else
				if self.BTN and GetBindingAction(key) ~= "" then
					self.Confirm:SetText(format(SETUP.OVERRIDE, GetBindingText(key), _G["BINDING_NAME_"..GetBindingAction(key)], self.ButtonTex:GetTexture()))
				elseif self.BTN then
					self.Confirm:SetText(format(SETUP.CONTINUE, self.ButtonTex:GetTexture()))
				end
				self.SET = false
			end
			self.Binding:SetText(key)
			self.VAL = key
		end);
		Wizard:SetScript("OnUpdate", function(self, elapsed)
			if 	ConsolePortSplashFrame and
				ConsolePortSplashFrame:IsVisible() then
				self:Hide()
			else
				local unassigned = ConsolePort:CheckUnassignedBindings()
				if unassigned then
					self.BTN = unassigned[1];
					if self.BTN then
						if self.BTN == "CP_TR1" then
							self.ButtonTex:SetTexture(db.TEXTURE.RONE)
						elseif self.BTN == "CP_TR2" then
							self.ButtonTex:SetTexture(db.TEXTURE.RTWO)
						else
							self.ButtonTex:SetTexture(db.TEXTURE[strupper(db.NAME[self.BTN])])
						end
					end
				else
					self:Hide()
				end
			end
		end)
	elseif self:CheckUnassignedBindings() then
		ConsolePortWizardFrame:Show()
		PlaySound("SPELLBOOKOPEN")
	end
end


function ConsolePort:CreateSplashFrame()
	if not ConsolePortSplashFrame then
		local A = "TOPLEFT"
		local B = "TOPRIGHT"
		local C = "TOP"
		local P = {
			off 	= { X = 512, 	Y =  -512	},
			gra		= { L = -200, 	R =  200	},
			cro		= { X = -14,	Y = -10,	},
			btn		= { L = -210, 	R =  210,	Y = 10 },
			txt 	= { L = -175,	R = 175, 	Y = -90},
			sha 	= { Y = -38 },
			rot 	= { P = 0.523598776, N = -0.523598776 },
			size 	= { X = 710 }
		}
		local S = {
			main 	= { x = 902, y = 581 },
			button 	= { x = 350, y = 390 },
		}
		local Splash = CreateFrame("Frame", "ConsolePortSplashFrame", UIParent);
		local SplashHelpButton = CreateFrame("Button", nil, Splash, "MainHelpPlateButton");
		local SplashPlaystationButton = CreateFrame("Button", nil, Splash);
		local SplashXboxButton = CreateFrame("Button", nil, Splash);
		local SplashCloseButton = CreateFrame("Button", nil, Splash, "UIPanelCloseButtonNoScripts");
		SplashPlaystationButton:SetSize(S.button.x, S.button.y);
		SplashXboxButton:SetSize(S.button.x, S.button.y);
		Splash:SetFrameStrata("DIALOG");
		Splash:SetWidth(S.main.x);
		Splash:SetHeight(S.main.y);
		Splash:EnableMouse(true);
		-- Regions
		local SplashTop 		= Splash:CreateTexture(nil, "ARTWORK", nil, 2);
		local SplashLeftTop 	= Splash:CreateTexture(nil, "BACKGROUND");
		local SplashLeftBottom 	= Splash:CreateTexture(nil, "BACKGROUND");
		local SplashRightTop 	= Splash:CreateTexture(nil, "BACKGROUND");
		local SplashRightBottom = Splash:CreateTexture(nil, "BACKGROUND");
			-- Playstation
		local SplashPlaystation = Splash:CreateTexture(nil, "ARTWORK");
		local SplashPlaystationHighlight = Splash:CreateTexture(nil, "ARTWORK", nil, 1);
			-- Xbox
		local SplashXbox 		= Splash:CreateTexture(nil, "ARTWORK");
		local SplashXboxHighlight = Splash:CreateTexture(nil, "ARTWORK", nil, 1);
			-- Header
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
		-- Resize and rotate
		SplashHelpButton:SetSize(75,75);
		SplashPlaystation:SetSize(P.size.X, P.size.X);
		SplashPlaystationHighlight:SetSize(P.size.X, P.size.X);
		SplashXbox:SetSize(P.size.X, P.size.X);
		SplashXboxHighlight:SetSize(P.size.X, P.size.X);
		SplashPlaystation:SetRotation(P.rot.N);
		SplashPlaystationHighlight:SetRotation(P.rot.N);
		SplashXbox:SetRotation(P.rot.P);
		SplashXboxHighlight:SetRotation(P.rot.P);
		-- Points
		SplashHelpButton:SetPoint(C, 0, -128);
		SplashTop:SetPoint(C, 0, 0);
		SplashLeftTop:SetPoint(A);
		SplashLeftBottom:SetPoint(A, 0, P.off.Y);
		SplashRightTop:SetPoint(B, 0, 0);
		SplashRightBottom:SetPoint(B, 0, P.off.Y);
		SplashHeader:SetPoint(C, 0, -16);
		SplashCloseButton:SetPoint(B, P.cro.X, P.cro.Y);
		SplashPlaystation:SetPoint(C, P.gra.R, P.btn.Y);
		SplashPlaystationHighlight:SetPoint(C, P.gra.R, P.btn.Y);
		SplashPlaystationButton:SetPoint("CENTER", P.btn.R, P.btn.Y-80);
		SplashXbox:SetPoint(C, P.gra.L, P.btn.Y+10);
		SplashXboxHighlight:SetPoint(C, P.gra.L, P.btn.Y+10);
		SplashXboxButton:SetPoint("CENTER", P.btn.L, P.btn.Y-80);
		-- Add references
		Splash.HelpButton 			= SplashHelpButton;
		Splash.Top 					= SplashTop;
		Splash.LeftTop 				= SplashLeftTop;
		Splash.LeftBottom			= SplashLeftBottom;
		Splash.RightTop 			= SplashRightTop;
		Splash.RightBottom 			= SplashRightBottom;
		Splash.Playstation 			= SplashPlaystation;
		Splash.PlaystationHighlight = SplashPlaystationHighlight;
		Splash.Xbox 				= SplashXbox;
		Splash.XboxHighlight 		= SplashXboxHighlight;
		Splash.Header 				= SplashHeader;
		Splash.PlaystationButton 	= SplashPlaystationButton;
		Splash.XboxButton 			= SplashXboxButton;
		-- Text
		SplashHeader:SetText("Select Controller");
		-- Scripts
		SplashPlaystationButton:SetScript("OnEnter", function(self)
			db.UIFrameFadeIn(SplashPlaystationHighlight, 0.1, 0, 1);
		end);
		SplashPlaystationButton:SetScript("OnLeave", function(self)
			db.UIFrameFadeIn(SplashPlaystationHighlight, 0.1, 1, 0);
		end);
		SplashPlaystationButton:SetScript("OnClick", function(...)
			ConsolePortSettings.type = "PS4";
			PlaySound("GLUEENTERWORLDBUTTON");
			ReloadUI();
		end);

		SplashXboxButton:SetScript("OnEnter", function(self)
			db.UIFrameFadeIn(SplashXboxHighlight, 0.1, 0, 1);
		end);
		SplashXboxButton:SetScript("OnLeave", function(self)
			db.UIFrameFadeIn(SplashXboxHighlight, 0.1, 1, 0);
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
		SplashHelpButton:HookScript("OnEnter", function(self)
			HelpPlateTooltip.ArrowRIGHT:Hide();
			HelpPlateTooltip.ArrowGlowRIGHT:Hide();
			HelpPlateTooltip.ArrowUP:Show();
			HelpPlateTooltip.ArrowGlowUP:Show();
			HelpPlateTooltip.Text:SetText(SETUP.CONTROLLER);
			HelpPlateTooltip:SetPoint("LEFT", self, "LEFT", -75, 75);
			HelpPlateTooltip:Show();
		end);
		SplashHelpButton:HookScript("OnClick", function(...)
			db.UIFrameFlash(SplashXboxHighlight, 0.25, 0.25, 0.75, false, 0.25, 0);
			db.UIFrameFlash(SplashPlaystationHighlight, 0.25, 0.25, 0.75, false, 0.25, 0);
		end);
		SplashHelpButton.Ring:SetAlpha(0.5);
		SplashPlaystationHighlight:SetAlpha(0);
		SplashXboxHighlight:SetAlpha(0);
		Splash:SetPoint("CENTER", 0,0);
		Splash.HelpButton.hasPriority = true
		self:AddFrame(Splash)
	end
	ConsolePortSplashFrame:Show();
	PlaySound("SPELLBOOKOPEN");
end