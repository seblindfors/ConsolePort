--- Warning popup and modification of the keybinding UI.
-- This code simply adds an extra layer of protection when messing with keyboard bindings while CP is running.
-- CP is using unsaved bindings to get the correct bindings keys in secure scopes since overrides might be present.
-- Saving bindings while these temp bindings are configured will overwrite regular keyboard bindings.

local _, db = ...

ConsolePort:AddPlugin('Blizzard_BindingUI', function(self)
	local 	kbF, okayButton, popup = 
			KeyBindingFrame, KeyBindingFrame.okayButton

	local function OnAccept()
		kbF:Hide()
		ToggleFrame(GameMenuFrame)
		ConsolePortOldConfig:OpenCategory('Binds')
	end

	local function OnAlt()
		kbF:Hide()
		ToggleFrame(GameMenuFrame)
		ConsolePort:CalibrateController(true)
	end

	local function OnCancel()
		ConsolePort:ClearPopup()
		okayButton:SetButtonState('NORMAL')
	end

	StaticPopupDialogs['CONSOLEPORT_WARNINGBINDINGUI'] = {
		text = db.TUTORIAL.SLASH.WARNINGBINDINGUI,
		button1 = db.TUTORIAL.SLASH.EDITBINDS,
		button2 = CONTINUE,
		button3 = db.TUTORIAL.SLASH.CALIBRATE,
		showAlert = true,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		preferredIndex = 3,
		enterClicksFirstButton = true,
		exclusive = true,
		OnAlt = OnAlt,
		OnAccept = OnAccept,
		OnCancel = OnCancel,
	}

	kbF:HookScript('OnShow', function()
		okayButton:SetButtonState('DISABLED')
		popup = self:ShowPopup('CONSOLEPORT_WARNINGBINDINGUI')
	end)

	kbF:HookScript('OnHide', function()
		if popup then
			ConsolePort:ClearPopup()
			popup:Hide()
			popup = nil
		end
	end)
end)