local _, db = ...

db.PLUGINS["Blizzard_BindingUI"] = function(self)
	local 	kbF, okayButton, popup = 
			KeyBindingFrame, KeyBindingFrame.okayButton

	local function OnAccept()
		kbF:Hide()
		ToggleFrame(GameMenuFrame)
		ConsolePortConfig:OpenCategory(2)
	end

	local function OnCancel()
		ConsolePort:ClearPopup()
		okayButton:SetButtonState("NORMAL")
	end

	StaticPopupDialogs["CONSOLEPORT_WARNINGBINDINGUI"] = {
		text = db.TUTORIAL.SLASH.WARNINGBINDINGUI,
		button1 = db.TUTORIAL.SLASH.ACCEPT,
		button2 = db.TUTORIAL.SLASH.CANCEL,
		showAlert = true,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		preferredIndex = 3,
		enterClicksFirstButton = true,
		exclusive = true,
		OnAccept = OnAccept,
		OnCancel = OnCancel,
	}

	kbF:HookScript("OnShow", function()
		okayButton:SetButtonState("DISABLED")
		popup = self:ShowPopup("CONSOLEPORT_WARNINGBINDINGUI")
	end)

	kbF:HookScript("OnHide", function()
		if popup then
			ConsolePort:ClearPopup()
			popup:Hide()
			popup = nil
		end
	end)
end