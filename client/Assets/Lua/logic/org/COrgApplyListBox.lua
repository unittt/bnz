local COrgApplyListBox = class("COrgApplyListBox", CBox)

function COrgApplyListBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_ApplyGrid = self:NewUI(1, CGrid)
	self.m_ScrollView = self:NewUI(2, CScrollView)
	self.m_ApplyBoxClone = self:NewUI(3, COrgApplyBox)
	self.m_TipLabel = self:NewUI(4, CLabel)
	self.m_ClearAllBtn =self:NewUI(5, CButton)
	self.m_RefreshBtn = self:NewUI(6, CButton)
	self.m_TopContainer = self:NewUI(7, CWidget)
	self.m_ScrollViewContainer = self:NewUI(8, CWidget)
	self.m_BottomContainer = self:NewUI(9, CWidget)
	self.m_AcceptCheckBox = self:NewUI(10, CWidget)
	self.m_AcceptCheckBtn = self:NewUI(11, CWidget)

	self.m_ApplyList = nil
	self.m_ApplyBoxs = {}
	self:InitContent()
end

function COrgApplyListBox.InitContent(self)
	self:RefreshAutoAcceptBox(false)
	self.m_TipLabel:SetActive(false)
	-- self.m_ClearAllBtn:SetActive(false)
	self.m_ApplyBoxClone:SetActive(false)
	self.m_ClearAllBtn:AddUIEvent("click", callback(self, "RequestClearAll"))
	self.m_RefreshBtn:AddUIEvent("click", callback(self, "RequestRefresh"))
	self.m_AcceptCheckBtn:AddUIEvent("click", callback(self, "OnClickAutoAccept"))
	-- self:RefreshMemberGrid()
	g_OrgCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
end

function COrgApplyListBox.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Org.Event.GetApplyList then
		self.m_ApplyList = nil
		self:RefreshApplyGrid()
	elseif oCtrl.m_EventID == define.Org.Event.DelApply then
		-- 单个删除本地处理
		local delList = oCtrl.m_EventData
		table.print(delList)
		if #delList == 1 then
			-- 找出要删除的成员
			local memberid = delList[1]
			local oBox = self:GetMemberBox(memberid)
			if oBox then
				self:DelectApply(oBox)
			end
		end

		--只有执行全部同意才进行全局刷新
		if #delList > 1 or table.count(self.m_ApplyList) == 1 then
			self.m_ApplyList = nil
			self:RefreshApplyGrid()
		end
	elseif oCtrl.m_EventID == define.Org.Event.SetAutoAccept then
		self:RefreshAutoAcceptBox(oCtrl.m_EventData)
	end
end

function COrgApplyListBox.GetMemberBox(self, memberid)
	for k, oBox in pairs(self.m_ApplyBoxs) do
		if oBox.pid == memberid then
			return oBox
		end
	end
	return nil
end

function COrgApplyListBox.RefreshApplyGrid(self)
	self.m_ScrollView:ResetPosition()
	if not self.m_ApplyList then
		self.m_ApplyList = g_OrgCtrl:GetApplyList()
	end 
	for k,oBox in pairs(self.m_ApplyBoxs) do
		oBox:SetActive(false)
	end
	if self.m_LoadTimer then
		Utils.DelTimer(self.m_LoadTimer)
		self.m_LoadTimer = nil
	end
	local iApplyCnt = not self.m_ApplyList and 0 or #self.m_ApplyList
	local iIndex = 1 
	local iBgCount = 0

	local function load()
		if Utils.IsNil(self) or iIndex > iApplyCnt then
			self.m_ApplyGrid:Reposition()
			return
		end
		for i = 1, 10 do
			local dApplyInfo = self.m_ApplyList[iIndex]

			local oBox = self.m_ApplyBoxs[iIndex]
			if not oBox then
				oBox = self.m_ApplyBoxClone:Clone()
				self.m_ApplyBoxs[iIndex] = oBox
				oBox:SetCallback(callback(self, "DelectApply"))
				self.m_ApplyGrid:AddChild(oBox)
			end
			oBox.pid = dApplyInfo.pid
			oBox:SetActive(true)
			oBox:SetApplyInfo(dApplyInfo)
			iBgCount = iBgCount + 1
			oBox:RefreshBg(iBgCount)
			iIndex = iIndex + 1
			if iIndex > iApplyCnt then
				break
			end
		end
		self.m_ApplyGrid:Reposition()
		return true
	end
	self.m_LoadTimer = Utils.AddTimer(load, 1/30, 0)
	self:RefreshApplyStatus()
end

function COrgApplyListBox.RefreshApplyStatus(self)
	local bHasApply = table.count(self.m_ApplyList) > 0
	self.m_TipLabel:SetActive(not bHasApply)
	-- self.m_ClearAllBtn:SetActive(bHasApply)
	self.m_TopContainer:SetActive(bHasApply)
	self.m_ScrollViewContainer:SetActive(bHasApply)
	-- self.m_BottomContainer:SetActive(bHasApply)
end

function COrgApplyListBox.DelectApply(self, oBox)
	for k,dApplyInfo in pairs(self.m_ApplyList) do
		if dApplyInfo.pid == oBox.m_ApplyInfo.pid then		
			oBox:SetActive(false)
			self.m_ApplyList[k] = nil
		end
	end
	self.m_ApplyGrid:Reposition()
	self:RefreshApplyStatus()
end

function COrgApplyListBox.RefreshAutoAcceptBox(self, bIsAuto)
	self.m_AcceptCheckBox:SetActive(g_AttrCtrl.org_pos == 1)
	self.m_AcceptCheckBox:SetSelected(bIsAuto)
end

function COrgApplyListBox.RequestRefresh(self)
	if g_CountdownTimerCtrl:GetRecord(g_CountdownTimerCtrl.Type.OrgRefreshApply, 1) == nil then
		netorg.C2GSOrgApplyJoinList(1)
		local cd = 3
		g_CountdownTimerCtrl:AddRecord(g_CountdownTimerCtrl.Type.OrgRefreshApply, 1, cd)
		self.m_RequestExpireTime = g_TimeCtrl:GetTimeS() + cd
		g_NotifyCtrl:FloatMsg(data.orgdata.TEXT[1129].content)
	else
        local SS = self.m_RequestExpireTime - g_TimeCtrl:GetTimeS()
		g_NotifyCtrl:FloatMsg(string.gsub(data.orgdata.TEXT[1063].content, "#SS", SS))
	end
end

function COrgApplyListBox.RequestClearAll(self)
	if g_AttrCtrl.org_pos > 2 then
		g_NotifyCtrl:FloatMsg(data.orgdata.TEXT[1146].content)
		return
	end
	if table.count(self.m_ApplyList) == 0 then
		g_NotifyCtrl:FloatMsg(data.orgdata.TEXT[1152].content)
		return
	end
	netorg.C2GSClearApplyList()
end

function COrgApplyListBox.OnClickAutoAccept(self)
	local bIsAuto = self.m_AcceptCheckBox:GetSelected() and 0 or 1
	netorg.C2GSSetAutoJoin(bIsAuto)
end
return COrgApplyListBox