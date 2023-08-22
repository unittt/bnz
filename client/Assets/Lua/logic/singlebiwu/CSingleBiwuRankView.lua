local CSingleBiwuRankView = class("CSingleBiwuRankView", CViewBase)

function CSingleBiwuRankView.ctor(self, cb)
	CViewBase.ctor(self, "UI/SingleBiwu/SingleBiwuRankView.prefab", cb)
	--界面设置
	self.m_GroupName = "main"
	self.m_ExtendClose = "ClickOut"
end

function CSingleBiwuRankView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_ScrollView = self:NewUI(2, CScrollView)
	self.m_RankGrid = self:NewUI(3, CGrid)
	self.m_RankBoxClone = self:NewUI(4, CBox)
	self.m_MyRankLbl = self:NewUI(5, CLabel)
	self.m_MyPointLbl = self:NewUI(6, CLabel)
	self.m_MyGroupLbl = self:NewUI(7, CLabel)
	self.m_GroupGrid = self:NewUI(8, CGrid)

	self.m_CurGroup = 0
	self.m_RankBoxs = {}
	self:InitContent()
end

function CSingleBiwuRankView.InitContent(self)
	self.m_RankBoxClone:SetActive(false)

	self.m_GroupGrid:InitChild(function (obj, idx)
		local oBtn = CButton.New(obj)
		oBtn:AddUIEvent("click", callback(self, "ChangeGroup", idx))
		oBtn:SetGroup(self.m_GroupGrid:GetInstanceID())
		return oBtn
	end)

	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))

	self:ChangeGroup(g_SingleBiwuCtrl.m_MyGroup)
end

function CSingleBiwuRankView.RefreshUI(self)
	self:RefreshRankList()
	self:RefreshMyInfo()
end

function CSingleBiwuRankView.RefreshRankList(self)
	self.m_ScrollView:ResetPosition()
	for k,oBox in pairs(self.m_RankBoxs) do
		oBox:SetActive(false)
	end
	local lRankInfo = g_SingleBiwuCtrl:GetFinalRankListByGroup(self.m_CurGroup)
	for i,dInfo in ipairs(lRankInfo) do
		local oBox = self.m_RankBoxs[i]
		if not oBox then
			oBox = self:CreateRankBox()
			self.m_RankBoxs[i] = oBox
			self.m_RankGrid:AddChild(oBox)
		end
		self:UpdateRankBox(oBox, dInfo, i)
	end
	self.m_RankGrid:Reposition()
end

function CSingleBiwuRankView.CreateRankBox(self)
	local oBox = self.m_RankBoxClone:Clone()
	oBox.m_RankL = oBox:NewUI(1, CLabel)
	oBox.m_NameL = oBox:NewUI(2, CLabel)
	oBox.m_PointL = oBox:NewUI(3, CLabel)
	oBox.m_WinL = oBox:NewUI(4, CLabel)
	oBox.m_RankSpr = oBox:NewUI(5, CSprite)
	oBox.m_BgSpr = oBox:NewUI(6, CSprite)
	return oBox
end

function CSingleBiwuRankView.UpdateRankBox(self, oBox, dInfo, iIndex)
	local dData = data.schooldata.DATA[dInfo.school]
	oBox:SetActive(true)
	oBox:AddUIEvent("click", callback(self, "OnPlayerInfo", dInfo.pid))
	oBox.m_RankL:SetActive(iIndex > 3)
	oBox.m_RankSpr:SetActive(iIndex <= 3)
	oBox.m_RankSpr:SetSpriteName("h7_no"..iIndex)
	oBox.m_RankL:SetText(iIndex)
	oBox.m_NameL:SetText(dInfo.name)
	oBox.m_PointL:SetText(dInfo.point)
	oBox.m_WinL:SetText(dInfo.win_seri_max)
	if iIndex % 2  == 1 then  -- 奇数
        oBox.m_BgSpr:SetSpriteName("h7_di_3")
    else    -- 偶数
        oBox.m_BgSpr:SetSpriteName("h7_di_4")
    end 
end

function CSingleBiwuRankView.OnPlayerInfo(self, pid)
	netplayer.C2GSGetPlayerInfo(pid)
end

function CSingleBiwuRankView.RefreshMyInfo(self)
	if not g_SingleBiwuCtrl.m_FinalRank then
		self.m_MyRankLbl:SetText("我的名次：榜单外")
	else
		self.m_MyRankLbl:SetText("我的名次："..g_SingleBiwuCtrl.m_FinalRank)
	end
	self.m_MyPointLbl:SetText("我的积分："..g_SingleBiwuCtrl.m_FinalPoint or 0)
	local sGroup = define.SingleBiwu.Group[g_SingleBiwuCtrl.m_MyGroup]
	self.m_MyGroupLbl:SetText("分组："..sGroup)
end

function CSingleBiwuRankView.ChangeGroup(self, iGroup)
	if self.m_CurGroup == iGroup then
		return
	end
	self.m_CurGroup = iGroup
	local oGroupTab = self.m_GroupGrid:GetChild(iGroup)
	oGroupTab:SetSelected(true)
	self:RefreshUI()
end

return CSingleBiwuRankView