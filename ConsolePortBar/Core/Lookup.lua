function ConsolePort:GetBindingIcon(binding)
	local icons = {
		["JUMP"] = "Interface\\Icons\\Ability_Karoz_Leap",
	}
	return icons[binding]
end