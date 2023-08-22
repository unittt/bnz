local COrgMemberBox = class("COrgMemberBox", CBox)

function COrgMemberBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_SchoolSpr = self:NewUI(1, CSprite)
	self.m_NameLabel = self:NewUI(2, CLabel)
	self.m_GradeLabel = self:NewUI(3, CLabel)
	self.m_SchoolLabel = self:NewUI(4, CLabel)
	self.m_JobLabel = self:NewUI(5, CLabel)
	self.m_ContributionL = self:NewUI(6, CLabel)
	self.m_ActiveLabel = self:NewUI(7, CLabel)
	self.m_StatusLabel = self:NewUI(8, CLabel)
	self.m_MainBtn = self:NewUI(9, CButton)
	self.m_TouxianL = self:NewUI(10, CLabel)
	
	self.m_Member = nil
	
	self.m_NameColor = {
		friend = "a64e00",
		other = "244B4E"
	}

	self:InitContent()
end

function COrgMemberBox.InitContent(self)
	self.m_MainBtn:AddUIEvent("click", callback(self, "RequestPlayerInfo"))
end

function COrgMemberBox.SetCallback(self, cb)
	self.m_Callback = cb
end

function COrgMemberBox.SetMember(self, dMember)
	local pid = dMember.pid
	self.m_Member = dMember
	self.m_Pid = pid

	local tData =  data.schooldata.DATA[dMember.school]
	local sJobName = data.orgdata.POSITIONID[dMember.position].name
	if dMember.honor > 0 then
		if dMember.position == 6 then
			sJobName = string.format("%s", data.orgdata.HONORID[dMember.honor].name)
		else
			if dMember.position <= dMember.honor then
				sJobName = string.format("%s", sJobName)
			else
				sJobName = string.format("%s[%s]", sJobName, data.orgdata.HONORID[dMember.honor].name)
			end
		end
	end
	self.m_SchoolSpr:SpriteSchool(dMember.school)
	self.m_SchoolLabel:SetText(tData.name)
	self:RefreshNameColor()
	self.m_NameLabel:SetText(dMember.name)
	self.m_GradeLabel:SetText(tostring(dMember.grade))
	self.m_JobLabel:SetText(sJobName)
	self.m_ContributionL:SetText(dMember.hisoffer)
	self.m_ActiveLabel:SetText(dMember.weekhuoyue)
	if dMember.offline == 0 then
		self.m_StatusLabel:SetText("在线")
		self.m_SchoolSpr:SetGrey(false)
	else
		self.m_SchoolSpr:SetGrey(true)
		self.m_StatusLabel:SetText("离线")
		self.m_StatusLabel:SetText(self:GetOfflineDesc(dMember.offline))
	end
	if dMember.touxian and dMember.touxian ~= 0 then
		local dData = data.touxiandata.DATA[dMember.touxian]
		self.m_TouxianL:SetText(dData.name)
	else
		self.m_TouxianL:SetText("无")
	end
end

function COrgMemberBox.RefreshNameColor(self)
	local bIsFriend = g_FriendCtrl:IsMyFriend(self.m_Pid)
	local color = Color.RGBAToColor(bIsFriend and self.m_NameColor.friend or self.m_NameColor.other)
	self.m_NameLabel:SetColor(color)
end

function COrgMemberBox.RefreshBg(self, index)
	if self.m_Pid and self.m_Pid == g_AttrCtrl.pid then
		self.m_MainBtn:SetSpriteName("h7_di_5")
	elseif index % 2  == 1 then  -- 奇数
        self.m_MainBtn:SetSpriteName("h7_di_3")
    else    -- 偶数
        self.m_MainBtn:SetSpriteName("h7_di_4")
    end 
end

function COrgMemberBox.GetOfflineDesc(self, offline)
	local diffTime = math.floor(os.difftime(g_TimeCtrl:GetTimeS(), offline)/(60*60*24))
	local curDate = os.date("%Y/%m/%d", g_TimeCtrl:GetTimeS())
	local offlineDate = os.date("%Y/%m/%d", offline)
	if curDate == offlineDate then
		return "不久前"
	else
		local diffDate = math.min(diffTime, 7)
		diffDate = math.max(diffDate, 1)
		return string.format("%d天前", diffDate)
	end
end

function COrgMemberBox.DoCallback(self)
	if self.m_Callback then
		self.m_Callback()
	end
end

function COrgMemberBox.RequestPlayerInfo(self)
	if self.m_Member.pid == g_AttrCtrl.pid then
		g_NotifyCtrl:FloatMsg("这是你自己")
	end
	netplayer.C2GSGetPlayerInfo(self.m_Member.pid)
end
return COrgMemberBox