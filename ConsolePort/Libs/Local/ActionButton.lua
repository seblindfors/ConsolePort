local Lib = LibStub:NewLibrary('ConsolePortActionButton', 1) -- TODO: rename the lib?
if not Lib then return end
local LAB = LibStub('LibActionButton-1.0')
local LBG = LibStub('LibButtonGlow-1.0')
---------------------------------------------------------------
Lib.CustomTypes = {};
---------------------------------------------------------------

function Lib:NewPool(info)
	local i = CreateCounter();
	local id, name, header = info.id, info.name, info.header;
	local type, config, mixin = info.type, info.config, info.mixin;
	local customType = self.CustomTypes[type];

	local function creationFunc()
		local index = i();
		local frame = LAB:CreateButton(id and id..index or index, name..index, header, config)
		frame:SetID(index)
		if customType then
			Mixin(frame, customType)
		end
		return frame;
	end

	local function resetterFunc(pool, frame)
		frame:Hide()
		frame:ClearAllPoints()
	end

	return creationFunc, resetterFunc, mixin;
end

---------------------------------------------------------------
-- Common action button
---------------------------------------------------------------
local Common = {}; Lib.CustomTypes.Common = Common;

---------------------------------------------------------------
-- Pet action button
---------------------------------------------------------------
local Pet = CreateFromMixins(Common); Lib.CustomTypes.Pet = Pet;

function Pet:HasAction()         return true                                 end
function Pet:GetCooldown()       return GetPetActionCooldown(self.id)        end
function Pet:IsAttack()          return IsPetAttackAction(self.id)           end
function Pet:IsCurrentlyActive() return select(4, GetPetActionInfo(self.id)) end
function Pet:IsAutoRepeat()      return select(6, GetPetActionInfo(self.id)) end
function Pet:IsUsable()          return GetPetActionSlotUsable(self.id)      end
function Pet:SetTooltip()        return GameTooltip:SetPetAction(self.id)    end

function Pet:GetTexture()
	local texture, isToken = select(2, GetPetActionInfo(self.id))
	return isToken and _G[texture] or texture
end

function Pet:UpdateLocal()
	local _, _, _, isActive, _, autoCastEnabled = GetPetActionInfo(self.id)
	if autoCastEnabled then
		AutoCastShine_AutoCastStart(self.AutoCastShine, CPAPI.GetClassColor())
	else
		AutoCastShine_AutoCastStop(self.AutoCastShine)
	end
end

---------------------------------------------------------------
Lib.Skin = {};
---------------------------------------------------------------

do -- Lib.Skin.RingButton
local inject = function(self, k, v)
	-- NOTE: This is a workaround for LAB charge cooldowns.
	if ( k == 'chargeCooldown' and v ) then
		local script = v:GetScript('OnCooldownDone')
		v:SetUseCircularEdge(true)
		v:SetScript('OnCooldownDone', function()
			v:SetUseCircularEdge(false)
			if script then
				script(v)
			end
		end)
	end
	rawset(self, k, v)
