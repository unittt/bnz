local CChatTaskPart = class("CChatTaskPart", CPageBase)

function CChatTaskPart.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CChatTaskPart.OnInitPage(self)
	self.m_EmojiPage = self:NewUI(1, CFactoryPartScroll)
	self:InitContent()
end

function CChatTaskPart:InitContent()
	local oPage = self.m_EmojiPage
	oPage:SetPartSize(2, 2)
	local function factory(oClone, dData)
		if dData then
			local oBox = oClone:Clone()
			oBox.m_NameLabel = oBox:NewUI(1, CLabel)
			oBox.m_TargetLabel = oBox:NewUI(2, CLabel)
			oBox.m_ClickObj = oBox:NewUI(3, CSprite)
			oBox.m_LeftLbl = oBox:NewUI(4, CLabel)
			oBox.m_ClickObj:AddUIEvent("click", callback(self, "OnEmoji", dData))
			oBox.m_NameLabel:SetText(dData.name)
			local oOldText = g_ChatCtrl:ReplaceColor(dData.target)
			oOldText = string.gsub(oOldText, "ccebdb", "244B4E")
			-- oBox.m_TargetLabel:SetText(string.gettitle(g_ChatCtrl:ReplaceColor(dData.target), 18, "..."))
			oBox.m_TargetLabel:SetText(oOldText)
			if string.len(oOldText) ~= string.len(oBox.m_TargetLabel.m_UIWidget.processedText) then
				oBox.m_LeftLbl:SetText("...")
			else
				oBox.m_LeftLbl:SetText("")
			end
			oBox:SetActive(true)
			return oBox
		end
	end
	oPage:SetFactoryFunc(factory)
	local taskData = g_TaskCtrl:GetTaskDataListWithSort()
	local function data()
		local t = {}
		for k, oTask in ipairs(taskData) do
			local data = {
				id = oTask:GetSValueByKey("taskid"),
				name = string.format("%s-%s", oTask.m_TaskType.name, oTask:GetSValueByKey("name")),
				target = CTaskHelp.GetTargetDesc(oTask),
				desc = oTask:GetSValueByKey("detaildesc"),
			}
			table.insert(t, data)
		end

		return t
	end
	if #taskData > 0 then
		oPage:SetDataSource(data)
		oPage:RefreshAll()
	end
end

function CChatTaskPart.OnEmoji(self, dData)
	local oTargetDesc = string.gsub(dData.target, "ccebdb", "244B4E")
	self.m_ParentView:Send(LinkTools.GenerateTaskLink(dData.id, dData.name, oTargetDesc, "[244B4E]"..dData.desc))
end

return CChatTaskPart