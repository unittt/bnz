local COrgRespondPart = class("COrgRespondPart", CPageBase)

function COrgRespondPart.ctor(self, obj)
    CPageBase.ctor(self, obj)
end

function COrgRespondPart.OnInitPage(self)
    -- self.m_CloseBtn                      = self:NewUI(1, CButton)
    self.m_OneClickRespondBtn            = self:NewUI(2, CButton)
    self.m_SearchInput                   = self:NewUI(3, CInput)
    self.m_SearchBtn                     = self:NewUI(4, CButton)
    self.m_ClearSearchBtn                = self:NewUI(5, CButton)
    self.m_AimLabel                      = self:NewUI(6, CLabel)
    self.m_RespondTimeRemainningLabel    = self:NewUI(7, CLabel)
    self.m_CoolDownLabel                 = self:NewUI(8, CLabel)
    self.m_WorldChannelAdvertiseBtn      = self:NewUI(9, CButton)
    self.m_Grid                          = self:NewUI(10, CGrid)
    self.m_ItemClone                     = self:NewUI(11, CRespondOrgItem)
    self.m_AimContainer                  = self:NewUI(12, CWidget)
    self.m_RespondJoinOrgBtn             = self:NewUI(13, CButton)
    self.m_CancelRespondJoinOrgBtn       = self:NewUI(14, CButton)
    self.m_VitalityPerAdvertisementLabel = self:NewUI(15, CLabel)
    self.m_SuccessConditionLabel         = self:NewUI(16, CLabel)
    self.m_ScrollView                    = self:NewUI(17, CScrollView)
    self.m_CurRespondOrgId = nil
    self.m_EnableWorldChannelAdvertise = false

    self:InitContent()
end

function COrgRespondPart.InitContent(self)
    self.m_CoolDownLabel:SetActive(false)
    local hours = g_OrgCtrl:ConvertSecondsStrV2(data.orgdata.OTHERS[1].create_respond_time)
    local numRespond = data.orgdata.OTHERS[1].create_respond_people
    self.m_SuccessConditionLabel:SetText(hours .. "内，有" .. numRespond .. "名玩家响应才能创建成功")

    local energy = data.orgdata.OTHERS[1].world_ad_energy
    self.m_VitalityPerAdvertisementLabel:SetText("每次宣传需要" .. energy .. "活力")
    self.m_ClearSearchBtn:SetActive(false)
    -- self.m_CloseBtn                 :AddUIEvent("click", callback(self, "CloseView"))
    self.m_OneClickRespondBtn       :AddUIEvent("click", callback(self, "OnOneClickRespond"))
    self.m_SearchBtn                :AddUIEvent("click", callback(self, "OnSearch"))
    self.m_ClearSearchBtn           :AddUIEvent("click", callback(self, "OnClearSearch"))
    self.m_WorldChannelAdvertiseBtn :AddUIEvent("click", callback(self, "OnWorldChannelAdvertise"))
    self.m_RespondJoinOrgBtn        :AddUIEvent("click", callback(self, "OnRespondJoinOrg"))
    self.m_CancelRespondJoinOrgBtn  :AddUIEvent("click", callback(self, "OnCancelRespondJoinOrg"))
    g_OrgCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnOrgEvent"))
    g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAttrEvent"))
    g_FriendCtrl:AddCtrlEvent(self:GetInstanceID(),callback(self, "OnFriendEvent"))

    -- netorg.C2GSReadyOrgList()
    -- netopenui.C2GSOpenInterface(1)

    self:RebuildRespondOrgList(g_OrgCtrl.m_RespondOrgList)
end

function COrgRespondPart.OnShowPage(self)
    -- netorg.C2GSReadyOrgList()
    netopenui.C2GSOpenInterface(1)
end

function COrgRespondPart.CloseView(self)
    -- printc("响应帮派界面，关闭")
    netopenui.C2GSCloseInterface(1)
    g_ViewCtrl:CloseView(self)
end

