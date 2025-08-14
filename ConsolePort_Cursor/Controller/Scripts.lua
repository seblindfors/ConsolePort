---------------------------------------------------------------
-- Scripts
---------------------------------------------------------------
-- Replace problematic scripts or add custom functionality.
-- Original functions become taint-bearing when called insecurely
-- because they modify properties of protected objects, either
-- directly or indirectly by execution path.

local env, db, _, L = CPAPI.GetEnv(...); _ = CPAPI.OnAddonLoaded;
local xpcall, CallErrorHandler = xpcall, CallErrorHandler;
local Scripts = CPAPI.Proxy({}, function(self, key) return rawget(rawset(self, key, {}), key) end);

local function ExecuteFrameScript(frame, scriptName, ...)
	local pre, main, post =
		frame:GetScript(scriptName, LE_SCRIPT_BINDING_TYPE_INTRINSIC_PRECALL),
		frame:GetScript(scriptName, LE_SCRIPT_BINDING_TYPE_EXTRINSIC),
		frame:GetScript(scriptName, LE_SCRIPT_BINDING_TYPE_INTRINSIC_POSTCALL);
	if pre  then xpcall(pre,  CallErrorHandler, frame, ...) end;
	if main then xpcall(main, CallErrorHandler, frame, ...) end;
	if post then xpcall(post, CallErrorHandler, frame, ...) end;
end

function env.ExecuteScript(node, scriptType, ...)
	local script, ok, err = Scripts[scriptType][node:GetScript(scriptType) or node];
	if script then
		ok, err = pcall(script, node, ...)
	else
		ok, err = pcall(ExecuteFrameScript, node, scriptType, ...)
	end
	if not ok then
		CPAPI.Log('Script execution failed in %s handler:\n%s', scriptType, err)
	end
end

function env.ExecuteMethod(node, method, ...)
	local script, ok, err = Scripts[method][node[method]];
	if script then
		ok, err = pcall(script, node, ...)
	else
		ok, err = pcall(node[method], node, ...)
	end
	if not ok then
		CPAPI.Log('Method execution failed in %s handler:\n%s', method, err)
	end
end

function env.ReplaceScript(scriptType, original, replacement)
	assert(type(scriptType)  == 'string',   'scriptType must be of type string'   )
	assert(type(original)    == 'function', 'original must be of type function'   )
	assert(type(replacement) == 'function', 'replacement must be of type function')
	Scripts[scriptType][original] = replacement;
end

---------------------------------------------------------------
do -- FrameXML
---------------------------------------------------------------
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
	local SpellButtonOnLeave = SpellButton_OnLeave or SpellButton1 and SpellButton1:GetScript('OnLeave')
	if SpellButtonOnLeave then
		Scripts.OnLeave[ SpellButtonOnLeave ] = function(self)
			GameTooltip:Hide()
		end
	end
end

---------------------------------------------------------------
do -- Misc addon fixes
---------------------------------------------------------------
	_('Blizzard_HelpPlate', function()
		Scripts.OnEnter[ HelpPlateButtonMixin.OnEnter ] = function(self)
			ExecuteFrameScript(self:GetParent(), 'OnEnter')
		end;
	end)
end

-----------------------------------------------------------
if CPAPI.IsRetailVersion then -- Misc retail addon fixes
-----------------------------------------------------------
	_('Blizzard_Collections', function()
		Scripts.OnEnter[ ToySpellButton_OnEnter ] = function(self)
			-- Strip fanfare/UpdateTooltip from toy spell buttons,
			-- since the taint prevents UseToy from working.
			if self.itemID then
				GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
				GameTooltip:SetToyByItemID(self.itemID)
				GameTooltip:Show()
			end
		end
	end)
end

