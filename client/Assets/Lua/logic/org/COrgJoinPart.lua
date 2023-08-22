local COrgJoinPart = class("COrgJoinPart", CPageBase)

function COrgJoinPart.ctor(self, obj)
    CPageBase.ctor(self, obj)
end

function COrgJoinPart.OnInitPage(self)
    -- self.m_CloseBtn              = self:NewUI(1, CButton)
    self.m_CreateOrgBtn          = self:NewUI(2, CButton)
    self.m_ApplyJoinOrgBtn       = self:NewUI(3, CButton)
    self.m_OneClickApplyBtn      = self:NewUI(4, CButton)
    -- self.m_RespondOrgBtn         = self:NewUI(5, CButton)
    self.m_SearchBtn             = self:NewUI(6, CButton)
    self.m_ClearSearchBtn        = self:NewUI(7, CButton)
    self.m_Grid                  = self:NewUI(8, CGrid)
    self.m_ItemClone             = self:NewUI(9, CJoinOrgItem)
    self.m_AimContainer          = self:NewUI(10, CWidget)
    self.m_AimLabel              = self:NewUI(11, CLabel)
    self.m_SearchInput           = self:NewUI(12, CInput)
    self.m_CancelApplyJoinOrgBtn = self:NewUI(13, CButton)
    self.m_EmptyContainer        = self:NewUI(14, CWidget)
    self.m_EmptyCreateOrgBtn     = self:NewUI(15, CButton)
    self.m_ListContainer         = self:NewUI(16, CWidget)
    self.m_EmptyRespondOrgBtn    = self:NewUI(17, CButton)
    self.m_ScrollView            = self:NewUI(18, CScrollView)
    self.m_CurOrgId = nil
    self.m_OneClickApplyBtnExpireTime = 0
    self.m_IsFirstRequest = true
    g_GuideCtrl:AddGuideUI("joinorgview_emptyrespond_btn", self.m_EmptyRespondOrgBtn)
    self:InitContent()
end

function COrgJoinPart.InitContent(self)
    local openCreateOrgSta = g_OpenSysCtrl:GetOpenSysState(define.System.CreateOrg)
    self.m_CreateOrgBtn:SetActive(openCreateOrgSta)

    self.m_EmptyContainer:SetActive(false)
    -- self.m_ListContainer:SetActive(false)
    self.m_AimContainer:SetActive(false)
    self.m_ClearSearchBtn:SetActive(false)

    -- self.m_CloseBtn              :AddUIEvent("click", callback(self, "OnClose"))
    self.m_CreateOrgBtn          :AddUIEvent("click", callback(self, "OnCreateOrg"))
    self.m_EmptyCreateOrgBtn     :AddUIEvent("click", callback(self, "OnCreateOrg"))
    self.m_EmptyRespondOrgBtn    :AddUIEvent("click", callback(self, "OnRespondOrg"))
    self.m_ApplyJoinOrgBtn       :AddUIEvent("click", callback(self, "OnApplyJoinOrg"))
    self.m_CancelApplyJoinOrgBtn :AddUIEvent("click", callback(self, "OnCancelApplyJoinOrg"))
    -- self.m_RespondOrgBtn         :AddUIEvent("click", callback(self, "OnRespondOrg"))
    self.m_SearchBtn             :AddUIEvent("click", callback(self, "OnSearch"))
    self.m_ClearSearchBtn        :AddUIEvent("click", callback(self, "OnClearSearch"))
    self.m_OneClickApplyBtn:AddUIEvent("click", callback(self, "OnOneClickApply"))
    g_OrgCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnOrgEvent"))
    g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAttrEvent"))
    g_FriendCtrl:AddCtrlEvent(self:GetInstanceID(),callback(self, "OnFriendEvent"))
    -- printc("加入帮派界面，InitContent，发送 C2GSOrgList 请求数据")
    if self.m_IsFirstRequest then
        netorg.C2GSOrgList(g_OrgCtrl.m_OrgListVersion)
        -- netorg.C2GSReadyOrgList()   -- 用于创建帮派按钮逻辑
    end
    --一键申请相关
    self.m_OneClickApplyBtn:SetGrey(g_OrgCtrl:IsInOneKeyApply())
    g_GuideCtrl:AddGuideUI("org_oneclickapply_btn", self.m_OneClickApplyBtn)

    self:RebuildOrgList(g_OrgCtrl.m_OrgList)