function COrgRespondPart.OnOneClickRespond(self)
    -- printc("响应帮派界面，点击一键响应")

     -- 按钮 CD
    if g_CountdownTimerCtrl:GetRecord(g_CountdownTimerCtrl.Type.OrgOneClickRespondJoin, self:GetInstanceID()) then
        -- local SS = self.m_OneClickRespondExpireTime - g_TimeCtrl:GetTimeS()
        -- g_NotifyCtrl:FloatMsg(string.gsub(data.orgdata.TEXT[1031].content, "#SS", SS))
        g_NotifyCtrl:FloatMsg("一键响应不能过于频繁，建议尝试单个响应")
        return
    end

    -- netorg.C2GSMultiRespondOrg()

    local cd = data.orgdata.OTHERS[1].respond_rate
    g_CountdownTimerCtrl:AddRecord(g_CountdownTimerCtrl.Type.OrgOneClickRespondJoin, self:GetInstanceID(), cd)
    self.m_OneClickRespondExpireTime = g_TimeCtrl:GetTimeS() + cd
end

function COrgRespondPart.OnSearch(self)
    local searchText = self.m_SearchInput:GetText()
    if searchText == "" then
        g_NotifyCtrl:FloatMsg(data.orgdata.TEXT[1002].content)
        return
    end
    local tResult = g_OrgCtrl:GetRespondSearchResult(searchText)
    if #tResult <= 0 then
        g_NotifyCtrl:FloatMsg(data.orgdata.TEXT[1001].content)
        return
    end
    self.m_ClearSearchBtn:SetActive(true)
    self:RebuildRespondOrgList(tResult)
end

function COrgRespondPart.OnClearSearch(self)
    -- printc("响应帮派界面，点击清空搜索")
    self.m_ClearSearchBtn:SetActive(false)
    self.m_SearchInput:SetText("")
    self:RebuildRespondOrgList(g_OrgCtrl.m_RespondOrgList)
end

function COrgRespondPart.OnWorldChannelAdvertise(self, left_time)
    -- printc("响应帮派界面，点击世界频道宣传")
    if not self.m_EnableWorldChannelAdvertise then
        g_NotifyCtrl:FloatMsg(data.orgdata.TEXT[1030].content)
        return
    end

    if g_AttrCtrl.energy < data.orgdata.OTHERS[1].world_ad_energy then
        -- printc("当前活力为 " .. g_AttrCtrl.energy .. "，不能在世界频道宣传")
        g_NotifyCtrl:FloatMsg(data.orgdata.TEXT[1028].content)
        return
    end

    -- 冷却飘字
    if left_time ~= nil and left_time > 0 then
        local curTimeS = g_TimeCtrl:GetTimeS()
        local leftTimeS = self.m_WorldChannelAdvertiseBtnExpireTime - curTimeS
        -- local leftHH, leftMM, leftSS = g_OrgCtrl:ConvertSecondsHHMMSS(leftTimeS)
        -- local s = string.gsub(data.orgdata.TEXT[1029].content, "#HH", leftHH)
        -- s = string.gsub(s, "#MM", leftMM)
        -- s = string.gsub(s, "#SS", leftSS)
        local str = os.date("%M:%S", leftTimeS)--g_OrgCtrl:ConvertSecondsStr(leftTimeS)
        g_NotifyCtrl:FloatMsg("宣传功能30分钟使用一次（剩余时间:" .. str..")")
    else
        g_NotifyCtrl:FloatMsg("已向全世界宣传你的帮派")
        netorg.C2GSSpreadOrg()
    end

end

function COrgRespondPart.SetCoolDownVal(self, val)
    local str = g_OrgCtrl:ConvertSecondsStr(val)

    if str == "00:00" then  -- 要跟 ConvertSecondsStr 里的格式一致
        self.m_CoolDownLabel:SetActive(false)
    else
        self.m_CoolDownLabel:SetActive(true)
        self.m_CoolDownLabel:SetText("冷却中：" .. str)
    end
end

