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
Lib.Skin.RingButton = function(self)
	assert(type(self.rotation) == 'number', 'Ring button must have a rotation value.')
	local obj;
	local r, g, b = CPAPI.GetClassColor()
	do obj = self.NormalTexture;
		obj:ClearAllPoints()
		obj:SetPoint('CENTER', -1, 0)
		obj:SetSize(110, 110)
		obj:SetVertexColor(r, g, b, 1)
		CPAPI.SetAtlas(obj, 'ring-metallight')
	end
	do obj = self.PushedTexture;
		obj:ClearAllPoints()
		obj:SetPoint('CENTER')
		obj:SetSize(110, 110)
		obj:SetVertexColor(r, g, b, 1)
		CPAPI.SetAtlas(obj, 'ring-metaldark')
	end
	do obj = self.CheckedTexture;
		obj:ClearAllPoints()
		obj:SetPoint('CENTER', 0, 0)
		obj:SetSize(78, 78)
		obj:SetDrawLayer('OVERLAY', -1)
		CPAPI.SetAtlas(obj, 'ring-select')
	end
	do obj = self.HighlightTexture;
		obj:ClearAllPoints()
		obj:SetPoint('CENTER')
		obj:SetSize(90, 90)
		CPAPI.SetAtlas(obj, 'ring-select')
	end
	do obj = self.icon;
		obj:SetAllPoints()
	end
	do obj = self.IconMask;
		obj:SetTexture([[Interface\Masks\CircleMask]])
		obj:SetPoint('CENTER')
		obj:SetSize(58, 58)
	end
	do obj = self.Flash;
		obj:ClearAllPoints()
		obj:SetPoint('CENTER', 1, 0)
		obj:SetSize(110, 110)
		obj:SetBlendMode('ADD')
		CPAPI.SetAtlas(obj, 'ring-horde')
		obj:SetDrawLayer('OVERLAY', 1)
	end
	do obj = self.SlotBackground;
		obj:SetPoint('CENTER')
		obj:SetSize(64, 64)
		obj:SetTexture(CPAPI.GetAsset([[Textures\Button\Icon_Mask64]]))
		obj:SetRotation(self.rotation + math.pi)
		obj:AddMaskTexture(self.IconMask)
		obj:SetDrawLayer('BACKGROUND', -1)
	end
	do obj = self.SpellHighlightTexture;
		obj:ClearAllPoints()
		obj:SetPoint('CENTER', 0, 0)
		obj:SetSize(64, 64)
		obj:SetTexture([[Interface\Buttons\IconBorder-GlowRing]])
	end
	do obj = self.cooldown;
		obj:SetSwipeTexture([[Interface\AddOns\ConsolePort_Bar\Textures\Cooldown\Swipe]])
		obj:SetSwipeColor(RED_FONT_COLOR:GetRGBA())
		obj:SetUseCircularEdge(true)
		obj.SetEdgeTexture = nop;
	end
	do obj = self.chargeCooldown;
		-- HACK: Workaround for LAB's private charge cooldowns.
		if obj and not self.hookedChargeCooldown then
			self.hookedChargeCooldown = true;
			local script = obj:GetScript('OnCooldownDone')
			obj:SetUseCircularEdge(true)
			obj:SetScript('OnCooldownDone', function()
				obj:SetUseCircularEdge(false)
				self.hookedChargeCooldown = nil;
				if script then
					script(obj)
				end
			end)
		end
	end
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
	local obj;
	do obj = self.SlotBackground;
		obj:SetDrawLayer('BACKGROUND', -1)
		obj:SetTexture(CPAPI.GetAsset([[Textures\Button\EmptyIcon]]))
		obj:SetDesaturated(true)
		obj:SetVertexColor(0.5, 0.5, 0.5, 1)
		obj:AddMaskTexture(self.IconMask)
		obj:SetRotation(self.rotation)
	end
	do obj = self.Border;
		obj:SetDrawLayer('BACKGROUND', -2)
		obj:ClearAllPoints()
		obj:Show()
		if (self:GetAttribute('type') == 'action' and self:GetAttribute('action') == CPAPI.ExtraActionButtonID) then
			local skin, hasBarSkin = CPAPI.GetOverrideBarSkin(), true;
			if not skin then
				skin, hasBarSkin = [[Interface\ExtraButton\stormwhite-extrabutto]], false;
			end
			obj:SetSize(256 * 0.8, 128 * 0.8)
			obj:SetPoint('CENTER', -2, 0)
			obj:SetTexture(skin)
			if hasBarSkin then
				obj:SetVertexColor(1, 1, 1, 1)
			else
				obj:SetVertexColor(r, g, b, 0.5)
			end
		else
			obj:SetTexture(CPAPI.GetAsset([[Textures\Button\Shadow]]))
			obj:SetPoint('TOPLEFT', -5, 0)
			obj:SetPoint('BOTTOMRIGHT', 5, -10)
		end
	end
end;
end -- Lib.Skin.UtilityRingButton