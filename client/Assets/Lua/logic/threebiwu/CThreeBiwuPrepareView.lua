local CThreeBiwuPrepareView = class("CThreeBiwuPrepareView", CViewBase)

function CThreeBiwuPrepareView.ctor(self, cb)
	CViewBase.ctor(self, "UI/ThreeBiwu/ThreeBiwuPrepareView.prefab", cb)
	--界面设置
	self.m_DepthType = "Fourth"
	-- self.m_GroupName = "main"
	self.m_ExtendClose = "Shelter"
end

function CThreeBiwuPrepareView.OnCreateView(self)
	self.m_LeftGrid = self:NewUI(1, CGrid)
	self.m_BoxClone = self:NewUI(2, CBox)
	self.m_RightGrid = self:NewUI(3, CGrid)
	self.m_CancelBtn = self:NewUI(4, CButton)
	self.m_CountTimeLbl = self:NewUI(5, CLabel)
	self.m_DescLbl = self:NewUI(6, CLabel)
	self.m_CloseBtn = self:NewUI(7, CButton)
	self.m_LevelLbl1 = self:NewUI(8, CLabel)
	self.m_LevelLbl2 = self:NewUI(9, CLabel)
	self.m_BoxClone2 = self:NewUI(10, CBox)
	
	self:InitContent()
end

function CThreeBiwuPrepareView.InitContent(self)
	self.m_BoxClone:SetActive(false)
	self.m_BoxClone2:SetActive(false)
	self.m_CancelBtn:AddUIEvent("click", callback(self, "OnClickCancelBtn"))
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	g_ThreeBiwuCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlThreeBiwuEvent"))
end

function CThreeBiwuPrepareView.OnCtrlThreeBiwuEvent(self, oCtrl)
	if oCtrl.m_EventID == define.ThreeBiwu.Event.BiwuMatch then
		self:CheckOther()
	elseif oCtrl.m_EventID == define.ThreeBiwu.Event.BiwuRandomPrepare then
		self:SetOtherTeamList(g_ThreeBiwuCtrl.m_RandomTeamList)
	elseif oCtrl.m_EventID == define.ThreeBiwu.Event.BiwuPrepareCount then
		self:CheckDesc()
	end
end

function CThreeBiwuPrepareView.RefreshUI(self)
	self.m_RightGrid:Clear()
	self:SetMyTeamList()
	self:CheckOther()
	self:CheckDesc()
end

function CThreeBiwuPrepareView.CheckDesc(self)
	if g_ThreeBiwuCtrl.m_BiwuPrepareCountTime > 0 then
		self.m_DescLbl:SetText("准备战斗"..g_ThreeBiwuCtrl.m_BiwuPrepareCountTime)
	else
		self.m_DescLbl:SetText("匹配中...")
	end
end

function CThreeBiwuPrepareView.CheckOther(self)
	self:SetOtherTeamList()
	--暂时屏蔽
	-- if next(g_ThreeBiwuCtrl.m_OtherTeamList) then
	-- 	self.m_CancelBtn:SetActive(false)
	-- 	self.m_DescLbl:SetActive(false)
	-- else
	-- 	self.m_CancelBtn:SetActive(true)
	-- 	self.m_DescLbl:SetActive(true)
	-- end
end

--己方玩家列表
function CThreeBiwuPrepareView.SetMyTeamList(self)
	local oList = g_ThreeBiwuCtrl:GetMyTeamList()
	local optionCount = #oList
	local GridList = self.m_LeftGrid:GetChildList() or {}
	local oPlayerBox
	if optionCount > 0 then
		for i=1,optionCount do
			if i > #GridList then
				oPlayerBox = self.m_BoxClone:Clone(false)
				-- self.m_LeftGrid:AddChild(oOptionBtn)
			else
				oPlayerBox = GridList[i]
			end
			self:SetLeftBox(oPlayerBox, oList[i])
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

	self.m_LeftGrid:Reposition()

	local oLevel = 0
	for k,v in pairs(oList) do
		oLevel = oLevel + v.grade
	end
	self.m_LevelLbl1:SetText("平均等级："..math.floor(oLevel/optionCount))
end

function CThreeBiwuPrepareView.SetLeftBox(self, oPlayerBox, oData)
	oPlayerBox:SetActive(true)
	oPlayerBox.m_IconSp = oPlayerBox:NewUI(1, CSprite)
	oPlayerBox.m_LevelLbl = oPlayerBox:NewUI(2, CLabel)
	oPlayerBox.m_NameLbl = oPlayerBox:NewUI(3, CLabel)
	oPlayerBox.m_MarkLbl = oPlayerBox:NewUI(4, CLabel)
	oPlayerBox.m_SchoolSp = oPlayerBox:NewUI(5, CSprite)

	oPlayerBox.m_IconSp:SpriteAvatar(oData.icon)
	oPlayerBox.m_LevelLbl:SetText(oData.grade.."级")
	oPlayerBox.m_NameLbl:SetText(oData.name)
	oPlayerBox.m_SchoolSp:SpriteSchool(oData.school)

	oPlayerBox.m_MarkLbl:SetText(oData.score or 0)

	self.m_LeftGrid:AddChild(oPlayerBox)
	self.m_LeftGrid:Reposition()
end

--其他玩家列表
function CThreeBiwuPrepareView.SetOtherTeamList(self, oRandomList)
	local oList = oRandomList or g_ThreeBiwuCtrl.m_OtherTeamList
	local optionCount = #oList
	local GridList = self.m_RightGrid:GetChildList() or {}
	local oPlayerBox
	if optionCount > 0 then
		for i=1,optionCount do
			if i > #GridList then
				oPlayerBox = self.m_BoxClone2:Clone(false)
				-- self.m_RightGrid:AddChild(oOptionBtn)
			else
				oPlayerBox = GridList[i]
			end
			self:SetRightBox(oPlayerBox, oList[i])
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

	self.m_RightGrid:Reposition()

	if optionCount > 0 then
		local oLevel = 0
		for k,v in pairs(g_ThreeBiwuCtrl.m_OtherTeamList) do
			oLevel = oLevel + v.grade
		end
		self.m_LevelLbl2:SetText("平均等级："..math.floor(oLevel/optionCount))
	else
		self.m_LevelLbl2:SetText("")
	end
end

function CThreeBiwuPrepareView.SetRightBox(self, oPlayerBox, oData)
	oPlayerBox:SetActive(true)
	oPlayerBox.m_IconSp = oPlayerBox:NewUI(1, CSprite)
	oPlayerBox.m_LevelLbl = oPlayerBox:NewUI(2, CLabel)
	oPlayerBox.m_NameLbl = oPlayerBox:NewUI(3, CLabel)
	oPlayerBox.m_MarkLbl = oPlayerBox:NewUI(4, CLabel)
	oPlayerBox.m_SchoolSp = oPlayerBox:NewUI(5, CSprite)

	oPlayerBox.m_IconSp:SpriteAvatar(oData.icon)
	oPlayerBox.m_LevelLbl:SetText(oData.grade.."级")
	oPlayerBox.m_NameLbl:SetText(oData.name)
	oPlayerBox.m_SchoolSp:SpriteSchool(oData.school)

	oPlayerBox.m_MarkLbl:SetText(oData.score or 0)

	self.m_RightGrid:AddChild(oPlayerBox)
	self.m_RightGrid:Reposition()
end

-----------------以下是点击事件-----------------

function CThreeBiwuPrepareView.OnClickCancelBtn(self)
	nethuodong.C2GSThreeSetMatch(0)
	self:CloseView()
end

return CThreeBiwuPrepareView