function COrgRespondPart.SetRespondTimeRemainning(self, val)
    local function Time()
        val = val - 1
        if val <= 0 then
            self:OnClose()
            return false
        end
        local str = g_OrgCtrl:ConvertSecondsStr(val)
        if not self.m_RespondTimeRemainningLabel:IsDestroy() then
            self.m_RespondTimeRemainningLabel:SetText("剩余响应时间：" .. str)
        end
        return true
    end
    if self.m_DoneTimer then
        Utils.DelTimer(self.m_DoneTimer)
    end
    self.m_DoneTimer = Utils.AddTimer(Time, 1, 0)
end

function COrgRespondPart.OnRespondJoinOrg(self)
    if self.m_CurRespondOrgId == nil then
        g_NotifyCtrl:FloatMsg("请选择帮派")
        return
    end
    if g_AttrCtrl.org_status == COrgCtrl.ORG_STATUS_CREATE_RESPOND_ORG then
        g_NotifyCtrl:FloatMsg(data.orgdata.TEXT[1022].content)
        return
    end
    if g_AttrCtrl.org_status == COrgCtrl.ORG_STATUS_HAS_ORG then
        g_NotifyCtrl:FloatMsg(data.orgdata.TEXT[1021].content)
        return
    end

    -- 按钮 CD
    if g_CountdownTimerCtrl:GetRecord(g_CountdownTimerCtrl.Type.OrgRespondJoin, self:GetInstanceID()) then
        local SS = self.m_RespondExpireTime - g_TimeCtrl:GetTimeS()
        g_NotifyCtrl:FloatMsg(string.gsub(data.orgdata.TEXT[1031].content, "#SS", SS))
        return
    end

    -- netorg.C2GSRespondOrg(self.m_CurRespondOrgId, COrgCtrl.HAS_RESPOND_ORG)

    local cd = data.orgdata.OTHERS[1].respond_rate
    g_CountdownTimerCtrl:AddRecord(g_CountdownTimerCtrl.Type.OrgRespondJoin, self:GetInstanceID(), cd)
    self.m_RespondExpireTime = g_TimeCtrl:GetTimeS() + cd
end

function COrgRespondPart.OnCancelRespondJoinOrg(self)
    -- printc("响应帮派界面，点击取消响应")
    if self.m_CurRespondOrgId == nil then
        g_NotifyCtrl:FloatMsg("请选择帮派")
        return
    end

    -- 按钮 CD
    if g_CountdownTimerCtrl:GetRecord(g_CountdownTimerCtrl.Type.OrgRespondJoin, self:GetInstanceID()) then
        local SS = self.m_RespondExpireTime - g_TimeCtrl:GetTimeS()
        g_NotifyCtrl:FloatMsg(string.gsub(data.orgdata.TEXT[1031].content, "#SS", SS))
        return
    end

    -- netorg.C2GSRespondOrg(self.m_CurRespondOrgId, COrgCtrl.CANCEL_RESPOND_ORG)

    local cd = data.orgdata.OTHERS[1].respond_rate
    g_CountdownTimerCtrl:AddRecord(g_CountdownTimerCtrl.Type.OrgRespondJoin, self:GetInstanceID(), cd)
    self.m_RespondExpireTime = g_TimeCtrl:GetTimeS() + cd
end

function COrgRespondPart.OnOrgEvent(self, callbackBase)
    local eventID = callbackBase.m_EventID
    -- printc("响应帮派界面，OnOrgEvent, eventID = " .. eventID)
    if eventID == define.Org.Event.GetRespondOrgList then
        self:OnUpdateRespondOrgList(callbackBase)
    elseif eventID == define.Org.Event.GetRespondOrgInfo then
        self:OnUpdateRespondOrgInfo(callbackBase)
    elseif eventID == define.Org.Event.GetRespondedOrg then
        self:OnUpdateRespondedStatus(callbackBase)
    elseif eventID == define.Org.Event.GetOrgJoinStatus then
        g_OrgCtrl:OnOrgJoinStatus(self, callbackBase)
    elseif eventID == define.Org.Event.DelRespondOrgList then
        self:RebuildRespondOrgList(g_OrgCtrl.m_RespondOrgList)
    elseif eventID == define.Org.Event.CancelAllOrgRespond then
        g_OrgCtrl:OnCancelAllOrgRespond()
    elseif eventID == define.Org.Event.UpdateRespondOrgCD then
        self:UpdateRespondOrgCD(callbackBase)
    elseif eventID == define.Org.Event.UpdateOrgRespondNum then
        self:UpdateOrgRespondNum(callbackBase)
    end
