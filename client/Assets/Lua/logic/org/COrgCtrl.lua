local COrgCtrl = class("COrgCtrl", CCtrlBase)

COrgCtrl.HAS_APPLY_ORG = 1
COrgCtrl.CANCEL_APPLY_ORG = 0

COrgCtrl.HAS_RESPOND_ORG = 1
COrgCtrl.CANCEL_RESPOND_ORG = 0

COrgCtrl.ORG_STATUS_NO_ORG = 0
COrgCtrl.ORG_STATUS_CREATE_RESPOND_ORG = 1
COrgCtrl.ORG_STATUS_HAS_ORG = 2

COrgCtrl.LEADER_IS_MY_FRIEND = 1
COrgCtrl.LEADER_ISNOT_MY_FRIEND = 0

COrgCtrl.JOIN_ORG_SUCCESS = 1   -- 不区分是我创建帮派成功，还是我加入别人的帮派成功，反正就是我进入了一个帮派
COrgCtrl.JOIN_ORG_FAIL = 0

COrgCtrl.GET_ORG_MAIN_INFO_COMPLETE = 0  -- 包括帮派事件
COrgCtrl.GET_ORG_MAIN_INFO_SIMPLE = 1    -- 不包括帮派事件，仅包含一些经常变化的数据

COrgCtrl.BUILDING_STATUS = {
    UNBUILT = 0,
    BUILDING = 1, 
    BUILT = 2,
}

COrgCtrl.VERSION_OP_TYPE = {
    ADD = 1,
    UPDATE = 2, 
    DELETE = 3,
}

function COrgCtrl.ctor(self)
    CCtrlBase.ctor(self)
    self.m_OrgList = {}
    self.m_RespondOrgList = {}
    self.m_Org = {}
    self.m_CreateOrgTempName = ""   -- 下次进入“创建帮派”界面时，显示之前编辑过的名称
    self.m_CreateOrgTempAim  = ""   -- 下次进入“创建帮派”界面时，显示之前编辑过的宗旨
    self.m_OrgTempMail = ""  --保存编辑中邮件
    self.m_OrgPosList = {} --记录帮派各个位置总人数
    self.m_MemberDict = {}
    self.m_ApplyList = {}
    self.m_ApplyDict = {}
    self.m_InviteOrgInfo = {}
    self.m_LoginOrgRedPontInfo = {}
    self.m_OnlineMemberList = {}
    self.m_Buildings = {
        [101] = {bid = 101, level = 0, build_time = 0, quick_sec = 0, quick_num = 0, },
        [102] = {bid = 102, level = 0, build_time = 0, quick_sec = 0, quick_num = 0, },
        [103] = {bid = 103, level = 0, build_time = 0, quick_sec = 0, quick_num = 0, },
        [104] = {bid = 104, level = 0, build_time = 0, quick_sec = 0, quick_num = 0, },
        [105] = {bid = 105, level = 0, build_time = 0, quick_sec = 0, quick_num = 0, },
    }
    --客户端玩家选择的物品列表
    self.m_FloatItemList = nil
    self.m_OneClickLeftTimes = {}
    self.m_BuildStopLevel = 1 --珍宝阁默认1
    self.m_MaxBuildStopLevel = 6
    self.m_OrgListVersion = 0 --帮派列表版本号，0为默认最新
    self.m_MemberDictVersion = 0 --成员列表版本号
    self.m_CDTimer = nil
    self.m_LeftMailCD = 0
    self.m_LeftAimCD = 0
end

function COrgCtrl.Clear(self)
    self.m_Org = {}
    self.m_OrgList = {}
    self.m_MemberDict = {}
    self.m_ApplyList = {}
    self.m_ApplyDict = {}
    self.m_OrgListVersion = 0
    self.m_MemberDictVersion = 0
    self.m_IsInDungeonView = false
    self.m_LoginOrgRedPontInfo = {}
    self:StopCDTimer()
    self.m_LeftMailCD = 0
    self.m_LeftAimCD = 0
    self:UpdateOrgRedPoint()
end

function COrgCtrl.OpenOrgView(self)
    if g_AttrCtrl.org_status == COrgCtrl.ORG_STATUS_NO_ORG then
        -- CJoinOrgView:ShowView()
        COrgJoinOrRespondView:ShowView(function(oView)
            oView:ShowSubPageByIndex(1)
        end)
    elseif g_AttrCtrl.org_status == COrgCtrl.ORG_STATUS_CREATE_RESPOND_ORG then
        -- CRespondOrgView:ShowView()
        COrgJoinOrRespondView:ShowView(function(oView)
            oView:ShowSubPageByIndex(2)
        end)
    elseif g_AttrCtrl.org_status == COrgCtrl.ORG_STATUS_HAS_ORG then
        COrgInfoView:ShowView(function(oView)
            local info = g_OrgCtrl.m_LoginOrgRedPontInfo
            local iTab = oView:GetPageIndex("Info")
            if next(info) == nil then  -- 没有收到协议
                return
            end
            if info.apply_leader_pid ~= 0 and info.apply_leader_pid ~= g_AttrCtrl.pid then
                iTab = oView:GetPageIndex("Info")
            elseif info.has_apply == 1 then
                iTab = oView:GetPageIndex("Member")
                oView:ShowSubPageByIndex(iTab)
                oView.m_CurPage:ShowApplyList()
                return
            elseif info.sign_status == 0 or info.pos_status == 1 or info.bonus_status == 1 then
                iTab = oView:GetPageIndex("Welfare")
            elseif info.shop_status == 1 then
                iTab = oView:GetPageIndex("Building")
            end
            if iTab ~= 1 then
                oView:ShowSubPageByIndex(iTab)
            end
        end
        )
    end
