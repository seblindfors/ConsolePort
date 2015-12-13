---------------------------------------------------------------
-- Splash.lua: Init splash frame and binding wizard
---------------------------------------------------------------
-- Creates initial tutorial and helper frames for new users. 

local _, db = ...
local KEY = db.KEY
local SETUP = db.TUTORIAL.SETUP
local PATH = "Interface\\AddOns\\ConsolePort\\Textures\\Splash\\"

-- Determine if the base (unmodified) bindings are assigned.
function ConsolePort:CheckUnassignedBindings()
	local ctrlType = ConsolePortSettings.type
	local ButtonUnassigned = false
	local buttons = self:GetBindingNames()
	local unassigned = {}
	for i, button in pairs(buttons) do
		-- temporary Steam guide button fix, remove this.
		if not (ctrlType == "STEAM" and button == "CP_C_OPTION") then 
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
		local Wizard = db.Atlas.GetSetupWindow("ConsolePortWizardFrame")
		local ctrlType = ConsolePortSettings.type

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

		Wizard.Overlay:SetTexture(PATH.."Splash"..ctrlType)
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
		local Splash = db.Atlas.GetSetupWindow("ConsolePortSplashFrame")
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