end

function COrgRespondPart.UpdateOrgRespondNum(self, callbackBase)
    local orgid = callbackBase.m_EventData.orgid
    local oItem = self:GetRespondOrgItemById(orgid)
    if oItem ~= nil then
        oItem:UpdateResponded()
    end
end

function COrgRespondPart.UpdateRespondOrgCD(self, callbackBase)
    local orgid = callbackBase.m_EventData.orgid
    local spread_cd = callbackBase.m_EventData.spread_cd
    --self:SetCoolDownVal(spread_cd)

    self.m_WorldChannelAdvertiseBtnExpireTime = g_TimeCtrl:GetTimeS() + spread_cd
    self.m_WorldChannelAdvertiseBtn:AddUIEvent("click", callback(self, "OnWorldChannelAdvertise", spread_cd))
end

function COrgRespondPart.OnAttrEvent(self, callbackBase)
    if callbackBase.m_EventID == define.Attr.Event.Change then
        g_OrgCtrl:OnOrgStatusChange(callbackBase)
    end
end

function COrgRespondPart.OnFriendEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Friend.Event.Add or oCtrl.m_EventID == define.Friend.Event.Del then
        local lPidList = oCtrl.m_EventData
        local dFriendPid = {}
        for _, iPid in ipairs(lPidList) do
            dFriendPid[iPid] = true
        end

        local list = self.m_Grid:GetChildList()
        for i,oBox in ipairs(list) do
            if oBox:GetActive() and oBox.m_LeaderId and dFriendPid[oBox.m_LeaderId] then
                oBox:RefreshNameColor()
            end
        end
    end
end

function COrgRespondPart.OnUpdateRespondOrgList(self, callbackBase)
    -- printc("响应帮派界面：更新响应帮派列表")
    local tRespondOrg = callbackBase.m_EventData
    self:RebuildRespondOrgList(tRespondOrg)
end

function COrgRespondPart.OnUpdateRespondOrgInfo(self, callbackBase)
    local orgid = callbackBase.m_EventData.orgid
    -- printc("响应帮派界面：更新帮派宗旨，id = " .. orgid)
    local aim = callbackBase.m_EventData.aim
    local left_time = callbackBase.m_EventData.left_time
    local spread_cd = callbackBase.m_EventData.spread_cd
    self.m_AimLabel:SetText(aim)
    self:SetRespondTimeRemainning(left_time)
    --self:SetCoolDownVal(spread_cd)
    self.m_WorldChannelAdvertiseBtnExpireTime = g_TimeCtrl:GetTimeS() + spread_cd
    self.m_WorldChannelAdvertiseBtn:AddUIEvent("click", callback(self, "OnWorldChannelAdvertise", spread_cd))
end

function COrgRespondPart.OnUpdateRespondedStatus(self, callbackBase)
    local orgid = callbackBase.m_EventData.orgid
    -- printc("响应帮派界面：OnUpdateRespondedStatus, orgid = " .. orgid)
    self:UpdateOrgRespondedStatus(orgid)
end

function COrgRespondPart.OnCancelAllOrgRespond(self)
    for _, org in pairs(g_OrgCtrl.m_RespondOrgList) do
        self:UpdateOrgRespondStatus(org.orgid)
    end
end

function COrgRespondPart.UpdateOrgRespondStatus(self, orgid)
    -- 刷新响应按钮状态
    local org = g_OrgCtrl:GetRespondOrgById(orgid)
    if org.hasrespond == g_OrgCtrl.HAS_RESPOND_ORG then
        self.m_RespondJoinOrgBtn:SetActive(false)
        self.m_CancelRespondJoinOrgBtn:SetActive(true)
    else
        self.m_CancelRespondJoinOrgBtn:SetActive(false)
        self.m_RespondJoinOrgBtn:SetActive(true)
    end
    -- 刷新 item 图标
    local oOrg = self:GetRespondOrgItemById(orgid)
    if oOrg ~= nil then
        oOrg:UpdateResponded()
    end
