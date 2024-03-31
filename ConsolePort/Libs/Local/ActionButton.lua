local Lib = LibStub:NewLibrary('ConsolePortActionButton', 1) -- TODO: rename the lib?
if not Lib then return end
local LAB = LibStub('LibActionButton-1.0')
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

Lib.Skin.RingButton = function(self)
	assert(type(self.rotation) == 'number', 'Ring button must have a rotation value.')
	local tex;
	local r, g, b = CPAPI.GetClassColor()
	do tex = self.NormalTexture;
		tex:ClearAllPoints()
		tex:SetPoint('CENTER')
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
	end
	do tex = self.Border;
		tex:ClearAllPoints()
		tex:Hide()
	end
end;