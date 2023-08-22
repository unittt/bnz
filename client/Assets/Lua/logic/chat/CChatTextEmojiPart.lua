local CChatTextEmojiPart = class("CChatTextEmojiPart", CPageBase)

function CChatTextEmojiPart.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CChatTextEmojiPart.OnInitPage(self)
	self.m_EmojiPage = self:NewUI(1, CFactoryPartScroll)
	self:InitContent()
end

function CChatTextEmojiPart:InitContent()
	local oPage = self.m_EmojiPage
	oPage:SetPartSize(4, 4)
	local function factory(oClone, dData)
		if dData then
			local oBox = oClone:Clone()
			oBox.item = oBox:NewUI(1, CBox)
			oBox.item:AddUIEvent("click", callback(self, "OnEmoji", dData))
            oBox.item:NewUI(1,CLabel):SetText(dData.name)
			oBox:SetActive(true)
			return oBox
		end
	end
	oPage:SetFactoryFunc(factory)
	local function datasource()
		local t = {}
		for k, v in ipairs(data.chatdata.TEXTEMOJI) do
			local datalist = {
                id = v.id,
                name = v.text,
                content = v.content2
			}
			table.insert(t, datalist)
	    end
		return t
	end
	oPage:SetDataSource(datasource)
	oPage:RefreshAll()
end

function CChatTextEmojiPart.OnEmoji(self, dData)
	local sText = string.gsub(dData.content, "#role", "#G"..g_AttrCtrl.name.."#n")
	sText = string.gsub(sText, "#other", "")

	local oFriendView = CFriendInfoView:GetView()
	if oFriendView and oFriendView.m_Brief.m_TalkPart:GetActive() then
		if oFriendView.m_Brief.m_TalkPart.m_ID then
			g_TalkCtrl:AddSelfMsg(oFriendView.m_Brief.m_TalkPart.m_ID, sText)
			g_TalkCtrl:SendChat(oFriendView.m_Brief.m_TalkPart.m_ID, sText)
			return
		end
	end

	local oView = CChatMainView:GetView()
	if g_ChatCtrl:SendMsg(sText, g_ChatCtrl:GetTextEmojiChannel()) then
		if oView then
			oView.m_ChatPage:SetChannelTip(g_ChatCtrl:GetTextEmojiChannel())
		end
	end
	--发送消息后解除锁屏状态
	if oView then
		oView.m_ChatPage:ShowNewMsg()
	end
end

return CChatTextEmojiPart