end

function COrgRespondPart.UpdateOrgRespondedStatus(self, orgid)
    -- 刷新响应按钮状态
    local org = g_OrgCtrl:GetRespondOrgById(orgid)
    if org.hasrespond == g_OrgCtrl.HAS_RESPOND_ORG then
        self.m_RespondJoinOrgBtn:SetActive(false)
        self.m_CancelRespondJoinOrgBtn:SetActive(true)
    else
        self.m_CancelRespondJoinOrgBtn:SetActive(false)
        self.m_RespondJoinOrgBtn:SetActive(true)
    end
    
    -- 刷新 item 图标 & 响应人数
    local oOrg = self:GetRespondOrgItemById(orgid)
    if oOrg ~= nil then
        oOrg:UpdateResponded()
    end
end

function COrgRespondPart.GetRespondOrgItemById(self, orgid)
    local childList = self.m_Grid:GetChildList()
    -- -- printc("响应帮派界面 GetRespondOrgItemById, childList = ")
    -- table.print(childList)
    for _, oOrg in pairs(childList) do
        if oOrg.m_RespondOrgid == orgid then
            return oOrg
        end
    end
    return nil
end

function COrgRespondPart.SortFunc(orgA, orgB)
    if orgA ~= nil and orgB ~= nil then
        return orgA.createtime > orgB.createtime
    end
end

function COrgRespondPart.GetOrgIndex(self, tRespondOrg, oid)
    for index, org in pairs(tRespondOrg) do
        if org.orgid == oid then
            return index, org
        end
    end
    return nil, nil
end

function COrgRespondPart.RebuildRespondOrgList(self, tRespondOrg)
    -- 按创建时间排序
    if #tRespondOrg > 1 then
        table.sort(tRespondOrg, self.SortFunc)
    end

    -- 我的响应帮派置顶
    local myRespondOrgId = g_OrgCtrl:GetMyRespondOrgId()
    if myRespondOrgId ~= nil then
        local myOrgIndex, myOrg = self:GetOrgIndex(tRespondOrg, myRespondOrgId)
        if myOrgIndex ~= nil and myOrg ~= nil then
            table.remove(tRespondOrg, myOrgIndex)
            table.insert(tRespondOrg, 1, myOrg)
        end
    end
    -- self.m_Grid:Clear()

    if self.m_LoadTimer then
        Utils.DelTimer(self.m_LoadTimer)
        self.m_LoadTimer = nil
    end
    self.m_OrgCnt = #tRespondOrg
    self.m_LoadIndex = 1

    self.m_LoadTimer = Utils.AddTimer(callback(self, "LoadOrg", tRespondOrg), 1/30, 0)    
end

function COrgRespondPart.LoadOrg(self, tOrg)
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

function COrgRespondPart.ScrollToTop(self)
    self.m_ScrollView:ResetPosition()
    self.m_ScrollView:MoveRelative(Vector3.zero)
end

function COrgRespondPart.AddSingleOrgItem(self, respondOrg, idx)
    -- printc("响应帮派界面：填充单条 ScrollView item 数据，respondOrg = ")
    -- table.print(respondOrg)

    if respondOrg == nil then
        return
    end

    local oItem = self.m_Grid:GetChild(idx)
    if not oItem then
        oItem = self.m_ItemClone:Clone()
        oItem:SetGroup(self.m_Grid:GetInstanceID())
        self.m_Grid:AddChild(oItem)
    end
    oItem:SetCallback(function()
        self:ItemCallBack(respondOrg)
    end)
    oItem:SetActive(true)
    oItem:SetBoxInfo(respondOrg, idx)
end