-----------------------------------------------------------
if CPAPI.IsRetailVersion then -- Modern spellbook/talents
-----------------------------------------------------------
	_('Blizzard_PlayerSpells', function()
		-- Talent frame customization:
		-- Remove action bar highlights from talent buttons, since they taint the action bar controller.
		-- Also, add a special click handler to split talent buttons, so that they can be selected by clicking on them,
		-- instead of on mouseover. Finally, hook the spell menu to remove focus from the talent frame so that
		-- pickups and bar placements from the talent frame can go smoothly.

		local selectionChoiceFrame = PlayerSpellsFrame.TalentsFrame.SelectionChoiceFrame;
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
			local spellID = self:GetSpellID()
			if spellID then
				GameTooltip:SetSpellByID(spellID)
				GameTooltip:AddLine(env.Hooks:GetSpecialActionPrompt(INSPECT_TALENTS_BUTTON))
				GameTooltip:Show()
			else
				GameTooltip:SetText(env.Hooks:GetSpecialActionPrompt(INSPECT_TALENTS_BUTTON))
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

		-- Remove clearing of action bar highlights from talent buttons, since they taint the action bar controller.
		-- When leaving a split choice talent popup, hide the popup if the cursor is not over a nested selection button.
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

		ConsolePortSpellMenu:HookScript('OnShow', function()
			if PlayerSpellsFrame:IsShown() then
				PlayerSpellsFrame:SetAlpha(0.25)
				PlayerSpellsFrame:SetAttribute(env.Attributes.IgnoreNode, true)
			end
		end)
		ConsolePortSpellMenu:HookScript('OnHide', function()
			if PlayerSpellsFrame:GetAttribute(env.Attributes.IgnoreNode) then
				PlayerSpellsFrame:SetAlpha(1)
				PlayerSpellsFrame:SetAttribute(env.Attributes.IgnoreNode, nil)
			end
		end)
	end)
end -- Modern spellbook/talents

---------------------------------------------------------------
if CPAPI.IsRetailVersion then -- MapCanvasPinMixin
---------------------------------------------------------------
	_('Blizzard_MapCanvas', function()
		_('Blizzard_SharedMapDataProviders', function()
			-- Map pins OnEnter/OnLeave scripts propagate to basically everywhere on the map,
			-- resulting in widespread taint. Because it's too ardous to figure out which taint
			-- is caused by which pin type, we just apply a safe mixin to all pins that
			-- overrides the problematic methods, so that they are not allowed to execute in
			-- combat. This is a bad solution, but it works for now.
			--
			-- Wouldn't it be nice if we could execute OnEnter/OnLeave securely out of combat?

			local SafePinMixin = {};
			function SafePinMixin:SetPassThroughButtons(...)
				db:RunSafe(GenerateClosure(CPAPI.Index(self).SetPassThroughButtons, self), ...)
			end

			function SafePinMixin:SetPropagateMouseClicks(...)
				db:RunSafe(GenerateClosure(CPAPI.Index(self).SetPropagateMouseClicks, self), ...)
			end

			local function FixPinTaint(pin)
				Mixin(pin, SafePinMixin);
			end

			local cachedPins, worldMapTainted = {}, false;
			local function FixCachedPinTaint()
				worldMapTainted = true;
				for pin in pairs(cachedPins) do
					FixPinTaint(pin);
				end
				wipe(cachedPins);
			end

			local function PinTemplateDefaultHandler(map, pinTemplate)
				for pin in map:EnumeratePinsByTemplate(pinTemplate) do
					if worldMapTainted then
						FixPinTaint(pin);
					elseif not cachedPins[pin] then
						cachedPins[pin] = true;
						Scripts.OnEnter[ pin.OnMouseEnter ] = function(self)
							FixCachedPinTaint()
							return self:OnMouseEnter()
						end;
						Scripts.OnLeave[ pin.OnMouseLeave ] = function(self)
							FixCachedPinTaint()
							return self:OnMouseLeave()
						end;
					end
				end
			end

			local PinTemplateHandlers = CPAPI.Proxy({
				DungeonEntrancePinTemplate = function(map, pinTemplate)
					-- Invoking EncounterJournal_OpenJournal used to taint the UI
					-- panel manager, but this does not seem to be the case anymore.
					-- Leaving this here in case the issue resurfaces.
					PinTemplateDefaultHandler(map, pinTemplate)
				end;
			}, CPAPI.Static(PinTemplateDefaultHandler));

			hooksecurefunc(WorldMapFrame, 'AcquirePin', function(map, pinTemplate)
				PinTemplateHandlers[pinTemplate](map, pinTemplate)
			end)
		end)
	end)
end -- MapCanvasPinMixin