local CBlackFrdItem = class("CBlackFrdItem", CBox)

function CBlackFrdItem.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_NameLabel = self:NewUI(1, CLabel)
	self.m_HeadSprite = self:NewUI(2, CSprite)
	self.m_OrgLabel = self:NewUI(3, CLabel)
	self.m_Button = self:NewUI(4, CButton, true, false)
	self.m_DelBtn = self:NewUI(5, CButton)
	self.m_SchoolSprite = self:NewUI(6, CSprite)
	self.m_GradeLabel = self:NewUI(7, CLabel)

	self.m_DelBtn:AddUIEvent("click", callback(self, "DelBalckFriend"))
end

function CBlackFrdItem.SetPlayer(self, pid)
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
	else
		self:SetName()
		self:SetHead()
		self:SetGrade()
		self:SetSchool()
		self:SetOrg()
	end
end

function CBlackFrdItem.SetName(self, sName)
	if sName then
		self.m_NameLabel:SetText(sName)
	else
		self.m_NameLabel:SetText(string.format("玩家%d", self.m_ID))
	end
end

function CBlackFrdItem.SetHead(self, iShape)
	if iShape then
		self.m_HeadSprite:SpriteAvatar(iShape)
	else
		self.m_HeadSprite:SpriteAvatar(1110)
	end
end

function CBlackFrdItem.SetGrade(self, iGrade)
	if iGrade then
		self.m_GradeLabel:SetText(iGrade)
	else
		self.m_GradeLabel:SetText(0)
	end
end

function CBlackFrdItem.SetSchool(self, iSchool)
	if iSchool then
		self.m_SchoolSprite:SetActive(true)
		self.m_SchoolSprite:SpriteSchool(iSchool)
	else
		self.m_SchoolSprite:SetActive(false)
	end
end

function CBlackFrdItem.SetOrg(self, sName)
	if sName then
		self.m_OrgLabel:SetText(sName)
	else
		self.m_OrgLabel:SetText("")
	end
end

function CBlackFrdItem.DelBalckFriend(self)
	-- netfriend.C2GSFriendUnshield(self.m_ID)
	local name = ""
	local frdobj = g_FriendCtrl:GetFriend(self.m_ID)
	if frdobj then
		name = frdobj.name
	end
	g_FriendCtrl:ApplyDelBlackFriend(self.m_ID, name)
end

return CBlackFrdItem