local _, Help = ...
ConsolePortHelp = Help
Help.Pages = {}

function Help:SetWelcomePage(page)
	self.WelcomePage = page
end

function Help:FindParent(parentID, tbl)
	tbl = tbl or self.Pages
	if type(tbl) ~= 'table' then
		return
	end
	if tbl[parentID] then
		return tbl[parentID]
	else
		local match
		for k, v in pairs(tbl) do
			match = self:FindParent(parentID, v)
			if match then
				return match
			end
		end
	end
end

function Help:AddPage(id, parentID, content)
	local contentTable, valid = {}
	if parentID then
		local parentPage = self:FindParent(parentID)
		if parentPage then
			if not parentPage.children then
				parentPage.children = {}
			end
			parentPage.children[id] = contentTable
			valid = true
		end
	else
		self.Pages[id] = contentTable
		valid = true
	end

	contentTable.content = content
	return valid
end

function Help:GetPages()
	return self.Pages, self.WelcomePage
end