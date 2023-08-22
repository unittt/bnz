local CTeamPartnerBox = class("CTeamPartnerBox", CBox)

function CTeamPartnerBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_ActorTexture = self:NewUI(1, CActorTexture)
	self.m_NameLabel = self:NewUI(2, CLabel)
	self.m_SchoolSpr = self:NewUI(3, CSprite)
	self.m_GradeLabel = self:NewUI(4, CLabel)
	self.m_InviteBtn = self:NewUI(5, CButton)
	self.m_EffectBoxs = {
		self:NewUI(6, CBox),
		self:NewUI(7, CBox)
	}
	self.m_SwitchBtn = self:NewUI(8, CSprite)

	self.m_Partner = nil
	self:InitContent()
end

function CTeamPartnerBox.InitContent(self)
	self:InitEffectBox()
	self.m_InviteBtn:AddUIEvent("click", callback(self, "OnInvite"))
	self.m_SwitchBtn:AddUIEvent("click", callback(self, "OnClickSwitchPos"))
	g_PartnerCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnPartnerCtrlEvent"))
end

function CTeamPartnerBox.OnPartnerCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Partner.Event.PropChange then
		local dInfo = oCtrl.m_EventData
		local iOffGrade = dInfo.offsetData["grade"]
		if self.m_Sid == dInfo.partnerid and iOffGrade and
			iOffGrade > 0 and self:GetActive() then
			self:RefreshGrade()
		end
	end
end

function CTeamPartnerBox.InitEffectBox(self)
	for i,oBox in ipairs(self.m_EffectBoxs) do
		oBox.m_EffectL = oBox:NewUI(1, CLabel)
		oBox.m_ArrowSpr = oBox:NewUI(2, CSprite)
	end
end

function CTeamPartnerBox.SetFormationEffect(self, tEffectInfo)
	self.m_EffectBoxs[1]:SetActive(false)
	self.m_EffectBoxs[2]:SetActive(false)

	if not tEffectInfo then 
		return
	end
	for i,dInfo in ipairs(tEffectInfo) do
		local oBox = self.m_EffectBoxs[i]
		oBox:SetActive(true)
		oBox.m_EffectL:SetText(dInfo.name)
		if dInfo.value >= 0 then
			oBox.m_ArrowSpr:SetSpriteName("h7_sheng")
		else
			oBox.m_ArrowSpr:SetSpriteName("h7_jiang")
		end
	end
end

function CTeamPartnerBox.SetPartner(self, dPartner, iDelay)
	local id = dPartner.id
	self.m_Pid = id
	self.m_Sid = dPartner.sid
	self.m_Partner = dPartner
	local dInfo = data.partnerdata.INFO[dPartner.sid]
	self.m_NameLabel:SetText(dInfo.name)
	self:RefreshGrade(dPartner.grade)
	self.m_SchoolSpr:SpriteSchool(dInfo.school)
	if self.m_LoadTimer then
		Utils.DelTimer(self.m_LoadTimer)
		self.m_LoadTimer = nil
	end
	local function loadShape()
		if not Utils.IsNil(self) then
			local model_info = {}
			 model_info.shape = dPartner.model_info.shape
			self.m_ActorTexture:ChangeShape(model_info)
		end
	end
	self.m_LoadTimer = Utils.AddTimer(loadShape, 0, iDelay)
end

function CTeamPartnerBox.RefreshGrade(self)
	local iGrade = self.m_Partner.grade
	if not g_TeamCtrl:IsJoinTeam() or g_TeamCtrl:IsLeader() then
		local dPartner = g_PartnerCtrl:GetRecruitPartnerDataBySID(self.m_Pid)
		iGrade = dPartner.grade
	end
	self.m_GradeLabel:SetText("等级:"..iGrade)
end

function CTeamPartnerBox.OnInvite(self)
	CTeamFriendInviteView:ShowView()
end

function CTeamPartnerBox.ShowSwitchPanel(self)
	self.m_SwitchBtn:SetActive(false)
	if (g_TeamCtrl:IsJoinTeam() and not g_TeamCtrl:IsLeader()) or 
		g_TeamCtrl.m_SelectedPid == self.m_Pid then
		return false
	end
	self.m_SwitchBtn:SetActive(true)
	return true
end

function CTeamPartnerBox.HideSwitchPanel(self)
	self.m_SwitchBtn:SetActive(false)
end

function CTeamPartnerBox.OnClickSwitchPos(self)
	local iLineup = g_PartnerCtrl:GetCurLineup()
	local iFmtId = -1
	local tPartnerPosList = {}
	local iSelectedPid = g_TeamCtrl.m_SelectedPid

	if not g_TeamCtrl:IsJoinTeam() then
		iFmtId = g_FormationCtrl:GetCurrentFmt()
		tPartnerPosList = g_FormationCtrl:GetCurrentPartnerList()
	else
		iFmtId = g_TeamCtrl:GetFormationInfo().fmt_id
		tPartnerPosList = g_TeamCtrl.m_PartnerPosList
	end

	if g_WarCtrl:IsWar() then
		if not g_TeamCtrl.m_OriginalPos["partner"] then
			g_TeamCtrl.m_OriginalPos["partner"] = table.copy(tPartnerPosList)
		end
	end

	for i,pid in ipairs(tPartnerPosList) do
		if pid == iSelectedPid then
			tPartnerPosList[i] = self.m_Pid
		elseif pid == self.m_Pid then
			tPartnerPosList[i] = iSelectedPid
		end
	end
	netpartner.C2GSSetPartnerPosInfo(iLineup, iFmtId, tPartnerPosList)

	if g_WarCtrl:IsWar() then
		g_TeamCtrl.m_IsPartnerChanged = false
		for i,pid in ipairs(g_TeamCtrl.m_OriginalPos["partner"]) do
			if pid ~= tPartnerPosList[i] then
				g_TeamCtrl.m_IsPartnerChanged = true
				break
			end
		end
	end
end

return CTeamPartnerBox