local db, _, env = ConsolePort:DB(), ...;
---------------------------------------------------------------
-- Console variable fields
---------------------------------------------------------------
local Cvar = CreateFromMixins(CPIndexButtonMixin)

function Cvar:OnLoad()
	self:SetWidth(700)
	self:SetScript('OnEnter', CPIndexButtonMixin.OnIndexButtonEnter)
	self:SetScript('OnLeave', CPIndexButtonMixin.OnIndexButtonLeave)
end

function Cvar:Construct(name, varID, field, newObj)
	if newObj then
		self:SetText(L(name))
		local constructor = Widgets[varID] or Widgets[field[1]:GetType()];
		if constructor then
			constructor(self, varID, field)
		end
	end
	self:Hide()
	self:Show()
end


---------------------------------------------------------------
-- Console variable fields
---------------------------------------------------------------
local Variables = CreateFromMixins(CPFocusPoolMixin, env.ScaleToContentMixin)
env.VariablesMixin = Variables;

function Variables:OnLoad()
	CPFocusPoolMixin.OnLoad(self)
	self:CreateFramePool('IndexButton',
		'CPIndexButtonBindingHeaderTemplate', Cvar, nil, self.Child)
	db:RegisterCallback('Gamepad/Active', self.OnActiveDeviceChanged, self)
end

function Variables:OnActiveDeviceChanged()
--[[
	self:ReleaseAll()
	local device = db('Gamepad/Active')
	if device then
		-- TODO: render cvars
	end
	self:SetHeight(not device and 0 or nil)
]]
end