local env, db = CPAPI.GetEnv(...);
---------------------------------------------------------------
local BUFF_CANCEL_ROW_INDEX = env.QMenuID();
local DEBUFF_INFO_ROW_INDEX = env.QMenuID();

---------------------------------------------------------------
local Aura = { getData = C_UnitAuras.GetAuraDataByIndex };
---------------------------------------------------------------
local SetTimer, ClearTimer = CooldownFrame_Set, CooldownFrame_Clear;

function Aura:OnLoad()
	self.cooldown:SetReverse(true)
	if self.cooldown.SetUseAuraDisplayTime then
		self.cooldown:SetUseAuraDisplayTime(true)
	end
end

function Aura:GetFilter()
	return self:GetAttribute('filter');
end

function Aura:GetUnit()
	return self:GetParent():GetAttribute('unit');
end

function Aura:GetArguments(unit)
	return unit or self:GetUnit(), self:GetID(), self:GetFilter();
end

function Aura:GetData(unit)
	return self.getData(self:GetArguments(unit));
end

function Aura:Update(unit)
	local data = self:GetData(unit);
	if not data then return self:SetIcon(nil) end;

	self:SetIcon(data.icon)
	self:SetCount(data.applications)

	local color = BLUE_FONT_COLOR;
	if data.isHelpful then
		color = NORMAL_FONT_COLOR;
	elseif data.isHarmful then
		color = RED_FONT_COLOR;
	end
	self.cooldown:SetSwipeColor(color:GetRGBA())
	if data.duration > 0 then
		self.cooldown:SetHideCountdownNumbers(data.duration > 60)
		SetTimer(self.cooldown, data.expirationTime - data.duration, data.duration, true)
	else
		ClearTimer(self.cooldown)
	end
end

function Aura:OnEnter()
	GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMRIGHT')
	self:UpdateTooltip()
	self:LockHighlight()
end

function Aura:UpdateTooltip()
	GameTooltip:SetUnitAura(self:GetArguments())
	local data = self:GetData();
	if not data or not data.isHelpful then return end;

	local text = env:GetTooltipPromptForClick('RightButton', CANCEL)
	if text then
		GameTooltip:AddLine(text, 1, 1, 1)
		GameTooltip:Show()
	end
end

function Aura:OnLeave()
	GameTooltip:Hide()
	self:UnlockHighlight()
end

---------------------------------------------------------------
local Header = {};
---------------------------------------------------------------
CPAPI.Props(Header)
	.Prop('Title')
	.Bool('Helpful', true)

function Header:OnLoad()
	self:HookScript('OnShow', self.Update)
	self:HookScript('OnEvent', self.Update)
	self:SetAttribute('nodepass', true)
end

function Header:Update()
	local i, unit, aura = CreateCounter(0), self:GetAttribute('unit');
	repeat aura = self:GetAttribute('child'..i())
		if not aura or not aura:IsShown() then break end;
		if not aura.Update then
			CPAPI.Specialize(aura, Aura)
		end
		aura:Update(unit)
	until false;
end

---------------------------------------------------------------
-- Initializer
---------------------------------------------------------------
env:RegisterSafeCallback('QMenu.Loaded', function(QMenu)
	local function CreateHeader(index, filter, title)
		local frame = CreateFrame('Frame', '$parentAuras'..index, QMenu, 'CPQMenuAuraHeader')
		frame:SetAttribute('filter', filter)
		CPAPI.Specialize(frame, Header)
		frame:SetTitle(title);
		QMenu:AddFrame(frame, index)
		return frame;
	end

	local Helpful = CreateHeader(BUFF_CANCEL_ROW_INDEX, 'HELPFUL', BUFFOPTIONS_LABEL);
	local Harmful = CreateHeader(DEBUFF_INFO_ROW_INDEX, 'HARMFUL', BUFFOPTIONS_LABEL);

	function Helpful:OnVariablesChanged()
		self:SetShown(db('QMenuCollectionBuffs'))
		self:SetAttribute('paddingBottom', db('QMenuCollectionDebuffs') and 8 or 20);
		if not self:IsShown() then
			env.QMenu:Run([[ self::OnAurasChanged(%q, -math.huge)]], self:GetAttribute('filter'))
		end
	end

	function Harmful:OnVariablesChanged()
		self:SetShown(db('QMenuCollectionDebuffs'))
		self:SetTitle(db('QMenuCollectionBuffs') and '' or BUFFOPTIONS_LABEL)
		if not self:IsShown() then
			env.QMenu:Run([[ self::OnAurasChanged(%q, -math.huge)]], self:GetAttribute('filter'))
		end
	end

	db:RegisterSafeCallbacks(Helpful.OnVariablesChanged, Helpful,
		'Settings/QMenuCollectionBuffs',
		'Settings/QMenuCollectionDebuffs'
	);
	db:RegisterSafeCallbacks(Harmful.OnVariablesChanged, Harmful,
		'Settings/QMenuCollectionBuffs',
		'Settings/QMenuCollectionDebuffs'
	);

	Helpful:OnVariablesChanged();
	Harmful:OnVariablesChanged();
end)