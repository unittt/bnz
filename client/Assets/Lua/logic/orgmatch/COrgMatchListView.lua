local COrgMatchListView = class("COrgMatchListView", CViewBase)

function COrgMatchListView.ctor(self, cb)
	CViewBase.ctor(self, "UI/OrgMatch/OrgMatchListView.prefab", cb)
	--界面设置
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function COrgMatchListView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_EmptyObj = self:NewUI(2, CObject)
	self.m_MatchScrollView = self:NewUI(3, CScrollView)
	self.m_MatchGrid = self:NewUI(4, CGrid)
	self.m_MatchBoxClone = self:NewUI(5, CBox)
	self.m_EnterBtn = self:NewUI(6, CButton)
	self.m_ActivityTabs = {
		[1] = self:NewUI(7, CBox),
		[2] = self:NewUI(8, CBox),
	}
	self.m_TitleObj = self:NewUI(9, CObject)
	self.m_TipBtn = self:NewUI(10, CButton)
	self.m_BattleListBtn = self:NewUI(11, CButton)

	--胜，负，平，无
	self.m_ResultSpr = { 
		[1] = "h7_shengli",
		[2] = "h7_baibei",
		[3] = "h7_pingju",
		[4] = "h7_shengli"
	}
	self.m_MatchBoxs = {}

	self:InitContent()
end

function COrgMatchListView.InitContent(self)
	--TODO:后续可能多按钮tab切换，先默认选中第一个
	self.m_BattleListBtn:SetSelected(true)

	self:InitActivityTab()

	self.m_MatchBoxClone:SetActive(false)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_EnterBtn:AddUIEvent("click", callback(self, "OnClickEnter"))
	self.m_TipBtn:AddUIEvent("click", callback(self, "OnClickTip"))

	g_OrgMatchCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	self:RefreshMatchGrid()
end

function COrgMatchListView.InitActivityTab(self)
	local dActivity = data.orgdata.ACTIVITY[1025]
	for i,oTab in ipairs(self.m_ActivityTabs) do
		oTab.m_WeekL = oTab:NewUI(1, CLabel)
		oTab.m_TimeL = oTab:NewUI(2, CLabel)
		oTab.m_FlagSpr = oTab:NewUI(3, CSprite)
		oTab:SetGroup(self:GetInstanceID())

		local iWeek = dActivity.date_list[i]
		self:UpdateTab(iWeek, oTab)
		if i == 1 then
			-- self:RequestGetMatchList(iWeek, oTab)
			oTab:SetSelected(true)
		end
	end
end

function COrgMatchListView.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.OrgMatch.Event.RefreshOrgMatchList then
		self:RefreshMatchGrid()
	end
end

function COrgMatchListView.UpdateTab(self, iWeek, oTab)
	local iCurWeek = tonumber(g_TimeCtrl:GetTimeWeek())
	iCurWeek = iCurWeek == 0 and 7 or iCurWeek
	local dActivity = data.orgdata.ACTIVITY[1025]
	local sDate = os.date(" %m月%d日", g_TimeCtrl:GetTimeS() + (iWeek - iCurWeek)*60*60*24)
	oTab.m_WeekL:SetText("周"..string.number2text(iWeek)..sDate)
	oTab.m_TimeL:SetText(dActivity.time.."~"..dActivity.end_time)

	if iWeek ~= iCurWeek then
		oTab.m_FlagSpr:SetActive(false)
	elseif iWeek == iCurWeek then
		local dActivity = data.orgdata.ACTIVITY[1025]
		local sCurTime = g_TimeCtrl:GetTimeHM()
		if sCurTime >= dActivity.start_time and sCurTime <= dActivity.end_time then
			oTab.m_FlagSpr:SetSpriteName("h7_duizhanzhong")
		elseif sCurTime < dActivity.time or sCurTime > dActivity.end_time then
			oTab.m_FlagSpr:SetActive(false)
		end
	end
	oTab:AddUIEvent("click", callback(self, "RequestGetMatchList", iWeek, oTab))
