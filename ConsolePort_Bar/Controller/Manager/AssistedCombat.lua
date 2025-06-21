if not AssistedCombatManager then
	return;
end

local AssistedCombatManager, _, env = tFilter(AssistedCombatManager, function(v) return type(v) == 'function' end), ...;
-- These should not be shared with the original.
AssistedCombatManager.rotationSpells = {};
AssistedCombatManager.assistedHighlightCandidateActionButtons = {};
AssistedCombatManager.spellDataLoadedCancelCallback = nil;

function AssistedCombatManager:Init()
	self.init = true;

	CVarCallbackRegistry:RegisterCallback('assistedCombatIconUpdateRate', AssistedCombatManager.ProcessCVars, AssistedCombatManager);
	CVarCallbackRegistry:RegisterCallback('assistedCombatHighlight', AssistedCombatManager.ProcessCVars, AssistedCombatManager);

	AssistedCombatManager:ProcessCVars();
end

function AssistedCombatManager:OnSpellsChanged()
	-- update the rotation spells before anything else
	wipe(self.rotationSpells);
	local rotationSpells = C_AssistedCombat.GetRotationSpells();
	for i, spellID in ipairs(rotationSpells) do
		self.rotationSpells[spellID] = true;
	end

	local actionSpellID = C_AssistedCombat.GetActionSpell();
	self:SetActionSpell(actionSpellID);

	self.hasShapeshiftForms = GetNumShapeshiftForms() > 0;

	-- OnSpellsChanged will fire after VARIABLES_LOADED and PLAYER_ENTERING_WORLD
	if not self.init then
		self:Init();
	elseif self:IsAssistedHighlightActive() then
		self:UpdateAssistedHighlightCandidateActionButtonsList()
	end

	-- Because SPELLS_CHANGED fires at the end of frame, systems responding to synchronous events
	-- would get the wrong info if they rely on AssistedCombatManager:IsRotationSpell or anything that calls it.
	env:TriggerEvent('AssistedCombat.RotationSpellsUpdated');
end

function AssistedCombatManager:SetActionSpell(actionSpellID)
	if self.actionSpellID == actionSpellID then
		return;
	end

	self.spellDescription = nil;

	if self.spellDataLoadedCancelCallback then
		self.spellDataLoadedCancelCallback();
		self.spellDataLoadedCancelCallback = nil;
	end

	if actionSpellID then
		-- store the spell description now so there are no sparse headaches later
		local spell = Spell:CreateFromSpellID(actionSpellID);
		self.spellDataLoadedCancelCallback = spell:ContinueWithCancelOnSpellLoad(function()
			self.spellDescription = spell:GetSpellDescription(actionSpellID);
			self.spellDataLoadedCancelCallback = nil;
		end);
	end

	self.actionSpellID = actionSpellID;
	env:TriggerEvent('AssistedCombat.OnSetActionSpell', actionSpellID);
end

function AssistedCombatManager:SetCanHighlightSpellbookSpells(on)
	self.canHighlightSpellbookSpells = on;
	env:TriggerEvent('AssistedCombat.OnSetCanHighlightSpellbookSpells');
end

function AssistedCombatManager:ShouldHighlightSpellbookSpell(spellID)
	if not self.canHighlightSpellbookSpells and not self:IsAssistedHighlightActive() then
		return false;
	end

	return self:IsHighlightableSpellbookSpell(spellID);
end

function AssistedCombatManager:ShouldDowngradeSpellAlertForButton(actionButton)
	local action = actionButton:GetAttribute('action');
	if not action then
		return false;
	end

	local usingAssistedCombat = self:IsAssistedHighlightActive() or C_ActionBar.HasAssistedCombatActionButtons();
	if not usingAssistedCombat then
		return false;
	end

	-- Only spells that are part of the rotation should have downgrade spell alerts
	local type, id, subType = GetActionInfo(action);
	if type == 'spell' or (type == 'macro' and subType == 'spell') then
		return self:IsRotationSpell(id);
	end

	return false;
end

