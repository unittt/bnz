local CMasterCommendView = class("CMasterCommendView", CViewBase)

function CMasterCommendView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Master/MasterCommendView.prefab", cb)
	--界面设置
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function CMasterCommendView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_DescLbl = self:NewUI(2, CLabel)
	self.m_TitleLbl = self:NewUI(3, CLabel)
	self.m_ScrollView = self:NewUI(4, CScrollView)
	self.m_Grid = self:NewUI(5, CGrid)
	self.m_BoxClone = self:NewUI(6, CBox)

	self.m_IsNotCheckOnLoadShow = true

	self:InitContent()
end

function CMasterCommendView.InitContent(self)
	self.m_BoxClone:SetActive(false)

	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
end

function CMasterCommendView.RefreshUI(self)
	self:SetCommendList()
end

function CMasterCommendView.SetCommendList(self)
	local optionCount = #g_MasterCtrl.m_RecommendMentorList
	local GridList = self.m_Grid:GetChildList() or {}
	local oCommendBox
	if optionCount > 0 then
		for i=1,optionCount do
			if i > #GridList then
				oCommendBox = self.m_BoxClone:Clone(false)
				-- self.m_Grid:AddChild(oOptionBtn)
			else
				oCommendBox = GridList[i]
			end
			self:SetCommendBox(oCommendBox, g_MasterCtrl.m_RecommendMentorList[i])
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
	-- self.m_ScrollView:ResetPosition()
end

function CMasterCommendView.SetCommendBox(self, oCommendBox, oData)
	oCommendBox:SetActive(true)
	oCommendBox.m_IconSp = oCommendBox:NewUI(1, CSprite)
	oCommendBox.m_NameLbl = oCommendBox:NewUI(2, CLabel)
	oCommendBox.m_LevelLbl = oCommendBox:NewUI(3, CLabel)
	oCommendBox.m_SchoolLbl = oCommendBox:NewUI(4, CLabel)
	oCommendBox.m_MasterBtn = oCommendBox:NewUI(5, CButton)

	oCommendBox.m_IconSp:SpriteAvatar(oData.icon)
	oCommendBox.m_NameLbl:SetText(oData.name)
	oCommendBox.m_LevelLbl:SetText(oData.grade.."级")
	oCommendBox.m_SchoolLbl:SetText(data.schooldata.DATA[oData.school].name)
	oCommendBox.m_MasterBtn:AddUIEvent("click", callback(self, "OnClickCommendMasterBtn", oData))

	self.m_Grid:AddChild(oCommendBox)
	self.m_Grid:Reposition()
end

function CMasterCommendView.OnClickCommendMasterBtn(self, oData)
	netmentoring.C2GSDirectBuildReleationship(oData.pid)
	self:OnClose()
end

return CMasterCommendView