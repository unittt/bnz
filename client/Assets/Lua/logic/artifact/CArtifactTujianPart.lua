local CArtifactTujianPart = class("CArtifactTujianPart", CPageBase)

function CArtifactTujianPart.ctor(self, obj)
	CPageBase.ctor(self, obj)
	self.m_ScrollView = self:NewUI(1, CScrollView)
	self.m_Grid = self:NewUI(2, CGrid)
	self.m_BoxClone = self:NewUI(3, CBox)
	self.m_IconSp = self:NewUI(4, CSprite)
	self.m_NameLbl = self:NewUI(5, CLabel)
	self.m_DescLbl = self:NewUI(6, CLabel)

	self:InitContent()
end

function CArtifactTujianPart.InitContent(self)
	self.m_BoxClone:SetActive(false)

	self:RefreshUI()
end

function CArtifactTujianPart.RefreshUI(self)
	self:SetTujianList()
	if self.m_SelectShowIndex then
		self:SelectOne(self.m_SelectShowIndex)
	else
		self:SelectOne(1)
	end
end

function CArtifactTujianPart.SetTujianList(self)
	local optionCount = #g_ArtifactCtrl.m_QiLingSkillConfigList
	local GridList = self.m_Grid:GetChildList() or {}
	local oTujianBox
	if optionCount > 0 then
		for i=1,optionCount do
			if i > #GridList then
				oTujianBox = self.m_BoxClone:Clone(false)
				-- self.m_Grid:AddChild(oOptionBtn)
			else
				oTujianBox = GridList[i]
			end
			self:SetTujianBox(oTujianBox, g_ArtifactCtrl.m_QiLingSkillConfigList[i])
		end

		if #GridList > optionCount then
			for i=optionCount+1,#GridList do
				GridList[i]:SetActive(false)
				GridList[i].m_Data = nil
			end
		end
	else
		if GridList and #GridList > 0 then
			for _,v in ipairs(GridList) do
				v:SetActive(false)
				v.m_Data = nil
			end
		end
	end

	self.m_Grid:Reposition()
	-- self.m_ScrollView:ResetPosition()
end

function CArtifactTujianPart.SetTujianBox(self, oTujianBox, oData)
	oTujianBox:SetActive(true)
	oTujianBox.m_NameLbl = oTujianBox:NewUI(1, CLabel)
	oTujianBox.m_IconSp = oTujianBox:NewUI(2, CSprite)
	oTujianBox.m_ItemBtn = oTujianBox:NewUI(3, CWidget)
	oTujianBox.m_SelNameLbl = oTujianBox:NewUI(4, CLabel)
	oTujianBox.m_ItemBtn:SetGroup(self:GetInstanceID())
	oTujianBox.m_Data = oData

	local oConfig = data.artifactdata.SKILL[oData.id]
	oTujianBox.m_IconSp:SpriteSkill(tostring(oConfig.icon))
	oTujianBox.m_NameLbl:SetText(oConfig.name)
	oTujianBox.m_SelNameLbl:SetText(oConfig.name)
	
	oTujianBox.m_ItemBtn:AddUIEvent("click", callback(self, "OnClickTujianBox", oData))

	self.m_Grid:AddChild(oTujianBox)
	self.m_Grid:Reposition()
end

function CArtifactTujianPart.SelectOneById(self, oId)
	local GridList = self.m_Grid:GetChildList() or {}
	for k,v in pairs(GridList) do
		if v.m_Data and v.m_Data.id == oId then
			v.m_ItemBtn:SetSelected(true)
			break
		end
	end
	self:OnShowEachById(oId)
end

function CArtifactTujianPart.SelectOne(self, oIndex)
	local oChild = self.m_Grid:GetChild(oIndex)
	if oChild then
		oChild.m_ItemBtn:SetSelected(true)
	end
	self:OnShowEachByIndex(oIndex)
end

function CArtifactTujianPart.OnShowEachByIndex(self, oIndex)
	if not g_ArtifactCtrl.m_QiLingSkillConfigList[oIndex] then
		return
	end
	self.m_SelectShowIndex = oIndex
	self:OnShowEachById(g_ArtifactCtrl.m_QiLingSkillConfigList[oIndex].id)
end

function CArtifactTujianPart.OnShowEachById(self, oId)
	local oConfig = data.artifactdata.SKILL[oId]
	if not oConfig then
		return
	end
	self.m_SelectShowId = oId
	self.m_IconSp:SpriteSkill(tostring(oConfig.icon))
	self.m_NameLbl:SetText(oConfig.name)
	self.m_DescLbl:SetText(oConfig.desc)
end

--------------以下是点击事件--------------

function CArtifactTujianPart.OnClickTujianBox(self, oData)
	self:OnShowEachById(oData.id)
end

return CArtifactTujianPart