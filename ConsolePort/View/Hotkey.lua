local _, db = ...;
local HotkeyMixin, HotkeyHandler = {}, CPAPI.CreateEventHandler({'Frame', 'ConsolePortHotkeyHandler'}, {
	'CVAR_UPDATE';
	'UPDATE_BINDINGS';
	'MODIFIER_STATE_CHANGED';
})

function HotkeyHandler:UpdateActiveDevice(name)
	print(name, ':)')
end

ConsolePort:RegisterVarCallback('Gamepad/Active', HotkeyHandler.UpdateActiveDevice, HotkeyHandler)