end

function COrgJoinPart.OnShowPage(self)
    if not self.m_IsFirstRequest then
        netorg.C2GSOrgList(g_OrgCtrl.m_OrgListVersion)
        -- netorg.C2GSReadyOrgList()
    end
    self.m_IsFirstRequest = false
end

function COrgJoinPart.OnCreateOrg(self)
    -- printc("加入帮派界面：点击创建帮派")
    local bIsUnlock = g_OpenSysCtrl:GetOpenSysState(define.System.CreateOrg)
    local iUnlockLevel = data.opendata.OPEN[define.System.CreateOrg].p_level
    if not bIsUnlock then
        g_NotifyCtrl:FloatMsg(string.gsub(data.orgdata.TEXT[1011].content, "#grade", iUnlockLevel))
        return
    end
    if g_AttrCtrl.org_status == COrgCtrl.ORG_STATUS_CREATE_RESPOND_ORG then
        g_NotifyCtrl:FloatMsg(data.orgdata.TEXT[1009].content)
        return
    end
    local hasApplyOtherOrg = g_OrgCtrl:HasApplyOtherOrg()
    local hasRespondOtherOrg = g_OrgCtrl:HasRespondOtherOrg()
    if not hasApplyOtherOrg and not hasRespondOtherOrg then  -- 00
        CCreateOrgView:ShowView()
        return
    end

    if not hasApplyOtherOrg and hasRespondOtherOrg then  -- 01
        self:ShowConfirmCreateOrgWindow(1)
        return
    end

    if hasApplyOtherOrg and not hasRespondOtherOrg then  -- 10
        self:ShowConfirmCreateOrgWindow(2)
        return
    end

    if hasApplyOtherOrg and hasRespondOtherOrg then  -- 11
        self:ShowConfirmCreateOrgWindow(3)
        return
    end
end

function COrgJoinPart.ShowConfirmCreateOrgWindow(self, flag)
    local sMsg = ""
    if flag == 1 then
        sMsg = data.orgdata.TEXT[1007].content
    elseif flag == 2 then
        sMsg = data.orgdata.TEXT[1006].content
    elseif flag == 3 then
        sMsg = data.orgdata.TEXT[1008].content
    end

    local windowConfirmInfo = {
        title = "提示",
        msg = sMsg,
        okStr = "确定",
        cancelStr = "取消",
        okCallback = function()
            -- printc("加入帮派界面：点击确定进入创建帮派界面")
            CCreateOrgView:ShowView()
            g_OrgCtrl:CancelAllOrgApply()
            g_OrgCtrl:CancelAllOrgRespond()
            netorg.C2GSClearApplyAndRespond()
        end
    }
    g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo,
        function (oView)
            self.m_WinTipViwe = oView
        end
    )
end

function COrgJoinPart.OnApplyJoinOrg(self)
    if g_AttrCtrl.org_status == COrgCtrl.ORG_STATUS_CREATE_RESPOND_ORG then
        g_NotifyCtrl:FloatMsg(data.orgdata.TEXT[1003].content)
        return
    end
    if g_AttrCtrl.org_status == COrgCtrl.ORG_STATUS_HAS_ORG then
        g_NotifyCtrl:FloatMsg(data.orgdata.TEXT[1021].content)
        return
    end
    if g_AttrCtrl.org_status == COrgCtrl.ORG_STATUS_NO_ORG then
        g_OrgCtrl:ApplyJoinOrg(self.m_CurOrgId)
        return
    end
end

