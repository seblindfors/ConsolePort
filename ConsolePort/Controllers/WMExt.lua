local CHARACTER_RUNNING = true

hooksecurefunc('ToggleRun', function()
	CHARACTER_RUNNING = not CHARACTER_RUNNING
	print(CHARACTER_RUNNING, GetBindingKey('TOGGLERUN'))
end)