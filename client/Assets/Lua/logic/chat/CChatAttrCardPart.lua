local CChatAttrCardPart = class("CChatAttrCardPart", CPageBase)

function CChatAttrCardPart.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CChatAttrCardPart.OnInitPage(self)
	self.m_EmojiPage = self:NewUI(1, CFactoryPartScroll)
	self:InitContent()
end

function CChatAttrCardPart:InitContent()
	local oPage = self.m_EmojiPage
	oPage:SetPartSize(2, 3)
	local function factory(oClone, dData)
		if dData then
			local oBox = oClone:Clone()
			oBox.item = oBox:NewUI(1, CBox)
            oBox.item:NewUI(1,CSprite):SpriteAvatar(dData.icon)
			oBox.item:AddUIEvent("click", callback(self, "OnEmoji", dData))
		    oBox.item:NewUI(3,CLabel):SetText(dData.grade.."级")
            oBox.item:NewUI(4,CLabel):SetText(dData.name)
			oBox:SetActive(true)
			return oBox
		end
	end
	oPage:SetFactoryFunc(factory)
	local function data()
		local t = {}
		local g_AttrCtrl = g_AttrCtrl
		table.insert(t, {pid = g_AttrCtrl.pid,
						 showid = g_AttrCtrl.showid,
						 icon = g_AttrCtrl.icon,
						 grade = g_AttrCtrl.grade,
                         name = g_AttrCtrl.name,
						 })
        local cardData = g_FriendCtrl:GetMyFriend()
		for k, v in ipairs(cardData) do
			v = g_FriendCtrl:GetFriend(v)
			if v then
				local data = {
					pid = v.pid,
					showid = v.showid,
					icon = v.icon,
					grade = v.grade,
	                name = v.name,
				}
				table.insert(t, data)
			end
	    end
		return t
	end
	oPage:SetDataSource(data)
	oPage:RefreshAll()
end

function CChatAttrCardPart.OnEmoji(self, dData)
	local showID = (dData.showid and dData.showid > 0) and dData.showid or dData.pid
	self.m_ParentView:Send(LinkTools.GenerateAttrCardLink("名片-" .. dData.name, showID))
end

return CChatAttrCardPart