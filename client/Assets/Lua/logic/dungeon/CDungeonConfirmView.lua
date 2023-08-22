local CDungeonConfirmView = class("CDungeonConfirmView", CViewBase)

function CDungeonConfirmView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Dungeon/DungeonConfirmView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	-- self.m_ExtendClose = "Black"
end

function CDungeonConfirmView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_TargetL = self:NewUI(2, CLabel)
	self.m_MemberGrid = self:NewUI(3, CGrid)
	self.m_TimeSlider = self:NewUI(4, CSlider)
	self.m_CountdownL = self:NewUI(5, CLabel)
	self.m_Agreebtn = self:NewUI(6, CButton)
	self.m_RejectBtn = self:NewUI(7, CButton) 
	self.m_TitleL = self:NewUI(8, CLabel)

	self.m_StatusConfig = {
		[0] = {color = "#W", text = "待确认"},
		[1] = {color = "#W", text = "已同意"},
		[2] = {color = "#W", text = "拒绝"},
	}

	self:InitContent()
end

function CDungeonConfirmView.InitContent(self)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_Agreebtn:AddUIEvent("click", callback(self, "OnClickAgree"))
	self.m_RejectBtn:AddUIEvent("click", callback(self, "OnClickReject"))
	local function initbox(obj, idx)
		local oBox = CBox.New(obj)
		oBox.m_SchoolSpr = oBox:NewUI(1, CSprite)
		oBox.m_AvatarSpr = oBox:NewUI(2, CSprite)
		oBox.m_GradeL = oBox:NewUI(3, CLabel)
		oBox.m_NameL = oBox:NewUI(4, CLabel)
		oBox.m_StatusL = oBox:NewUI(5, CLabel)
		oBox.m_StatusSpr = oBox:NewUI(6, CSprite)
		return oBox
	end
	self.m_MemberGrid:InitChild(initbox)

	g_DungeonCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnDungeonCtrlEvent"))
	g_WarCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnWarCtrlEvent"))
end

function CDungeonConfirmView.OnWarCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.War.Event.WarStart or oCtrl.m_EventID == define.War.Event.WarEnd then
		if g_WarCtrl:IsWar() then
			self:CloseView()
		end
	end
end

function CDungeonConfirmView.OnDungeonCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Dungeon.Event.RefreshComfirm then
		self:RefreshAll()
	elseif oCtrl.m_EventID == define.Dungeon.Event.RefreshPlayerComfirm then
		self:UpdateMemberBoxByPid(oCtrl.m_EventData)
	elseif oCtrl.m_EventID == define.Dungeon.Event.FinishComfirm then
		self:CloseView()
	end
end

function CDungeonConfirmView.RefreshAll(self)
	self:RefreshTitle()
	self:RefreshMemberGrid()
	self:RefreshCountdownSlider()
end

function CDungeonConfirmView.RefreshTitle(self)
	local iDungeonId = g_DungeonCtrl:GetDungeonId()
	local tData = DataTools.GetDungeonData(iDungeonId)
	if tData then
		self.m_TitleL:SetText(tData.name)
		self.m_TargetL:SetText(string.format("即将进入【%s】副本，确定要进入副本么？", tData.name))
	end
end

function CDungeonConfirmView.RefreshMemberGrid(self)
	local lMember = g_TeamCtrl:GetMemberList()
	for i,oBox in ipairs(self.m_MemberGrid:GetChildList()) do
		local dMember = lMember[i]
		local iStatus = dMember and g_DungeonCtrl:GetPlayerConfirmState(dMember.pid) or 0
		self:UpdateMemberBox(oBox, dMember, iStatus)
	end
end

function CDungeonConfirmView.UpdateMemberBox(self, oBox, dMember, iStatus)
	oBox:SetActive(dMember ~= nil and g_TeamCtrl:IsInTeam(dMember.pid))
	if not dMember or not g_TeamCtrl:IsInTeam(dMember.pid) then
		return
	end
	oBox.m_Pid = dMember.pid
	oBox.m_SchoolSpr:SpriteSchool(dMember.school)
	oBox.m_AvatarSpr:SpriteAvatar(dMember.icon)
	oBox.m_GradeL:SetText(dMember.grade.."级")
	oBox.m_NameL:SetText(dMember.name)
	if dMember.pid == g_AttrCtrl.pid then
		self:RefreshButtonStatus(iStatus)
		oBox.m_NameL:SetColor(Color.RGBAToColor("a64e00"))
	else
		oBox.m_NameL:SetColor(Color.RGBAToColor("244B4E"))
	end
	local dConfig = self.m_StatusConfig[iStatus]
	local sStatus = string.format("%s%s#n", dConfig.color, dConfig.text)
	oBox.m_StatusL:SetText(sStatus)
	if iStatus == 0 then
		oBox.m_StatusSpr:SetSpriteName("h7_daiqueren")
	elseif iStatus == 1 then
		oBox.m_StatusSpr:SetSpriteName("h7_yitongyi")
	end
end

function CDungeonConfirmView.UpdateMemberBoxByPid(self, iPid)
	for i,oBox in ipairs(self.m_MemberGrid:GetChildList()) do
		if oBox.m_Pid == iPid then
			local iStatus = g_DungeonCtrl:GetPlayerConfirmState(iPid)
			local dConfig = self.m_StatusConfig[iStatus]
			local sStatus = string.format("%s%s#n", dConfig.color, dConfig.text)
			oBox.m_StatusL:SetText(sStatus)
			if iPid == g_AttrCtrl.pid then
				self:RefreshButtonStatus(iStatus)
			end
		end
	end
end

function CDungeonConfirmView.RefreshCountdownL(self, iSecond)
	self.m_CountdownL:SetActive(iSecond > 0)
	-- self.m_CountdownL:SetText(iSecond.."秒")
	self.m_RejectBtn:SetText(iSecond > 0 and string.format("拒绝（%d）", iSecond) or "拒绝")
end

function CDungeonConfirmView.RefreshCountdownSlider(self)
	local iFinishTime = g_DungeonCtrl:GeConfirmFinishTime()
	if self.m_Timer then
		Utils.DelTimer(self.m_Timer)
		self.m_Timer = nil
	end
	local function update()
		if Utils.IsNil(self) then
			return false
		end
		local iDiffTime = os.difftime(iFinishTime, g_TimeCtrl:GetTimeS())
		local iRatio = iDiffTime/60
		self.m_TimeSlider:SetValue(iRatio)
		self:RefreshCountdownL(iDiffTime)
		return iDiffTime > 0
	end
	self.m_Timer = Utils.AddTimer(update, 1, 0)
end

function CDungeonConfirmView.RefreshButtonStatus(self, iStatus)
	self.m_Agreebtn:SetActive(iStatus == 0)
	self.m_RejectBtn:SetActive(iStatus == 0)
end

function CDungeonConfirmView.OnClickReject(self)
	local iSessionidx = g_DungeonCtrl:GetConfirmSession()
	if iSessionidx > 0 then
		netother.C2GSCallback(iSessionidx, 0)
	end
end

function CDungeonConfirmView.OnClickAgree(self)
	local iSessionidx = g_DungeonCtrl:GetConfirmSession()
	if iSessionidx > 0 then
		netother.C2GSCallback(iSessionidx, 1)
	end
end

return CDungeonConfirmView