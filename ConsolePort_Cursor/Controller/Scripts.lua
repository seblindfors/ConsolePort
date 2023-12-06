---------------------------------------------------------------
-- Scripts
---------------------------------------------------------------
-- Replace problematic scripts or add custom functionality.
-- Original functions become taint-bearing when called insecurely
-- because they modify properties of protected objects, either
-- directly or indirectly by execution path.

local _, env, L = ...; L = env.db.Locale;
local Execute, Scripts = ExecuteFrameScript, CPAPI.Proxy({}, function(self, key) return rawget(rawset(self, key, {}), key) end);

function env.TriggerScript(node, scriptType, ...)
	local script, ok, err = Scripts[scriptType][node:GetScript(scriptType)];
	if script then
		ok, err = pcall(script, node, ...)
	else
		ok, err = pcall(Execute, node, scriptType, ...)
	end
	if not ok then
		CPAPI.Log('Script execution failed in %s handler:\n%s', scriptType, err)
	end
end

function env.ReplaceScript(scriptType, original, replacement)
	assert(type(scriptType)  == 'string',   'scriptType must be of type string'   )
	assert(type(original)    == 'function', 'original must be of type function'   )
	assert(type(replacement) == 'function', 'replacement must be of type function')
	Scripts[scriptType][original] = replacement;
end

function _(addOn, script) EventUtil.ContinueOnAddOnLoaded(addOn, GenerateClosure(pcall, script)) end
---------------------------------------------------------------
-- Scripts: OnEnter
---------------------------------------------------------------
do
	local ActionButtonOnEnter = ActionButton1 and ActionButton1:GetScript('OnEnter')
	if ActionButtonOnEnter then
		Scripts.OnEnter[ ActionButtonOnEnter ] = function(self)
			-- strips action bar highlights from action buttons
			ActionButton_SetTooltip(self)
		end
	end
	local SpellButtonOnEnter = SpellButton1 and SpellButton1:GetScript('OnEnter')
	if SpellButtonOnEnter then
		Scripts.OnEnter[ SpellButtonOnEnter ] = function(self)
			-- spellbook buttons push updates to the action bar controller in order to draw highlights
			-- on actionbuttons that holds the spell in question. this taints the action bar controller.
			local slot = SpellBook_GetSpellBookSlot(self)
			GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
			GameTooltip:SetSpellBookItem(slot, SpellBookFrame.bookType)
			
			if ( self.SpellHighlightTexture and self.SpellHighlightTexture:IsShown() ) then
				GameTooltip:AddLine(SPELLBOOK_SPELL_NOT_ON_ACTION_BAR, LIGHTBLUE_FONT_COLOR.r, LIGHTBLUE_FONT_COLOR.g, LIGHTBLUE_FONT_COLOR.b)
			end
			GameTooltip:Show()
		end
	end
	if CPAPI.IsRetailVersion then
	-----------------------------------------------------------
		_('Blizzard_Collections', function()
	-----------------------------------------------------------
			Scripts.OnEnter[ ToySpellButton_OnEnter ] = function(self)
				-- strips fanfare/UpdateTooltip from toy spell buttons, since the taint prevents UseToy from working
				if self.itemID then
					GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
					GameTooltip:SetToyByItemID(self.itemID)
					GameTooltip:Show()
				end
			end
		end)
	-----------------------------------------------------------
		_('Blizzard_ClassTalentUI', function()
	-----------------------------------------------------------
			-- Talent frame customization:
			-- Remove action bar highlights from talent buttons, since they taint the action bar controller.
			-- Also, add a special click handler to split talent buttons, so that they can be selected by clicking on them,
			-- instead of on mouseover. Finally, hook the spell menu to remove focus from the talent frame so that
			-- pickups and bar placements from the talent frame can go smoothly.

			local selectionChoiceFrame = ClassTalentFrame.TalentsTab.SelectionChoiceFrame;
			local currentBaseButton;

			Scripts.OnEnter[ ClassTalentButtonSpendMixin.OnEnter ] = function(self)
				selectionChoiceFrame:Hide()
				TalentButtonSpendMixin.OnEnter(self)
			end;
			Scripts.OnEnter[ ClassTalentButtonSelectMixin.OnEnter ] = function(self)
				selectionChoiceFrame:Hide()
				TalentButtonSelectMixin.OnEnter(self)
			end;
			Scripts.OnEnter[ ClassTalentSelectionChoiceMixin.OnEnter ] = TalentDisplayMixin.OnEnter;
			Scripts.OnEnter[ ClassTalentButtonSplitSelectMixin.OnEnter ] = function(self)
				self:SetAttribute(env.Attributes.SpecialClick, function(self, button, down)
					TalentButtonSplitSelectMixin.OnEnter(self)
					RunNextFrame(function()
						env.Cursor:SetCurrentNode(selectionChoiceFrame.selectionFrameArray[1])
					end)
				end)

				selectionChoiceFrame:Hide()
				currentBaseButton = self;

				GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
				local selectTalentText = L'Select talent';
				local spellID = self:GetSpellID()
				if spellID then
					GameTooltip:SetSpellByID(spellID)
					GameTooltip:AddLine(env.Hooks:GetSpecialActionPrompt(selectTalentText))
					GameTooltip:Show()
				else
					GameTooltip:SetText(env.Hooks:GetSpecialActionPrompt(selectTalentText))
					GameTooltip:Show()
				end
			end;

			selectionChoiceFrame:HookScript('OnHide', function(self)
				if currentBaseButton then
					RunNextFrame(function()
						env.Cursor:SetCurrentNode(currentBaseButton)
						currentBaseButton = nil;
					end)
				end
			end)

			ConsolePortSpellMenu:HookScript('OnShow', function()
				if ClassTalentFrame:IsShown() then
					ClassTalentFrame:SetAlpha(0.25)
					ClassTalentFrame:SetAttribute(env.Attributes.IgnoreNode, true)
				end
			end)
			ConsolePortSpellMenu:HookScript('OnHide', function()
				if ClassTalentFrame:GetAttribute(env.Attributes.IgnoreNode) then
					ClassTalentFrame:SetAlpha(1)
					ClassTalentFrame:SetAttribute(env.Attributes.IgnoreNode, nil)
				end
			end)
		end)
	end
