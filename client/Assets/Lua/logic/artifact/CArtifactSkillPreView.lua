local CArtifactSkillPreView = class("CArtifactSkillPreView", CViewBase)

function CArtifactSkillPreView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Artifact/ArtifactSkillPreView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	-- self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function CArtifactSkillPreView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_ScrollView = self:NewUI(2, CScrollView)
	self.m_Grid = self:NewUI(3, CGrid)
	self.m_BoxClone = self:NewUI(4, CBox)
	
	self:InitContent()
end

function CArtifactSkillPreView.InitContent(self)
	self.m_BoxClone:SetActive(false)

	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
end

function CArtifactSkillPreView.RefreshUI(self)
	self:SetSkillList()
end

function CArtifactSkillPreView.SetSkillList(self)
	local oList = g_ArtifactCtrl.m_QiLingSkillConfigList
	
	local optionCount = #oList
	local GridList = self.m_Grid:GetChildList() or {}
	local oSkillBox
	if optionCount > 0 then
		for i=1,optionCount do
			if i > #GridList then
				oSkillBox = self.m_BoxClone:Clone(false)
				-- self.m_Grid:AddChild(oOptionBtn)
			else
				oSkillBox = GridList[i]
			end
			self:SetSkillBox(oSkillBox, oList[i])
		end

		if #GridList > optionCount then
			for i=optionCount+1,#GridList do
				GridList[i]:SetActive(false)
			end
		end
	else
		if GridList and #GridList > 0 then
			for _,v in ipairs(GridList) do
				v:SetActive(false)
			end
		end
	end

	self.m_Grid:Reposition()
	self.m_ScrollView:ResetPosition()
end

function CArtifactSkillPreView.SetSkillBox(self, oSkillBox, oData)
	oSkillBox:SetActive(true)
	oSkillBox.m_IconSp = oSkillBox:NewUI(1, CSprite)
	oSkillBox.m_TalentSp = oSkillBox:NewUI(2, CSprite)
	oSkillBox.m_BindSp = oSkillBox:NewUI(3, CSprite)
	oSkillBox.m_SureSp = oSkillBox:NewUI(4, CSprite)
	oSkillBox.m_InfoWidget = oSkillBox:NewUI(5, CWidget)
	oSkillBox.m_EquipSp = oSkillBox:NewUI(6, CSprite)
	oSkillBox.m_QualitySp = oSkillBox:NewUI(7, CSprite)

	local oConfig = data.artifactdata.SKILL[oData.id]
	oSkillBox.m_IconSp:SpriteSkill(tostring(oConfig.icon))

	oSkillBox.m_IconSp:AddUIEvent("click", callback(self, "OnClickSkillIcon", oConfig, oSkillBox.m_IconSp))

	self.m_Grid:AddChild(oSkillBox)
	self.m_Grid:Reposition()
end

function CArtifactSkillPreView.OnClickSkillIcon(self, oConfig, oWidget)
	if not oConfig then
		return
	end
	CSummonSkillItemTipsView:ShowView(function (oView)
		oView:SetArtifactSkillTips(oConfig, oWidget)
	end)
end

return CArtifactSkillPreView