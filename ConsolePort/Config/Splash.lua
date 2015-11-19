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

local function SetupWindow(name)
	local self = CreateFrame("Frame", name, UIParent)

	self.Close = CreateFrame("Button", nil, self, "UIPanelCloseButtonNoScripts")
	self.Close:SetScript("OnClick", function(...)
		self:Hide()
		PlaySound("SPELLBOOKCLOSE")
	end)
	-- Regions
	-- Corner
	self.BottomLeftCorner 	= self:CreateTexture(nil, "BORDER")
	self.BottomRightCorner 	= self:CreateTexture(nil, "BORDER")
	self.TopLeftCorner 		= self:CreateTexture(nil, "BORDER")
	self.TopRightCorner 	= self:CreateTexture(nil, "BORDER")
	-- Border
	self.BottomBorder		= self:CreateTexture(nil, "BORDER")	
	self.TopBorder			= self:CreateTexture(nil, "BORDER")
	self.LeftBorder			= self:CreateTexture(nil, "BORDER")
	self.RightBorder		= self:CreateTexture(nil, "BORDER")
	-- BG
	self.BG					= self:CreateTexture(nil, "BACKGROUND")
	self.TopRight			= self:CreateTexture(nil, "OVERLAY")
	self.TopLeft			= self:CreateTexture(nil, "OVERLAY")
	self.TopMiddle			= self:CreateTexture(nil, "OVERLAY")
	-- Header
	self.Header 			= self:CreateFontString(nil, "OVERLAY", "GameFontHighlightMedium", 1)

	-- Size
	self.BottomLeftCorner:SetSize(209,158)
	self.BottomRightCorner:SetSize(209,158)
	self.TopLeftCorner:SetSize(209,158)
	self.TopRightCorner:SetSize(208,158)

	self.BottomBorder:SetSize(256,86)
	self.TopBorder:SetSize(256,91)
	self.LeftBorder:SetSize(93,256)
	self.RightBorder:SetSize(94,256)	

	self.TopRight:SetSize(220,85)
	self.TopLeft:SetSize(219,85)
	self.TopMiddle:SetSize(256,85)

	-- Texture coords
	self.BottomLeftCorner:SetTexCoord(0.00195313, 0.41015625, 0.30468750, 0.61328125)
	self.BottomRightCorner:SetTexCoord(0.41406250, 0.82226563, 0.30468750, 0.61328125)
	self.TopLeftCorner:SetTexCoord(0.00195313, 0.41015625, 0.61718750, 0.92578125)
	self.TopRightCorner:SetTexCoord(0.41406250, 0.82031250, 0.61718750, 0.92578125)

	self.BottomBorder:SetTexCoord(0.00000000, 1.00000000, 0.17187500, 0.33984375)
	self.TopBorder:SetTexCoord(0.00000000, 1.00000000, 0.34375000, 0.52148438)
	self.LeftBorder:SetTexCoord(0.00390625, 0.36718750, 0.00000000, 1.00000000)
	self.RightBorder:SetTexCoord(0.37500000, 0.74218750, 0.00000000, 1.00000000)

	self.TopRight:SetTexCoord(0.00195313, 0.43164063, 0.13476563, 0.30078125)
	self.TopLeft:SetTexCoord(0.43554688, 0.86328125, 0.13476563, 0.30078125)
	self.TopMiddle:SetTexCoord(0.00000000, 1.00000000, 0.00195313, 0.16796875)

		-- Points
	self.BottomLeftCorner:SetPoint("BOTTOMLEFT")
	self.BottomRightCorner:SetPoint("BOTTOMRIGHT")
	self.TopLeftCorner:SetPoint("TOPLEFT")
	self.TopRightCorner:SetPoint("TOPRIGHT")

	self.BottomBorder:SetPoint("BOTTOMLEFT", self.BottomLeftCorner, "BOTTOMRIGHT", 0, 2)
	self.BottomBorder:SetPoint("BOTTOMRIGHT", self.BottomRightCorner, "BOTTOMLEFT", 0, 2)
	self.TopBorder:SetPoint("TOPLEFT", self.TopLeftCorner, "TOPRIGHT", 0, -1)
	self.TopBorder:SetPoint("TOPRIGHT", self.TopRightCorner, "TOPLEFT", 0, -1)
	self.LeftBorder:SetPoint("TOPLEFT", self.TopLeftCorner, "BOTTOMLEFT", 2, 0)
	self.LeftBorder:SetPoint("BOTTOMLEFT", self.BottomLeftCorner, "TOPLEFT", 2, 0)
	self.RightBorder:SetPoint("TOPRIGHT", self.TopRightCorner, "BOTTOMRIGHT", 0, 0)
	self.RightBorder:SetPoint("BOTTOMRIGHT", self.BottomRightCorner, "TOPRIGHT", 0, 0)

	self.BG:SetPoint("TOPLEFT", 20, -20)
	self.BG:SetPoint("BOTTOMRIGHT", -20, 20)
	self.TopRight:SetPoint("TOPRIGHT", -42, -44)
	self.TopLeft:SetPoint("TOPLEFT", 42, -44)
	self.TopMiddle:SetPoint("TOPLEFT", self.TopLeft, "TOPRIGHT")
	self.TopMiddle:SetPoint("TOPRIGHT", self.TopRight, "TOPLEFT")

	self.Header:SetPoint("LEFT", self.TopLeft, "LEFT")
	self.Header:SetPoint("RIGHT", self.TopRight, "RIGHT")
	self.Close:SetPoint("TOPRIGHT", -10, -10)

	-- File
	local prefix = "Interface\\QuestionFrame\\Question-"
	self.BottomLeftCorner:SetTexture(prefix.."Main")
	self.BottomRightCorner:SetTexture(prefix.."Main")
	self.TopLeftCorner:SetTexture(prefix.."Main")
	self.TopRightCorner:SetTexture(prefix.."Main")

	self.BottomBorder:SetTexture(prefix.."HTile")
	self.TopBorder:SetTexture(prefix.."HTile")
	self.LeftBorder:SetTexture(prefix.."VTile")
	self.RightBorder:SetTexture(prefix.."VTile")	

	self.BG:SetTexture(prefix.."Background")
	self.TopRight:SetTexture(prefix.."Main")
	self.TopLeft:SetTexture(prefix.."Main")
	self.TopMiddle:SetTexture(prefix.."HTile")
	return self
