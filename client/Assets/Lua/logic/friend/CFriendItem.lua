local CFriendItem = class("CFriendItem", CBox)
	     
function CFriendItem.ctor(self, obj)
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
	-- self.m_ExpandBtn:AddUIEvent("click", callback(self, "OpenFriend"))
end

function CFriendItem.SetPlayer(self, pid)
	local frdobj = g_FriendCtrl:GetFriend(pid)
	self.m_ID = pid
	if frdobj then
		self:SetName(frdobj.name)
		self:SetHead(frdobj.icon)
		self:SetGrade(frdobj.grade)
		if frdobj.orgname and frdobj.orgname ~= "" then
			-- self.m_OrgLabel:SetColor(Color.white)
			-- self:SetOrg("[244b4e]帮派:[-][808080]"..frdobj.orgname.."[-]")
			self:SetOrg("帮派:"..frdobj.orgname)
		else
			-- self.m_OrgLabel:SetColor(Color.white)
			-- self.m_OrgLabel:SetColor(Color.RGBAToColor("244b4e"))
			self:SetOrg("帮派:暂无帮派")
		end

		self:SetSchool(frdobj.school)

		if g_AttrCtrl.engageInfo and pid == g_AttrCtrl.engageInfo.pid then
			self.m_RelationSprite:SetLocalPos(Vector3.New(105, -40, 0))
			self.m_RelationLbl:SetLocalPos(Vector3.New(105, -80, 0))
			local iState = g_AttrCtrl.engageInfo.status
			if iState == define.Engage.State.Engage then
				self.m_RelationSprite:SetSpriteName("h7_fuqi_2")
			else
				self.m_RelationSprite:SetSpriteName("h7_fuqi")
			end
			self.m_RelationSprite:MakePixelPerfect()
			self.m_RelationLbl:SetActive(true)
			self.m_RelationLbl:SetText(frdobj.friend_degree)
		else
			self.m_RelationSprite:SetLocalPos(Vector3.New(105, -45, 0))
			self.m_RelationLbl:SetLocalPos(Vector3.New(105, -75, 0))
			self:SetRelation(frdobj.friend_degree, frdobj.relation)
		end

	else
		self:SetName()
		self:SetHead()
		self:SetGrade()
		self:SetOrg()
		self:SetSchool()
		self:SetRelation()
	end
	self:SetOnlineState()
end

function CFriendItem.SetName(self, sName)
	if sName then
		self.m_NameLabel:SetText(sName)
	else
		self.m_NameLabel:SetText(string.format("玩家%d", self.m_ID))
	end
end

function CFriendItem.SetHead(self, iShape)
	if iShape then
		self.m_HeadSprite:SpriteAvatar(iShape)
	else
		self.m_HeadSprite:SpriteAvatar(1110)
	end
end

function CFriendItem.SetGrade(self, iGrade)
	if iGrade then
		self.m_GradeLabel:SetText(iGrade.."级")
	else
		self.m_GradeLabel:SetText("0级")
	end
end

function CFriendItem.SetOrg(self, sOrg)
	if sOrg then
		self.m_OrgLabel:SetText(sOrg)
	else
		self.m_OrgLabel:SetText("")
	end
end

function CFriendItem.SetSchool(self, iSchool)
	if iSchool then
		self.m_SchoolSprite:SetActive(true)
		self.m_SchoolSprite:SpriteSchool(iSchool)
	else
		self.m_SchoolSprite:SetActive(false)
	end
end

function CFriendItem.SetRelation(self, iDegree, relation)
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
	self.m_RelationSprite:MakePixelPerfect()
end

function CFriendItem.SetOnlineState(self)
	local state = g_FriendCtrl:GetOnlineState(self.m_ID)
	if state == 0 then
		self.m_HeadSprite:SetGrey(true)
	else
		self.m_HeadSprite:SetGrey(false)
	end
end

function CFriendItem.OpenFriend(self)
	netplayer.C2GSGetPlayerInfo(self.m_ID)
end

return CFriendItem