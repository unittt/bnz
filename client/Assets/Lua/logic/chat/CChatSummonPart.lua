local CChatSummonPart = class("CChatSummonPart", CPageBase)

function CChatSummonPart.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CChatSummonPart.OnInitPage(self)
	self.m_EmojiPage = self:NewUI(1, CFactoryPartScroll)
	self:InitContent()
end

function CChatSummonPart:InitContent()
	local oPage = self.m_EmojiPage
	oPage:SetPartSize(2, 2)
	local function factory(oClone, dData)
		if dData then
			local oBox = oClone:Clone()
			oBox.m_Sprtite = oBox:NewUI(1, CSprite)
			oBox.m_Sprtite:SpriteAvatar(dData.icon)
			oBox.m_GradeLabel = oBox:NewUI(2, CLabel)
			oBox.m_NameLabel = oBox:NewUI(3, CLabel)
			oBox.m_ScoreLabel = oBox:NewUI(4, CLabel)
			oBox.m_GodSprite = oBox:NewUI(5, CSprite)
			oBox.m_RareSprite = oBox:NewUI(6, CSprite)
			oBox.m_SelfSprite = oBox:NewUI(7, CSprite)
			oBox.m_ClickObj = oBox:NewUI(8, CSprite)
			oBox.m_ClickObj:AddUIEvent("click", callback(self, "OnEmoji", dData))

			oBox.m_NameLabel:SetText(dData.name)
			oBox.m_ScoreLabel:SetText(dData.score)
			oBox.m_GradeLabel:SetText(string.format("%d", dData.grade).."级")
			oBox:SetActive(true)
			return oBox
		end
	end
	oPage:SetFactoryFunc(factory)
	local function data()
		local t = {}
		local summonData = g_SummonCtrl.m_SummonsSort
		for k, v in ipairs(summonData) do
			local data = {
				id = v.id,
				typeid = v.typeid,
				icon = v.model_info.shape,
				grade = v["grade"],
				name = v.name,
				score = v.summon_score,

			}
			table.insert(t, data)
		end

		return t
	end
	if table.count(g_SummonCtrl.m_SummonsSort) > 0 then
		oPage:SetDataSource(data)
		oPage:RefreshAll()
	end
end

function CChatSummonPart.OnEmoji(self, dData)
	self.m_ParentView:Send(LinkTools.GenerateSummonLink(g_AttrCtrl.pid, dData.id, dData.typeid, g_TimeCtrl:GetTimeS()))
end

return CChatSummonPart