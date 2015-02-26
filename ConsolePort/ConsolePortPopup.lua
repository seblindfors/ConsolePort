local _
local _, G = ...;
function ConsolePort:Popup (key, state)
	local PopupFocus = StaticPopup1;
	if  	StaticPopup4:IsVisible() then
		StaticPopup3:SetAlpha(0.5);
		StaticPopup2:SetAlpha(0.5);
		StaticPopup1:SetAlpha(0.5);
		PopupFocus = StaticPopup4;
	elseif	StaticPopup3:IsVisible() then
		StaticPopup2:SetAlpha(0.5);
		StaticPopup1:SetAlpha(0.5);
		PopupFocus = StaticPopup3;
	elseif	StaticPopup2:IsVisible() then
		StaticPopup1:SetAlpha(0.5);
		PopupFocus = StaticPopup2;
	end
	PopupFocus:SetAlpha(1);
	ConsolePort:SetClickButton(CP_R_RIGHT_NOMOD, _G[PopupFocus:GetName().."Button2"]);
	ConsolePort:SetClickButton(CP_R_LEFT_NOMOD, _G[PopupFocus:GetName().."Button1"]);
end