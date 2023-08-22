local CTeamApplyBox = class("CTeamApplyBox", CBox)

function CTeamApplyBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_ActorTexture = self:NewUI(1, CActorTexture)
	self.m_NameLabel = self:NewUI(2, CLabel)
	self.m_SchoolSpr = self:NewUI(3, CSprite)
	self.m_GradeLabel = self:NewUI(4, CLabel)
	self.m_AgreeBtn = self:NewUI(5, CButton)
	self.m_RelationLabel = self:NewUI(6, CLabel)
	self.m_Apply = nil

	self.m_AgreeBtn:SetActive(g_TeamCtrl:IsLeader())
	self.m_AgreeBtn:AddUIEvent("click", callback(self, "OnAgree"))

	self:AddUIEvent("click", callback(self, "ShowPlayerTip"))
end

function CTeamApplyBox.SetApply(self, dApply)
	self.m_Apply = dApply
	local dModelInfo = table.copy(dApply.model_info)
	dModelInfo.horse = nil
	self.m_ActorTexture:ChangeShape(dModelInfo)
	self.m_NameLabel:SetText(dApply.name)
	self.m_GradeLabel:SetText("等级:"..tostring(dApply.grade))
	self.m_SchoolSpr:SpriteSchool(dApply.school)
	self:RefreshRelationLabel()
end

function CTeamApplyBox.RefreshRelationLabel(self)
	--TODO:帮派id需修改服务器协议
	self.m_RelationLabel:SetActive(true)
	if g_FriendCtrl:IsMyFriend(self.m_Apply.pid) then
		self.m_RelationLabel:SetText("[c]#D好友#n")
	elseif g_AttrCtrl.org_id ~= 0 and g_AttrCtrl.org_id == self.m_Apply.orgid then
		self.m_RelationLabel:SetText("[c]#P同帮#n")
	else
		self.m_RelationLabel:SetActive(false)
	end
end

function CTeamApplyBox.OnAgree(self)
	netteam.C2GSApplyTeamPass(self.m_Apply.pid)
end

function CTeamApplyBox.ShowPlayerTip(self)
	netplayer.C2GSGetPlayerInfo(self.m_Apply.pid)
end

return CTeamApplyBox