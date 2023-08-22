local COrgMemberListBox = class("COrgMemberListBox", CBox)

function COrgMemberListBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_MemberGrid = self:NewUI(1, CGrid)
	self.m_MemberBoxClone = self:NewUI(2, COrgMemberBox)
	self.m_QuitBtn = self:NewUI(3, CButton)
	self.m_TipBtn =self:NewUI(4, CButton)
	self.m_SearchInput = self:NewUI(5, CInput)
	self.m_SearchBtn = self:NewUI(6, CButton)
	self.m_ClearBtn = self:NewUI(7, CButton)

	self.m_TitleBtns = {}
	for i=8,15 do	 --不是很安全的做法，把所有title保存起来，不能轻易修改预设的下标顺序,8是姓名，暂时没有
		self.m_TitleBtns[i - 7] = self:NewUI(i, CLabel)
	end
	self.m_ScrollView = self:NewUI(16, CScrollView)

	self.m_MemberList = nil
	self.m_MemberBoxs = {}
	self.m_SearchName = ""
	self.m_IsDisband = false
	self.m_IsInitSort = true
	self.m_LoadTimer = nil

	self.m_SortMode = {positive = 1, negative = 2, default = 3}
	self.m_SortConfig = {	
		[0] = {key = "", mode = self.m_SortMode.default, curMode = 0, clickCount = 1},
		[1] = {key = "name", mode = self.m_SortMode.positive, curMode = 0, clickCount = 1},
		[2] = {key = "grade", mode = self.m_SortMode.negative, curMode = 0, clickCount = 1},
		[3] = {key = "school", mode = self.m_SortMode.negative, curMode = 0, clickCount = 1},
		[4] = {key = "position", mode = self.m_SortMode.positive, curMode = 0, clickCount = 1},
		[5] = {key = "hisoffer", mode = self.m_SortMode.negative, curMode = 0, clickCount = 1},
		[6] = {key = "weekhuoyue", mode = self.m_SortMode.negative, curMode = 0, clickCount = 1},
		[7] = {key = "difftime", mode = self.m_SortMode.positive, curMode = 0, clickCount = 1},
		[8] = {key = "touxian", mode = self.m_SortMode.negative, curMode = 0, clickCount = 1},
	}

	self:InitContent()
end

function COrgMemberListBox.InitContent(self)
	self.m_MemberBoxClone:SetActive(false)
	self.m_ClearBtn:SetActive(false)
	self.m_QuitBtn:AddUIEvent("click", callback(self, "RequestQuitOrg"))
	self.m_SearchBtn:AddUIEvent("click", callback(self, "OnSearchMember"))
	self.m_ClearBtn:AddUIEvent("click", callback(self, "OnClearInput"))
	self.m_TipBtn:AddUIEvent("click", callback(self, "OnQuitOrgTipBtn"))
	for index,btn in pairs(self.m_TitleBtns) do
		btn:AddUIEvent("click", callback(self, "ChangeSort", index))
	end
	-- self:RefreshMemberGrid()
	g_OrgCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	g_FriendCtrl:AddCtrlEvent(self:GetInstanceID(),callback(self, "OnFriendCtrlEvent"))
	self:ResetSortConfig()
end

function COrgMemberListBox.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Org.Event.GetMemeberList then
		self.m_MemberList = g_OrgCtrl:GetMemeberList()
		self.m_IsInitSort = true
		self:ChangeSort(0)
	elseif oCtrl.m_EventID == define.Org.Event.DelMember then
		local iPid = oCtrl.m_EventData
		self:DelMember(iPid)
	elseif oCtrl.m_EventID == define.Org.Event.ChangePosition then
		local tData = oCtrl.m_EventData
		self:UpdateMemberPosition(tData.pid, tData.pos)
	end
	self:RefreshQuitButton()
end