-- This will be called when a conditional macro changes which spell will be cast,
-- or when an action changes, like dragging a spell on/off or swapping the main action bar.
function AssistedCombatManager:OnActionButtonActionChanged(actionButton)
	local spellID = self:GetActionButtonSpellForAssistedHighlight(actionButton);
	self.assistedHighlightCandidateActionButtons[actionButton] = spellID;
	self:SetAssistedHighlightFrameShown(actionButton, self.lastNextCastSpellID and spellID == self.lastNextCastSpellID);

	local actionID = actionButton:GetAttribute('action');
	local retainCandidate = true;
	local isAssistedCombatAction = C_ActionBar.IsAssistedCombatAction(actionID);
	self:OnActionButtonTypeChanged(actionButton, retainCandidate)

	if isAssistedCombatAction then
		actionButton.autoRotationSpellID = self.lastNextCastSpellID;
		actionButton.autoRotationTicker = C_Timer.NewTicker(self:GetUpdateRate(), function()
			if actionButton.autoRotationSpellID ~= self.lastNextCastSpellID then
				actionButton.autoRotationSpellID = self.lastNextCastSpellID;
				actionButton:UpdateAction(true);
			end
		end);
	end

	if self.hasShapeshiftForms then
		self:ForceUpdateAtEndOfFrame();
	end
end

function AssistedCombatManager:OnActionButtonTypeChanged(actionButton, retainCandidate)
	if not retainCandidate then
		self.assistedHighlightCandidateActionButtons[actionButton] = nil;
	end
	if not actionButton.autoRotationTicker then return end;
	actionButton.autoRotationTicker:Cancel();
	actionButton.autoRotationTicker = nil;
	actionButton.autoRotationSpellID = nil;
end

-- Will return a spellID for an actionButton that holds a rotation spell (ignoring AssistedRotation button)
-- or any macro (since a macro can contain multiple spells or include non-spells), nil otherwise
function AssistedCombatManager:GetActionButtonSpellForAssistedHighlight(actionButton)
	local action = actionButton:GetAttribute('action');
	if action then
		local type, id, subType = GetActionInfo(action);
		if type == 'macro' then
			if subType == 'spell' then
				return id;
			else
				-- This macro doesn't display a spell right now, but it could contain one.
				-- 0 won't match a spell but will keep this button as a candidate.
				return 0;
			end
		elseif type == 'spell' and subType ~= 'assistedcombat' then
			if self:IsRotationSpell(id) then
				return id;
			end
		end
	end
	return nil;
end

function AssistedCombatManager:SetAssistedHighlightFrameShown(actionButton, shown)
	if actionButton.ShowOverlayGlow and shown then
		return actionButton:ShowOverlayGlow();
	elseif actionButton.HideOverlayGlow then
		return actionButton:HideOverlayGlow();
	end

	local highlightFrame = actionButton.AssistedCombatHighlightFrame;
	if shown then
		if not highlightFrame then
			highlightFrame = CreateFrame('FRAME', nil, actionButton, 'ActionBarButtonAssistedCombatHighlightTemplate');
			actionButton.AssistedCombatHighlightFrame = highlightFrame;
			highlightFrame:SetPoint('CENTER');
			highlightFrame:SetUsingParentLevel(true);
			highlightFrame.Flipbook:SetDrawLayer('OVERLAY', 7);

			-- have to do this to get a single frame of the flipbook instead of the whole texture
			highlightFrame.Flipbook.Anim:Play();
			highlightFrame.Flipbook.Anim:Stop();
			-- stance buttons are smaller
			if not actionButton:GetAttribute('action') then
				highlightFrame.Flipbook:SetSize(48, 48);
			end
		end
		highlightFrame:Show();
		if self.affectingCombat then
			highlightFrame.Flipbook.Anim:Play();
		else
			highlightFrame.Flipbook.Anim:Stop();
		end
	elseif highlightFrame then
		highlightFrame:Hide();
	end
end

