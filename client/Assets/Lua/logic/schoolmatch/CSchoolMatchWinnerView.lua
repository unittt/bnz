local CSchoolMatchWinnerView = class("CSchoolMatchWinnerView", CViewBase)

function CSchoolMatchWinnerView.ctor(self, cb)
	CViewBase.ctor(self, "UI/SchoolMatch/SchoolMatchWinnerView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function CSchoolMatchWinnerView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_ScrollView = self:NewUI(2, CScrollView)
	self.m_WinnerGrid = self:NewUI(3, CGrid)
	self.m_WinnerBoxClone = self:NewUI(4, CBox)

	self:InitContent()
end

function CSchoolMatchWinnerView.InitContent(self)
	self.m_WinnerBoxClone:SetActive(false)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	g_MapCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnMapEvent"))
	self:RefreshWinnerGrid()
end

function CSchoolMatchWinnerView.OnMapEvent(self, oCtrl)
   if oCtrl.m_EventID == define.Map.Event.EnterScene then
   		if g_SchoolMatchCtrl.m_ActivityMap ~= oCtrl.m_MapID then
   			self:CloseView()
   		end
   end
end

function CSchoolMatchWinnerView.RefreshWinnerGrid(self)
	self.m_ScrollView:ResetPosition()
	if not g_SchoolMatchCtrl.m_WinnerList then
		return
	end
	for i,dInfo in ipairs(g_SchoolMatchCtrl.m_WinnerList) do
		local oBox = self:CreateWinnerBox()
		self.m_WinnerGrid:AddChild(oBox)
		self:UpdateWinnerBox(oBox, dInfo, i)
	end
	self.m_WinnerGrid:Reposition()
end

function CSchoolMatchWinnerView.CreateWinnerBox(self)
	local oBox = self.m_WinnerBoxClone:Clone()
	oBox.m_NameL = oBox:NewUI(1, CLabel)
	oBox.m_GradeL = oBox:NewUI(2, CLabel)
	oBox.m_SchoolL = oBox:NewUI(3, CLabel)
	oBox.m_SchoolSpr = oBox:NewUI(4, CSprite)
	oBox.m_ChampionSpr = oBox:NewUI(5, CSprite)
	return oBox
end

function CSchoolMatchWinnerView.UpdateWinnerBox(self, oBox, dInfo, iIndex)
	local dData = data.schooldata.DATA[dInfo.school]

	oBox:SetActive(true)
	oBox.m_NameL:SetText(dInfo.name)
	oBox.m_GradeL:SetText(dInfo.grade)
	oBox.m_SchoolL:SetText(dData.name)
	oBox.m_SchoolSpr:SpriteSchool(dInfo.school)
	-- oBox.m_ChampionSpr:SetActive(dInfo.first == 1)
end

return CSchoolMatchWinnerView