function COrgJoinPart.OnCancelApplyJoinOrg(self)
    -- printc("加入帮派界面：点击取消申请，ID = " .. self.m_CurOrgId)
    netorg.C2GSApplyJoinOrg(self.m_CurOrgId, g_OrgCtrl.CANCEL_APPLY_ORG)
end

function COrgJoinPart.OnRespondOrg(self)
    -- printc("加入帮派界面：点击响应帮派")
    if #g_OrgCtrl.m_RespondOrgList > 0 then
        COrgJoinOrRespondView:ShowView(function(oView)
            oView:ShowSubPageByIndex(2)
        end)
    else
        g_NotifyCtrl:FloatMsg(data.orgdata.TEXT[1010].content)
    end
end

function COrgJoinPart.OnSearch(self)
    local searchText = self.m_SearchInput:GetText()
    -- printc("加入帮派界面：点击搜索，关键字为 " .. searchText)
    if searchText == "" then
        g_NotifyCtrl:FloatMsg(data.orgdata.TEXT[1002].content)
        return
    end
    netorg.C2GSSearchOrg(searchText)
end

function COrgJoinPart.OnClearSearch(self)
    -- printc("加入帮派界面：点击清空搜索")
    self.m_ClearSearchBtn:SetActive(false)
    self.m_SearchInput:SetText("")
    self:RebuildOrgList(g_OrgCtrl.m_OrgList)
end

function COrgJoinPart.OnOrgEvent(self, callbackBase)
    local eventID = callbackBase.m_EventID
    -- printc("加入帮派界面：OnOrgEvent, eventID = " .. eventID)
    if eventID == define.Org.Event.GetOrgList then
        self:OnUpdateOrgList(callbackBase)
    elseif eventID == define.Org.Event.GetSearchResultList then
        self:OnUpdateOrgSearchList(callbackBase)
    elseif eventID == define.Org.Event.GetOrgAim then
        self:OnUpdateOrgAim(callbackBase)
    elseif eventID == define.Org.Event.GetAppliedOrg then
        self:OnUpdateAppliedOrg(callbackBase)
    elseif eventID == define.Org.Event.CancelAllOrgApply then
        self:OnCancelAllOrgApply()
    elseif eventID == define.Org.Event.GetOrgJoinStatus then
        g_OrgCtrl:OnOrgJoinStatus(self, callbackBase)
    elseif eventID == define.Org.Event.DelOrgList then
        self:RebuildOrgList(g_OrgCtrl.m_OrgList)
    -- elseif eventID == define.Org.Event.UpdateOneClickApplyCoolDown then
    --     self:UpdateOneClickApplyCoolDown(callbackBase)
    elseif eventID == define.Org.Event.OneClickTime then
        self.m_OneClickApplyBtn:SetGrey(g_OrgCtrl:IsInOneKeyApply())
    end
end

function COrgJoinPart.OnAttrEvent(self, oAttrCtrl)
    if oAttrCtrl.m_EventID == define.Attr.Event.Change then
        g_OrgCtrl:OnOrgStatusChange(oAttrCtrl)
    end
end

function COrgJoinPart.OnFriendEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Friend.Event.Add or oCtrl.m_EventID == define.Friend.Event.Del then
        local lPidList = oCtrl.m_EventData
        local dFriendPid = {}
        for _, iPid in ipairs(lPidList) do
            dFriendPid[iPid] = true
        end

        local list = self.m_Grid:GetChildList()
        for i,oBox in ipairs(list) do
            if oBox:GetActive() and oBox.m_LeaderID and dFriendPid[oBox.m_LeaderID] then
                oBox:RefreshNameColor()
            end
        end
    end
end

