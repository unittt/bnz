local CChatSkillPart = class("CChatSkillPart", CPageBase)

function CChatSkillPart.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CChatSkillPart.OnInitPage(self)
	self.m_EmojiPage = self:NewUI(1, CFactoryPartScroll)
	self:InitContent()
end

function CChatSkillPart:InitContent()
	local oPage = self.m_EmojiPage
	oPage:SetPartSize(2, 2)
	local function factory(oClone, dData)
		if dData then
			local oBox = oClone:Clone()
			oBox.m_NameLabel = oBox:NewUI(1, CLabel)
			oBox.m_LevelLabel = oBox:NewUI(2, CLabel)
			oBox.m_ClickObj = oBox:NewUI(3, CSprite)
			oBox.m_ClickObj:AddUIEvent("click", callback(self, "OnEmoji", dData))
			oBox.m_NameLabel:SetText(dData.name)
			oBox.m_LevelLabel:SetText("当前等级:"..dData.level.."级")
			oBox:SetActive(true)
			return oBox
		end
	end
	oPage:SetFactoryFunc(factory)
	local list = {}
	for k,v in pairs(g_AttrCtrl.org_skill) do
		table.insert(list, v)
	end
	table.sort(list, function(a, b) return a.sk < b.sk end)
	local skillData = list
	local function datasource()
		local t = {}
		for k, v in ipairs(skillData) do
			local data = {
				id = v.sk,
				name = data.skilldata.ORGSKILL[v.sk].name,
				level = v.level,
				desc = data.skilldata.ORGSKILL[v.sk].des,
			}
			table.insert(t, data)
		end

		return t
	end
	if #skillData > 0 then
		oPage:SetDataSource(datasource)
		oPage:RefreshAll()
	end
end

function CChatSkillPart.OnEmoji(self, dData)
	self.m_ParentView:Send(LinkTools.GenerateOrgSkillLink(tonumber(dData.id), dData.name, dData.level, dData.desc))
end

return CChatSkillPart