end

function ConsolePort:CreateBindingWizard()
	if not ConsolePortWizardFrame then
		local Wizard = SetupWindow("ConsolePortWizardFrame") 

		Wizard:SetPoint("CENTER", 0,0)
		Wizard:SetFrameStrata("DIALOG")
		Wizard:SetSize(600,544)
		Wizard:EnableMouse(true)
		Wizard:EnableKeyboard(true)

		-- Regions
		-- BG
		Wizard.Overlay 				= Wizard:CreateTexture(nil, "ARTWORK")
		Wizard.ButtonTex 			= Wizard:CreateTexture(nil, "ARTWORK")
		Wizard.Wrapper 				= Wizard:CreateTexture(nil, "OVERLAY")
		-- Text fields
		Wizard.Status 				= Wizard:CreateFontString(nil, "OVERLAY", "SystemFont_Shadow_Med2")
		Wizard.Binding 				= Wizard:CreateFontString(nil, "OVERLAY", "SplashHeaderFont")
		Wizard.Description 			= Wizard:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge2")
		Wizard.Confirm 				= Wizard:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge2")

		Wizard.ButtonTex:SetSize(50, 50)
		Wizard.Wrapper:SetSize(512, 128)

		Wizard.Overlay:SetPoint("TOPLEFT")
		Wizard.Overlay:SetPoint("BOTTOMRIGHT")
		Wizard.ButtonTex:SetPoint("CENTER", Wizard.Wrapper, -142, -4)
		Wizard.Wrapper:SetPoint("CENTER", 0, -20)

		Wizard.Binding:SetPoint("CENTER", Wizard.Wrapper, 10, 0)
		Wizard.Status:SetPoint("TOP", 0, -350)
		Wizard.Description:SetPoint("TOP", 0, -175)
		Wizard.Confirm:SetPoint("TOP", 0, -400)

		Wizard.Overlay:SetTexture(PATH.."Splash"..ConsolePortSettings.type)
		Wizard.Wrapper:SetTexture(PATH.."ButtonWrapper")

		-- Alpha
		Wizard.Overlay:SetAlpha(0.075)
		Wizard.Status:SetAlpha(0)
		-- Text values
		Wizard.Header:SetText(SETUP.HEADER)
		Wizard.Binding:SetText(SETUP.EMPTY)
		Wizard.Description:SetText(SETUP.HEADLINE)
		-- Bind to frame
		Wizard.BTN = nil
		Wizard.VAL = nil
		Wizard.SET = false
		-- Scripts
		Wizard:SetScript("OnKeyDown", function(self, key)
			self.Wrapper:SetVertexColor(1, 1, 0.5)
		end)
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
		end)
		Wizard:SetScript("OnUpdate", function(self, elapsed)
			if 	ConsolePortSplashFrame and
				ConsolePortSplashFrame:IsVisible() then
				self:Hide()
			else
				local unassigned = ConsolePort:CheckUnassignedBindings()
				if unassigned then
					self.BTN = unassigned[1]
					if self.BTN then
						self.ButtonTex:SetTexture(db.TEXTURE[self.BTN])
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
		local Splash = SetupWindow("ConsolePortSplashFrame")
		local BTN_WIDTH, BTN_HEIGHT, TEX_SIZE, TEX_ROTATION = 200, 390, 710, 0.523598776
		local Controllers = {
			Playstation = {id = "PS4", pos = 1},
			Xbox 		= {id = "XBOX", pos = 2},
			Steam 		= {id = "STEAM", pos = 3},
		}

		local function OnEnter(self)
			db.UIFrameFadeIn(self.Highlight, 0.1, 0, 1)
		end

		local function OnLeave(self)
			db.UIFrameFadeIn(self.Highlight, 0.1, 1, 0)
		end

		local function OnClick(self)
			ConsolePortSettings.type = self.ID
			PlaySound("GLUEENTERWORLDBUTTON")
			ReloadUI()
		end

		Splash.Center = CreateFrame("Frame", nil, Splash)
		Splash.Center:SetPoint("BOTTOM", 0, 50)
		Splash.Center:SetHeight(BTN_HEIGHT)

		for ctrl, info in pairs(Controllers) do
			Splash.Center:SetWidth(Splash.Center:GetWidth() + BTN_WIDTH)

			local Controller = CreateFrame("Button", nil, Splash)
			Splash[ctrl] = Controller

			Controller:SetSize(BTN_WIDTH, BTN_HEIGHT)
			Controller:SetPoint("LEFT", Splash.Center, "LEFT", BTN_WIDTH*(info.pos-1), 0)
			Controller.ID = info.id

			Controller.Normal = Controller:CreateTexture(nil, "ARTWORK", nil, info.pos)
			Controller.Normal:SetSize(TEX_SIZE, TEX_SIZE)
			Controller.Normal:SetPoint("CENTER", 0, 0)
			Controller.Normal:SetTexture(PATH.."Splash"..info.id)
			Controller.Normal:SetRotation(TEX_ROTATION)

			Controller.Highlight = Controller:CreateTexture(nil, "ARTWORK", nil, info.pos+3)
			Controller.Highlight:SetSize(TEX_SIZE, TEX_SIZE)
			Controller.Highlight:SetPoint("CENTER", 0, 0)
			Controller.Highlight:SetTexture(PATH.."Splash"..info.id.."Highlight")
			Controller.Highlight:SetRotation(TEX_ROTATION)
			Controller.Highlight:SetAlpha(0)

			Controller:SetScript("OnEnter", OnEnter)
			Controller:SetScript("OnLeave", OnLeave)
			Controller:SetScript("OnClick", OnClick)
		end

		Splash:SetFrameStrata("DIALOG")
		Splash:SetPoint("CENTER", 0,0)
		Splash:SetSize(750, 550)
		Splash:EnableMouse(true)
		-- Text
		Splash.Header:SetText(SETUP.LAYOUT)
	end
	ConsolePortSplashFrame:Show()
	PlaySound("SPELLBOOKOPEN")
end