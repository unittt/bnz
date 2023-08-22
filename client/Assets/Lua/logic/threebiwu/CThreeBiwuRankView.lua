local CThreeBiwuRankView = class("CThreeBiwuRankView", CViewBase)

function CThreeBiwuRankView.ctor(self, cb)
	CViewBase.ctor(self, "UI/ThreeBiwu/ThreeBiwuRankView.prefab", cb)
	--界面设置
	self.m_DepthType = "Fourth"
	self.m_GroupName = "main"
	self.m_ExtendClose = "ClickOut"
end

function CThreeBiwuRankView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_ScrollView = self:NewUI(2, CScrollView)
	self.m_Grid = self:NewUI(3, CGrid)
	self.m_BoxClone = self:NewUI(4, CBox)
	self.m_RankLbl = self:NewUI(5, CLabel)
	self.m_JifenLbl = self:NewUI(6, CLabel)

	self.m_RankTotal = 10
	
	self:InitContent()
end

function CThreeBiwuRankView.InitContent(self)
	self.m_BoxClone:SetActive(false)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
end

function CThreeBiwuRankView.RefreshUI(self)
	self:SetRankList()
	if g_ThreeBiwuCtrl.m_RankIndex > self.m_RankTotal then
		self.m_RankLbl:SetText("我的名次：榜单外")
	else
		self.m_RankLbl:SetText("我的名次："..g_ThreeBiwuCtrl.m_RankIndex)
	end
	self.m_JifenLbl:SetText("我的积分："..g_ThreeBiwuCtrl.m_Point)
end

function CThreeBiwuRankView.SetRankList(self)
	local optionCount = #g_ThreeBiwuCtrl.m_EndRankList
	local GridList = self.m_Grid:GetChildList() or {}
	local oRankBox
	if optionCount > 0 then
		for i=1,optionCount do
			if i > #GridList then
				oRankBox = self.m_BoxClone:Clone(false)
				-- self.m_Grid:AddChild(oOptionBtn)
			else
				oRankBox = GridList[i]
			end
			self:SetRankBox(oRankBox, g_ThreeBiwuCtrl.m_EndRankList[i])
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

function CThreeBiwuRankView.SetRankBox(self, oRankBox, oData)
	oRankBox:SetActive(true)
	oRankBox.m_RankLbl = oRankBox:NewUI(1, CLabel)
	oRankBox.m_NameLbl = oRankBox:NewUI(2, CLabel)
	oRankBox.m_JifenLbl = oRankBox:NewUI(3, CLabel)
	oRankBox.m_WinLinkLbl = oRankBox:NewUI(4, CLabel)
	oRankBox.m_TopSp = oRankBox:NewUI(5, CSprite)

	if oData.rank <= 3 then
		oRankBox.m_RankLbl:SetActive(false)
		oRankBox.m_TopSp:SetActive(true)
		oRankBox.m_TopSp:SetSpriteName("h7_no"..oData.rank)
	else
		oRankBox.m_RankLbl:SetActive(true)
		oRankBox.m_TopSp:SetActive(false)
		oRankBox.m_RankLbl:SetText(oData.rank)
	end
	oRankBox.m_NameLbl:SetText(oData.name)
	oRankBox.m_JifenLbl:SetText(oData.point)
	oRankBox.m_WinLinkLbl:SetText(oData.maxwin)

	self.m_Grid:AddChild(oRankBox)
	self.m_Grid:Reposition()
end

return CThreeBiwuRankView