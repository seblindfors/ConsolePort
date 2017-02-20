---------------------------------------------------------------
-- Splash.lua: Init splash frame and binding wizard
---------------------------------------------------------------
-- Creates initial tutorial and helper frames for new users. 

local _, db = ...
local KEY = db.KEY
local SETUP = db.TUTORIAL.SETUP

-- Determine if the base (unmodified) bindings are assigned.
function ConsolePort:CheckCalibration(forceCustom)
	if not db.Settings.skipCalibration then
		local ctrlType = db.Settings.type

		-- if this is not a forced custom calibration, load bindings from disk.
		if not forceCustom then
			local calibration = db.Settings.calibration
			if calibration then
				for binding, key in pairs(calibration) do
					SetBinding(key, binding)
				end
			end
		end

		-- no calibration data found, go to custom calibration.
		local unassigned
		for button in self:GetBindings() do
			if 	not (db.Settings.skipGuideBtn and button == "CP_X_CENTER") and not button:match("CP_T_.3") then
				local key1, key2 = GetBindingKey(button)
				if not key1 and not key2 then
					if not unassigned then
						unassigned = { button }
					else
						unassigned[#unassigned + 1] = button
					end
				end
			end
		end
		return unassigned
	end
end

function ConsolePort:CalibrateController(reset)
	if reset then
		db.Settings.calibration = nil
		for button in self:GetBindings() do
			if not button:match("CP_T_.3") then -- ignore mouse buttons
				local key1, key2 = GetBindingKey(button)
				if key1 then SetBinding(key1) end
				if key2 then SetBinding(key2) end
			end
		end
	end
	if not self.calibrationFrame then
		local cbF = db.Atlas.GetFutureWindow("ConsolePortCalibrationFrame", nil, nil, nil, nil, true)
		local ctrlType = db.Settings.type
		local red, green, blue = db.Atlas.GetCC()

		self.calibrationFrame = cbF

		cbF.Reload = db.Atlas.GetFutureButton("$parentReload", cbF)
		cbF.Container = CreateFrame("Frame", "$parentContainer", cbF)
		cbF.Container:SetBackdrop(db.Atlas.Backdrops.Border)
		cbF.Container:SetPoint("TOPLEFT", 8, -64)
		cbF.Container:SetPoint("BOTTOMRIGHT", -8, 8)

		cbF.HelpButton = CreateFrame("Button", "$parentHelpButton", cbF)
		cbF.HelpButton:SetSize(64, 64)
		cbF.HelpButton:SetNormalTexture("Interface\\Common\\help-i")
		cbF.HelpButton:SetHighlightTexture("Interface\\Common\\help-i")
		cbF.HelpButton:SetPoint("BOTTOMRIGHT", -16, 16)
		cbF.HelpButton:SetScript("OnEnter", function(self)
			GameTooltip:Hide()
			GameTooltip:SetOwner(self, "ANCHOR_TOP")
			GameTooltip:SetText(SETUP.WTFTEXT)
			GameTooltip:Show()
		end)
		cbF.HelpButton:SetScript("OnLeave", function(self)
			GameTooltip:Hide()
		end)

		-- Show the clarifying helper frame if the user is confused about mapping their controller.
		cbF.HelpButton:SetScript("OnClick", function(self)
			if not cbF.helpFrame then
				local ctrlType = db.Settings.type
				local helpFrame = db.Atlas.GetFutureWindow("ConsolePortCalibrationHelpFrame", nil, nil, nil, nil, true)
				helpFrame:SetPoint("CENTER", 0,0)
				helpFrame:SetFrameStrata("DIALOG")
				helpFrame:SetSize(760, 350)

				helpFrame.MapperTexture = helpFrame:CreateTexture(nil, "ARTWORK")
				helpFrame.MapperTexture:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\UIAsset")
				helpFrame.MapperTexture:SetTexCoord(0, 576/1024, 921/1024, 1)
				helpFrame.MapperTexture:SetSize(576, 103)
				helpFrame.MapperTexture:SetPoint("CENTER", 70, -20)

				helpFrame.Controller = helpFrame:CreateTexture(nil, "ARTWORK")
				helpFrame.Controller:SetSize(165, 165)
				helpFrame.Controller:SetPoint("RIGHT", helpFrame.MapperTexture, "LEFT", 10, 0)
				helpFrame.Controller:SetTexture("Interface\\AddOns\\ConsolePort\\Controllers\\"..ctrlType.."\\Front")

				helpFrame.Continue = db.Atlas.GetFutureButton("$parentContinue", helpFrame)
				helpFrame.Continue:SetText(SETUP.CONTINUECLICK)
				helpFrame.Continue:SetScript("OnClick", function(self)
					helpFrame:Hide()
					ConsolePort:CalibrateController()
				end)

				-- WoWmapper post-init launch and no exported calibration was found.
				-- Add a button to omit the calibration thus far and reload
				-- to get the new calibration data from the WoWmapper client.
				if IsWindowsClient() and db.Controllers[ctrlType].WoWmapper then
					helpFrame.Continue:SetPoint("BOTTOMRIGHT", helpFrame, "BOTTOM", -10, 24)
					helpFrame.Reload = db.Atlas.GetFutureButton("$parentReload", helpFrame)
					helpFrame.Reload:SetText(SETUP.LOADWOWMAPPER)
					helpFrame.Reload:SetPoint("BOTTOMLEFT", helpFrame, "BOTTOM", 10, 24)
					helpFrame.Reload:SetScript("OnClick", function(self)
						db.Settings.calibration = nil
						ReloadUI()
					end)
				else
					helpFrame.Continue:SetPoint("BOTTOM", 0, 24)
				end

				helpFrame.LinkBox = CreateFrame("EditBox", "$parentLinkBox", helpFrame, "InputBoxTemplate")
				helpFrame.LinkBox:SetPoint("CENTER", 0, 54)
				helpFrame.LinkBox:SetSize(200, 12)
				helpFrame.LinkBox:Hide()

				helpFrame.LinkBox:SetScript("OnShow", function(self) self:SetText(self.link or "") end)
				helpFrame.LinkBox:SetScript("OnEditFocusGained", function(self) self:SetText(self.link or "") end)

				helpFrame.Description = helpFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
				helpFrame.Description:SetPoint("TOP", 0, -46)

				-- Add instructions and links to the helper frame, if available.
				local instructions, link
				if IsWindowsClient() then
					instructions = db.Controllers[ctrlType].Win
					link = db.Controllers[ctrlType].LinkWin
				elseif IsMacClient() then
					instructions = db.Controllers[ctrlType].Mac
					link = db.Controllers[ctrlType].LinkMac
				end

				helpFrame.Description:SetFormattedText(SETUP.AHATEXT, instructions or SETUP.NOINSTRUCTIONS)

				if link then
					helpFrame.LinkBox.link = link
					helpFrame.LinkBox:Show()
				end

				helpFrame.Disclaimer = helpFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
				helpFrame.Disclaimer:SetText("|cFF888888"..SETUP.DISCLAIMER.."|r")
				helpFrame.Disclaimer:SetPoint("BOTTOM", 0, 80)

				cbF.helpFrame = helpFrame
			end
			cbF.helpFrame:Show()
			cbF:Hide()
		end)

		cbF:SetPoint("CENTER", 0,0)
		cbF:SetFrameStrata("DIALOG")
		cbF:SetSize(580, 416)

		if ctrlType ~= "PS4" then

			cbF.Skip = db.Atlas.GetFutureButton("$parentSkip", cbF)
			cbF.Skip:SetPoint("BOTTOM", 0, 24)
			cbF.Skip:SetText(SETUP.SKIPGUIDE)
			cbF.Skip:Hide()
			cbF.Reload:SetScript("OnShow", function(self)
				cbF.Reload:Hide()
			end)
			cbF.Skip:SetScript("OnClick", function()
				db.Settings.skipGuideBtn = true
				self:CheckCalibration(true)
			end)
		end

		cbF.Reload:SetPoint("BOTTOM", 0, 24)
		cbF.Reload:SetText(SETUP.CONTINUECLICK)
		cbF.Reload:Hide()
		cbF.Reload:SetScript("OnShow", function(self)
			if cbF.Skip and cbF.Skip:IsVisible() then
				self:Hide()
			end
		end)
		cbF.Reload:SetScript("OnClick", function(self)
			if not InCombatLockdown() then
				ReloadUI()
			end
		end)

		-- Regions
		-- BG
		cbF.Controller 	= cbF:CreateTexture(nil, "ARTWORK", nil, 7)
		cbF.ButtonRim 	= cbF:CreateTexture(nil, "OVERLAY", nil, 5)
		cbF.ButtonTex 	= cbF:CreateTexture(nil, "OVERLAY", nil, 6)
		cbF.ButtonPress = cbF:CreateTexture(nil, "OVERLAY", nil, 7)
		cbF.Wrapper 	= cbF:CreateTexture(nil, "ARTWORK", nil, 6)
		-- Text fields
		cbF.Header 		= cbF:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
		cbF.Status 		= cbF:CreateFontString(nil, "OVERLAY", "SystemFont_Shadow_Med2")
		cbF.Binding 	= cbF:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge2")
		cbF.Description = cbF:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		cbF.Confirm 	= cbF:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")

		-- FontStrings
		cbF.Header:SetPoint("TOP", 0, -40)
		cbF.Header:SetText(SETUP.HEADER)

		cbF.Status:SetPoint("CENTER", 0, -54)
		cbF.Status:SetAlpha(0)

		cbF.Binding:SetPoint("CENTER", 0, 0)
		cbF.Binding:SetText(SETUP.EMPTY)
		cbF.Binding:SetJustifyH("CENTER")

		cbF.Description:SetText(SETUP.HEADLINE)
		cbF.Description:SetPoint("TOP", cbF.Wrapper, 0, 50)

		cbF.Confirm:SetPoint("BOTTOM", 0, 72)

		-- Textures
		cbF.ButtonTex:SetSize(50, 50)
		cbF.ButtonTex:SetPoint("CENTER", cbF.Wrapper, -142, 0)

		cbF.ButtonPress:SetSize(50, 50)
		cbF.ButtonPress:SetPoint("CENTER", cbF.ButtonTex, 0, 2)
		cbF.ButtonPress:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\IconMask")
		cbF.ButtonPress:Hide()

		cbF.ButtonRim:SetSize(60, 60)
		cbF.ButtonRim:SetPoint("CENTER", cbF.Wrapper, -142, 0)
		cbF.ButtonRim:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\IconMask64")

		cbF.Wrapper:SetSize(400, 72)
		cbF.Wrapper:SetPoint("CENTER", 0, 0)
		cbF.Wrapper:SetTexCoord(0, 0.640625, 0, 1)
		cbF.Wrapper:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Window\\Highlight")
		cbF.Wrapper:SetBlendMode("ADD")
		cbF.Wrapper:SetGradientAlpha("HORIZONTAL", red, green, blue, 1, 1, 1, 1, 1)

		cbF.Controller:SetTexture("Interface\\AddOns\\ConsolePort\\Controllers\\"..ctrlType.."\\Front")
		cbF.Controller:SetPoint("TOPLEFT", 16, -16)
		cbF.Controller:SetPoint("BOTTOMRIGHT", -16, 16)
		cbF.Controller:SetTexCoord(0.345703125, 0.0625, 0.0703125, 0.53515625, 1, 0.4453125, 0.73046875, 0.91796875)
		cbF.Controller:SetAlpha(0.075)

		local forbidden = {
			W = BINDING_NAME_MOVEFORWARD,	UP = BINDING_NAME_MOVEFORWARD,
			A = BINDING_NAME_STRAFELEFT,	LEFT = BINDING_NAME_STRAFELEFT,
			S = BINDING_NAME_MOVEBACKWARD,	DOWN = BINDING_NAME_MOVEBACKWARD,
			D = BINDING_NAME_STRAFERIGHT,	RIGHT = BINDING_NAME_STRAFERIGHT,
		}

		-- Scripts
		cbF:SetScript("OnKeyDown", function(self, key)
			if key == "ESCAPE" then
				self:Hide()
				return
			elseif forbidden[key] then
				self.Status:SetFormattedText(SETUP.RESERVED, key, forbidden[key])
				self.Status:SetAlpha(1)
				return
			end
			self.ButtonPress:Show()
			self.ButtonTex:SetPoint("CENTER", self.Wrapper, -142, -2)
		end)

		cbF:SetScript("OnKeyUp", function(self, key)
			if key == "ESCAPE" or forbidden[key] then return end
			self.ButtonTex:SetPoint("CENTER", self.Wrapper, -142, 0)
			self.ButtonPress:Hide()
			self.Reload:Hide()
			self.Status:SetAlpha(0)
			if self.VAL and self.VAL == key and self.SET then
				if not InCombatLockdown() then
					if not SetBinding(key, self.BTN) then
						local isTrigger = self.BTN:match("CP_T")
						local changeModifier = isTrigger and (key:match("SHIFT") and "CP_M1" or key:match("CTRL") and "CP_M2")
						if changeModifier then
							self:SetScript("OnUpdate", nil)
							self:EnableKeyboard(false)

							local settings = db.Settings

							local otherModifierKey = changeModifier == "CP_M1" and "CP_M2" or "CP_M1"
							local otherModifier = settings[otherModifierKey]
							
							local shoulder = {
								["CP_TL1"] = true,
								["CP_TL2"] = true,
								["CP_TR1"] = true,
								["CP_TR2"] = true,
								["CP_L_GRIP"] = true,
								["CP_R_GRIP"] = true,
 							}

 							local ordered = {
 								"CP_TL1",
 								"CP_TL2",
 								"CP_TR1",
 								"CP_TR2",
 								"CP_L_GRIP",
 								"CP_R_GRIP",
 							}

 							local newModifier = self.ButtonTex:GetTexture():match("CP_.+")

 							shoulder[newModifier] = nil
 							shoulder[otherModifier] = nil
 							settings[changeModifier] = newModifier

 							local i = 0
 							for k, button in pairs(ordered) do
 								if shoulder[button] then
	 								i = i + 1
	 								settings["CP_T"..i] = button
	 							end
 							end

							self.Reload:Show()
							self.Status:SetText(SETUP.NEWMODIFIER)
						else
							self.Status:SetText(SETUP.INVALID)
						end
						self.VAL = nil
						self.Confirm:SetText("")
						self.Status:SetAlpha(1)
					else
						if not db.Settings.calibration then
							db.Settings.calibration = {}
						else
							for btn, cKey in pairs(db.Settings.calibration) do
								if key == cKey then
									db.Settings.calibration[btn] = nil
								end
							end
						end
						db.Settings.calibration[self.BTN] = key
						self.Status:SetFormattedText(SETUP.SUCCESS, self.ButtonTex:GetTexture(), key)
						db.UIFrameFadeIn(self.Status, 3, 1, 0)
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
					self.Confirm:SetFormattedText(SETUP.CONFIRM, self.ButtonTex:GetTexture())
				end
			else
				if self.BTN then
					local action = GetBindingAction(key)
					if db.Settings.calibration and db.Settings.calibration[action] then
						self.Confirm:SetFormattedText(SETUP.OVERRIDE_C, GetBindingText(key), _G["BINDING_NAME_"..GetBindingAction(key)] or SETUP.NOEXISTFIX, self.ButtonTex:GetTexture())
					elseif action ~= "" then
						self.Confirm:SetFormattedText(SETUP.OVERRIDE, GetBindingText(key), _G["BINDING_NAME_"..GetBindingAction(key)] or SETUP.NOEXISTFIX, self.ButtonTex:GetTexture())
					else

						self.Confirm:SetFormattedText(SETUP.CONTINUE, self.ButtonTex:GetTexture())
					end
				end
				self.SET = false
			end
			self.Binding:SetText(GetBindingText(key))
			self.VAL = key
		end)
		cbF:SetScript("OnUpdate", function(self, elapsed)
			if 	(ConsolePortSplashFrame and ConsolePortSplashFrame:IsVisible()) or
				(HelpFrame and HelpFrame:IsVisible()) then
				self:Hide()
			elseif ConsolePortConfig and ConsolePortConfig:IsVisible() then
				self.Close:Hide()
				self:SetAlpha(0)
				self:EnableKeyboard(false)
				self:EnableMouse(false)
			else
				self.Close:Show()
				self:SetAlpha(1)
				self:EnableKeyboard(true)
				self:EnableMouse(true)
				local unassigned = ConsolePort:CheckCalibration(true)
				if unassigned then
					self.BTN = unassigned[1]
					if self.Skip and self.BTN == "CP_X_CENTER" then
						self.Skip:Show()
					elseif self.Skip then
						self.Skip:Hide()
					end
					if self.BTN then
						self.ButtonTex:SetTexture(db.TEXTURE[self.BTN])
					end
				else
					self:Hide()
				end
			end
		end)
		cbF:SetScript("OnHide", function(self)
			if self.helpFrame and self.helpFrame:IsVisible() then
				return
			end
			if ConsolePort.CheckLoadedSettings then
				ConsolePort:CheckLoadedSettings()
			end
		end)
	elseif self:CheckCalibration(true) then
		ConsolePortCalibrationFrame:Show()
		PlaySound("SPELLBOOKOPEN")
	end
end

function ConsolePort:SelectController()
	if not ConsolePortSplashFrame then
		local Splash = db.Atlas.GetFutureWindow("ConsolePortSplashFrame")
		local BTN_WIDTH, BTN_HEIGHT, TEX_SIZE, TEX_ROTATION = 200, 390, 600, 0.523598776
		Splash.Controllers = {}

		local function OnEnter(self)
			for _, controller in pairs(Splash.Controllers) do
				db.UIFrameFadeOut(controller, 0.1, controller:GetAlpha(), 0.25)
			end
			db.UIFrameFadeIn(self, 0.1, self:GetAlpha(), 1)
		end

		local function OnLeave(self)
			for _, controller in pairs(Splash.Controllers) do
				db.UIFrameFadeIn(controller, 0.1, controller:GetAlpha(), 1)
			end
		end

		local function OnClick(self)
			db.Settings.type = self.ID

			for key, value in pairs(db.Controllers[self.ID].Settings) do
				db.Settings[key] = value
			end

			db.Settings.newController = true
			db.Settings.forceController = self.ID

			PlaySound("GLUEENTERWORLDBUTTON")
			ReloadUI()
		end

		Splash.Header = Splash:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
		Splash.Header:SetPoint("TOP", 0, -40)
		Splash.Header:SetText(SETUP.LAYOUT)

		Splash.Container = CreateFrame("Frame", "$parentContainer", Splash)
		Splash.Container:SetBackdrop(db.Atlas.Backdrops.Border)
		Splash.Container:SetPoint("TOPLEFT", 8, -64)
		Splash.Container:SetPoint("BOTTOMRIGHT", -8, 8)

		Splash.Center = CreateFrame("Frame", "$parentCenter", Splash)
		Splash.Center:SetPoint("CENTER", -24, 0)
		Splash.Center:SetHeight(BTN_HEIGHT)

		local pos = 0
		for name, template in pairs(db.Controllers) do
			if not template.Hide then
				pos = pos + 1

				Splash.Center:SetWidth(Splash.Center:GetWidth() + BTN_WIDTH)

				local Controller = CreateFrame("Button", nil, Splash)
				Splash[name] = Controller

				Controller.Strata = pos

				Controller:SetSize(BTN_WIDTH, BTN_HEIGHT)
				Controller:SetPoint("LEFT", Splash.Center, "LEFT", BTN_WIDTH*(pos-1), 0)
				Controller.ID = name

				Controller.Normal = Controller:CreateTexture(nil, "ARTWORK", nil, pos*2)
				Controller.Normal:SetSize(TEX_SIZE, TEX_SIZE)
				Controller.Normal:SetPoint("CENTER", 0, 0)
				Controller.Normal:SetTexture("Interface\\AddOns\\ConsolePort\\Controllers\\"..name.."\\Front")
				Controller.Normal:SetRotation(TEX_ROTATION)

				Controller:SetScript("OnEnter", OnEnter)
				Controller:SetScript("OnLeave", OnLeave)
				Controller:SetScript("OnClick", OnClick)

				Splash.Controllers[#Splash.Controllers + 1] = Controller
			end
		end

		Splash:SetFrameStrata("DIALOG")
		Splash:SetPoint("CENTER", 0,0)
		Splash:SetSize(750, 550)
		Splash:EnableMouse(true)
		Splash:SetScript("OnShow", MouselookStop)
		Splash:Hide()
		Splash:Show()
	end
	ConsolePortSplashFrame:Show()
	PlaySound("SPELLBOOKOPEN")
end