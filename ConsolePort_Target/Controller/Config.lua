local env, db, _, L = CPAPI.GetEnv(...);
---------------------------------------------------------------
-- Assist spells (target ring)
---------------------------------------------------------------
-- Scans the action bars for helpful spells, which can be
-- individually opted in to open the target ring when cast
-- without an assistable target.

local DP, SETTINGS_PANEL_ID = 1, 2;

ConsolePort:RegisterConfigCallback(function(_, configEnv)
	local Elements, Widget = configEnv.Elements, configEnv.Settings.Base;

	---------------------------------------------------------------
	local AssistSpell = CreateFromMixins(Elements.Setting);
	---------------------------------------------------------------

	function AssistSpell:UpdateTooltip()
		if not self.isTooltipOwned then return end;
		GameTooltip:SetOwner(self, self.tooltipAnchor or 'ANCHOR_TOP')
		GameTooltip:SetSpellByID(self.spellID)
		GameTooltip:AddLine(' ')
		Widget.UpdateTooltip(self)
	end

	function AssistSpell:Init(elementData)
		local data = elementData:GetData()
		self.spellID = data.spellID;
		self.disableTooltipInit = true;
		xpcall(self.Mount, geterrorhandler(), self, {
			name     = data.field.name;
			varID    = data.varID;
			field    = data.field;
			owner    = ConsolePortConfig;
			registry = db;
			newObj   = true;
			callbackFn = function(enabled)
				db.TargetRing:SetAssistSpell(data.spellID, enabled)
				self:OnValueChanged(enabled)
			end;
		})
		self.UpdateTooltip = AssistSpell.UpdateTooltip;
	end

	function AssistSpell:OnAcquire(new)
		if new then
			Elements.InitializeSetting(self, configEnv.Setting, AssistSpell)
			self:SetAttribute('nohooks', true) -- no interface cursor spell menu
		end
	end

	function AssistSpell:Get()
		return db.TargetRing:IsAssistSpell(self.spellID)
	end

	function AssistSpell:Data(datapoint)
		return {
			varID   = 'assistSpell'..datapoint.spellID;
			spellID = datapoint.spellID;
			name    = datapoint.name;
			field   = {
				name = datapoint.name;
				desc = L'Casting this spell without an assistable target opens the ring to pick the target.';
				list = L'Assist Mode';
				[DP] = db.Data.Bool(false):Set(db.TargetRing:IsAssistSpell(datapoint.spellID));
			};
		};
	end

	local flush = CPAPI.Debounce(function()
		db:TriggerEvent('OnActionBarSlotsChanged')
	end, {});
	EventRegistry:RegisterFrameEventAndCallback('ACTIONBAR_SLOT_CHANGED', flush.Execute, flush)

	local Settings = configEnv:GetPanelByID(SETTINGS_PANEL_ID)
	Settings:AddProvider(function(AddSetting, GetSortIndex)
		local IsHelpful = CPAPI.IsSpellHelpful;
		if not ( db.TargetRing and IsHelpful ) then return end;
		local main, head = BINDING_HEADER_TARGETING, 'Target Ring';

		local spells = {};
		for _, pages in ipairs(db.Actionbar.Pages) do
			for _, page in ipairs(pages) do
				for slot = (page - 1) * NUM_ACTIONBAR_BUTTONS + 1, page * NUM_ACTIONBAR_BUTTONS do
					local actionType, spellID, subType = GetActionInfo(slot)
					if ( actionType == 'spell'
						and subType == 'spell'
						and spellID and spellID ~= 0
						and not spells[spellID]
						and IsHelpful(spellID) ) then
						spells[spellID] = CPAPI.GetSpellInfo(spellID);
					end
				end
			end
		end

		local sorted = {};
		for spellID, info in pairs(spells) do
			if info.name then
				tinsert(sorted, { spellID = spellID, name = info.name, icon = info.iconID })
			end
		end
		table.sort(sorted, function(a, b) return a.name < b.name end)

		local sort = GetSortIndex(main, head);
		for i, spell in ipairs(sorted) do
			local data = AssistSpell:Data({
				spellID = spell.spellID;
				name    = ('|T%s:24:24|t %s'):format(spell.icon or [[Interface\Icons\INV_Misc_QuestionMark]], spell.name);
			});
			data.type = AssistSpell;
			data.sort = sort + i;
			AddSetting(main, head, data)
		end

		return 'OnActionBarSlotsChanged';
	end)
	Settings:OnIndexChanged()
end, env)