end

function COrgCtrl.GetOrgById(self, oid)
    for _, org in pairs(self.m_OrgList) do
        if org.orgid == oid then
            return org
        end
    end
    return nil
end

function COrgCtrl.GetRespondOrgById(self, roid)
    for _, respondOrg in pairs(self.m_RespondOrgList) do
        if respondOrg.orgid == roid then
            return respondOrg
        end
    end
    return nil
end

function COrgCtrl.OnOrgJoinStatus(self, cviewbase, pbdata)
    -- local orgid = pbdata.orgid
    local success = pbdata.flag
    if success == COrgCtrl.JOIN_ORG_SUCCESS then
        cviewbase:OnClose()
        COrgInfoView:ShowView()
    end
end

function COrgCtrl.CreateRespondOrgSuccess(self)
    self:ClearCreateOrgTempInfo()
    CCreateOrgView:OnClose()
    -- CJoinOrgView:OnClose()
    -- CRespondOrgView:ShowView()
    COrgJoinOrRespondView:ShowView(function(oView)
        oView:ShowSubPageByIndex(2)
    end)
    self:ClearBuildInfo()
end

function COrgCtrl.JoinOrgResult(self)
    if g_AttrCtrl.org_status == COrgCtrl.ORG_STATUS_HAS_ORG then
        -- CJoinOrgView:OnClose()
        -- CRespondOrgView:OnClose()
        COrgJoinOrRespondView:CloseView()
        COrgInfoView:ShowView()
        self:ClearBuildInfo()
    end
end

function COrgCtrl.GetBuildInfo(self, id)
    return self.m_Buildings[id]
end

function COrgCtrl.ClearBuildInfo(self)
    for j, c in pairs(self.m_Buildings) do
        for k, v in pairs(c) do
            if k ~= "bid" then
                self.m_Buildings[j][k] = 0
            end
        end
    end
end

function COrgCtrl.ClearCreateOrgTempInfo(self)
    -- printc("COrgCtrl 清空临时帮派名称和宗旨")
    self.m_CreateOrgTempName = ""
    self.m_CreateOrgTempAim = ""
end

function COrgCtrl.SaveCreateOrgTempInfo(self, tempName, tempAim)
    -- printc("COrgCtrl 保存临时帮派名称和宗旨, tempName = " .. tempName .. ", tempAim = " .. tempAim)
    self.m_CreateOrgTempName = tempName
    self.m_CreateOrgTempAim = tempAim
end

function COrgCtrl.GetCreateOrgTempInfo(self)
    -- printc("COrgCtrl 获取临时帮派名称和宗旨")
    return self.m_CreateOrgTempName, self.m_CreateOrgTempAim
end

function COrgCtrl.SaveOrgTempMail(self, tempMail)
    self.m_OrgTempMail = tempMail
end

function COrgCtrl.GetOrgTempMail(self)
    return self.m_OrgTempMail
end

