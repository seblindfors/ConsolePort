local env, db, _, L = CPAPI.GetEnv(...);
---------------------------------------------------------------
-- Helpers
---------------------------------------------------------------
local function GetAddOnVersion()
	return C_AddOns.GetAddOnMetadata('ConsolePort', 'Version')
end

local function GetAuthor()
	return C_AddOns.GetAddOnMetadata('ConsolePort', 'Author')
end

local function GetInterfaceVersion()
	if C_AddOns.GetAddOnInterfaceVersion then
		return C_AddOns.GetAddOnInterfaceVersion('ConsolePort')
	end
	return select(7, GetBuildInfo())
end

local function GetYear()
	return C_DateAndTime.GetCurrentCalendarTime().year;
end

local function GetMaxLevel()
	if GetMaxLevelForLatestExpansion then
		return GetMaxLevelForLatestExpansion()
	end
	return MAX_PLAYER_LEVEL;
end

local function GetPowerLevel()
	if C_GamePad.GetPowerLevel then
		return C_GamePad.GetPowerLevel()
	end
	return 5;
end

local function __(str, a1, ...)
	if not str then return end;
	if type(str) == 'table' then
		return str:WrapTextInColorCode(__(a1, ...));
	end
	if a1 then
		return str:format(a1, ...);
	end
	return str;
end

---------------------------------------------------------------
local Credits = {};
---------------------------------------------------------------

function Credits:OnLoad()
	self:SetPoint('CENTER', 0, 100)
	self.Slot:SetIgnoreParentAlpha(true)
end

function Credits:Update()
	self:SetOwner(self.canvas, 'ANCHOR_NONE')
	self:SetPoint('CENTER', 0, 100)
	pcall(self.AddSillyTooltip, self)
	self:Show()
	db.Alpha.FadeIn(self, 1, 0, 1)
	NineSliceUtil.ApplyLayoutByName(
		self.NineSlice,
		self.layoutType,
		self.NineSlice:GetFrameLayoutTextureKit()
	);
	self:SetPadding(4, 24, 4, 4)
end

function Credits:AddSillyTooltip()
	local tlc = BAG_ITEM_QUALITY_COLORS[Enum.ItemQuality.Legendary];

	self:SetText('ConsolePort', tlc.r, tlc.g, tlc.b)

	local year = tostring(GetYear());
	local version = tostring(GetInterfaceVersion());

	local major = #version == 6 and version:sub(1, 2) or version:sub(1, 1)
	local minor = #version == 6 and version:sub(3, 4) or version:sub(2, 3)
	local patch = #version == 6 and version:sub(5, 6) or version:sub(4, 5)

	local add, sub = 43, 45;

	for _, texts in ipairs({
		{ __(NORMAL_FONT_COLOR, ITEM_LEVEL, GetAddOnVersion():gsub('%.', '')) };
		{ __(ITEM_BIND_ON_PICKUP) };
		{ __(ITEM_UNIQUE) };
		{ __(INVTYPE_2HWEAPON), __(INVTYPE_RELIC) };
		{ __(DAMAGE_TEMPLATE, year:sub(1, 2), year:sub(3, 4)), __('%s 0.%d', STAT_SPEED, patch) };
		{ __(DPS_TEMPLATE, ('%d.%d'):format(major, minor)) };
		{ __(ITEM_MOD_INTELLECT, add, random(60, 99)) };
		{ __(ITEM_MOD_STAMINA,   add, random(70, 99)) };
		{ __(ITEM_MOD_SPIRIT,    add, random(50, 99)) };
		{ __(ITEM_MOD_AGILITY,   sub, random(10, 30)) };
		{ __(DURABILITY_TEMPLATE, GetPowerLevel() * 10, 60) };
		{ __(ITEM_MIN_LEVEL, GetMaxLevel()) };
		{ __(GREEN_FONT_COLOR, __('%s %s',
			ITEM_SPELL_TRIGGER_ONEQUIP,
			__(ITEM_MOD_MASTERY_RATING, random(100, 200)
		)))};
		{ __(GREEN_FONT_COLOR, __('%s %s',
			ITEM_SPELL_TRIGGER_ONUSE,
			VOICEMACRO_19_Dw_2
		)), true};
		{ __(NORMAL_FONT_COLOR, __('"%s"', VOICEMACRO_19_Gn_3)) };
		{ __(ITEM_CREATED_BY, GetAuthor()) };
	}) do
		local left, right = unpack(texts)
		if type(right) == "string" and left then
			self:AddDoubleLine(left, right, 1, 1, 1, 1, 1, 1)
		elseif left then
			self:AddLine(left, 1, 1, 1, right)
		end
	end
end

---------------------------------------------------------------
-- About Panel
---------------------------------------------------------------
local About = env:CreatePanel({
	name = 'About';
	nav  = false; -- No navigation button for about
})

function About:OnLoad()
	CPAPI.Start(self)
end

function About:OnShow()
	self:Render()
end

function About:InitCanvas(canvas)
	self.Credits = CreateFrame('GameTooltip', 'ConsolePortCredits', canvas, 'CPCredits')
	self.Credits.canvas = canvas;
	CPAPI.SpecializeOnce(self.Credits, Credits)
end

function About:Render()
	local canvas, newObj = self:GetCanvas(true)
	if newObj then
		self:InitCanvas(canvas)
	end
	canvas:Show()
	self.Credits:Update()
end