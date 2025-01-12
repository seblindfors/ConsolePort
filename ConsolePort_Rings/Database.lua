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
};

env.LABConfig = {
	showGrid = true;
	hideElements = {
		macro = true;
	};
};

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

function env:LoadModules(data)
	if self.Loaders then
		for _, loader in ipairs(self.Loaders) do
			loader(self.Frame, data);
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