local _, env = ...;
local HANDLER, LDD = CPAPI.CreateEventHandler({'Frame'}, {'PLAYER_REGEN_DISABLED'}), LibStub('LibUIDropDownMenu-4.0');

local function CacheAvailableBinding(bindings, prune, binding, category, key, ...)
	if key then
		if prune and IsBindingForGamePad(key) then
			return -- handle overlap if pruning enabled
		end
	else
		if binding then
			category = category or BINDING_HEADER_OTHER;
			bindings[category] = bindings[category] or {};
			bindings[category][#bindings[category] + 1] = binding;
		end
		return
	end
	return CacheAvailableBinding(bindings, prune, binding, category, ...)
end

local function GetRealBindingName(binding)
	return _G[('BINDING_NAME_%s'):format(binding) or binding]
		or (select(3, env.db.Bindings:GetDescriptionForBinding(binding)))
		or GetBindingName(binding)
end

local function OnBindingClick(self)
	if SetBinding(HANDLER:GetBindingString(), self.value) then
		CPAPI.Log('Binding %s was successfully changed to |cFFFFFFFF%s|r.', 
			ConsolePort:GetFormattedButtonCombination(HANDLER:GetBinding()),
			GetRealBindingName(self.value)
		);
	end
	SaveBindings(GetCurrentBindingSet())
	HANDLER:Close()
end

local function OnBindingCancel(self)
	HANDLER:Close()
end

local function ShowBindingDropdown(frame, level, menuList)
	local info = LDD:UIDropDownMenu_CreateInfo()
	local bindings = {};
	local pruningEnabled = not env.db('bindingOverlapEnable')

	for i=1, GetNumBindings() do
		CacheAvailableBinding(bindings, pruningEnabled, GetBinding(i))
	end

	local customHeader = (' |T%s:0|t %s '):format(CPAPI.GetAsset('Textures\\Logo\\CP_Tiny.blp'), SPECIAL)
	for i, data in env.db:For('Bindings') do
		if not data.readonly then
			CacheAvailableBinding(bindings, pruningEnabled, data.binding, customHeader, GetBindingKey(data.binding))
		end
	end

	info.notCheckable = 1;
	if (level == 1) then
		-- show which binding is being modified
		info.func = nop;
		info.text = ('%s: %s'):format(
			NORMAL_FONT_COLOR:WrapTextInColorCode(KEY_BINDING),
			ConsolePort:GetFormattedButtonCombination(HANDLER:GetBinding()) or ''
		);

		LDD:UIDropDownMenu_AddButton(info)

		-- add cancel button
		info.func = OnBindingCancel;
		info.text = CANCEL;
		LDD:UIDropDownMenu_AddButton(info)

		-- separate, prepare for binding menus
		LDD:UIDropDownMenu_AddSeparator(level)
		info.func = nil;

		-- binding menus
		for category, set in env.db.table.spairs(bindings) do
			info.text = _G[category] or category;
			info.hasArrow = true;
			info.menuList = category;
			LDD:UIDropDownMenu_AddButton(info)
		end
	else
		local set = bindings[menuList];
		if set then
			local lastIndexWasSeparator = true;
			for i, binding in ipairs(set) do
				if binding:match('^HEADER_BLANK') then
					if not lastIndexWasSeparator then
						LDD:UIDropDownMenu_AddSeparator(level)
						lastIndexWasSeparator = true;
					end
				elseif binding:match('^HEADER') then
					-- do something?
				else
					lastIndexWasSeparator = false;
					info.text = GetRealBindingName(binding);
					info.value = binding;
					info.owner = frame;
					info.func = OnBindingClick;
					LDD:UIDropDownMenu_AddButton(info, level)
				end
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
	self.mod = owner.isMainButton and CPAPI.CreateKeyChord('') or owner.mod;

	LDD:UIDropDownMenu_Initialize(self, ShowBindingDropdown)
	LDD:ToggleDropDownMenu(nil, nil, self, 'cursor')
end

HANDLER.PLAYER_REGEN_DISABLED = HANDLER.Close;

function env:OpenBindingDropdown(frame)
	if InCombatLockdown() then return end

	HANDLER:SetFrame(frame)
	if not HANDLER.initialized then
		ConsolePort:AddInterfaceCursorFrame('L_DropDownList1')
		ConsolePort:AddInterfaceCursorFrame('L_DropDownList2')
		HANDLER.initialized = true;
		if L_DropDownList1Border then
			L_DropDownList1Border:SetBackdrop(CPAPI.Backdrops.Frame)
			L_DropDownList1Border:SetBackdropColor(0, 0, 0, 0.75)
		end
		if L_DropDownList2Border then
			L_DropDownList2Border:SetBackdrop(CPAPI.Backdrops.Frame)
			L_DropDownList2Border:SetBackdropColor(0, 0, 0, 0.75)
		end
	end
end