function COrgCtrl.UpdateOrgList(self, infos, version, bIsUpdate)
    printc("COrgCtrl 更新帮派列表", version, bIsUpdate, #infos)
    -- 保存完整列表
    self.m_OrgListVersion = version
    if not bIsUpdate then
        self.m_OrgList = table.copy(infos)
    else
        self:UpdateOrgListVersion(infos)
    end
    self:OnEvent(define.Org.Event.GetOrgList, self.m_OrgList)
end

function COrgCtrl.UpdateOrgListVersion(self, infos)
    local dOrgList = {}
    for i,dOrg in ipairs(infos) do
        dOrgList[dOrg.orgid] = dOrg
    end
    local iCnt = #self.m_OrgList
    for i=iCnt, 1, -1 do
        local dOrg = self.m_OrgList[i]
        local iOrgId = dOrg.orgid
        local dNewOrg = dOrgList[iOrgId]
        local bIsDel = dNewOrg and dNewOrg.optype == COrgCtrl.VERSION_OP_TYPE.DELETE
        local bIsUpdate = dNewOrg and dNewOrg.optype == COrgCtrl.VERSION_OP_TYPE.UPDATE
        local bIsAdd = dNewOrg and dNewOrg.optype == COrgCtrl.VERSION_OP_TYPE.ADD
        if bIsDel then
            table.remove(self.m_OrgList, i)
        end
        if bIsUpdate or bIsAdd then
            self.m_OrgList[i] = dNewOrg
        end
        if bIsDel or bIsUpdate or bIsAdd then
            dOrgList[iOrgId] = nil 
        end
    end
    for _,dOrg in pairs(dOrgList) do
        if dOrg ~= nil and (dOrg.optype == COrgCtrl.VERSION_OP_TYPE.UPDATE or 
            dOrg.optype == COrgCtrl.VERSION_OP_TYPE.ADD) then
            table.insert(self.m_OrgList, dOrg)
        end
    end
end

function COrgCtrl.UpdateOrgAim(self, pbdata)
    -- printc("COrgCtrl 更新帮派宗旨，ID = " .. pbdata.orgid .. ", 宗旨 = " .. pbdata.aim)
    local org = self:GetOrgById(pbdata.orgid)
    if org ~= nil then
        org.aim = pbdata.aim
    end
    self:OnEvent(define.Org.Event.GetOrgAim, pbdata)
end

function COrgCtrl.UpdateSearchResultList(self, infos)
    self:OnEvent(define.Org.Event.GetSearchResultList, infos)
end

function COrgCtrl.UpdateAppliedOrg(self, pbdata, bNotFloat)
    -- printc("COrgCtrl 更新帮派申请状态，ID = " .. pbdata.orgid .. ", flag = " .. pbdata.flag)
    local org = self:GetOrgById(pbdata.orgid)
    if org ~= nil then
        org.hasapply = pbdata.flag
    end
    --printc(data.orgdata.TEXT[1119].content)
    if not bNotFloat then
        if pbdata.flag == 1 then
            g_NotifyCtrl:FloatMsg(data.orgdata.TEXT[1119].content)
        else
            g_NotifyCtrl:FloatMsg(data.orgdata.TEXT[1132].content) 
        end
    end
    self:OnEvent(define.Org.Event.GetAppliedOrg, pbdata)
end

function COrgCtrl.UpdateOneClickAppliedOrgs(self, pbdata)
    self:UpdateOneClickApplyCoolDown(pbdata.left_time)
    if pbdata.left_time > 0 then
        self:SetOneClickApplyCountTime(pbdata.left_time)
    end
    for _, oid in pairs(pbdata.orgids) do
        local pbdata = {
            orgid = oid,
            flag = COrgCtrl.HAS_APPLY_ORG,
        }
        self:UpdateAppliedOrg(pbdata, true)
    end
    if pbdata.orgids and next(pbdata.orgids) then
        g_NotifyCtrl:FloatMsg(data.orgdata.TEXT[1119].content)
    end
end

function COrgCtrl.UpdateOneClickApplyCoolDown(self, left_time)
    self:OnEvent(define.Org.Event.UpdateOneClickApplyCoolDown, left_time)
end

--一键申请的倒计时
function COrgCtrl.SetOneClickApplyCountTime(self, left_time) 
    self:ResetOneClickApplyTimer()
    local pid = g_AttrCtrl.pid
    local function progress()
        self.m_OneClickLeftTimes[pid] = self.m_OneClickLeftTimes[pid] - 1

        self:OnEvent(define.Org.Event.OneClickTime)
        
        if self.m_OneClickLeftTimes[pid] <= 0 then
            self.m_OneClickLeftTimes[pid] = 0

            self:OnEvent(define.Org.Event.OneClickTime)

            return false
        end
        return true
    end
    self.m_OneClickLeftTimes[pid] = left_time + 1
    self.m_OneClickTimer = Utils.AddTimer(progress, 1, 0)
end

function COrgCtrl.ResetOneClickApplyTimer(self)
    if self.m_OneClickTimer then
        Utils.DelTimer(self.m_OneClickTimer)
        self.m_OneClickTimer = nil           
    end
end

function COrgCtrl.IsInOneKeyApply(self)
    local iLeftTime = self.m_OneClickLeftTimes[g_AttrCtrl.pid]
    return iLeftTime and iLeftTime > 0
end

function COrgCtrl.ApplyJoinOrg(self, orgid)
    if g_AttrCtrl.org_status == COrgCtrl.ORG_STATUS_CREATE_RESPOND_ORG then
        g_NotifyCtrl:FloatMsg(data.orgdata.TEXT[1003].content)
        return
    end
    netorg.C2GSApplyJoinOrg(orgid, COrgCtrl.HAS_APPLY_ORG)
end

function COrgCtrl.CancelAllOrgApply(self)
    for _, org in pairs(self.m_OrgList) do
        org.hasapply = COrgCtrl.CANCEL_APPLY_ORG
    end
    self:OnEvent(define.Org.Event.CancelAllOrgApply)
end

function COrgCtrl.CancelAllOrgRespond(self)
    for _, org in pairs(self.m_RespondOrgList) do
        org.hasrespond = COrgCtrl.CANCEL_RESPOND_ORG
    end
    self:OnEvent(define.Org.Event.CancelAllOrgRespond)
end

function COrgCtrl.UpdateOrgJoinStatus(self, pbdata)
    self:OnEvent(define.Org.Event.GetOrgJoinStatus, pbdata)    
end

function COrgCtrl.UpdateRespondOrgList(self, infos)
    -- printc("COrgCtrl 更新响应帮派列表")
    self.m_RespondOrgList = infos
    self:OnEvent(define.Org.Event.GetRespondOrgList, infos)
end

function COrgCtrl.UpdateRespondOrgInfo(self, pbdata)
    local orgid = pbdata.orgid
    local aim = pbdata.aim
    local left_time = pbdata.left_time --响应剩余时间
    local spread_cd = pbdata.spread_cd --世界宣传cd

    local oRespondOrg = self:GetRespondOrgById(orgid)
    if oRespondOrg ~= nil then
        oRespondOrg.aim = aim
        oRespondOrg.left_time = left_time
        oRespondOrg.spread_cd = spread_cd
    end
    self:OnEvent(define.Org.Event.GetRespondOrgInfo, pbdata)
end

function COrgCtrl.UpdateRespondedOrg(self, pbdata)
    local org = self:GetRespondOrgById(pbdata.orgid)
    if org ~= nil then
        org.hasrespond = pbdata.flag
        org.respondcnt = pbdata.respondcnt
    end
    self:OnEvent(define.Org.Event.GetRespondedOrg, pbdata)
end

function COrgCtrl.UpdateInviteInfo(self,pbdata)
    self.m_InviteOrgInfo = {}
    table.update(self.m_InviteOrgInfo,pbdata)
    if not self.m_IsInDungeonView then
        local view = CMainMenuView:GetView()
        if view then
            view.m_RB.m_QuickMsgBox:RefreshOrgInviteBtn(true)
        end
    else
        self:OnEvent(define.Org.Event.ReceiveInvite, pbdata)
    end
    --g_NotifyCtrl:ShowInviteOrgInfo() 
end

function COrgCtrl.UpdateOrgMainInfo(self, dict)
    for k, v in pairs(dict) do
        self.m_Org[k] = v
    end
    self:StartCDTimer()
    self:OnEvent(define.Org.Event.GetOrgMainInfo)
end

function COrgCtrl.UpdateMemberList(self, infos, bIsUpdate)
    --printerror("UpdateMemberList")
    if not bIsUpdate then
        self.m_MemberDict = {}
        for i,v in ipairs(infos) do
            self.m_MemberDict[v.pid] = v
        end
    else
        self:UpdateMemberListVersion(infos)
    end

    self.m_OrgPosList = {}
    for k,v in pairs(self.m_MemberDict) do
        if v.offline == 0 then     --排序使用的时间差
            v.difftime = 0 
        else
            v.difftime = os.difftime(g_TimeCtrl:GetTimeS(), v.offline)
        end
        if self.m_OrgPosList[v.position] == nil then
            self.m_OrgPosList[v.position] = 0
        end
        self.m_OrgPosList[v.position] = self.m_OrgPosList[v.position] + 1
    end
    self:OnEvent(define.Org.Event.GetMemeberList)
end

function COrgCtrl.UpdateMemberListVersion(self, infos)
    local dMemberInfos = {}
    for i,dMember in ipairs(infos) do
        dMemberInfos[dMember.pid] = dOrg
    end
    for iPid,dMember in pairs(self.m_MemberDict) do
        local dNewMember = dMemberInfos[iPid]
        local bIsDel = dNewMember and dNewMember.optype == COrgCtrl.VERSION_OP_TYPE.DELETE
        local bIsUpdate = dNewMember and dNewMember.optype == COrgCtrl.VERSION_OP_TYPE.UPDATE
        local bIsAdd = dNewMember and dNewMember.optype == COrgCtrl.VERSION_OP_TYPE.ADD
        if bIsDel then
            --printc("remove",iPid)
            self.m_MemberDict[iPid] = nil
        end
        if bIsUpdate or bIsAdd then
            --printc("add",iPid)
            self.m_MemberDict[iPid] = dNewMember
        end
        if bIsDel or bIsUpdate or bIsAdd then
            dMemberInfos[iPid] = nil 
        end
    end

    for _,dMember in pairs(dMemberInfos) do
        if dMember ~= nil and (dMember.optype == COrgCtrl.VERSION_OP_TYPE.UPDATE or 
            dMember.optype == COrgCtrl.VERSION_OP_TYPE.ADD) then
            --printc("add other",iPid)
            self.m_MemberDict[iPid] = dMember
        end
    end
end

function COrgCtrl.DelMember(self, iPid)
    local member = self.m_MemberDict[iPid]
    if member then
        self.m_OrgPosList[member.position] = self.m_OrgPosList[member.position] - 1 
    end
    self.m_MemberDict[iPid] = nil
    self:OnEvent(define.Org.Event.DelMember, iPid)
end

function COrgCtrl.GetMemeberList(self)
    local list = {}
    for k,member in pairs(self.m_MemberDict) do
        table.insert(list, member)
    end
    return list
end

function COrgCtrl.SetMemberPosition(self, iPid, iPos)
    local member = self.m_MemberDict[iPid]
    if member == nil then
        return
    end
    self.m_OrgPosList[member.position] = self.m_OrgPosList[member.position] - 1
    member.position = iPos
    self.m_MemberDict[iPid] = member
    if self.m_OrgPosList[iPos] == nil then
        self.m_OrgPosList[iPos] = 0
    end
    self.m_OrgPosList[iPos] = self.m_OrgPosList[iPos] + 1
    self:OnEvent(define.Org.Event.ChangePosition, {pid = iPid, pos = iPos})
end

function COrgCtrl.UpdateApplyList(self, infos)
    self.m_ApplyList = table.copy(infos)
    self.m_ApplyDict = {}
    for k,v in ipairs(infos) do
        self.m_ApplyDict[v.pid] = true
    end   
    self:OnEvent(define.Org.Event.GetApplyList)
end

function COrgCtrl.DelApply(self, pids)
    for k,pid in pairs(pids) do
        self.m_ApplyDict[pid] = false
    end
    self:OnEvent(define.Org.Event.DelApply, pids)
end

function COrgCtrl.GetApplyList(self)
    local list = {}
    for k,player in ipairs(self.m_ApplyList) do
        if self.m_ApplyDict[player.pid] then
            table.insert(list, player)
        end
    end
    return list
end

function COrgCtrl.GetMemberAmountByPos(self, iPos)
    return self.m_OrgPosList[iPos] or 0
end

--判断是否为帮派管理员（即长老及以上）
function COrgCtrl.IsManager(self, iPid)
    if not self.m_MemberDict[iPid] then
        return false
    end
    return self.m_MemberDict[iPid].position <= 3
end

--判断是否为帮派成员
function COrgCtrl.IsInOrg(self, iPid)
    return self.m_MemberDict[iPid] ~= nil
end

function COrgCtrl.IamInOrg(self)
    return g_AttrCtrl.org_status == COrgCtrl.ORG_STATUS_HAS_ORG
end

function COrgCtrl.HasOrg(self, showFloatMsg)
    if g_AttrCtrl.org_status == COrgCtrl.ORG_STATUS_CREATE_RESPOND_ORG or g_AttrCtrl.org_status == COrgCtrl.ORG_STATUS_HAS_ORG then
        if showFloatMsg then
            g_NotifyCtrl:FloatMsg(data.orgdata.TEXT[1021].content)
        end
        return true
    end
    return false
end

function COrgCtrl.HasApplyOtherOrg(self)
    for _, org in pairs(self.m_OrgList) do
        if org ~= nil and org.hasapply == COrgCtrl.HAS_APPLY_ORG then
            return true
        end
    end
    return false
end

function COrgCtrl.HasRespondOtherOrg(self)
    for _, org in pairs(self.m_RespondOrgList) do
        if org ~= nil and org.hasrespond == self.HAS_RESPOND_ORG then
            return true
        end
    end
    return false
end

function COrgCtrl.DelRespondOrgList(self, orgids)
    for _, orgid in pairs(orgids) do
        for index, respondOrg in pairs(self.m_RespondOrgList) do
            if respondOrg.orgid == orgid then
                table.remove(self.m_RespondOrgList, index)
                break
            end
        end
    end
    self:OnEvent(define.Org.Event.DelRespondOrgList)
end

function COrgCtrl.DelOrgList(self, orgids)
    for _, orgid in pairs(orgids) do
        for index, org in pairs(self.m_OrgList) do
            if org.orgid == orgid then
                table.remove(self.m_OrgList, index)
                break
            end
        end
    end
    self:OnEvent(define.Org.Event.DelOrgList)
end

function COrgCtrl.GetMyRespondOrgId(self)
    for _, org in pairs(self.m_RespondOrgList) do
        if org.leaderid == g_AttrCtrl.pid then
            return org.orgid
        end
    end
    return nil
end

function COrgCtrl.ConvertSecondsHHMMSS(self, seconds)
    local mins = math.floor(seconds / 60)
    local HH = math.floor(mins / 60)
    local MM = mins - HH * 60
    local SS = seconds - MM * 60 - HH * 3600
    return string.format("%02d", HH), string.format("%02d", MM), string.format("%02d", SS)
end

-- 转换秒数为格式“HH:MM”的字符串
function COrgCtrl.ConvertSecondsStr(self, seconds)
    -- seconds = seconds + 59   -- 为了显示 00:00 时让玩家认为是到时间了，所以往前移了一分钟
    local HH, MM = self:ConvertSecondsHHMMSS(seconds)
    if HH == "00" then
        return MM..":00"
    end
    return HH .. ":" .. MM
end

-- 转换秒数为格式“HH小时MM分钟”的字符串
function COrgCtrl.ConvertSecondsStrV2(self, seconds)
    local sHH, sMM = self:ConvertSecondsHHMMSS(seconds)
    local HH = tonumber(sHH)
    local MM = tonumber(sMM)

    local str = ""
    if HH > 0 then
        if HH > 24 then
            local day = HH/24
            HH = HH%24
            if HH > 0 then
                str = string.format("%d天%d小时", day, HH)
            else
                str = string.format("%d天", day)
            end
        else
            str = str .. HH .. "小时"
        end
    end
    if MM > 0 then
        str = str .. MM .. "分钟"
    end
    return str
end

function COrgCtrl.GetRespondSearchResult(self, searchText)
    local tResult = {}
    -- 遍历所有帮派 ID，看是否包含 searchText
    for k, org in pairs(self.m_RespondOrgList) do
        local startIdx, endIdx = string.find(org.showid, searchText)
        if startIdx ~= nil and endIdx ~= nil then
            tResult[k] = org
        end
    end
    -- 遍历所有帮派 name，看是否包含 searchText
    for k, org in pairs(self.m_RespondOrgList) do
        local startIdx, endIdx = string.find(org.name, searchText)
        if startIdx ~= nil and endIdx ~= nil then
            tResult[k] = org
        end
    end
    return tResult
end

function COrgCtrl.OnOrgStatusChange(self, oAttrCtrl)
    local dAttr = oAttrCtrl.m_EventData.dAttr
    local dPreAttr = oAttrCtrl.m_EventData.dPreAttr

    if dAttr.org_status
        and dPreAttr.org_status
        and dAttr.org_status == COrgCtrl.ORG_STATUS_HAS_ORG
        and dAttr.org_status ~= dPreAttr.org_status then
        self:JoinOrgResult()
    end
end

function COrgCtrl.GetEverydayMaintainConsume(self)
    local sFormula = data.orgdata.OTHERS[1].daily_maintain_consume
    -- -- printc("sFormula = " .. sFormula)

   --local splitFormula = string.split(sFormula, '=')[2]
    -- -- printc("splitFormula = " .. splitFormula)

    --local sOrgLevel = string.split(splitFormula, '*')[1]
    -- -- printc("sOrgLevel = " .. sOrgLevel)

    local formula = string.gsub(sFormula, "org_lv", self.m_Org.level)
    -- -- printc("formula = " .. formula)

    local func = loadstring("return " .. formula)
    -- -- printc(func())
    -- -- printc(type(func()))

    return func()
end

function COrgCtrl.CanEditOrgAim(self)
    local pos = self.m_Org.info.position
    local canEdit = data.orgdata.POSITIONAUTHORITY[pos].edit_aim
    return canEdit == 1
end

function COrgCtrl.UpdateSelfApplyResult(self, pbdata)
    self.m_Org.applyname = pbdata.applyname
    self.m_Org.applyschool = pbdata.applyschool
    self.m_Org.applylefttime = pbdata.applylefttime
    self.m_Org.applypid = pbdata.applypid
    self.m_Org.canapplyleader = pbdata.canapplyleader

    self:OnEvent(define.Org.Event.GetOrgMainInfo)
end

function COrgCtrl.UpdateRespondOrgCD(self, pbdata)
    self:OnEvent(define.Org.Event.UpdateRespondOrgCD, pbdata)
end

function COrgCtrl.ContainsMaskWordAndHighlight(self, str, cinput, coverLabel, sHint)

    -- 获取 str CharList
    local charList = g_MaskWordCtrl:GetCharList(str)  
    -- 获取 reaplceStr CharList
    local reaplceStr = g_MaskWordCtrl:ReplaceMaskWord(str, true)
    local charList2 = g_MaskWordCtrl:GetCharList(reaplceStr)
    -- printc("reaplceStr charList2")
    -- table.print(charList2)

    -- 比较 CharList & CharList2，看是否有敏感词
    local contained = false
    local startIdx = 0
    local endIdx = 0
    for i = 1, #charList do  -- 替换时参数为 true 保证了 charList, charList2 长度相等
        if charList[i] ~= charList2[i] then  -- 被替换了，记录 startIdx, endIdx
            contained = true
            if startIdx == 0 then
                startIdx = i
            end
        else
            if startIdx > 0 then
                endIdx = i - 1
                break
            end
        end
    end
    if startIdx > 0 and endIdx == 0 then  -- 敏感词在末尾
        endIdx = #charList
    end

    -- 有敏感词，替换并飘字提示
    if contained then
        -- printc("有敏感词, [" .. startIdx .. ", " .. endIdx .. "]")
        g_NotifyCtrl:FloatMsg(sHint)
        local coloredStr = ""
        for i = 1, #charList do
            if i == startIdx then
                coloredStr = coloredStr .. "#R" .. charList[i]  -- 敏感词替换为红色
            elseif i == endIdx then
                coloredStr = coloredStr .. charList[i] .. "#n"
            else
                coloredStr = coloredStr .. charList[i]
            end
        end
        coloredStr = "[c][896055FF]" .. coloredStr .. "[-]"

        cinput.activeTextColor = Color.clear
        coverLabel:SetColor(Color.white)
        coverLabel:SetText(coloredStr)
        return true
    end
    return false
end

function COrgCtrl.UpdateOrgRespondNum(self, infos)
    for _, info in pairs(infos) do
        local org = self:GetRespondOrgById(info.orgid)
        if org ~= nil then
            org.respondcnt = info.respondcnt
            self:OnEvent(define.Org.Event.UpdateOrgRespondNum, info)
        end
    end
end

function COrgCtrl.UpdateOrgRedPoint(self)
    self:OnEvent(define.Org.Event.UpdateOrgRedPoint)
end

function COrgCtrl.SetOnlineMemeberList(self, list)
    self.m_OnlineMemberList = list
    self:OnEvent(define.Org.Event.GetOnlineMemberList)
end

function COrgCtrl.DelOnlineMember(self, iPid)
    for i,dMember in ipairs(self.m_OnlineMemberList) do
        if dMember.pid == iPid then
            table.remove(self.m_OnlineMemberList, i)
            break
        end
    end
end

function COrgCtrl.GetOnlineMemberList(self)
    local list = {}
    for k,dMember in ipairs(self.m_OnlineMemberList) do
        table.insert(list, dMember)
    end
    local sort = function(d1, d2)
        if d1.grade ~= d2.grade then
            return d1.grade > d2.grade
        else
            return d1.school < d2.school 
        end
    end
    table.sort(list, sort)
    return list
end

function COrgCtrl.IamLeader(self)
    return self:IamPos(1)
end

function COrgCtrl.IamViceLeader(self)
    return self:IamPos(2)
end

function COrgCtrl.IamXuetu(self)
    return self:IamPos(7)
end

-- 我是否某个职位
function COrgCtrl.IamPos(self, posid)
    if self:HasOrg() then
        local mypos = self.m_Org.info.position
        return mypos ~= nil and mypos == data.orgdata.POSITIONID[posid].id
    else
        return false
    end
end

function COrgCtrl.ShowBuildingTreasureShop(self, info)
    local view = COrgInfoView:GetView()
    if view then
        view:CloseRPanel()
        view.m_BuildingPart:ShowTreasureShop(info)
    end
end

function COrgCtrl.CloseBuildingTreasureRoom(self)
    local view = COrgInfoView:GetView()
    if view then
        view:ShowRPanel()
        view.m_BuildingPart:CloseTreasureRoomBox()
    end
end

function COrgCtrl.UpdateBuildingInfos(self, infos)
    for _, info in pairs(infos) do
        for k,v in pairs(self.m_Buildings[info.bid]) do
            self.m_Buildings[info.bid][k] = info[k]
        end
    end
    self:OnEvent(define.Org.Event.UpdateOrgBuildingInfos, self.m_Buildings)
end

-- 计算建筑的建造状态：未建造、建造中、已建造
function COrgCtrl.GetBuildingStatus(self, building)
    if building.level > 0 then
        return self.BUILDING_STATUS.BUILT
    else
        if building.build_time > 0 then
            return self.BUILDING_STATUS.BUILDING
        else
            return self.BUILDING_STATUS.UNBUILT
        end
    end
end

function COrgCtrl.IsBuilt(self, building)
    return self:GetBuildingStatus(building) == self.BUILDING_STATUS.BUILT
end

function COrgCtrl.IsBuilding(self, building)
    return self:GetBuildingStatus(building) == self.BUILDING_STATUS.BUILDING
end

function COrgCtrl.IsUnbuilt(self, building)
    return self:GetBuildingStatus(building) == self.BUILDING_STATUS.UNBUILT
end

function COrgCtrl.CalculateTime(self, needTime, build_time, buildSlider, callback)
    local passTime = g_TimeCtrl:GetTimeS() - build_time
    if passTime >= needTime then
        if callback then
            callback()
        end
        return false
    end 
    local h, m, s = self:ConvertSecondsHHMMSS(needTime-passTime)
    return h..":"..m..":"..s, passTime/needTime
end

function COrgCtrl.PlayEffect(self, parent, startPos, endPos)
    printc("播放特效")
    local effect = CEffect.New("Effect/UI/ui_eff_1007/Prefabs/ui_eff_1007_04.prefab", parent:GetLayer())
	effect:SetParent(parent.m_Transform)
    effect:SetPos(startPos)
    --local tweenScale = DOTween.DOScale(self.m_Effect.m_Transform, Vector3.New(0,0,0), 0.5)
	--DOTween.SetDelay(tweenScale, 0.3)
    --DOTween.OnComplete(tweenScale, function()
    local tween = DOTween.DOMove(effect.m_Transform, endPos, 0.7, false)
    DOTween.OnComplete(tween, function() 
        effect:Destroy()
        effect = nil 
    end)
    --end)
end

function COrgCtrl.FormatTime(self, time)
    local hour = math.floor(time/3600)
    local minute = math.fmod(math.floor(time/60), 60)
    local second = math.fmod(time, 60)
    local rtTime = string.format("%s:%s:%s",hour, minute, second)
    return rtTime
end

function COrgCtrl.SetOrgTaskReward(self, iExp, iOrgOffer, lItem)
    self.m_OrgTaskReward = {
        exp = iExp,
        orgoffer = iOrgOffer,
        itemlist = lItem,
    }
end

function COrgCtrl.SetOrgStarReward(self, iExp, iOrgOffer, lItem)
    self.m_OrgStarReward = {
        exp = iExp,
        orgoffer = iOrgOffer,
        itemlist = lItem,
    }
end

function COrgCtrl.GetOrgTaskReward(self)
    return self.m_OrgTaskReward
end

function COrgCtrl.GetOrgStarReward(self)
    return self.m_OrgStarReward
end

function COrgCtrl.GS2CBuyItemResult(self)
    self:OnEvent(define.Org.Event.BuyItemResult)
end

function COrgCtrl.GS2COrgRefreshShopUnit(self, iItemId, iBuyCnt)
    self:OnEvent(define.Org.Event.BuyItemResult, {item = iItemId, cnt = iBuyCnt})
end

function COrgCtrl.GS2CGetAchieveInfo(self, data)
    local view = COrgInfoView:GetView()
    if view then
        view:CloseRPanel()
        view.m_WelfarePart:ShowGoalBox(data)
    end
end

function COrgCtrl.GS2CGetBoonInfo(self, info)
    local view = COrgInfoView:GetView()
    if view then
        view.m_WelfarePart:InitContent(info)
    end
end

function COrgCtrl.GS2CUpdateAchieveInfo(self, achieve)
    self:OnEvent(define.Org.Event.UpdateAchieveInfo, achieve)
end

function COrgCtrl.GS2CAddHistoryLog(self, info)
    if not self.m_Org.historys then
        return
    end
    table.insert(self.m_Org.historys, 1, info)
    printc("添加历史事件")
    self:OnEvent(define.Org.Event.AddHistoryLog, info)
end

function COrgCtrl.GS2CNextPageLog(self, infos)
    for k,v in pairs(infos) do
        table.insert(self.m_Org.historys, v)
    end
    self:OnEvent(define.Org.Event.NextPageLog, infos)
end

function COrgCtrl.GS2CChatBan(self, id, flag)
    local infos = {pid = id, flag = flag}
    self:OnEvent(define.Org.Event.UpdateChatBan, infos)
end

function COrgCtrl.GS2COpenOrgTaskUI(self, task, starlist, ringcnt, star, bout, pretaskinfo)
    COrgTaskView:ShowView(function(oView)
        oView:InitTaskInfo(task, starlist, ringcnt, star, bout, pretaskinfo)
    end)
end

function COrgCtrl.GS2CUpdateOrgTask(self, task, star, ringcnt, pretaskinfo)
    local infos = {task = task, star = star, ringcnt = ringcnt, pretaskinfo = pretaskinfo}
    self:OnEvent(define.Org.Event.UpdateOrgTask, infos)
end

function COrgCtrl.C2GSGetBuildInfo(self)
    netorg.C2GSGetBuildInfo()
end

function COrgCtrl.C2GSUpGradeBuild(self, bid)
    netorg.C2GSUpGradeBuild(bid)
end

function COrgCtrl.C2GSQuickBuild(self, bid, quickId)
    netorg.C2GSQuickBuild(bid, quickId)
end  

function COrgCtrl.C2GSGetShopInfo(self)
    netorg.C2GSGetShopInfo()
end

function COrgCtrl.C2GSBuyItem(self, id, cnt)
    netorg.C2GSBuyItem(id, cnt)
end

function COrgCtrl.C2GSGetBoonInfo(self)
    netorg.C2GSGetBoonInfo()
end

function COrgCtrl.C2GSEnterOrgScene(self)
    netorg.C2GSEnterOrgScene()
end

function COrgCtrl.C2GSNextPageLog(self)
    local id = self.m_Org.historys[#self.m_Org.historys].logid
    netorg.C2GSNextPageLog(id)
end

function COrgCtrl.GetBuildShop(self, level)
    local data = data.orgdata.BUILDSHOP
    local t ={}
    for _,v in pairs(data) do
        if v.level == level then
            table.insert(t, v)
        end
    end
    return t 
end

function COrgCtrl.GS2COrgFaneActiveInfo(self, lInfo)
    self:OnEvent(define.Org.Event.GetActivityInfo, lInfo)
end

function COrgCtrl.GS2COrgTaskCleanStarlist(self)
    self:OnEvent(define.Org.Event.CleanTaskStar)
end

function COrgCtrl.GS2CSetAutoJoin(self, bIsAutoAccept)
    self.m_IsAutoAccpet = bIsAutoAccept
    self:OnEvent(define.Org.Event.SetAutoAccept, bIsAutoAccept)
end

function COrgCtrl.GS2COrgPrestigeInfo(self, iMyRank, iMyPrestige)
    self.m_MyPrestigeRank = iMyRank
    self.m_MyPrestige = iMyPrestige
    self:OnEvent(define.Org.Event.UpdatePrestige)
end

function COrgCtrl.StartCDTimer(self)
    local iMailCD = self.m_Org.left_mail_cd ~= nil and self.m_Org.left_mail_cd or 0
    local iAimCD = self.m_Org.left_aim_cd ~= nil and self.m_Org.left_aim_cd or 0
    self.m_LeftMailCD = iMailCD
    self.m_LeftAimCD = iAimCD
    if iMailCD == 0 and iAimCD == 0 then
        return
    end
    local function update( ... )
        iMailCD = iMailCD - 1
        iAimCD = iAimCD - 1
        if iMailCD == 0 or iAimCD == 0 then
            self:OnEvent(define.Org.Event.GetOrgMainInfo)
        end
        self.m_LeftMailCD = iMailCD >= 0 and iMailCD or 0 
        self.m_LeftAimCD = iAimCD >= 0 and iMailCD or 0
        if iMailCD > 0 or iAimCD > 0 then
            return true
        end
    end
    self:StopCDTimer()
    Utils.AddTimer(update, 1, 1)
end

function COrgCtrl.StopCDTimer(self)
    if self.m_CDTimer then
        Utils.DelTimer(self.m_CDTimer)
        self.m_CDTimer = nil
    end
end
return COrgCtrl