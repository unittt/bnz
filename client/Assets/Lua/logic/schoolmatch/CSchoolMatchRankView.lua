local CSchoolMatchRankView = class("CSchoolMatchRankView", CViewBase)

function CSchoolMatchRankView.ctor(self, cb)
	CViewBase.ctor(self, "UI/SchoolMatch/SchoolMatchRankView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function CSchoolMatchRankView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_ScrollView = self:NewUI(2, CScrollView)
	self.m_RankGrid = self:NewUI(3, CGrid)
	self.m_RankBoxClone = self:NewUI(4, CBox)
	self.m_MySchoolBtn = self:NewUI(5, CButton)
	self.m_ChooseBox = self:NewUI(6, CChooseBox)
	self.m_RefreshBtn = self:NewUI(7, CButton)

	self.m_FiterSchool = 0
	self.m_RankBoxs = {}
	self:InitContent()
end

function CSchoolMatchRankView.InitContent(self)
	self:InitChooseBox()
	self.m_RankBoxClone:SetActive(false)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_MySchoolBtn:AddUIEvent("click", callback(self, "OnClickMySchool"))
	self.m_RefreshBtn:AddUIEvent("click", callback(self, "OnClickRefresh"))

	g_SchoolMatchCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	self:RefreshRankGrid()
end

function CSchoolMatchRankView.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.SchoolMatch.Event.RefreshRankList then
		self:RefreshRankGrid()
	end
end

function CSchoolMatchRankView.InitChooseBox(self)
	local tChooseData = {}
	for i,dSchool in ipairs(data.schooldata.DATA) do
		local dInfo = {icon = dSchool.icon, index = i, name = dSchool.name}
		table.insert(tChooseData, dInfo)
		if dSchool.id == g_AttrCtrl.school then
			self.m_ChooseIndex = i
		end
	end
	local dInfo = {icon = nil, index = #data.schooldata.DATA + 1, name = "全部门派"}
	table.insert(tChooseData, dInfo)
	self.m_ChooseBox:SetChooseData(tChooseData, dInfo.index)
	self.m_ChooseBox:SetCallback(function(index)
		self.m_FiterSchool = index
		nethuodong.C2GSLMLookInfo(index == #data.schooldata.DATA + 1 and 0 or self.m_FiterSchool)
		self:RefreshRankGrid()
	end)
end

function CSchoolMatchRankView.RefreshRankGrid(self)
	self.m_ScrollView:ResetPosition()
	for k,oBox in pairs(self.m_RankBoxs) do
		oBox:SetActive(false)
	end
	local lRankInfo = g_SchoolMatchCtrl:GetRankList()
	local iSchoolCount = #data.schooldata.DATA
	local iIndex = 1
	for i,dInfo in ipairs(lRankInfo) do
		local oBox = self.m_RankBoxs[i]
		if not oBox then
			oBox = self:CreateRankBox()
			self.m_RankBoxs[i] = oBox
			self.m_RankGrid:AddChild(oBox)
		end
		if self.m_FiterSchool > 0 and self.m_FiterSchool <= iSchoolCount then
			if self.m_FiterSchool ~= dInfo.school then
				oBox:SetActive(false)
			else
				self:UpdateRankBox(oBox, dInfo, iIndex)
				iIndex = iIndex + 1
			end
		else
			self:UpdateRankBox(oBox, dInfo, i)
		end
	end
	self.m_RankGrid:Reposition()
end

function CSchoolMatchRankView.CreateRankBox(self)
	local oBox = self.m_RankBoxClone:Clone()
	oBox.m_RankL = oBox:NewUI(1, CLabel)
	oBox.m_NameL = oBox:NewUI(2, CLabel)
	oBox.m_SchoolL = oBox:NewUI(3, CLabel)
	oBox.m_ScoreL = oBox:NewUI(4, CLabel)
	oBox.m_SchoolSpr = oBox:NewUI(5, CSprite)
	oBox.m_RankSpr = oBox:NewUI(6, CSprite)
	oBox.m_BgSpr = oBox:NewUI(7, CSprite)
	return oBox
end

function CSchoolMatchRankView.UpdateRankBox(self, oBox, dInfo, iIndex)
	local dData = data.schooldata.DATA[dInfo.school]

	oBox:SetActive(true)
	oBox.m_RankL:SetActive(iIndex > 3)
	oBox.m_RankSpr:SetActive(iIndex <= 3)
	oBox.m_RankSpr:SetSpriteName("h7_no"..iIndex)
	oBox.m_RankL:SetText(iIndex)
	oBox.m_NameL:SetText(dInfo.name)
	oBox.m_SchoolL:SetText(dData.name)
	oBox.m_SchoolSpr:SpriteSchool(dInfo.school)
	oBox.m_ScoreL:SetText(dInfo.point)
	if iIndex % 2  == 1 then  -- 奇数
        oBox.m_BgSpr:SetSpriteName("h7_di_3")
    else    -- 偶数
        oBox.m_BgSpr:SetSpriteName("h7_di_4")
    end 
end

function CSchoolMatchRankView.OnClickRefresh(self)
	nethuodong.C2GSLMLookInfo(self.m_FiterSchool > #data.schooldata.DATA and 0 or self.m_FiterSchool)
	g_NotifyCtrl:FloatMsg("刷新成功")
end

function CSchoolMatchRankView.OnClickMySchool(self)
	self.m_ChooseBox:JumpToTarget(self.m_ChooseIndex)
end

return CSchoolMatchRankView