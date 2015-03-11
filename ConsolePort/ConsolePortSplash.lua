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