function COrgRespondPart.ItemCallBack(self, respondOrg)
    if respondOrg == nil then
        return
    end

    -- 更新当前点击帮派 ID
    self.m_CurRespondOrgId = respondOrg.orgid

    -- 当前项显示 ToggleBG
    local orgItem = self:GetRespondOrgItemById(self.m_CurRespondOrgId)
    -- printc("响应帮派界面，点击 item, self.m_CurRespondOrgId = " .. self.m_CurRespondOrgId .. ", orgItem = " .. tostring(orgItem))
    if orgItem == nil then
        return
    end
    orgItem:SetSelected()

    -- 显示界面
    if g_AttrCtrl.org_status == COrgCtrl.ORG_STATUS_CREATE_RESPOND_ORG then  -- 我创建了帮派，正等待响应
        -- printc("显示宗旨 container：我创建了帮派，正等待响应, leaderid = " .. respondOrg.leaderid .. ", pid = " .. g_AttrCtrl.pid)
            if respondOrg.leaderid == g_AttrCtrl.pid then
            -- printc("点击自己的帮派")
            self:ShowOrgAimContainer(1)
        else
            -- printc("点击别人的帮派")
            self:ShowOrgAimContainer(2)
        end
    elseif g_AttrCtrl.org_status == COrgCtrl.ORG_STATUS_NO_ORG then          -- 我没有帮派
        -- printc("显示宗旨 container：我没有帮派")
        local org = g_OrgCtrl:GetRespondOrgById(self.m_CurRespondOrgId)
        if org.hasrespond == COrgCtrl.CANCEL_RESPOND_ORG then
            -- printc("我没有创建帮派，响应别人的帮派")
            self:ShowOrgAimContainer(3)
        else
            -- printc("我没有创建帮派，取消响应别人的帮派")
            self:ShowOrgAimContainer(4)
        end
    end

    -- 获取帮派宗旨
    -- printc("响应帮派界面，点击 orgID = " .. self.m_CurRespondOrgId .. "，获取帮派宗旨数据")
    -- netorg.C2GSReadyOrgInfo(self.m_CurRespondOrgId)
end

function COrgRespondPart.ShowOrgAimContainer(self, flag)
    -- printc("响应帮派界面，点击 orgID = " .. self.m_CurRespondOrgId .. "，显示 AimContainer")
    self.m_AimContainer:SetActive(true)

    if flag == 1 then       -- 我创建了帮派，点击自己的帮派
        self.m_RespondJoinOrgBtn:SetActive(false)
        self.m_CancelRespondJoinOrgBtn:SetActive(false)
        --self.m_CoolDownLabel:SetActive(true)
        self.m_WorldChannelAdvertiseBtn:SetActive(true)
        self.m_EnableWorldChannelAdvertise = true
        self.m_VitalityPerAdvertisementLabel:SetActive(true)
        self.m_OneClickRespondBtn:SetGrey(true)
    elseif flag == 2 then       -- 我创建了帮派，点击别人的帮派
        self.m_RespondJoinOrgBtn:SetActive(true)
        self.m_RespondJoinOrgBtn:SetGrey(true)
        self.m_CancelRespondJoinOrgBtn:SetActive(false)
        --self.m_CoolDownLabel:SetActive(true)
        self.m_WorldChannelAdvertiseBtn:SetActive(false)
        self.m_EnableWorldChannelAdvertise = false
        self.m_VitalityPerAdvertisementLabel:SetActive(true)
        self.m_OneClickRespondBtn:SetGrey(true)
    elseif flag == 3 then   -- 我没有创建帮派，响应别人的帮派
        self.m_CoolDownLabel:SetActive(false)
        self.m_WorldChannelAdvertiseBtn:SetActive(false)
        self.m_VitalityPerAdvertisementLabel:SetActive(false)
        self.m_CancelRespondJoinOrgBtn:SetActive(false)
        self.m_RespondJoinOrgBtn:SetActive(true)
    elseif flag == 4 then   -- 我没有创建帮派，取消响应别人的帮派
        self.m_CoolDownLabel:SetActive(false)
        self.m_WorldChannelAdvertiseBtn:SetActive(false)
        self.m_VitalityPerAdvertisementLabel:SetActive(false)
        self.m_RespondJoinOrgBtn:SetActive(false)
        self.m_CancelRespondJoinOrgBtn:SetActive(true)
    end
end

return COrgRespondPart