function COrgMemberListBox.OnFriendCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Friend.Event.Add or oCtrl.m_EventID == define.Friend.Event.Del then
		local lPidList = oCtrl.m_EventData
		local dFriendPid = {}
		for _, iPid in ipairs(lPidList) do
			dFriendPid[iPid] = true
		end

		for i,oBox in ipairs(self.m_MemberBoxs) do
			if oBox:GetActive() and oBox.m_Pid and dFriendPid[oBox.m_Pid] then
				oBox:RefreshNameColor()
			end
		end
	end
end

function COrgMemberListBox.RefreshQuitButton(self)
	if not self.m_MemberList then
		return
	end
	local iCOunt = table.count(self.m_MemberList) 
	self.m_IsDisband = iCOunt == 1
	if self.m_IsDisband then
		self.m_QuitBtn:SetText("解散帮派")
	else
		self.m_QuitBtn:SetText("脱离帮派")
	end
end

function COrgMemberListBox.RefreshMemberGrid(self, bIsResetPos)
	if bIsResetPos then
		self.m_ScrollView:ResetPosition()
	end
	if not self.m_MemberList then
		self.m_MemberList = g_OrgCtrl:GetMemeberList()
	end 

	if self.m_LoadTimer then
		Utils.DelTimer(self.m_LoadTimer)
		self.m_LoadTimer = nil
	end
	local iMemberCnt = #self.m_MemberList
	local iIndex = 1 
	local iBgCount = 0
	local dActive = {}
	local function load()
		if Utils.IsNil(self) then
			return
		end
		for i = 1, 10 do
			local dMember = self.m_MemberList[iIndex]
			local oBox = self.m_MemberBoxs[iIndex]
			if not oBox then
				oBox = self.m_MemberBoxClone:Clone()
				self.m_MemberBoxs[iIndex] = oBox
				self.m_MemberGrid:AddChild(oBox)
			end
			if self.m_SearchName ~= "" then
				if string.find(dMember.name, self.m_SearchName) then
					iBgCount = iBgCount + 1
					oBox:SetActive(true)
					dActive[iIndex] = true
				end
			else
				iBgCount = iBgCount + 1
				oBox:SetActive(true)
				dActive[iIndex] = true
			end
			oBox:SetMember(dMember)
			oBox:RefreshBg(iBgCount)
			iIndex = iIndex + 1
			if iIndex > iMemberCnt then
				for i,oBox in ipairs(self.m_MemberBoxs) do
					if not dActive[i] then
						oBox:SetActive(false)
					end
				end
				self.m_MemberGrid:Reposition()
				return false
			end
		end
		self.m_MemberGrid:Reposition()
		return true
	end
	self.m_LoadTimer = Utils.AddTimer(load, 1/30, 0)
end

function COrgMemberListBox.OnQuitOrgTipBtn(self)
	local id = define.Instruction.Config.QuitOrg
    local content = {
        title = data.instructiondata.DESC[id].title,
        desc  = data.instructiondata.DESC[id].desc
    }
    g_WindowTipCtrl:SetWindowInstructionInfo(content)
end

function COrgMemberListBox.DelMember(self, iPid)
	local iCount = #self.m_MemberList
	local index = 0
	for k,v in ipairs(self.m_MemberList) do
		if v.pid == iPid then
			index = k
			break
		end
	end
	if index ~= 0 then
		table.remove(self.m_MemberList, index)
	end
	self:RefreshMemberGrid(false)
end

function COrgMemberListBox.UpdateMemberPosition(self, iPid, iPos)
	local dMember = nil
	for k,v in ipairs(self.m_MemberList) do
		if v.pid == iPid then
			dMember = v
    		dMember.position = iPos
    		self.m_MemberList[k] = dMember
    		break
		end
	end
	for k,oBox in pairs(self.m_MemberBoxs) do
		if oBox.m_Pid == iPid and dMember then
			oBox:SetMember(dMember)
			break
		end
	end
end

