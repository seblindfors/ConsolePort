---------------------------------------------------------------
-- Scripts
---------------------------------------------------------------
-- Replace problematic scripts or add custom functionality.
-- Original functions become taint-bearing when called insecurely
-- because they modify properties of protected objects, either
-- directly or indirectly by execution path.

local _, env = ...;
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
	if QuestMapLogTitleButton_OnEnter then
		Scripts.OnEnter[ QuestMapLogTitleButton_OnEnter ] = function(self)
			-- this replacement script runs itself, but handles a particular bug when the cursor is atop a quest button when the map is opened.
			-- all data is not yet populated so difficultyHighlightColor can be nil, which isn't checked for in the default UI code.
			if self.questLogIndex then
				local _, level, _, isHeader, _, _, _, _, _, _, _, _, _, _, _, _, isScaling = GetQuestLogTitle(self.questLogIndex)
				local _, difficultyHighlightColor = GetQuestDifficultyColor(level, isScaling)
				if ( isHeader ) then
					_, difficultyHighlightColor = QuestDifficultyColors['header']
				end
				if difficultyHighlightColor then
					QuestMapLogTitleButton_OnEnter(self)
				end
			end
		end
	end
	if CPAPI.IsRetailVersion then
		_('Blizzard_Collections', function()
			Scripts.OnEnter[ ToySpellButton_OnEnter ] = function(self)
				-- strips fanfare/UpdateTooltip from toy spell buttons, since the taint prevents UseToy from working
				if self.itemID then
					GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
					GameTooltip:SetToyByItemID(self.itemID)
					GameTooltip:Show()
				end
			end
		end)
		_('Blizzard_ClassTalentUI', function()
			-- also taints action bar controller through highlights
			Scripts.OnEnter[ ClassTalentButtonSpendMixin.OnEnter ]       = TalentButtonSpendMixin.OnEnter;
			Scripts.OnEnter[ ClassTalentButtonSelectMixin.OnEnter ]      = TalentButtonSelectMixin.OnEnter;
			Scripts.OnEnter[ ClassTalentButtonSplitSelectMixin.OnEnter ] = TalentButtonSplitSelectMixin.OnEnter;
			Scripts.OnEnter[ ClassTalentSelectionChoiceMixin.OnEnter ]   = TalentDisplayMixin.OnEnter;
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
		_('Blizzard_ClassTalentUI', function()
			-- also taints action bar controller through highlights
			Scripts.OnLeave[ ClassTalentButtonSpendMixin.OnLeave ]       = TalentDisplayMixin.OnLeave;
			Scripts.OnLeave[ ClassTalentButtonSelectMixin.OnLeave ]      = TalentButtonSelectMixin.OnLeave;
			Scripts.OnLeave[ ClassTalentButtonSplitSelectMixin.OnLeave ] = TalentButtonSplitSelectMixin.OnLeave;
			Scripts.OnLeave[ ClassTalentSelectionChoiceMixin.OnLeave ]   = TalentDisplayMixin.OnLeave;
		end)
	end
end