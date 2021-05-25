local _, env = ...;
local HANDLER, LDD = CPAPI.CreateEventHandler({'Frame'}, {'PLAYER_REGEN_DISABLED'}), LibStub('LibUIDropDownMenu-4.0');

local function CacheAvailableBinding(bindings, binding, category, key, ...)
	if key then
		if IsBindingForGamePad(key) then -- handle overlap if enabled?
			return
		end
	else
		if not binding:match('^HEADER_') then
			bindings[category] = bindings[category] or {};
			bindings[category][#bindings[category] + 1] = binding;
		end
		return
	end
	return CacheAvailableBinding(bindings, binding, category, ...)
end

local function OnBindingClick(self)
	SetBinding(HANDLER:GetBindingString(), self.value)
	SaveBindings(GetCurrentBindingSet())
	HANDLER:Close()
end

local function ShowBindingDropdown(frame, level, menuList)
	local info = LDD:UIDropDownMenu_CreateInfo()
	local bindings = {};

	for i=1, GetNumBindings() do
		CacheAvailableBinding(bindings, GetBinding(i))
	end

	info.notCheckable = 1;
	if (level == 1) then
		info.text = ConsolePort:GetFormattedButtonCombination(HANDLER:GetBinding())
		LDD:UIDropDownMenu_AddButton(info)

		for category, set in pairs(bindings) do
			info.text = _G[category] or category;
			info.hasArrow = true;
			info.menuList = category;
			LDD:UIDropDownMenu_AddButton(info)
		end
	else
		local set = bindings[menuList];
		if set then
			for i, binding in ipairs(set) do
				info.text = _G[('BINDING_NAME_%s'):format(binding) or binding];
				info.value = binding;
				info.owner = frame;
				info.func = OnBindingClick;
				LDD:UIDropDownMenu_AddButton(info, level)
			end
		end
	end
end

function HANDLER:Close()
	LDD:CloseDropDownMenus()
	self:Hide()
	self:ClearAllPoints()
end

function HANDLER:GetBindingString()
	return (self.mod .. self.btn);
end

function HANDLER:GetBinding()
	return self.btn, self.mod;
end

function HANDLER:SetFrame(owner)
	self:Show()
	self:SetParent(owner)
	self:SetAllPoints(owner)

	self.btn = owner.plainID;
	self.mod = owner.isMainButton and CPAPI.CreateKeyChordStringUsingMetaKeyState('') or owner.mod;

	LDD:UIDropDownMenu_Initialize(self, ShowBindingDropdown)
	LDD:ToggleDropDownMenu(nil, nil, self, 'cursor')
end

HANDLER.PLAYER_REGEN_DISABLED = HANDLER.Close;

function env:OpenBindingDropdown(frame)
	if not InCombatLockdown() then
		HANDLER:SetFrame(frame)
		if not HANDLER.initialized then
			ConsolePort:AddInterfaceCursorFrame('L_DropDownList1')
			ConsolePort:AddInterfaceCursorFrame('L_DropDownList2')
			HANDLER.initialized = true;
		end
	end
end