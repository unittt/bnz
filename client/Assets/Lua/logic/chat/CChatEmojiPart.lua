local CChatEmojiPart = class("CChatEmojiPart", CPageBase)

function CChatEmojiPart.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CChatEmojiPart.OnInitPage(self)
	self.m_EmojiPage = self:NewUI(1, CFactoryPartScroll)
	self:InitContent()
end

function CChatEmojiPart:InitContent()
	local oPage = self.m_EmojiPage
	oPage:SetPartSize(7, 3)
	local function factory(oClone, dData)
		if dData then
			local oBox = oClone:Clone()
			oBox.m_Sprtite = oBox:NewUI(1, CSprite)
			if tonumber(dData.idx) == 1 then
				g_GuideCtrl:AddGuideUI("chatview_emoji_icon", oBox.m_Sprtite)
			end
			local sPrefix = string.format("#%d_", dData.idx)
			oBox.m_Sprtite:SetSpriteName(sPrefix.."00")
			oBox.m_Sprtite:SetNamePrefix(sPrefix)
			oBox.m_Sprtite:SetFramesPerSecond(4)
			oBox.m_Sprtite:AddUIEvent("click", callback(self, "OnEmoji", dData.idx))
			oBox:SetActive(true)		
			return oBox
		end
	end
	oPage:SetFactoryFunc(factory)
	local function data()
		local t = {}
		for i= 1, 55 do
			table.insert(t, {idx = i})
		end
		return t
	end
	oPage:SetDataSource(data)
	oPage:RefreshAll()
end

function CChatEmojiPart.OnEmoji(self, idx)
	self.m_ParentView:Send("#"..tostring(idx))
end

return CChatEmojiPart