end

function COrgMatchListView.RefreshMatchGrid(self)
	for i,oBox in ipairs(self.m_MatchBoxs) do
		oBox:SetActive(false)
	end
	for i,dInfo in ipairs(g_OrgMatchCtrl:GetOrgMatchList()) do
		local oBox = self.m_MatchBoxs[i]
		if not oBox then
			oBox = self:CreateMatchBox()
			self.m_MatchBoxs[i] = oBox
			self.m_MatchGrid:AddChild(oBox)
		end
		self:UpdateMatchBox(oBox, dInfo, i)
	end
	self.m_MatchGrid:Reposition()

	local bIsEmpty = #g_OrgMatchCtrl:GetOrgMatchList() == 0
	self.m_EmptyObj:SetActive(bIsEmpty)
	self.m_TitleObj:SetActive(not bIsEmpty)
end

function COrgMatchListView.CreateMatchBox(self)
	local oBox = self.m_MatchBoxClone:Clone()
	oBox.m_BgSpr = oBox:NewUI(1, CSprite)
	oBox.m_OrgBox = {
		[1] = {
			IDL = oBox:NewUI(2, CLabel),
			NameL = oBox:NewUI(3, CLabel),
			ResultSpr = oBox:NewUI(4, CSprite),
		},
		[2] = {
			IDL = oBox:NewUI(5, CLabel),
			NameL = oBox:NewUI(6, CLabel),
			ResultSpr = oBox:NewUI(7, CSprite),
		},
	}
	oBox.m_BgSpr:SetGroup(self.m_MatchGrid:GetInstanceID())
	return oBox
end

function COrgMatchListView.UpdateMatchBox(self, oBox, dInfo, iIndex)
	if iIndex % 2  == 1 then  -- 奇数
        oBox.m_BgSpr:SetSpriteName("h7_di_3")
    else    -- 偶数
        oBox.m_BgSpr:SetSpriteName("h7_di_4")
    end 
    self:UpdateOrgInfoBox(oBox.m_OrgBox[1], dInfo.org_unit1)
    self:UpdateOrgInfoBox(oBox.m_OrgBox[2], dInfo.org_unit2)
    oBox:SetActive(true)
end

function COrgMatchListView.UpdateOrgInfoBox(self, oBox, dOrgInfo)
	local bIsNotEmpty = dOrgInfo.org_id and dOrgInfo.org_id > 0
	oBox.IDL:SetActive(bIsNotEmpty)
	oBox.NameL:SetActive(bIsNotEmpty)
	oBox.ResultSpr:SetActive(bIsNotEmpty)

	if not bIsNotEmpty then
		return
	end
	local sColor = ""
	if dOrgInfo.org_id == g_AttrCtrl.org_id then
		sColor = "[c][a64e00]"
	end
	oBox.IDL:SetText(sColor..dOrgInfo.org_id)
	oBox.NameL:SetText(sColor..dOrgInfo.org_name)
	oBox.ResultSpr:SetSpriteName(self.m_ResultSpr[dOrgInfo.org_status])
end

function COrgMatchListView.RequestGetMatchList(self, iWeek, oTab)
	nethuodong.C2GSOrgWarOpenMatchList(iWeek)
	oTab:SetSelected(true)
end

function COrgMatchListView.OnClickEnter(self)
	nethuodong.C2GSOrgWarTryGotoNpc()
	COrgInfoView:CloseView()
	self:CloseView()
end

function COrgMatchListView.OnClickTip(self)
	local id = define.Instruction.Config.OrgMatch
    local content = {
        title = data.instructiondata.DESC[id].title,
        desc  = data.instructiondata.DESC[id].desc
    }
    g_WindowTipCtrl:SetWindowInstructionInfo(content)
end

return COrgMatchListView