---------------------------------------------------------------
-- Splash.lua: Init splash frame and binding wizard
---------------------------------------------------------------
-- Creates initial tutorial and helper frames for new users. 

local _, db = ...
local KEY = db.KEY
local SETUP = db.TUTORIAL.SETUP

-- Determine if the base (unmodified) bindings are assigned.
function ConsolePort:CheckUnassignedBindings()
	local ctrlType = db.Settings.type
	local ButtonUnassigned = false
	local buttons = self:GetBindingNames()
	local unassigned = {}
	for i, button in pairs(buttons) do
		-- temporary Steam guide button fix, remove this.
		if not (db.Settings.skipGuideBtn and button == "CP_C_OPTION") then
			local key1, key2 = GetBindingKey(button)
			if not key1 and not key2 then
				ButtonUnassigned = true
				tinsert(unassigned, button)
			end
		end
	end
	if not ButtonUnassigned then unassigned = nil end
	return unassigned
end

function ConsolePort:CreateBindingWizard()
	if not ConsolePortWizardFrame then
		local Wizard = db.Atlas.GetFutureWindow("ConsolePortWizardFrame")
		local ctrlType = db.Settings.type
		local red, green, blue = db.Atlas.GetCC()

		Wizard.Reload = db.Atlas.GetFutureButton("$parentReload", Wizard)
		Wizard.Container = CreateFrame("Frame", "$parentContainer", Wizard)
		Wizard.Container:SetBackdrop(db.Atlas.Backdrops.Border)
		Wizard.Container:SetPoint("TOPLEFT", 8, -64)
		Wizard.Container:SetPoint("BOTTOMRIGHT", -8, 8)

		Wizard:SetPoint("CENTER", 0,0)
		Wizard:SetFrameStrata("DIALOG")
		Wizard:SetSize(580, 416)
		Wizard:Hide()
		Wizard:Show()

		if ctrlType ~= "PS4" then

			Wizard.Skip = db.Atlas.GetFutureButton("$parentSkip", Wizard)
			Wizard.Skip:SetPoint("BOTTOM", 0, 24)
			Wizard.Skip:SetText(SETUP.SKIPGUIDE)
			Wizard.Skip:Hide()
			Wizard.Reload:SetScript("OnShow", function(self)
				Wizard.Reload:Hide()
			end)
			Wizard.Skip:SetScript("OnClick", function()
				db.Settings.skipGuideBtn = true
				self:CheckUnassignedBindings()
			end)
		end

		Wizard.Reload:SetPoint("BOTTOM", 0, 24)
		Wizard.Reload:SetText(SETUP.CONTINUECLICK)
		Wizard.Reload:Hide()
		Wizard.Reload:SetScript("OnShow", function(self)
			if Wizard.Skip and Wizard.Skip:IsVisible() then
				self:Hide()
			end
		end)
		Wizard.Reload:SetScript("OnClick", function(self)
			if not InCombatLockdown() then
				ReloadUI()
			end
		end)

		Wizard.Overlay:SetAlpha(0.035)

		-- Regions
		-- BG
		Wizard.Controller 	= Wizard:CreateTexture(nil, "ARTWORK", nil, 7)
		Wizard.ButtonRim 	= Wizard:CreateTexture(nil, "OVERLAY", nil, 5)
		Wizard.ButtonTex 	= Wizard:CreateTexture(nil, "OVERLAY", nil, 6)
		Wizard.ButtonPress 	= Wizard:CreateTexture(nil, "OVERLAY", nil, 7)
		Wizard.Wrapper 		= Wizard:CreateTexture(nil, "ARTWORK", nil, 6)
		-- Text fields
		Wizard.Header 		= Wizard:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
		Wizard.Status 		= Wizard:CreateFontString(nil, "OVERLAY", "SystemFont_Shadow_Med2")
		Wizard.Binding 		= Wizard:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge2")
		Wizard.Description 	= Wizard:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		Wizard.Confirm 		= Wizard:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")

		-- FontStrings
		Wizard.Header:SetPoint("TOP", 0, -40)
		Wizard.Header:SetText(SETUP.HEADER)

		Wizard.Status:SetPoint("CENTER", 0, -54)
		Wizard.Status:SetAlpha(0)

		Wizard.Binding:SetPoint("CENTER", 0, 0)
		Wizard.Binding:SetText(SETUP.EMPTY)
		Wizard.Binding:SetJustifyH("CENTER")

		Wizard.Description:SetText(SETUP.HEADLINE)
		Wizard.Description:SetPoint("TOP", Wizard.Wrapper, 0, 50)

		Wizard.Confirm:SetPoint("BOTTOM", 0, 72)

		-- Textures
		Wizard.ButtonTex:SetSize(50, 50)
		Wizard.ButtonTex:SetPoint("CENTER", Wizard.Wrapper, -142, 0)

		Wizard.ButtonPress:SetSize(50, 50)
		Wizard.ButtonPress:SetPoint("CENTER", Wizard.ButtonTex, 0, 2)
		Wizard.ButtonPress:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\IconMask")
		Wizard.ButtonPress:Hide()

		Wizard.ButtonRim:SetSize(60, 60)
		Wizard.ButtonRim:SetPoint("CENTER", Wizard.Wrapper, -142, 0)
		Wizard.ButtonRim:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\IconMask64")

		Wizard.Wrapper:SetSize(400, 72)
		Wizard.Wrapper:SetPoint("CENTER", 0, 0)
		Wizard.Wrapper:SetTexCoord(0, 0.640625, 0, 1)
		Wizard.Wrapper:SetTexture("Interface\\AddOns\\ConsolePort\\Textures\\Window\\Highlight")
		Wizard.Wrapper:SetBlendMode("ADD")
		Wizard.Wrapper:SetGradientAlpha("HORIZONTAL", red, green, blue, 1, 1, 1, 1, 1)

		Wizard.Controller:SetSize(512, 512)
		Wizard.Controller:SetPoint("CENTER", 0, 0)
		Wizard.Controller:SetTexture("Interface\\AddOns\\ConsolePort\\Controllers\\"..ctrlType.."\\Front")
		Wizard.Controller:SetPoint("TOPLEFT", 8, -8)
		Wizard.Controller:SetPoint("BOTTOMRIGHT", -8, 8)
		Wizard.Controller:SetTexCoord(0.345703125, 0.0625, 0.0703125, 0.53515625, 1, 0.4453125, 0.73046875, 0.91796875)
		Wizard.Controller:SetAlpha(0.075)

		-- Scripts
		Wizard:SetScript("OnKeyDown", function(self, key)
			self.ButtonPress:Show()
			self.ButtonTex:SetPoint("CENTER", self.Wrapper, -142, -2)
		end)
		Wizard:SetScript("OnKeyUp", function(self, key)
			self.ButtonTex:SetPoint("CENTER", self.Wrapper, -142, 0)
			self.ButtonPress:Hide()
			self.Reload:Hide()
			self.Status:SetAlpha(0)
			if self.VAL and self.VAL == key and self.SET then
				if not InCombatLockdown() then
					if not SetBinding(key, self.BTN) then
						local isTrigger = self.BTN:match("CP_T")
						local changeModifier = isTrigger and (key:match("SHIFT") and "shift" or key:match("CTRL") and "ctrl")
						if changeModifier then
							self:SetScript("OnUpdate", nil)
							self:EnableKeyboard(false)

							local settings = db.Settings
							local pairsByKeys = db.Table.pairsByKeys
							
							local triggers = {
								["CP_TL1"] = true,
								["CP_TL2"] = true,
								["CP_TR1"] = true,
								["CP_TR2"] = true,
 							}

 							local keys = {
 								changeModifier == "shift" and "ctrl" or "shift",
 								"trigger1",
 								"trigger2",
 							}

 							local newModifier = self.ButtonTex:GetTexture():match("CP_T%a%d")

 							triggers[newModifier] = nil
 							settings[changeModifier] = newModifier

 							local i, key
 							for trigger in pairsByKeys(triggers) do
 								i, key = next(keys, i)
 								settings[key] = trigger
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
					self.Confirm:SetText(format(SETUP.OVERRIDE, GetBindingText(key), _G["BINDING_NAME_"..GetBindingAction(key)] or SETUP.NOEXISTFIX, self.ButtonTex:GetTexture()))
				elseif self.BTN then
					self.Confirm:SetText(format(SETUP.CONTINUE, self.ButtonTex:GetTexture()))
				end
				self.SET = false
			end
			self.Binding:SetText(key)
			self.VAL = key
		end)
		Wizard:SetScript("OnUpdate", function(self, elapsed)
			if 	ConsolePortSplashFrame and ConsolePortSplashFrame:IsVisible() then
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
				local unassigned = ConsolePort:CheckUnassignedBindings()
				if unassigned then
					self.BTN = unassigned[1]
					if self.Skip and self.BTN == "CP_C_OPTION" then
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
	elseif self:CheckUnassignedBindings() then
		ConsolePortWizardFrame:Show()
		PlaySound("SPELLBOOKOPEN")
	end
end

function ConsolePort:CreateSplashFrame()
	if not ConsolePortSplashFrame then
	--	local Splash = db.Atlas.GetSetupWindow("ConsolePortSplashFrame")
		local Splash = db.Atlas.GetFutureWindow("ConsolePortSplashFrame")
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
			db.Settings.type = self.ID

			for key, value in pairs(db.Controllers[self.ID].Settings) do
				db.Settings[key] = value
			end

			db.Settings.newController = true

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
			pos = pos + 1

			Splash.Center:SetWidth(Splash.Center:GetWidth() + BTN_WIDTH)

			local Controller = CreateFrame("Button", nil, Splash)
			Splash[name] = Controller

			Controller:SetSize(BTN_WIDTH, BTN_HEIGHT)
			Controller:SetPoint("LEFT", Splash.Center, "LEFT", BTN_WIDTH*(pos-1), 0)
			Controller.ID = name

			Controller.Normal = Controller:CreateTexture(nil, "ARTWORK", nil, pos)
			Controller.Normal:SetSize(TEX_SIZE, TEX_SIZE)
			Controller.Normal:SetPoint("CENTER", 0, 0)
			Controller.Normal:SetTexture("Interface\\AddOns\\ConsolePort\\Controllers\\"..name.."\\Front")
			Controller.Normal:SetRotation(TEX_ROTATION)

			Controller.Highlight = Controller:CreateTexture(nil, "ARTWORK", nil, pos+3)
			Controller.Highlight:SetSize(TEX_SIZE, TEX_SIZE)
			Controller.Highlight:SetPoint("CENTER", 0, 0)
			Controller.Highlight:SetTexture("Interface\\AddOns\\ConsolePort\\Controllers\\"..name.."\\FrontHighlight")
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
		Splash:Hide()
		Splash:Show()
		-- Text
	--	Splash.Header:SetText(SETUP.LAYOUT)
	end
	ConsolePortSplashFrame:Show()
	PlaySound("SPELLBOOKOPEN")
end