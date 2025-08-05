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
local Credits = CreateFromMixins(env.Mixin.UpdateStateTimer);
---------------------------------------------------------------

function Credits:OnLoad()
	self:SetPoint('CENTER', 0, 100)
	self:SetUpdateStateDuration(0.25)
	self.Slot:SetIgnoreParentAlpha(true)
end

function Credits:Update(callback)
	self:SetUpdateStateTimer(function()
		callback = callback or self.AddSillyTooltip;
		self:SetOwner(self.canvas, 'ANCHOR_NONE')
		self:SetPoint('CENTER', self.canvas, 'CENTER', 0, 90)
		pcall(callback, self)
		self:Show()

		local slot = self.Slot;
		local pointer = slot.Point;
		local isSillyTooltip = callback == self.AddSillyTooltip;

		slot:ClearAllPoints()
		if isSillyTooltip then
			slot:SetPoint('TOPRIGHT', self, 'TOPLEFT', 4, 0)
		else
			slot:SetPoint('BOTTOM', self, 'TOP', 0, -4)
		end

		db.Alpha.FadeIn(pointer, 0.5, pointer:GetAlpha(), isSillyTooltip and 1 or 0)
		NineSliceUtil.ApplyLayoutByName(
			self.NineSlice,
			self.layoutType,
			self.NineSlice:GetFrameLayoutTextureKit()
		);
		self:SetPadding(4, 24, 4, 4)
	end)
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

	local quotes = {
		VOICEMACRO_19_Dw_2,
		VOICEMACRO_19_Gn_3,
		VOICEMACRO_19_Ta_5,
		VOICEMACRO_20_Hu_1_FEMALE,
	};

	for _, texts in ipairs({
		{ __(NORMAL_FONT_COLOR, ITEM_LEVEL, GetAddOnVersion():gsub('%.', '')) };
		{ __(ITEM_BIND_ON_PICKUP) };
		{ __(ITEM_UNIQUE) };
		{ __(INVTYPE_2HWEAPON), __(INVTYPE_RELIC) };
		{ __(DAMAGE_TEMPLATE, year:sub(1, 2), year:sub(3, 4)), __('%s 1.%02d', STAT_SPEED, patch) };
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
			VOICEMACRO_18_Tr_2
		)), true};
		{ __(NORMAL_FONT_COLOR, __('"%s"', quotes[random(1, #quotes)])), true };
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
local Link = CreateFromMixins(CPCardSmallMixin)
---------------------------------------------------------------
local ActivePopup;

function Link:Init(data, tooltip)
	CPAPI.Specialize(self, Link, data)

	self.NormalTexture:SetTexture(data.icon)
	self.HighlightTexture:SetTexture(data.icon)
	self.PushedTexture:SetTexture(data.icon)
	self:SetText(data.text)
	self.Text:SetTextColor(1, 1, 1)

	self.tooltip = tooltip;
end

function Link:OnEnter()
	CPCardSmallMixin.OnEnter(self)

	self.tooltip:Update(function(tooltip)
		local art = BAG_ITEM_QUALITY_COLORS[Enum.ItemQuality.Artifact];
		tooltip:SetText(self.hint, art.r, art.g, art.b)
		tooltip:AddLine(CPAPI.FormatLongText(self.desc), 1, 1, 1, true)
	end)
end

function Link:OnLeave()
	CPCardSmallMixin.OnLeave(self)
	self.tooltip:Update()
end

function Link:OnClick()
	self:SetChecked(false)
	if ActivePopup then
		ActivePopup:Hide()
	end
	ActivePopup = CPAPI.Popup('ConsolePort_External_Link', {
		text = CPAPI.FormatLongText(L('LINK_COPY', self.text));
		hasEditBox = 1;
		maxLetters = 0;
		button1 = DONE;
		EditBoxOnEscapePressed = function(editBox) editBox:GetParent():Hide() end;
		EditBoxOnEnterPressed  = function(editBox) editBox:GetParent():Hide() end;
		EditBoxOnTextChanged   = function(editBox)
			if ( editBox:GetText() ~= self.link ) then
				editBox:SetText(self.link)
			end
			editBox:SetCursorPosition(0)
			editBox:HighlightText()
		end;
		OnHide = function()
			ActivePopup = nil;
		end;
		OnShow = function(popup)
			local editBox = popup.editBox or popup:GetEditBox();
			editBox:SetText(self.link)
		end;
	})
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

	self.Links = CreateFrame('Frame', nil, canvas, 'CPAboutLinkTray')
	self.Links:SetPoint('BOTTOM', 0, 70)
	self.Links:SetButtonSetup(Link.Init)

	for _, data in ipairs({
		{
			text = L'Discord';
			hint = L'Join Discord';
			desc = L.LINK_DISCORD_TEXT;
			icon = CPAPI.GetAsset [[Textures\Logo\Discord]];
			link = 'https://discord.gg/AWeHd48';
		};
		{
			text = L'Patreon';
			hint = L'Support on Patreon';
			desc = L.LINK_PATREON_TEXT;
			icon = CPAPI.GetAsset [[Textures\Logo\Patreon]];
			link = 'https://www.patreon.com/ConsolePort';
		};
		{
			text = L'PayPal';
			hint = L'Donate via PayPal';
			desc = L.LINK_PAYPAL_TEXT;
			icon = CPAPI.GetAsset [[Textures\Logo\PayPal]];
			link = 'https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=5ADQW5L2FE4XC';
		};
	}) do
		self.Links:AddControl(data, self.Credits)
	end
end

function About:Render()
	local canvas, newObj = self:GetCanvas(true)
	if newObj then
		self:InitCanvas(canvas)
	end
	canvas:Show()
	self.Credits:Update()
	db.Alpha.FadeIn(self.Credits, 1, 0, 1)
end