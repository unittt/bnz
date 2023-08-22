local CTeamApplyView = class("CTeamApplyView", CViewBase)

function CTeamApplyView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Team/TeamApplyView.prefab", cb)

	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function CTeamApplyView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_ApplyGrid = self:NewUI(2, CGrid)
	self.m_ApplyBox = self:NewUI(3, CTeamApplyBox)
	self.m_SchoolGrid = self:NewUI(4, CGrid)
	self.m_CurCntLabel = self:NewUI(5, CLabel)
	self.m_ClearBtn = self:NewUI(6, CButton)
	self.m_ScrollView = self:NewUI(7, CScrollView)
	self.m_CurIndex = 0
	self.m_ApplyList = {}
	self.m_ShowLimit = 20
	self:InitContent()
end

function CTeamApplyView.InitContent(self)
	self.m_SchoolGrid:InitChild(function(obj, idx)
			local oBox = CBox.New(obj)
			oBox.m_Sprite = oBox:NewUI(1, CSprite)
			oBox.m_Label = oBox:NewUI(2, CLabel)
			return oBox
		end)
	self.m_ApplyBox:SetActive(false)
	self.m_ClearBtn:SetActive(g_TeamCtrl:IsLeader())
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_ClearBtn:AddUIEvent("click", callback(self, "RequestClearAll"))
	g_TeamCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	g_TeamCtrl:ReadApply()
	self:RefreshApply()
	self:RefreshCurTeam()
end

function CTeamApplyView.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Team.Event.ClearApply then
		self:ClearAndCloseView()
	elseif oCtrl.m_EventID == define.Team.Event.AddApply then
		if self:IsExist(oCtrl.m_EventData.pid) then
			return
		end
		table.insert(self.m_ApplyList, oCtrl.m_EventData)
		self:UpdateApplyGrid()
	elseif oCtrl.m_EventID == define.Team.Event.DelApply then
		local index = self:GetApplyIndexById(oCtrl.m_EventData.pid)
		if index then
			if index <= self.m_CurIndex then
				self:DelApplyBox(oCtrl.m_EventData.pid)
				self.m_CurIndex = self.m_CurIndex - 1
			end
			table.remove(self.m_ApplyList, index)
			self:UpdateApplyGrid()
		end
	elseif oCtrl.m_EventID == define.Team.Event.AddTeam 
		or oCtrl.m_EventID == define.Team.Event.DelTeam then
		self:RefreshCurTeam()
	end
end

function CTeamApplyView.UpdateApplyGrid(self)
	if self.m_CurIndex >= self.m_ShowLimit then
		return
	end
	local dApply = self.m_ApplyList[self.m_CurIndex + 1]
	if dApply then
		self.m_CurIndex = self.m_CurIndex + 1
		self:AddApplyBox(dApply)
		self.m_ApplyGrid:Reposition()
	end
end

function CTeamApplyView.GetApplyIndexById(self, iPid)
	local index
	for i, dApply in ipairs(self.m_ApplyList) do
		if dApply.pid == iPid then
			index = i
		end
	end
	return index
end

function CTeamApplyView.RefreshApply(self)
	-- printc("refresh")
	self.m_ApplyGrid:Clear()
	local lApply = g_TeamCtrl:GetApplyList()
	self.m_ApplyList = lApply
	for i, dApply in ipairs(lApply) do
		self.m_CurIndex = i
		self:AddApplyBox(dApply)
		if i >= self.m_ShowLimit then
			break
		end
	end
end

function CTeamApplyView.AddApplyBox(self, dApply)
	local oBox = self.m_ApplyBox:Clone()
	oBox:SetActive(true)
	oBox:SetApply(dApply)
	oBox:SetName(tostring(self.m_ApplyGrid:GetCount()))
	self.m_ApplyGrid:AddChild(oBox)
end

function CTeamApplyView.DelApplyBox(self, pid)
	for i, oBox in ipairs(self.m_ApplyGrid:GetChildList()) do
		if oBox.m_Apply.pid == pid then
			self.m_ApplyGrid:RemoveChild(oBox)
			break
		end
	end
	local iCnt = self.m_ApplyGrid:GetCount()
	if iCnt == 0 then
		self:ClearAndCloseView()
	end
end

function CTeamApplyView.RefreshCurTeam(self)
	local iMaxCount = 5
	local tTargetInfo = g_TeamCtrl:GetTargetInfo()
	if tTargetInfo then
		local tAutoTeamData = data.teamdata.AUTO_TEAM[tTargetInfo.auto_target]
		iMaxCount = tAutoTeamData.max_count
	end
	
	local lMember = g_TeamCtrl:GetMemberList()
	for i, oBox in ipairs(self.m_SchoolGrid:GetChildList()) do
		local dMember = lMember[i]

		if dMember then
			oBox.m_Sprite:SpriteSchool(dMember.school)
		end
		oBox.m_Label:SetActive(dMember==nil)
		oBox.m_Sprite:SetActive(dMember~=nil)
	end
	self.m_CurCntLabel:SetText(string.format("%d/%d", #lMember, iMaxCount))
end

function CTeamApplyView.RequestClearAll(self)
	netteam.C2GSClearApply()
end

function CTeamApplyView.ClearAndCloseView(self)
	self.m_ApplyGrid:Clear()
	self.m_CurIndex = 0
	self.m_ApplyList = {}
	self:CloseView()
	-- g_NotifyCtrl:FloatMsg("暂时还没有人申请入队哦")
end

function CTeamApplyView.IsExist(self, iPid)
	for i,dApply in ipairs(self.m_ApplyList) do
		if dApply.pid == iPid then
			return true
		end
	end
	return false
end
return CTeamApplyView