end
Lib.Skin.RingButton = function(self)
	assert(type(self.rotation) == 'number', 'Ring button must have a rotation value.')
	local tex;
	local r, g, b = CPAPI.GetClassColor()
	do tex = self.NormalTexture;
		tex:ClearAllPoints()
		tex:SetPoint('CENTER', -1, 0)
		tex:SetSize(110, 110)
		tex:SetVertexColor(r, g, b, 1)
		CPAPI.SetAtlas(tex, 'ring-metallight')
	end
	do tex = self.PushedTexture;
		tex:ClearAllPoints()
		tex:SetPoint('CENTER')
		tex:SetSize(110, 110)
		tex:SetVertexColor(r, g, b, 1)
		CPAPI.SetAtlas(tex, 'ring-metaldark')
	end
	do tex = self.CheckedTexture;
		tex:ClearAllPoints()
		tex:SetPoint('CENTER', 0, 0)
		tex:SetSize(78, 78)
		tex:SetDrawLayer('OVERLAY', -1)
		CPAPI.SetAtlas(tex, 'ring-select')
	end
	do tex = self.HighlightTexture;
		tex:ClearAllPoints()
		tex:SetPoint('CENTER')
		tex:SetSize(90, 90)
		CPAPI.SetAtlas(tex, 'ring-select')
	end
	do tex = self.icon;
		tex:SetAllPoints()
	end
	do tex = self.IconMask;
		tex:SetTexture([[Interface\Masks\CircleMask]])
		tex:SetPoint('CENTER')
		tex:SetSize(58, 58)
	end
	do tex = self.Flash;
		tex:ClearAllPoints()
		tex:SetPoint('CENTER', 1, 0)
		tex:SetSize(110, 110)
		tex:SetBlendMode('ADD')
		CPAPI.SetAtlas(tex, 'ring-horde')
		tex:SetDrawLayer('OVERLAY', 1)
	end
	do tex = self.SlotBackground;
		tex:SetPoint('CENTER')
		tex:SetSize(64, 64)
		tex:SetTexture(CPAPI.GetAsset([[Textures\Button\Icon_Mask64]]))
		tex:SetRotation(self.rotation + math.pi)
		tex:AddMaskTexture(self.IconMask)
		tex:SetDrawLayer('BACKGROUND', -1)
	end
	do tex = self.SpellHighlightTexture;
		tex:ClearAllPoints()
		tex:SetPoint('CENTER', 0, 0)
		tex:SetSize(64, 64)
		tex:SetTexture([[Interface\Buttons\IconBorder-GlowRing]])
	end
	do tex = self.cooldown;
		tex:SetSwipeTexture([[Interface\AddOns\ConsolePort_Bar\Textures\Cooldown\Swipe]])
		tex:SetSwipeColor(RED_FONT_COLOR:GetRGBA())
		tex:SetUseCircularEdge(true)
		tex.SetEdgeTexture = nop;
	end
	CPAPI.Inject(self, inject)
	if not self.RingMasked then
		local mask = self:GetParent().InnerMask;
		for _, region in ipairs({
			self.NormalTexture,
			self.PushedTexture,
			self.HighlightTexture,
			self.Border,
		}) do region:AddMaskTexture(mask) end
		self.RingMasked = true;
	end
end;
end -- Lib.Skin.RingButton


do Lib.Skin.UtilityRingButton = function(self)
	Lib.Skin.RingButton(self)
	local r, g, b = CPAPI.GetClassColor()
	local tex;
	do tex = self.SlotBackground;
		tex:SetDrawLayer('BACKGROUND', -1)
		tex:SetTexture(CPAPI.GetAsset([[Textures\Button\EmptyIcon]]))
		tex:SetDesaturated(true)
		tex:SetVertexColor(0.5, 0.5, 0.5, 1)
		tex:AddMaskTexture(self.IconMask)
		tex:SetRotation(self.rotation)
	end
	do tex = self.Border;
		tex:SetDrawLayer('BACKGROUND', -2)
		tex:ClearAllPoints()
		tex:Show()
		if (self:GetAttribute('type') == 'action' and self:GetAttribute('action') == CPAPI.ExtraActionButtonID) then
			local skin, hasBarSkin = CPAPI.GetOverrideBarSkin(), true;
			if not skin then
				skin, hasBarSkin = [[Interface\ExtraButton\stormwhite-extrabutto]], false;
			end
			tex:SetSize(256 * 0.8, 128 * 0.8)
			tex:SetPoint('CENTER', -2, 0)
			tex:SetTexture(skin)
			if hasBarSkin then
				tex:SetVertexColor(1, 1, 1, 1)
			else
				tex:SetVertexColor(r, g, b, 0.5)
			end
		else
			tex:SetTexture(CPAPI.GetAsset([[Textures\Button\Shadow]]))
			tex:SetPoint('TOPLEFT', -5, 0)
			tex:SetPoint('BOTTOMRIGHT', 5, -10)
		end
	end
end;
end -- Lib.Skin.UtilityRingButton