function COrgJoinPart.OnOneClickApply(self)
    if g_AttrCtrl.org_status == COrgCtrl.ORG_STATUS_CREATE_RESPOND_ORG then
        g_NotifyCtrl:FloatMsg(data.orgdata.TEXT[1004].content)
        return
    end
    if not g_OrgCtrl:IsInOneKeyApply() then
        netorg.C2GSMultiApplyJoinOrg()
    else
        local leftHH, leftMM, leftSS = g_OrgCtrl:ConvertSecondsHHMMSS(g_OrgCtrl.m_OneClickLeftTimes[g_AttrCtrl.pid])
        local s = string.gsub(data.orgdata.TEXT[1072].content, "#HH", leftHH)
        s = string.gsub(s, "#MM", leftMM)
        s = string.gsub(s, "#SS", leftSS)
        g_NotifyCtrl:FloatMsg(s)
    end
end

function COrgJoinPart.OnUpdateOrgList(self, callbackBase)
    -- printc("加入帮派界面：更新帮派列表")
    local tOrg = callbackBase.m_EventData
    -- table.print(tOrg)
    local bIsEmpty = #tOrg == 0
    self.m_EmptyContainer:SetActive(bIsEmpty)
    self.m_ListContainer:SetActive(not bIsEmpty)
    if #tOrg == 0 then
        -- printc("没有帮派列表，显示 m_EmptyContainer")
        self.m_EmptyContainer:SetActive(true)
    else
        -- printc("有帮派列表，显示 m_ListContainer")
        -- self.m_ListContainer:SetActive(true)
        self:RebuildOrgList(tOrg)
    end
end

function COrgJoinPart.OnUpdateOrgSearchList(self, callbackBase)
    -- printc("加入帮派界面：更新帮派搜索列表")
    local tOrg = callbackBase.m_EventData
    -- table.print(tOrg)
    if #tOrg > 0 then
        self.m_ClearSearchBtn:SetActive(true)
        self:RebuildOrgList(tOrg)
    else
        g_NotifyCtrl:FloatMsg(data.orgdata.TEXT[1001].content)
    end
end

function COrgJoinPart.OnUpdateOrgAim(self, callbackBase)
    local orgid = callbackBase.m_EventData.orgid
    local aim = callbackBase.m_EventData.aim
    -- printc("加入帮派界面：更新帮派宗旨，ID = " .. tostring(orgid) .. ", 宗旨 = " .. tostring(aim))

    -- 更新宗旨
    if aim == nil or aim == "" then
        self.m_AimLabel:SetText(data.orgdata.TEXT[1070].content)
    else
        self.m_AimLabel:SetText(aim)
    end
end

function COrgJoinPart.UpdateOrgAppliedStatus(self, orgid)
    -- 刷新申请按钮状态
    if orgid == self.m_CurOrgId then
        local org = g_OrgCtrl:GetOrgById(orgid)
        if org.hasapply == g_OrgCtrl.HAS_APPLY_ORG then
            self.m_ApplyJoinOrgBtn:SetActive(false)
            self.m_CancelApplyJoinOrgBtn:SetActive(true)
        else
            self.m_CancelApplyJoinOrgBtn:SetActive(false)
            self.m_ApplyJoinOrgBtn:SetActive(true)
        end
    end
    -- 刷新 item 图标
    local oOrg = self:GetOrgItemById(orgid)
    if oOrg ~= nil then
        oOrg:UpdateApplied()
    end
end

function COrgJoinPart.OnUpdateAppliedOrg(self, callbackBase)
    local orgid = callbackBase.m_EventData.orgid
    -- printc("加入帮派界面：OnUpdateAppliedOrg, orgid = " .. orgid)
    self:UpdateOrgAppliedStatus(orgid)
end

function COrgJoinPart.OnCancelAllOrgApply(self)
    for _, org in pairs(g_OrgCtrl.m_OrgList) do
        self:UpdateOrgAppliedStatus(org.orgid)
    end
end

function COrgJoinPart.SortFunc(orgA, orgB)
    return orgA.orgid < orgB.orgid
end

