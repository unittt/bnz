local CChatTitlePart = class("CChatTitlePart", CPageBase)

function CChatTitlePart.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CChatTitlePart.OnInitPage(self)
	self.m_EmojiPage = self:NewUI(1, CFactoryPartScroll)
	self:InitContent()
end

function CChatTitlePart:InitContent()
	local oPage = self.m_EmojiPage
	oPage:SetPartSize(2, 2)
	local function factory(oClone, dData)
		if dData then
			local oBox = oClone:Clone()
			oBox.item = oBox:NewUI(1, CBox)
			oBox.item:AddUIEvent("click", callback(self, "OnEmoji", dData))
            oBox.item:NewUI(4,CLabel):SetText(dData.name)
			oBox:SetActive(true)
			return oBox
		end
	end
	oPage:SetFactoryFunc(factory)
	local function data()
		local t = {}
		for k, v in pairs(g_TitleCtrl.m_TitleList) do
			local data = {
                tid = v.tid,
                name = v.name,
			}
			table.insert(t, data)
	    end
		return t
	end
	oPage:SetDataSource(data)
	oPage:RefreshAll()
end

function CChatTitlePart.OnEmoji(self, dData)
	self.m_ParentView:Send(LinkTools.GenerateTitleLink(dData.name, dData.tid))
end

return CChatTitlePart