function AssistedCombatManager:UpdateAllAssistedHighlightFramesForSpell(spellID)
	if self.assistedHighlightCandidateActionButtons then
		for actionButton, actionSpellID in pairs(self.assistedHighlightCandidateActionButtons) do
			local show = actionSpellID == spellID;
			self:SetAssistedHighlightFrameShown(actionButton, show);
		end
	end
end

function AssistedCombatManager:BuildAssistedHighlightCandidateActionButtonsList()
	wipe(self.assistedHighlightCandidateActionButtons);
	for actionButton in next, env.LAB.actionButtons do
		if actionButton:GetAttribute(env.Attributes.UUID) then
			local spellID = self:GetActionButtonSpellForAssistedHighlight(actionButton);
			if spellID then
				self.assistedHighlightCandidateActionButtons[actionButton] = spellID;
			end
		end
	end
end

function AssistedCombatManager:UpdateAssistedHighlightCandidateActionButtonsList()
	if self.assistedHighlightCandidateActionButtons then
		for actionButton in pairs(self.assistedHighlightCandidateActionButtons) do
			local spellID = self:GetActionButtonSpellForAssistedHighlight(actionButton);
			self.assistedHighlightCandidateActionButtons[actionButton] = spellID;
		end
	end
end

function AssistedCombatManager:UpdateAssistedHighlightState(wasActive)
	local isActive = self:IsAssistedHighlightActive();
	if isActive then
		if not self.updateFrame then
			self.updateFrame = CreateFrame('FRAME');
		end
		if not wasActive then
			self:BuildAssistedHighlightCandidateActionButtonsList();

			self.lastNextCastSpellID = nil;
			self.updateTimeLeft = 0;
			self.updateFrame:SetScript('OnUpdate', function(_frame, elapsed) self:OnUpdate(elapsed); end);

			env:RegisterCallback('ActionButton.OnActionChanged', self.OnActionButtonActionChanged, self);
			env:RegisterCallback('ActionButton.OnTypeChanged', self.OnActionButtonTypeChanged, self);
			EventRegistry:RegisterFrameEventAndCallback('PLAYER_REGEN_ENABLED', self.OnPlayerRegenChanged, self);
			EventRegistry:RegisterFrameEventAndCallback('PLAYER_REGEN_DISABLED', self.OnPlayerRegenChanged, self);
		end
	elseif wasActive then
		local spellID = nil;  -- hide all
		self:UpdateAllAssistedHighlightFramesForSpell(spellID);
		-- this must be after UpdateAllAssistedHighlightFramesForSpell
		wipe(self.assistedHighlightCandidateActionButtons);

		self.lastNextCastSpellID = nil;
		self.updateFrame:SetScript('OnUpdate', nil);

		env:UnregisterCallback('ActionButton.OnActionChanged', self);
		EventRegistry:UnregisterFrameEventAndCallback('PLAYER_REGEN_ENABLED', self);
		EventRegistry:UnregisterFrameEventAndCallback('PLAYER_REGEN_DISABLED', self);
	end

	if isActive ~= wasActive then
		env:TriggerEvent('AssistedCombat.OnSetUseAssistedHighlight', isActive);
	end
end

function AssistedCombatManager:ForceUpdateAtEndOfFrame()
	self.updateTimeLeft = 0;
	self.lastNextCastSpellID = nil;
end

function AssistedCombatManager:OnUpdate(elapsed)
	self.updateTimeLeft = self.updateTimeLeft - elapsed;
	if self.updateTimeLeft <= 0 then
		self.updateTimeLeft = self:GetUpdateRate();

		local checkForVisibleButton = false;
		local spellID = C_AssistedCombat.GetNextCastSpell(checkForVisibleButton);

		if spellID ~= self.lastNextCastSpellID then
			self.lastNextCastSpellID = spellID;
			self:UpdateAllAssistedHighlightFramesForSpell(spellID);
		end
	end
end

EventRegistry:RegisterFrameEventAndCallback('SPELLS_CHANGED', AssistedCombatManager.OnSpellsChanged, AssistedCombatManager);