function COrgJoinPart.RebuildOrgList(self, tOrg)
    -- printc("加入帮派界面：填充 ScrollView 数据")
    -- 按创建时间排序
    table.sort(tOrg, self.SortFunc)
    -- self.m_Grid:Clear()

    if self.m_LoadTimer then
        Utils.DelTimer(self.m_LoadTimer)
        self.m_LoadTimer = nil
    end

    self.m_OrgCnt = #tOrg
    self.m_LoadIndex = 1

    self.m_LoadTimer = Utils.AddTimer(callback(self, "LoadOrg", tOrg), 1/30, 0)    
end

function COrgJoinPart.LoadOrg(self, tOrg)
    if Utils.IsNil(self) then
        return
    end

    for i = 1, 10 do
        local dOrg = tOrg[self.m_LoadIndex]
        if dOrg then
            self:AddSingleOrgItem(dOrg, self.m_LoadIndex)
        end
        if self.m_LoadIndex == 1 then
            local firstItem = tOrg[1]
            self:ItemCallBack(firstItem)
        end
        self.m_LoadIndex = self.m_LoadIndex + 1
        if self.m_LoadIndex > self.m_OrgCnt then
            self.m_Grid:Reposition()
            -- 列表滚到顶
            self:ScrollToTop()

            -- 没有用到的oItem隐藏处理
            local itemList = self.m_Grid:GetChildList()
            for j=self.m_LoadIndex,#itemList do
                itemList[j]:SetActive(false)
            end

            return false
        end
    end

    if self.m_LoadIndex == 11 then
        self:ScrollToTop()
    end
    self.m_Grid:Reposition()
    return true
end

function COrgJoinPart.ScrollToTop(self)
    self.m_ScrollView:ResetPosition()
    self.m_ScrollView:MoveRelative(Vector3.zero)
end

function COrgJoinPart.AddSingleOrgItem(self, org, idx)
    -- printc("加入帮派界面：填充单条 ScrollView item 数据，org = ")
    -- table.print(org)

    if org == nil then
        return
    end

    local oItem = self.m_Grid:GetChild(idx)
    if not oItem then
        oItem = self.m_ItemClone:Clone()
        oItem:SetGroup(self.m_Grid:GetInstanceID())
        self.m_Grid:AddChild(oItem)
    end
    oItem:SetCallback(function ()
        self:ItemCallBack(org)
    end)
    oItem:SetActive(true)
    oItem:SetBoxInfo(org, idx)
end

function COrgJoinPart.ItemCallBack(self, org)
    if org == nil then
        return
    end

    -- 更新当前点击帮派 ID
    self.m_CurOrgId = org.orgid

    -- 当前项显示 ToggleBG
    local orgItem = self:GetOrgItemById(self.m_CurOrgId)
    -- printc("加入帮派界面，点击 item, self.m_CurOrgId = " .. self.m_CurOrgId .. ", orgItem = " .. tostring(orgItem))
    if orgItem == nil then
        return
    end
    orgItem:SetSelected()

    -- 显示界面
    self:ShowOrgAimContainer()

    -- 获取帮派宗旨
    -- printc("加入帮派界面，点击 orgID = " .. self.m_CurOrgId .. "，获取帮派宗旨数据")
    netorg.C2GSRequestOrgAim(self.m_CurOrgId)
end

function COrgJoinPart.ShowOrgAimContainer(self)
    -- printc("加入帮派界面，点击 orgID = " .. self.m_CurOrgId .. "，显示 AimContainer")

    -- 显示 container
    self.m_AimContainer:SetActive(true)

    -- 更新“申请”btn 状态，和 item 的 ./ 状态
    self:UpdateOrgAppliedStatus(self.m_CurOrgId)
end

function COrgJoinPart.GetOrgItemById(self, orgid)
    local childList = self.m_Grid:GetChildList()
    -- -- printc("加入帮派界面 GetOrgItemById, childList = ")
    -- table.print(childList)
    for _, oOrg in pairs(childList) do
        if oOrg.m_Orgid == orgid then
            return oOrg
        end
    end
    return nil
end

return COrgJoinPart