function COrgMemberListBox.RequestQuitOrg(self)	
	local sMsg = ""
	if self.m_IsDisband then
		sMsg = data.orgdata.TEXT[1065].content
	else
		sMsg = data.orgdata.TEXT[1055].content
	end
	local windowConfirmInfo = {
		msg = sMsg,
		okCallback = function () 
			netorg.C2GSLeaveOrg() 
			--if self.m_IsDisband then
				--COrgInfoView:GetView():CloseView()
			--end
		end,	
	}
	g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
end

function COrgMemberListBox.OnSearchMember(self)
	self.m_ClearBtn:SetActive(true)
	self.m_SearchName = self.m_SearchInput:GetText()
	self:RefreshMemberGrid(true)
end

function COrgMemberListBox.OnClearInput(self)
	self.m_SearchName = ""
	self.m_SearchInput:SetText("")
	self.m_ClearBtn:SetActive(false)
	self:RefreshMemberGrid(true)
end

function COrgMemberListBox.ChangeSort(self, index)
	-- -- printc(index)
	self:SortMemberList(index)
	self:RefreshMemberGrid(true)
end

function COrgMemberListBox.ResetSortConfig(self)
	for k,v in pairs(self.m_SortConfig) do
		v.curMode = v.mode
		v.clickCount = 1
		self.m_SortConfig[k] = v
	end
end

function COrgMemberListBox.SortMemberList(self, index)
    local sKey = self.m_SortConfig[index].key
    local iMode = self.m_SortConfig[index].curMode
    local iClickCount = self.m_SortConfig[index].clickCount

	local function sort(data1, data2)
		if index == 1 then
			local compareData_a = data1
			local compareData_b = data2
			if iMode ~= self.m_SortMode.positive then
				compareData_a = data2
				compareData_b = data1
			end 
			local dExtra = {a = compareData_a.pid, b = compareData_b.pid}

			if not self.m_IsInitSort then
				return compareData_a.sortid < compareData_b.sortid
			else
				return CInitialCtrl.InitialSortStr(compareData_a[sKey], compareData_b[sKey], dExtra)
			end
		end
		if index == 8 then
			local tTouxian_1 = data.touxiandata.DATA[data1[sKey]]
			local tTouxian_2 = data.touxiandata.DATA[data2[sKey]]
			local iPower_1 = tTouxian_1 and tTouxian_1.power or 0
			local iPower_2 = tTouxian_2 and tTouxian_2.power or 0
			if iMode == self.m_SortMode.positive then
				return iPower_1 < iPower_2
			else
				return iPower_1 > iPower_2
			end
		end
		if iMode == self.m_SortMode.positive then
			return data1[sKey] < data2[sKey]
		else
			return data1[sKey] > data2[sKey]
		end
	end

	local function defaultSort(data1, data2)
		local IsOnline_1 = data1.difftime == 0
		local IsOnline_2 = data2.difftime == 0 
		if IsOnline_1 == IsOnline_2 and data1.position == data2.position then
			return data1.jointime > data2.jointime
		end
		if IsOnline_1 == IsOnline_2 then
			return data1.position < data2.position
		end
		return data1.difftime < data2.difftime
	end

	if iMode == self.m_SortMode.default or iClickCount == 3 then
		self:ResetSortConfig()
		table.sort(self.m_MemberList, defaultSort)
	else
		table.sort(self.m_MemberList, sort)
		if index == 1 and iMode == self.m_SortMode.positive then
			self:SaveSortStatus()
		end
		iClickCount = iClickCount%3 + 1
		iMode = iMode%2 + 1
		self.m_SortConfig[index].clickCount = iClickCount
		self.m_SortConfig[index].curMode = iMode
	end
end

function COrgMemberListBox.SaveSortStatus(self)
	for index,tMember in ipairs(self.m_MemberList) do
		tMember.sortid = index 
		self.m_MemberList[index] = tMember
	end
	self.m_IsInitSort = false
	table.print(self.m_MemberList)
end
return COrgMemberListBox