-- TODO: everything
local _, db = ...;
--Button name="ConsolePortSpellFlyout" inherits="SecureHandlerBaseTemplate, SecureActionButtonTemplate" parent="UIParent" registerForClicks="AnyDown" hidden="true"
local Flyout, Selector = SpellFlyout, CreateFrame('Frame', 'ConsolePortSpellFlyout', UIParent, 'SecureHandlerBaseTemplate')

Selector:Execute('this = self')
Selector:Hide()
Selector:WrapScript(Flyout, 'OnShow', [[
	this:Show()
]])

Selector:WrapScript(Flyout, 'OnHide', [[
	this:Hide()
]])

db('Radial'):Register(Selector, 'SpellFlyout', {
	sticks = {'Left', 'Movement'};
	target = {'Left'};
})

function Selector:OnInput(...)
	print(...)
end