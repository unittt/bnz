local CChatMessagePart = class("CChatMessagePart", CPageBase)

function CChatMessagePart.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CChatMessagePart.OnInitPage(self)
	self.m_EmojiPage = self:NewUI(1, CFactoryPartScroll)
	self:InitContent()
end

function CChatMessagePart:InitContent()
	local oPage = self.m_EmojiPage
	oPage:SetPartSize(3, 3)
	local function factory(oClone, dData)
		if dData then
			local oBox = oClone:Clone()
			oBox.m_NameLabel = oBox:NewUI(1, CLabel)
			oBox.m_ClickObj = oBox:NewUI(2, CSprite)
			oBox.m_ClickObj:AddUIEvent("click", callback(self, "OnEmoji", dData))
			local sText = string.gettitle(self:GetMessageText(dData.text), 13, "…")
			oBox.m_NameLabel:SetText("[244B4E]"..sText)
			oBox:SetActive(true)
			return oBox
		end
	end
	oPage:SetFactoryFunc(factory)
	g_ChatCtrl:GetSelfChatMessageData()
	local messgaeData = g_ChatCtrl.m_SelfChatMessageList
	local function data()
		local t = {}
		for k, v in ipairs(messgaeData) do
			local data = {
				text = v.text,
			}
			table.insert(t, data)
		end

		return t
	end
	if #messgaeData > 0 then
		oPage:SetDataSource(data)
		oPage:RefreshAll()
	end
end

function CChatMessagePart.GetMessageText(self, sText)
	local t = {}
	for sLink in string.gmatch(sText, "%b{}") do
		local sPrintText = LinkTools.GetPrintedColorText(sLink)
		if t[sPrintText] then
			local k = t[sPrintText]
			t[sPrintText] = k + 1
			sPrintText = string.gsub(sPrintText, "]", string.format("%d]", k))
		else
			t[sPrintText] = 1
		end
		sText = string.replace(sText, sLink, sPrintText)
	end
	return sText
end

function CChatMessagePart.OnEmoji(self, dData)
	-- printc("CChatMessagePart.OnEmoji ", LinkTools.GenerateChatMessageLink(dData.text))
	self.m_ParentView:Send(dData.text, 1)
end

return CChatMessagePart