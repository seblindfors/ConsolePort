local env, _, localEnv = ConsolePortConfig:GetEnvironment(), ...;
----------------------------------------------------------------
local Consts = {}; env.MapperConsts = Consts;
----------------------------------------------------------------

Consts.Buttons = {
	'Up';
	'Right';
	'Down';
	'Left';
	'Face1';
	'Face2';
	'Face3';
	'Face4';
	'Face5';
	'Face6';
	'LStickIn';
	'RStickIn';
	'LShoulder';
	'RShoulder';
	'LTrigger';
	'RTrigger';
	'LStickUp';
	'LStickRight';
	'LStickDown';
	'LStickLeft';
	'RStickUp';
	'RStickRight';
	'RStickDown';
	'RStickLeft';
	'Paddle1';
	'Paddle2';
	'Paddle3';
	'Paddle4';
	'Forward';
	'Back';
	'System';
	'Social';
}

Consts.Axes = {
	'LStickX';
	'LStickY';
	'RStickX';
	'RStickY';
	'GStickX';
	'GStickY';
	'LTrigger';
	'RTrigger';
}

Consts.Sticks = {
	'Left';
	'Right';
	'Gyro';
	'Pad';
	'Movement';
	'Camera';
	'Look';
	'Cursor';
}

Consts.Labels = {
	'Generic';
	'Letters';
	'Reverse';
	'Shapes';
}

----------------------------------------------------------------
-- Append 'unassigned' value to each enum for the config.
do local unassigned = '|cffffffffN/A|r';
	for _, enum in pairs(Consts) do
		tinsert(enum, unassigned)
	end
	Consts.Unassigned = unassigned;
end

----------------------------------------------------------------
-- Local shared variables
----------------------------------------------------------------
localEnv[1], localEnv[2], localEnv[3] = env, env.db, env.L;
----------------------------------------------------------------
localEnv.PANEL_WIDTH = 960;
localEnv.FIELD_WIDTH = 480;
localEnv.STATE_VIEW_HEIGHT = 250;
----------------------------------------------------------------
-- Simple sub-content wrapper
----------------------------------------------------------------
local Wrapper = {}; localEnv.Wrapper = Wrapper;

function Wrapper:OnClick()
	local checked = self:GetChecked()
	self.Content:SetShown(checked)
	self.Hilite:SetShown(not checked)
	self:SetHeight(checked and self.fixedHeight or 40)
end

function Wrapper:OnLoad()
	self.Label:ClearAllPoints()
	self.Label:SetPoint('TOPLEFT', 16, 0)
	self.Label:SetJustifyH('LEFT')
	self.Label:SetTextColor(1, 1, 1)
end