end

---------------------------------------------------------------
-- Scripts: OnLeave
---------------------------------------------------------------
do
	local SpellButtonOnLeave = SpellButton_OnLeave or SpellButton1 and SpellButton1:GetScript('OnLeave')
	if SpellButtonOnLeave then
		Scripts.OnLeave[ SpellButtonOnLeave ] = function(self)
			GameTooltip:Hide()
		end
	end
	if CPAPI.IsRetailVersion then
	-----------------------------------------------------------
		_('Blizzard_ClassTalentUI', function()
	-----------------------------------------------------------
			-- Talent frame customization:
			-- Remove clearing of action bar highlights from talent buttons, since they taint the action bar controller.
			-- When leaving a split choice talent popup, hide the popup if the cursor is not over a nested selection button.

			local selectionChoiceFrame = ClassTalentFrame.TalentsTab.SelectionChoiceFrame;

			Scripts.OnLeave[ ClassTalentButtonSpendMixin.OnLeave ] = function(self)
				selectionChoiceFrame:Hide()
				TalentDisplayMixin.OnLeave(self)
			end;
			Scripts.OnLeave[ ClassTalentButtonSelectMixin.OnLeave ] = function(self)
				selectionChoiceFrame:Hide()
				TalentButtonSelectMixin.OnLeave(self)
			end;

			Scripts.OnLeave[ ClassTalentButtonSplitSelectMixin.OnLeave ] = TalentButtonSplitSelectMixin.OnLeave;
			Scripts.OnLeave[ ClassTalentSelectionChoiceMixin.OnLeave ] = function(self)
				TalentDisplayMixin.OnLeave(self)
				RunNextFrame(function()
					if ConsolePortSpellMenu:IsShown() then return end;
					
					local currentNode = env.Cursor:GetCurrentNode()
					if currentNode and currentNode:GetParent() ~= selectionChoiceFrame then
						selectionChoiceFrame:Hide()
					end
				end)
			end;
		end)
	end
end