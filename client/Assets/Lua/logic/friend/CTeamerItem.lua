local CTeamerItem = class("CTeamerItem", CBox)

function CTeamerItem.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_NameLabel = self:NewUI(1, CLabel)
	self.m_HeadSprite = self:NewUI(2, CSprite)
	self.m_OrgLabel = self:NewUI(3, CLabel)
	self.m_Button = self:NewUI(4, CButton, true, false)
	self.m_ExpandBtn = self:NewUI(5, CButton)
	self.m_GradeLabel = self:NewUI(6, CLabel)
	self.m_SchoolSprite = self:NewUI(7, CSprite)
	self.m_RelationSprite = self:NewUI(8, CSprite)
	self.m_RelationLbl = self:NewUI(9,CLabel)
	
	self.m_ExpandBtn:AddUIEvent("click", callback(self, "OpenFriend"))
end

function CTeamerItem.SetPlayer(self, pid)
	local frdobj = g_FriendCtrl:GetFriend(pid)
	self.m_ID = pid
	if frdobj then
		self:SetName(frdobj.name)
		self:SetHead(frdobj.icon)
		self:SetGrade(frdobj.grade)
		self:SetSchool(frdobj.school)
		if frdobj.orgname and frdobj.orgname ~= "" then
			-- self.m_OrgLabel:SetColor(Color.white)
			-- self:SetOrg("[244b4e]帮派:[-][808080]"..frdobj.orgname.."[-]")
			self:SetOrg("帮派:"..frdobj.orgname)
		else
			-- self.m_OrgLabel:SetColor(Color.white)
			-- self.m_OrgLabel:SetColor(Color.RGBAToColor("244b4e"))
			self:SetOrg("帮派:暂无帮派")
		end
		self:SetRelation(frdobj.friend_degree, frdobj.relation)
	else
		self:SetName()
		self:SetHead()
		self:SetGrade()
		self:SetSchool()
		self:SetRelation()
		self:SetOrg()
	end
	
	self.m_Button:AddUIEvent("click", callback(self, "ShowTalk", pid))
end

function CTeamerItem.SetName(self, sName)
	if sName then
		self.m_NameLabel:SetText(sName)
	else
		self.m_NameLabel:SetText(string.format("玩家%d", self.m_ID))
	end
end

function CTeamerItem.SetHead(self, iShape)
	if iShape then
		self.m_HeadSprite:SpriteAvatar(iShape)
	else
		self.m_HeadSprite:SpriteAvatar(1110)
	end
end

function CTeamerItem.SetGrade(self, iGrade)
	if iGrade then
		self.m_GradeLabel:SetText(iGrade)
	else
		self.m_GradeLabel:SetText(0)
	end
end

function CTeamerItem.SetSchool(self, iSchool)
	if iSchool then
		self.m_SchoolSprite:SetActive(true)
		self.m_SchoolSprite:SpriteSchool(iSchool)
	else
		self.m_SchoolSprite:SetActive(false)
	end
end

function CTeamerItem.SetOrg(self, sOrg)
	if sOrg then
		self.m_OrgLabel:SetText(sOrg)
	else
		self.m_OrgLabel:SetText("")
	end
end

function CTeamerItem.SetRelation(self, iDegree, relation)
	local name = nil
	if not g_FriendCtrl:IsMyFriend(self.m_ID) then
		iDegree = nil
	end
	if iDegree then
		name = g_FriendCtrl:GetRelationIcon(iDegree, relation)
	end
	if name then
		self.m_RelationSprite:SetActive(true)
		self.m_RelationSprite:SetSpriteName(name)
		self.m_RelationLbl:SetActive(true)
		self.m_RelationLbl:SetText(iDegree)
	else
		self.m_RelationSprite:SetActive(false)
		self.m_RelationLbl:SetActive(false)
	end
end

function CTeamerItem.ShowTalk(self)
	if self.m_ID then
		if g_FriendCtrl:IsBlackFriend(self.m_ID) then
			-- netfriend.C2GSFriendUnshield(self.m_ID)
			local name = ""
			local frdobj = g_FriendCtrl:GetFriend(self.m_ID)
			if frdobj then
				name = frdobj.name
			end
			g_FriendCtrl:ApplyDelBlackFriend(self.m_ID, name)
		else
			CFriendInfoView:ShowView(function (oView)
				oView:ShowTalk(self.m_ID)
			end)
			CChatMainView:CloseView()
		end
	end
end

function CTeamerItem.AddFriend(self)
	if self.m_ID then
		netfriend.C2GSApplyAddFriend(self.m_ID)
	end
end

function CTeamerItem.OpenFriend(self)
	netplayer.C2GSGetPlayerInfo(self.m_ID)
end

return CTeamerItem