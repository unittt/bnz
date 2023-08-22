local CRecentItem = class("CRecentItem", CBox)

function CRecentItem.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_NameLabel = self:NewUI(1, CLabel)
	self.m_HeadSprite = self:NewUI(2, CSprite)
	self.m_LastLabel = self:NewUI(3, CLabel)
	self.m_Button = self:NewUI(4, CButton, true, false)
	self.m_ExpandBtn = self:NewUI(5, CButton)
	self.m_MsgAmountBtn = self:NewUI(6, CButton)
	self.m_SchoolSprite = self:NewUI(7, CSprite)
	self.m_RelationSprite = self:NewUI(8, CSprite)
	self.m_GradeLabel = self:NewUI(9, CLabel)
	self.m_RelationLbl = self:NewUI(10,CLabel)

	self.m_ExpandBtn:AddUIEvent("click", callback(self, "OpenFriend"))
end

function CRecentItem.SetMsgAmount(self, iAmount)
	if iAmount >0 then
		self.m_MsgAmountBtn:SetActive(true)
		self.m_MsgAmountBtn:SetText(string.format("%d", iAmount))
	else
		self.m_MsgAmountBtn:SetActive(false)
	end
end

function CRecentItem.SetPlayer(self, pid)
	local frdobj = g_FriendCtrl:GetFriend(pid)
	self.m_ID = pid
	if frdobj then
		self:SetName(frdobj.name)
		self:SetHead(frdobj.icon)
		self:SetGrade(frdobj.grade)
		self:SetSchool(frdobj.school)
		if g_AttrCtrl.engageInfo and pid == g_AttrCtrl.engageInfo.pid then
			self.m_RelationSprite:SetLocalPos(Vector3.New(105, -40, 0))
			local iState = g_AttrCtrl.engageInfo.status
			if iState == define.Engage.State.Engage then
				self.m_RelationSprite:SetSpriteName("h7_fuqi_2")
			else
				self.m_RelationSprite:SetSpriteName("h7_fuqi")
			end
			self.m_RelationSprite:MakePixelPerfect()
		else
			self.m_RelationSprite:SetLocalPos(Vector3.New(105, -45, 0))
			self:SetRelation(frdobj.friend_degree, frdobj.relation)
		end
	else
		self:SetName()
		self:SetHead()
		self:SetGrade()
		self:SetSchool()
		self:SetRelation()
	end
	self:SetOnlineState()
	self:SetLastMsg()
end

function CRecentItem.SetLastMsg(self)
	g_TalkCtrl:InitMsg(self.m_ID)
	if g_TalkCtrl.m_MsgData[self.m_ID] and #g_TalkCtrl.m_MsgData[self.m_ID] == 0 then
		g_TalkCtrl:LoadMsgRecord(self.m_ID)
	end
	local msg = g_TalkCtrl:GetLastMsg(self.m_ID)
	if msg then
		msg = msg:GetText()
		msg = LinkTools.GetPrintedText(msg)

		local linkStr = {}
		for sLink in string.gmatch(msg, "#%d%d?") do --#%d+_%d%d
			table.insert(linkStr, sLink)
		end

		msg = string.gsub(msg, "#%d%d?", "赓赓")
		msg = string.gettitle(msg, 20, "...")

		local index = 1
		for sLink in string.gmatch(msg, "赓赓") do
			if linkStr[index] then
				msg = string.replace(msg, sLink, linkStr[index])
			end
			index = index + 1
		end
		msg = string.gsub(msg, "赓", "")

		self.m_LastLabel:SetRichText(msg)	
	else
		self.m_LastLabel:SetText("")
	end
end


function CRecentItem.SetName(self, sName)
	if sName then
		self.m_NameLabel:SetText(sName)
	else
		self.m_NameLabel:SetText(string.format("玩家%d", self.m_ID))
	end
end

function CRecentItem.SetHead(self, iShape)
	if iShape then
		self.m_HeadSprite:SpriteAvatar(iShape)
	else
		self.m_HeadSprite:SpriteAvatar(1110)
	end
end

function CRecentItem.SetGrade(self, iGrade)
	if iGrade then
		self.m_GradeLabel:SetText(iGrade.."级")
	else
		self.m_GradeLabel:SetText("0级")
	end
end     

function CRecentItem.SetSchool(self, iSchool)
	if iSchool then
		self.m_SchoolSprite:SetActive(true)
		self.m_SchoolSprite:SpriteSchool(iSchool)
	else
		self.m_SchoolSprite:SetActive(false)
	end
end

function CRecentItem.SetRelation(self, iDegree, relation)
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

function CRecentItem.SetOnlineState(self)
	local state = g_FriendCtrl:GetOnlineState(self.m_ID)
	if state == 0 then
		self.m_HeadSprite:SetGrey(true)
	else
		self.m_HeadSprite:SetGrey(false)
	end
end

function CRecentItem.OpenFriend(self)
	netplayer.C2GSGetPlayerInfo(self.m_ID)
end

return CRecentItem