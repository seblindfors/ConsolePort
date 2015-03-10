function ConsolePort:CreateSplashFrame()
	if not ConsolePortSplashFrame then
		local A = "TOPLEFT";
		local B = "TOPRIGHT";
		local C = "TOP";
		local Splash = CreateFrame("Frame", "ConsolePortSplashFrame", UIParent);
		local SplashPlaystationButton = CreateFrame("Button", nil, Splash);
		local SplashXboxButton = CreateFrame("Button", nil, Splash);
		local SplashCloseButton = CreateFrame("Button", nil, Splash, "UIPanelCloseButtonNoScripts");
		SplashPlaystationButton:SetSize(350, 390);
		SplashXboxButton:SetSize(350, 390);
		Splash:SetFrameStrata("DIALOG");
		Splash:SetWidth(902);
		Splash:SetHeight(581);
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
		SplashLeftBottom:SetPoint(A, 0, -512);
		SplashRightTop:SetPoint(A, 512, 0);
		SplashRightBottom:SetPoint(A, 512, -512);
		SplashShadow:SetPoint(C, 0, -38);
		SplashHeader:SetPoint(C, -9, -16);
		SplashCloseButton:SetPoint(B, -14, -10);
		SplashPlaystation:SetPoint(C, 290, -160);
		SplashPlaystationHighlight:SetPoint(C, 290, -160);
		SplashPlaystationButton:SetPoint(C, 210, -160);
		SplashXbox:SetPoint(C, -290, -160);
		SplashXboxHighlight:SetPoint(C, -290, -160);
		SplashXboxButton:SetPoint(C, -210, -160);
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
			ReloadUI();
		end);
		SplashCloseButton:SetScript("OnClick", function(...)
			Splash:Hide();
		end);
		SplashPlaystationHighlight:Hide();
		SplashXboxHighlight:Hide();
		Splash:SetPoint("CENTER", 0,0);
	end
	ConsolePortSplashFrame:Show();
end