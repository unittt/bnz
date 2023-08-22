local CSingleBiwuPrepareView = class("CSingleBiwuPrepareView", CViewBase)

function CSingleBiwuPrepareView.ctor(self, cb)
	CViewBase.ctor(self, "UI/SingleBiwu/SingleBiwuPrepareView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Shelter"
end

function CSingleBiwuPrepareView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_CancelBtn = self:NewUI(2, CButton)
	self.m_CountdownLbl = self:NewUI(3, CLabel)
	self.m_PlayerBoxL = self:NewUI(4, CBox)
	self.m_PlayerBoxR = self:NewUI(5, CBox)
	self.m_DescLbl = self:NewUI(6, CLabel)

	self:InitContent()
end

function CSingleBiwuPrepareView.InitContent(self)
	self:InitPlayerBox(self.m_PlayerBoxL)
	self:InitPlayerBox(self.m_PlayerBoxR)

	self.m_CancelBtn:AddUIEvent("click", callback(self, "OnClickCancelBtn"))
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	g_SingleBiwuCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))

	local dPlayer = g_SingleBiwuCtrl:GetPrepareRandomTarget()
	self:RefreshPlayerBox(self.m_PlayerBoxR, dPlayer)
	self:RefreshMyInfo()
end

function CSingleBiwuPrepareView.InitPlayerBox(self, oPlayerBox)
	oPlayerBox.m_IconSpr = oPlayerBox:NewUI(1, CSprite)
	oPlayerBox.m_GradeLbl = oPlayerBox:NewUI(2, CLabel)
	oPlayerBox.m_NameLbl = oPlayerBox:NewUI(3, CLabel)
	oPlayerBox.m_ScoreLbl = oPlayerBox:NewUI(4, CLabel)
	oPlayerBox.m_SchoolSpr = oPlayerBox:NewUI(5, CSprite)
end

function CSingleBiwuPrepareView.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.SingleBiwu.Event.BiwuMatch then
		self:RefreshPlayerBox(self.m_PlayerBoxR, oCtrl.m_EventData)
	elseif oCtrl.m_EventID == define.SingleBiwu.Event.BiwuPrepareCount then
		self:CheckDesc()
	end
end

function CSingleBiwuPrepareView.RefreshUI(self)
	self:CheckDesc()
end

function CSingleBiwuPrepareView.CheckDesc(self)
	if g_SingleBiwuCtrl.m_BiwuPrepareCountTime > 0 then
		self.m_DescLbl:SetText("准备战斗")
		self.m_CountdownLbl:SetText("#mark_"..g_SingleBiwuCtrl.m_BiwuPrepareCountTime)
		self.m_CountdownLbl:SetActive(true)
		self.m_CancelBtn:SetActive(false)
	else
		self.m_DescLbl:SetText("匹配中...")
	end
end

function CSingleBiwuPrepareView.RefreshMyInfo(self)
	local dInfo = {
		icon = g_AttrCtrl.icon,
		grade = g_AttrCtrl.grade,
		name = g_AttrCtrl.name,
		score = g_AttrCtrl.score,
		school = g_AttrCtrl.school,
	}
	self:RefreshPlayerBox(self.m_PlayerBoxL, dInfo)
end

function CSingleBiwuPrepareView.RefreshPlayerBox(self, oPlayerBox, dInfo)
	if not dInfo then
		return
	end
	oPlayerBox.m_IconSpr:SpriteAvatar(dInfo.icon)
	oPlayerBox.m_GradeLbl:SetText(dInfo.grade.."级")
	oPlayerBox.m_NameLbl:SetText(dInfo.name)
	oPlayerBox.m_ScoreLbl:SetText(dInfo.score)
	oPlayerBox.m_SchoolSpr:SpriteSchool(dInfo.school)
end

-----------------以下是点击事件-----------------

function CSingleBiwuPrepareView.OnClickCancelBtn(self)
	nethuodong.C2GSSingleWarStopMatch()
	self:CloseView()
end

return CSingleBiwuPrepareView