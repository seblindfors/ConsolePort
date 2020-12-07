local name, env = ...;
local Menu, Cursor = CreateFrame('Frame', 'ConsolePortGameMenu', GameMenuFrame, 'CPFullscreenMenuTemplate'), ConsolePortSecureCursor;

do	-- Initiate frame
	local headerTemplates = {'SecureHandlerBaseTemplate', 'SecureHandlerClickTemplate', 'CPMenuListCategoryTemplate'}; 
	local baseTemplates   = {'CPMenuButtonBaseTemplate', 'SecureActionButtonTemplate'};
	local hideMenuHook    = {hidemenu = true};

	LibStub('Carpenter')(Menu, {
		Character = {
			_ID    = 1;
			_Type  = 'CheckButton';
			_Setup = headerTemplates;
			_Text  = '|TInterface\\Store\\category-icon-armor:18:18:-4:0:64:64:14:50:14:50|t' .. CHARACTER;
			{
				Info = {
					_ID = 1;
					_Type  = 'Button';
					_Setup = baseTemplates;
					_Point = {'TOPLEFT', '$parent.$parent', 'BOTTOMLEFT', 16, -16};
					_Text  = CHARACTER_BUTTON;
					_Attributes = hideMenuHook;
					--------------------------------------
					_UpdateLevel = function(self, newLevel)
						local level = newLevel or UnitLevel('player')
						if ( level and level < MAX_PLAYER_LEVEL ) then
							self.Level:SetTextColor(1, 0.8, 0)
							self.Level:SetText(level)
						else
							self.Level:SetTextColor(CPAPI.GetItemLevelColor())
							self.Level:SetText(CPAPI.GetAverageItemLevel())
						end
					end;
					_OnClick = function(self) ToggleCharacter('PaperDollFrame') end;
					_OnEvent = function(self, event, ...)
						if event == 'UNIT_PORTRAIT_UPDATE' then
							SetPortraitTexture(self.Icon, 'player')
						elseif event == 'PLAYER_LEVEL_UP' then
							self:UpdateLevel(...)
						else
							SetPortraitTexture(self.Icon, 'player')
							self:UpdateLevel()
						end
					end;
					_RegisterUnitEvent = {'UNIT_PORTRAIT_UPDATE', 'player'};
					_Events = {'PLAYER_ENTERING_WORLD', 'PLAYER_LEVEL_UP'};
					{
						Level = {
							_Type   = 'FontString';
							_Setup  = {'OVERLAY'};
							_Font   = {Game12Font:GetFont()};
							_AlignH = 'RIGHT';
							_Point  = {'RIGHT', -10, 0},
						};
					};
				};
				Inventory = {
					_ID = 2;
					_Type  = 'Button';
					_Setup = baseTemplates;
					_Point = {'TOP', '$parent.Info', 'BOTTOM', 0, 0};
					_Text  = INVENTORY_TOOLTIP;
					_Image = 'INV_Misc_Bag_29';
					_Events = {'BAG_UPDATE'};
					_Attributes = hideMenuHook;
					_OnClick = ToggleAllBags;
					_OnEvent = function(self, event, ...)
						local totalFree, numSlots, freeSlots, bagFamily = 0, 0
						for i = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
							freeSlots, bagFamily = GetContainerNumFreeSlots(i)
							if ( bagFamily == 0 ) then
								totalFree = totalFree + freeSlots
								numSlots = numSlots + GetContainerNumSlots(i)
							end
						end
						self.Count:SetFormattedText('%s\n|cFFAAAAAA%s|r', totalFree, numSlots)
					end;
					{
						Count = {
							_Type   = 'FontString';
							_Setup  = {'OVERLAY'};
							_Font   = {Game12Font:GetFont()};
							_AlignH = 'RIGHT';
							_Point  = {'RIGHT', -10, 0};
						};
					};
				};
				Spec = {
					_ID = 3;
					_Type  = 'Button';
					_Setup = baseTemplates;
					_Point = {'TOP', '$parent.Inventory', 'BOTTOM', 0, 0};
					_Text  = TALENTS_BUTTON;
					_RefTo = TalentMicroButton;
					_Attributes = hideMenuHook;
					_EvaluateAlertVisibility = function(self)
						local alertText, alertPriority = TalentMicroButtonMixin.HasTalentAlertToShow(self);
						local pvpAlertText, pvpAlertPriority = TalentMicroButtonMixin.HasPvpTalentAlertToShow(self);

						if not alertText or pvpAlertPriority < alertPriority then
							-- pvpAlert is higher priority, use that instead
							alertText = pvpAlertText;
						end

						if not alertText then
							return self:SetPulse(false)
						end

						if not PlayerTalentFrame or not PlayerTalentFrame:IsShown() then
							self.tooltipText = alertText;
							self:SetPulse(true);
							return true;
						end
					end;
					_OnEnter = function(self)
						CPMenuButtonMixin.OnEnter(self)

						if self.tooltipText then
							GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
							GameTooltip:SetText(self.tooltipText)
							self.tooltipText = nil;
							self.hideTooltipOnLeave = true;
						end
					end;
					_OnLeave = function(self)
						CPMenuButtonMixin.OnLeave(self)

						if self.hideTooltipOnLeave then
							GameTooltip:Hide()
							self.hideTooltipOnLeave = nil;
						end
					end;
					_OnLoad = function(self)
						CPMenuButtonMixin.OnLoad(self)

						local iconFile, iconTCoords = CPAPI.GetClassIcon(select(2, UnitClass('player')))
						self.Icon:SetTexture(iconFile)
						self.Icon:SetTexCoord(unpack(iconTCoords))
						for _, event in ipairs({
							'HONOR_LEVEL_UPDATE',
							'NEUTRAL_FACTION_SELECT_RESULT',
							'PLAYER_LEVEL_CHANGED',
							'PLAYER_SPECIALIZATION_CHANGED',
							'PLAYER_TALENT_UPDATE',
						}) do self:RegisterEvent(event) end
					end;
					_OnEvent = function(self, event, ...)
						self.tooltipText = nil;
						self:EvaluateAlertVisibility()
					end;
				};
				Spellbook = {
					_ID = 4;
					_Type  = 'Button';
					_Setup = baseTemplates;
					_Point = {'TOP', '$parent.Spec', 'BOTTOM', 0, 0};
					_Text  = SPELLBOOK_BUTTON;
					_RefTo = SpellbookMicroButton;
					_Attributes = hideMenuHook;
					_OnLoad = function(self)
						CPMenuButtonMixin.OnLoad(self)
						self.Icon:SetTexture([[Interface\Spellbook\Spellbook-Icon]])
					end;
				};
				Collections = {
					_ID = 5;
					_Type  = 'Button';
					_Setup = baseTemplates;
					_Point = {'TOP', '$parent.Spellbook', 'BOTTOM', 0, 0};
					_Text  = COLLECTIONS;
					_RefTo = CollectionsMicroButton;
					_Image = 'MountJournalPortrait';
					_Attributes = hideMenuHook;
				};
			};
		};
	})

	Mixin(Menu, env.MenuMixin)
	Menu:LoadArt()
	Menu:StartEnvironment()
	Menu:Execute('hID, bID = 1, 1')
	Menu:DrawIndex(function(header)
		for i, button in ipairs({header:GetChildren()}) do
			if button:GetAttribute('hidemenu') then
				button:SetAttribute('type', 'macro')
				button:SetAttribute('macrotext', '/click GameMenuButtonContinue')
			end
			if button.RefTo then
				local macrotext = button:GetAttribute('macrotext')
				local prefix = (macrotext and macrotext .. '\n') or ''
				button:SetAttribute('macrotext', prefix .. '/click ' .. button.RefTo:GetName())
				button:SetAttribute('type', 'macro')
			end
			button:Hide()
			header:SetFrameRef(tostring(button:GetID()), button)
		end
	end)

	for name, script in pairs({
		_onshow = [[
			self:RunAttribute('SetDropdownButton', 0, 1)
		]],
		SetHeaderID = [[
			hID = ...
		]],
		ShowHeader = [[
			local hID = ...
			local header = headers[hID]
			for _, button in ipairs(newtable(header:GetChildren())) do
				local condition = button:GetAttribute('condition')
				if condition then
					local show = self:Run(condition)
					if show then
						button:Show()
					else
						button:Hide()
					end
				else
					button:Show()
				end
			end
		]],
		ClearHeader = [[
			for _, button in ipairs(newtable(header:GetChildren())) do
				button:Hide()
			end
		]],
		SetHeader = [[
			local buttons = newtable(header:GetChildren())
			local highIndex = 0
			if header:GetAttribute('onheaderset') then
				highestIndex = header:RunAttribute('onheaderset')
			else
				for _, button in pairs(buttons) do
					local condition = button:GetAttribute('condition')
					local currentID
					if condition then
						local show = self:Run(condition)
						if show then
							currentID = tonumber(button:GetID())
						end
					else
						currentID = tonumber(button:GetID())
					end
					if currentID and currentID > highIndex then
						highIndex = currentID
					end
				end
				highestIndex = highIndex
			end
		]],
		SetDropdownButton = [[
			local newIndex, delta = ...
			bID = newIndex + delta
			if current then
				current:CallMethod('OnLeave')
			end
			local header = headers[hID]
			if header then
				current = header:GetFrameRef(tostring(bID))
				if current and current:IsShown() then
					current:CallMethod('OnEnter')
				elseif bID > 1 and bID < highestIndex then
					self:RunAttribute('SetDropdownButton', bID, delta)
				end
			end
		]],
		OnInput = [[
			-- Click on a button
			if key == CROSS and current then
				current:CallMethod('SetButtonState', down and 'PUSHED' or 'NORMAL')
				if not down then
					returnHandler, returnValue = 'macrotext', '/click ' .. current:GetName()
				end

			-- Alternative clicks
			elseif key == CIRCLE and current then
				current:CallMethod('SetButtonState', down and 'PUSHED' or 'NORMAL')
				if not down then
					if current:GetAttribute('circleclick') then
						current:RunAttribute('circleclick')
					end
				end
			elseif key == SQUARE and current then
				current:CallMethod('SetButtonState', down and 'PUSHED' or 'NORMAL')
				if not down then
					if current:GetAttribute('squareclick') then
						current:RunAttribute('squareclick')
					end
				end
			elseif key == TRIANGLE and current then
				current:CallMethod('SetButtonState', down and 'PUSHED' or 'NORMAL')
				if not down then
					if current:GetAttribute('triangleclick') then
						current:RunAttribute('triangleclick')
					end
				end

			elseif ( key == CENTER or key == OPTIONS or key == SHARE ) and down then
				returnHandler, returnValue = 'macrotext', '/click GameMenuButtonContinue'

			-- Select button
			elseif key == UP and down and bID > 1 then
				self:RunAttribute('SetDropdownButton', bID, -1)
			elseif key == DOWN and down and bID < highestIndex then
				self:RunAttribute('SetDropdownButton', bID, 1)

			-- Select header
			elseif key == LEFT and down and hID > 1 then
				self:RunAttribute('ChangeHeader', -1)
			elseif key == RIGHT and down and hID < numheaders then
				self:RunAttribute('ChangeHeader', 1)
			end

			return 'macro', returnHandler, returnValue
		]],
	}) do Menu:AppendSecureScript(name, script) end

	Menu:SetIgnoreParentAlpha(true)
	Menu:HookScript('OnShow', function(self)
		env.db.Alpha.FadeOut(UIParent, 0.1, UIParent:GetAlpha(), 0)
		if UIDoFramesIntersect(self, Minimap) and Minimap:IsShown() then
			self.minimapHidden = true
			Minimap:Hide()
			MinimapCluster:Hide()
		end
	end)
	
	Menu:HookScript('OnHide', function(self)
		env.db.Alpha.FadeIn(UIParent, 0.1, UIParent:GetAlpha(), 1)
		if self.minimapHidden then
			Minimap:Show()
			MinimapCluster:Show()
			self.minimapHidden = false
		end
	end)

	env.db.Stack:HideFrame(GameMenuFrame, true)	
end