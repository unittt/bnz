local COrgApplyBox = class("COrgApplyBox", CBox)

function COrgApplyBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_SchoolSpr = self:NewUI(1, CSprite)
	self.m_NameLabel = self:NewUI(2, CLabel)
	self.m_GradeLabel = self:NewUI(3, CLabel)
	self.m_SchoolLabel = self:NewUI(4, CLabel)
	self.m_HonorL = self:NewUI(5, CLabel)
	self.m_RejectBtn = self:NewUI(6, CButton)
	self.m_AgreeBtn = self:NewUI(7, CButton)
	self.m_MainBtn = self:NewUI(8, CButton)

	self.m_ApplyInfo = nil
	self:InitContent()
end

function COrgApplyBox.InitContent(self)
	self:AddUIEvent("click", callback(self, "RequestPlayerInfo"))
	self.m_RejectBtn:AddUIEvent("click", callback(self, "RequestReject"))
	self.m_AgreeBtn:AddUIEvent("click", callback(self, "RequestAgree"))
end

function COrgApplyBox.SetCallback(self, cb)
	self.m_Callback = cb
end

function COrgApplyBox.SetApplyInfo(self, dApplyInfo)
	-- table.print(dApplyInfo)
	self.m_ApplyInfo = dApplyInfo
	local tData =  data.schooldata.DATA[dApplyInfo.school]

	self.m_SchoolSpr:SpriteSchool(dApplyInfo.school)
	self.m_SchoolLabel:SetText(tData.name)
	self.m_NameLabel:SetText(dApplyInfo.name)
	self.m_GradeLabel:SetText(tostring(dApplyInfo.grade))

	--TODO:待协议
	if dApplyInfo.touxian and dApplyInfo.touxian ~= 0 then
		local dData = data.touxiandata.DATA[dApplyInfo.touxian]
		self.m_HonorL:SetText(dData.name)
	else
		self.m_HonorL:SetText("无")
	end
end

function COrgApplyBox.RefreshBg(self, index)
	if index % 2  == 1 then  -- 奇数
        self.m_MainBtn:SetSpriteName("h7_di_3")
    else    -- 偶数
        self.m_MainBtn:SetSpriteName("h7_di_4")
    end 
end

function COrgApplyBox.DoCallback(self)
	if self.m_Callback then
		self.m_Callback(self)
	end
end

function COrgApplyBox.RequestReject(self)
	if not g_OrgCtrl:IsManager(g_AttrCtrl.pid) then
		g_NotifyCtrl:FloatMsg(data.orgdata.TEXT[1057].content)
		return
	end
	netorg.C2GSOrgDealApply(self.m_ApplyInfo.pid, 0)
	self:DoCallback()
end

function COrgApplyBox.RequestAgree(self)
	if not g_OrgCtrl:IsManager(g_AttrCtrl.pid) then
		g_NotifyCtrl:FloatMsg(data.orgdata.TEXT[1057].content)
		return
	end
	netorg.C2GSOrgDealApply(self.m_ApplyInfo.pid, 1)
end

function COrgApplyBox.RequestPlayerInfo(self)
	netplayer.C2GSGetPlayerInfo(self.m_ApplyInfo.pid)
end
return COrgApplyBox