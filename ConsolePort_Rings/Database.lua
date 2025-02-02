local _, Data, env, db, name = CPAPI.LinkEnv(...);
---------------------------------------------------------------
LibStub('RelaTable')(name, env, false);
---------------------------------------------------------------
-- Add variables to config
---------------------------------------------------------------
ConsolePort:AddVariables({
	_'Rings';
	ringPressAndHold = _{Data.Bool(true);
		name = 'Press and Hold';
		desc = 'Use press and hold to navigate and use rings. Press, point, release.';
		note = 'When disabled, you will need to press the accept button to confirm a selection.';
	};
	ringStickySelect = _{Data.Bool(false);
		name = 'Sticky Selection';
		desc = 'Selecting an item on a ring will stick until another item is chosen.';
	};
	ringAcceptButton = _{Data.Button('PAD1');
		name = 'Accept Button';
		desc = 'Button used to confirm a selected item from a ring.';
	};
	ringRemoveButton = _{Data.Button('PADRSHOULDER');
		name = 'Remove Button';
		desc = 'Button used to remove a selected item from an editable ring.';
	};
})

---------------------------------------------------------------
-- The basics
---------------------------------------------------------------
env.ActionButton  = LibStub('ConsolePortActionButton');
env.DisplayButton = CreateFromMixins(CPActionButton);

env.Attributes = {
	MetadataIndex  = 0;
	Sticky         = 'sticky';
	StickySelect   = 'stickySelect';
	PressAndHold   = 'pressAndHold';
	AcceptButton   = 'acceptButton';
	RemoveButton   = 'removeButton';
	AcceptBlocked  = 'acceptButtonBlocked';
	RemoveBlocked  = 'removeButtonBlocked';
	TriggerButton  = 'trigger';
	NestedRing     = 'nested';
	DefaultSetBtn  = 'LeftButton';
};

env.LABConfig = {
	showGrid = true;
	hideElements = {
		macro = true;
	};
};

---------------------------------------------------------------
-- States
---------------------------------------------------------------
---@brief
--- 'IsDataReady' is set to true when rings are ready to
--- be loaded. This is usually after PLAYER_ENTERING_WORLD.
env.IsDataReady = false;
---@brief
--- 'IsSpellValidationReady' is set to true when the spells
--- are ready to be validated. This is after SPELLS_CHANGED,
--- which can fire after PLAYER_ENTERING_WORLD on login.
env.IsSpellValidationReady = false;

---------------------------------------------------------------
-- Ring data
---------------------------------------------------------------
function env:GetData(skipValidation)
	if skipValidation then
		return self.Frame.Data;
	end
	return self:ValidateData(self.Frame.Data);
end

function env:GetShared(skipValidation)
	if skipValidation then
		return self.Frame.Shared;
	end
	return self:ValidateData(self.Frame.Shared);
end

function env:GetSet(setID, skipValidation)
	return self:GetData(skipValidation)[setID] or self:GetShared(skipValidation)[setID];
end

function env:CreateSet(rawName, container)
	local setID = self:ValidateSetID(rawName);
	if not setID then return end;
	container[setID] = env:ValidateSet(setID, {});
	return setID;
end

function env:GetSetIcon(setID)
	if setID then
		local icon = self.Frame:GetSetIcon(setID)
		if icon then return icon end;
	end
	return [[Interface\AddOns\ConsolePort_Bar\Assets\Textures\Icons\Ring.png]];
end

function env:SetIconForSet(setID, icon)
	self.Frame:SetIconForSet(setID, icon);
end

function env:GetRingNameSuggestion()
	local data = self:GetData(true)
	local shared = self:GetShared(true)

	local suggestion = max(1, #data, #shared) + 1; -- atleast 2
	while rawget(data, suggestion) or rawget(shared, suggestion) do
		suggestion = suggestion + 1;
	end

	return tostring(suggestion);
end

function env:ValidateSetID(rawName)
	local purifiedName  = tostring(rawName):gsub('[^A-Za-z0-9]', '');
	local processedName = tonumber(purifiedName) or purifiedName;
	if processedName ~= DEFAULT and not self:GetSet(processedName, true) then
		return processedName;
	end
end

---------------------------------------------------------------
-- Helpers
---------------------------------------------------------------
local HYPERLINK_FORMAT = ('|c%s|Haddon:%s:%s|h[%s]|h|r')

function env:AddLoader(loader)
	if not self.Loaders then
		self.Loaders = {};
	end
	tinsert(self.Loaders, loader);
end

function env:LoadModules()
	if self.Loaders then
		for _, loader in ipairs(self.Loaders) do
			loader(self.Frame, ConsolePortRings, ConsolePortRingsShared);
		end
	end
	self.Loaders, self.LoadModules, self.AddLoader = nil;
end

function env:GetTooltipPrompt(text, button)
	if not button then return end;
	local device = self.db.Gamepad.Active;
	if device then
		return device:GetTooltipButtonPrompt(button, text, 64);
	end
end

function env:GetRingLink(binding, text)
	return HYPERLINK_FORMAT:format(BLUE_FONT_COLOR:GenerateHexColor(), name, binding, text);
end

function env:GetRingBindingFromLink(link)
	local binding = link:match('.*:(.-)|h')
	return env.BindingFormat:format(binding);
end

function env:GetDescriptionFromRingLink(link)
	local binding = env:GetRingBindingFromLink(link);
	return db.Bindings:GetDescriptionForBinding(binding, true, 80);
end