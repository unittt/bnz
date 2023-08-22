local COrgInfoPart = class("COrgInfoPart", CPageBase)

function COrgInfoPart.ctor(self, cb)
    CPageBase.ctor(self, cb)

    self.m_NameLabel                  = self:NewUI( 1, CLabel)
    self.m_LevelLabel                 = self:NewUI( 2, CLabel)
    self.m_IDLabel                    = self:NewUI( 3, CLabel)
    self.m_LeaderHeadSprite           = self:NewUI( 4, CSprite)
    self.m_LeaderNameLabel            = self:NewUI( 5, CLabel)
    self.m_NumFormalMemberLabel       = self:NewUI( 6, CLabel)
    self.m_XuetuISprite               = self:NewUI( 7, CSprite)
    self.m_NumXuetuLabel              = self:NewUI( 8, CLabel)
    self.m_CashLabel                  = self:NewUI( 9, CLabel)
    self.m_MailBtn                    = self:NewUI(10, CSprite)
    self.m_BoomValLabel               = self:NewUI(11, CLabel)
    self.m_Grid                       = self:NewUI(12, CGrid)
    self.m_ItemClone                  = self:NewUI(13, COrgEventItem)
    self.m_AimLabel                   = self:NewUI(14, CLabel)
    self.m_CurBanggongLabel           = self:NewUI(15, CLabel)
    self.m_JobLabel                   = self:NewUI(16, CLabel)
    self.m_HistoryBanggongLabel       = self:NewUI(17, CLabel)
    self.m_TodayActiveLabel           = self:NewUI(18, CLabel)
    self.m_SelfRecommendLeaderBtn     = self:NewUI(19, CSprite)
    self.m_BackToCampBtn              = self:NewUI(20, CSprite)
    self.m_FormalMemberBG             = self:NewUI(21, CSprite)
    self.m_XuetuBG                    = self:NewUI(22, CSprite)
    self.m_XuetuIBtn                  = self:NewUI(23, CButton)
    self.m_SelfRecommendInfoContainer = self:NewUI(24, CWidget)
    self.m_CloseSelfRecommendBtn      = self:NewUI(25, CButton)
    self.m_LeftTimeLabel              = self:NewUI(26, CLabel)
    self.m_SelfRecommendSchoolSprite  = self:NewUI(27, CSprite)
    self.m_SelfRecommendNameLabel     = self:NewUI(28, CLabel)
    self.m_RejectBtn                  = self:NewUI(29, CButton)
    self.m_RedPoint                   = self:NewUI(30, CSprite)
    self.m_BoomBG                     = self:NewUI(31, CSprite)
    self.m_BoomLabel                  = self:NewUI(32, CLabel)
    self.m_EditAimBtn                 = self:NewUI(33, CButton)
    self.m_SelfApplyTitleLabel        = self:NewUI(34, CLabel)
    self.m_OrgCashSlider              = self:NewUI(35, CSlider)
    self.m_OrgCashHintBtn             = self:NewUI(36, CSprite)
    self.m_EventScrollView            = self:NewUI(37, CScrollView)
    self.m_BoomTipBtn                 = self:NewUI(38, CButton)
    self.m_PrestigeL                  = self:NewUI(39, CLabel)
    self.m_PrestigeBgSpr              = self:NewUI(40, CSprite)
    self.m_EditNameBtn                = self:NewUI(41, CButton)
    self.m_SelfRecommendWaitLabel     = self:NewUI(42, CLabel)

    self.m_OrgId                         = 0
    self.m_LeaderId                      = 0
    self.m_SelfRecommendId               = 0
    self.m_SatisfySelfRecommendCondition = 0
    self.m_OldTime                       = 0
    self.m_MapLock = false  -- 回到驻地现在是返回地图 2040，只处理第一次点击
    self.m_PositionId = 0

    self:InitContent()
end

function COrgInfoPart.OnInitPage(self)
end

function COrgInfoPart.InitContent(self)
    self.m_BackToCampBtn          :AddUIEvent("click", callback(self, "OnBackToCamp"))
    self.m_XuetuIBtn              :AddUIEvent("click", callback(self, "OnShowXuetuTipView"))
    self.m_CloseSelfRecommendBtn  :AddUIEvent("click", callback(self, "OnCloseSelfRecommendContainer"))
    self.m_RejectBtn              :AddUIEvent("click", callback(self, "OnRejectSelfRecommend", false))
    self.m_SelfRecommendNameLabel :AddUIEvent("click", callback(self, "OnClickSelfRecommendNameLabel"))
    self.m_EditAimBtn             :AddUIEvent("click", callback(self, "OnEditAim"))
    self.m_BoomTipBtn             :AddUIEvent("click", callback(self, "OnShowBoomTipView"))
    self.m_PrestigeBgSpr          :AddUIEvent("click", callback(self, "OnShowPrestigeTip"))
    self.m_MailBtn                :AddUIEvent("click", callback(self, "OnSendOrgMail"))
    self.m_EditNameBtn            :AddUIEvent("click", callback(self, "OnEditName"))

    self.m_FormalMemberBG         :SetHint((callback(self, "InitHintFormalMember")))
    self.m_XuetuBG                :SetHint((callback(self, "InitHintXuetu")))
    self.m_OrgCashHintBtn         :AddUIEvent("click", callback(self, "InitHintCash"))
    g_UITouchCtrl:TouchOutDetect(self.m_SelfRecommendInfoContainer, callback(self, "OnCloseSelfRecommendContainer"))
    g_OrgCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnOrgEvent"))
    g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAttrEvent"))
    g_OrgCtrl:C2GSGetBuildInfo()
    self.m_RedPoint:SetActive(false)
    self:RefreshBaseInfo()
end

function COrgInfoPart.GetMainInfo(self, flag)
    netorg.C2GSOrgMainInfo(flag)
    netorg.C2GSOrgPrestigeInfo()
end

function COrgInfoPart.OnBackToCamp(self)
    -- local mapID = 204000
    -- if self.m_MapLock then
    --     return
    -- end
    -- self.m_MapLock = true
    -- local function showMap()
    --     self.m_MapLock = false
    --     g_MapCtrl:C2GSClickWorldMap(mapID)
    --     self.m_ParentView:CloseView()
    --     return false
    -- end
    -- Utils.AddTimer(showMap, 0.05, 0.4)
    if g_MapCtrl.m_IsMapLoadDone then
        g_OrgCtrl:C2GSEnterOrgScene()
    end 
    if self.m_ParentView then
        self.m_ParentView:OnClose()
    end
end

function COrgInfoPart.InitHintFormalMember(self)
    return g_AttrCtrl.org_pos <= 3 and data.orgdata.TEXT[1036].content or data.orgdata.TEXT[1142].content
end

function COrgInfoPart.InitHintXuetu(self)
    return g_AttrCtrl.org_pos <= 3 and data.orgdata.TEXT[1037].content or data.orgdata.TEXT[1143].content
end

function COrgInfoPart.InitHintCash(self)
   g_NotifyCtrl:FloatMsg("帮派资金上限"..self:GetCashMaxVal())
end

function COrgInfoPart.SetAim(self, aim)
    if aim == "" then
        self.m_AimLabel:SetText(data.orgdata.TEXT[1070].content)
    else
        self.m_AimLabel:SetText(aim)
    end
end

function COrgInfoPart.OnOrgEvent(self, callbackBase)
    local eventID = callbackBase.m_EventID
    local eventData = callbackBase.m_EventData
    if eventID == define.Org.Event.GetOrgMainInfo then
        self:RefreshBaseInfo()
    end
    if eventID == define.Org.Event.AddHistoryLog then
        self:RebuildEventList()
    end
    if eventID == define.Org.Event.NextPageLog then
        for k,v in pairs(eventData) do
             self:AddSingleOrgItem(v)
        end
        self:SetMoveCallBackIndex()
        self.m_Grid:Reposition()
    end
    if eventID == define.Org.Event.UpdatePrestige then
        self.m_PrestigeL:SetText(g_OrgCtrl.m_MyPrestige)
    end
end

function COrgInfoPart.OnAttrEvent(self, callbackBase)
    local eventID = callbackBase.m_EventID
    local eventData = callbackBase.m_EventData
    if eventID == define.Attr.Event.Change then
        if eventData.dAttr.org_pos then
            self:RefreshMailButton()
        end
    end
end

function COrgInfoPart.RefreshBaseInfo(self)
    self:RefreshAimButton()
    self:RefreshMailButton()   
    local org = g_OrgCtrl.m_Org
    if table.count(org) < 3 then
        return
    end
    self.m_OrgId = org.orgid
    self.m_LeaderId = org.leaderid

    self.m_SelfRecommendId = org.applypid
    self.m_SatisfySelfRecommendCondition = org.canapplyleader

    self.m_NameLabel            :SetText(org.name)
    self.m_LevelLabel           :SetText(org.level)
    self.m_IDLabel              :SetText(org.showid)
    self.m_LeaderNameLabel      :SetText(org.leadername)
    self.m_LeaderHeadSprite     :SpriteSchool(tonumber(org.leaderschool))

    if g_AttrCtrl.org_pos <= 3 then
        self.m_NumFormalMemberLabel :SetText(org.onlinemem .. "/" .. org.membercnt .. "/" .. org.maxmembercnt)
        self.m_NumXuetuLabel        :SetText(org.onlinexuetu .. "/" .. org.xuetucnt  .. "/" .. org.maxxuetucnt)
    else
        self.m_NumFormalMemberLabel :SetText(org.membercnt .. "/" .. org.maxmembercnt)
        self.m_NumXuetuLabel        :SetText(org.xuetucnt  .. "/" .. org.maxxuetucnt)
    end
    self:SetAim(org.aim)
    self:SetCashVal(org.cash)
    -- self.m_MaintainConsumeLabel :SetText(g_OrgCtrl:GetEverydayMaintainConsume())
    --self.m_MaintainConsumeLabel :SetText(0)
    self:UpdateBoom(org.boom)
    if org.info ~= nil then
        self.m_CurBanggongLabel      :SetText(g_AttrCtrl.org_offer)
        self.m_HistoryBanggongLabel  :SetText(org.info.hisoffer)
        self.m_PositionId = org.info.position
        self.m_JobLabel              :SetText(data.orgdata.POSITIONID[self.m_PositionId].name)
        self.m_TodayActiveLabel      :SetText(org.info.huoyue)
    end
    if org.applylefttime ~= nil then
        local sTime = g_OrgCtrl:ConvertSecondsStr(org.applylefttime)
        sTime = string.gsub(sTime, ":", "小时")
        self.m_LeftTimeLabel         :SetText(sTime.."分")
    end
    if org.applyschool ~= nil then
        self.m_SelfRecommendSchoolSprite:SpriteSchool(tonumber(org.applyschool))
    end
    --printc("帮派信息界面：OnOrgEvent，自荐人名字 = " .. tostring(org.applyname))
    if org.applyname ~= nil then
        self.m_SelfRecommendNameLabel    :SetText(org.applyname)
    end
    self:RebuildEventList()
    self:RefreshSelfRecommendLeaderBtn()
    self:RefreshSelfRecommendRedPoint() 
end

function COrgInfoPart.RefreshMailButton(self)
    local dAuthority = data.orgdata.POSITIONAUTHORITY[g_AttrCtrl.org_pos]
    self.m_MailBtn:SetActive(dAuthority.send_mail == 1)
    self.m_MailBtn:SetGrey(g_OrgCtrl.m_Org.left_mail_cnt == 0 or (g_OrgCtrl.m_LeftMailCD ~= nil and g_OrgCtrl.m_LeftMailCD > 0))
end

function COrgInfoPart.RefreshAimButton(self)
    self.m_EditAimBtn:SetGrey(g_OrgCtrl.m_LeftAimCD ~= nil and g_OrgCtrl.m_LeftAimCD > 0)
end

function COrgInfoPart.GetCashMaxVal(self)
    local buildStock = 0
    if g_OrgCtrl:GetBuildInfo(105).level ~= 0 then
        buildStock = data.orgdata.BUILDLEVEL[105][g_OrgCtrl:GetBuildInfo(105).level].effect1
    end
    local max = data.orgdata.OTHERS[1].init_cash + buildStock
    return max
end

function COrgInfoPart.SetCashVal(self, cash)
    local max = self:GetCashMaxVal()
    self.m_OrgCashSlider:SetValue(cash/max)
    self.m_CashLabel:SetText(cash)
    -- local dailyConsume = g_OrgCtrl:GetEverydayMaintainConsume()
    -- if cash < dailyConsume then
    --     self.m_CashLabel:SetColor(Color.red)
    -- else
    --     self.m_CashLabel:SetColor(Color.RGBAToColor("EEFFFB"))
    -- end
end

function COrgInfoPart.UpdateBoom(self, boom)
    local HuangWuMin    = data.orgdata.OTHERS[1].huang_wu_min
    local HuangWuMax    = data.orgdata.OTHERS[1].huang_wu_max
    local QingJingMin   = data.orgdata.OTHERS[1].qing_jing_min   
    local QingJingMax   = data.orgdata.OTHERS[1].qing_jing_max
    local ReNaoMin      = data.orgdata.OTHERS[1].re_nao_min      
    local ReNaoMax      = data.orgdata.OTHERS[1].re_nao_max  
    local FanHuaMin     = data.orgdata.OTHERS[1].fan_hua_min     
    local FanHuaMax     = data.orgdata.OTHERS[1].fan_hua_max 
    local ChangShengMin = data.orgdata.OTHERS[1].chang_sheng_min 
    local ChangShengMax = data.orgdata.OTHERS[1].chang_sheng_max

    -- 繁荣值
    self.m_BoomValLabel:SetText(boom)

    -- BG + 文字
    if HuangWuMin <= boom and boom <= HuangWuMax then
        self.m_BoomLabel:SetText("荒芜")
        self.m_BoomBG:SetSpriteName("h7_lan")
    elseif QingJingMin <= boom and boom <= QingJingMax then
        self.m_BoomLabel:SetText("清静")
        self.m_BoomBG:SetSpriteName("h7_zi")
    elseif ReNaoMin <= boom and boom <= ReNaoMax then
        self.m_BoomLabel:SetText("热闹")
        self.m_BoomBG:SetSpriteName("h7_zihong")
    elseif FanHuaMin <= boom and boom <= FanHuaMax then
        self.m_BoomLabel:SetText("繁华")
        self.m_BoomBG:SetSpriteName("h7_hong_xiao")
    elseif ChangShengMin <= boom and boom <= ChangShengMax then
        self.m_BoomLabel:SetText("昌盛")
        self.m_BoomBG:SetSpriteName("h7_cheng")
    end
end

function COrgInfoPart.RebuildEventList(self)
    -- printc("帮派信息界面：填充 ScrollView 数据")
    for k, event in pairs(g_OrgCtrl.m_Org.historys) do
        local item = self.m_Grid:GetChild(k)
        if item then
            item:SetActive(true)
            printc("事件"..k)
            item:SetBoxInfo(event)
        else
            printc("事件添加")
            self:AddSingleOrgItem(event)
        end
    end

    self.m_Grid:Reposition()
    self:SetMoveCallBackIndex()
    printc("添加新数据")
    table.print(g_OrgCtrl.m_Org.historys)
end

function COrgInfoPart.AddSingleOrgItem(self, event)
    -- printc("帮派信息界面：填充单条 ScrollView item 数据")
    if event == nil then
        return
    end
    local oItem = nil
    oItem = self.m_ItemClone:Clone(
        function()
            --self:ItemCallBack(event)
        end
    )
    oItem:SetActive(true)
    oItem:SetBoxInfo(event)
    self.m_Grid:AddChild(oItem)
    oItem:SetGroup(self.m_Grid:GetInstanceID())
    return oItem
end

function COrgInfoPart.SetMoveCallBackIndex(self)
    local count = self.m_Grid:GetCount()
    if count > 3 then
        count = count - 3
    end
    self.m_EventScrollView:SetCullContent(self.m_Grid, callback(self, "ShowNewInfo"), count)
end

function COrgInfoPart.ItemCallBack(self)

end

function COrgInfoPart.OnShowXuetuTipView(self)
    -- printc("帮派信息界面：显示学徒说明文字界面")
    local id = define.Instruction.Config.OrgXuetu
    local content = {
        title = data.instructiondata.DESC[id].title,
        desc  = data.instructiondata.DESC[id].desc
    }
    g_WindowTipCtrl:SetWindowInstructionInfo(content)
end

function COrgInfoPart.OnShowBoomTipView(self)
    -- printc("帮派信息界面：显示学徒说明文字界面")
    local id = define.Instruction.Config.OrgBoom
    local content = {
        title = data.instructiondata.DESC[id].title,
        desc  = data.instructiondata.DESC[id].desc
    }
    g_WindowTipCtrl:SetWindowInstructionInfo(content)
end

function COrgInfoPart.OnCloseSelfRecommendContainer(self)
    self.m_SelfRecommendInfoContainer:SetActive(false)
end

function COrgInfoPart.OnRejectSelfRecommend(self, IamXuetu)
    --printc("帮派信息界面：点击自荐反对, IamXuetu = " .. tostring(IamXuetu))
    if IamXuetu then
        g_NotifyCtrl:FloatMsg(data.orgdata.TEXT[1074].content)
        return
    end

    if g_OrgCtrl.m_Org.applylefttime ~= nil
        and g_OrgCtrl.m_Org.applylefttime <= 0 then
        g_NotifyCtrl:FloatMsg(data.orgdata.TEXT[1045].content)
        return
    end

    -- g_NotifyCtrl:FloatMsg(data.orgdata.TEXT[1044].content)
    self.m_SelfRecommendInfoContainer:SetActive(false)
    netorg.C2GSVoteOrgLeader(0)
end

function COrgInfoPart.OnClickSelfRecommendNameLabel(self)
    -- printc("帮派信息界面：点击自荐人名字")
    netplayer.C2GSGetPlayerInfo(self.m_SelfRecommendId)
end

function COrgInfoPart.OnEditAim(self)
    -- printc("帮派信息界面：点击编辑宗旨")
    -- 没有权限
    if not g_OrgCtrl:CanEditOrgAim() then
        g_NotifyCtrl:FloatMsg(data.orgdata.TEXT[1154].content)
        return
    end
    if g_OrgCtrl.m_LeftAimCD > 0 then
        local sText = data.orgdata.TEXT[4005].content 
        local sLeftTime = g_TimeCtrl:GetLeftTimeString(g_OrgCtrl.m_LeftAimCD)
        sText = string.gsub(sText, "#time", sLeftTime)
        g_NotifyCtrl:FloatMsg(sText)
        return
    end
    CEditOrgAimView:ShowView()
end

function COrgInfoPart.RefreshSelfRecommendLeaderBtn(self)
    --printc("帮派信息界面：刷新自荐为帮主 btn")
    if g_OrgCtrl:IamLeader() then
        --printc("我是帮主")
        if self:SomeoneHasApply() then
            --printc("有人自荐成功")
            self:SetSelfApplyBtnBlue()
            self.m_SelfRecommendLeaderBtn:AddUIEvent("click", callback(self, "OnShowSelfApplyWindow", true, false, false))
        else
            --printc("没人自荐成功")
            self:SetSelfApplyBtnGrey()
            self.m_SelfRecommendLeaderBtn:AddUIEvent("click", callback(self, "OnShowFloatMsgYouAreLeader"))
        end
    elseif g_OrgCtrl:IamXuetu() then
        --printc("我是学徒")
        if self:SomeoneHasApply() then
            --printc("有人自荐成功")
            self:SetSelfApplyBtnBlue()
            self.m_SelfRecommendLeaderBtn:AddUIEvent("click", callback(self, "OnShowSelfApplyWindow", true, false, true))
        else
            --printc("没人自荐成功")
            self:SetSelfApplyBtnGrey()
            self.m_SelfRecommendLeaderBtn:AddUIEvent("click", callback(self, "OnShowFloatMsgOnlyFormalMemberCanDo"))
        end
    else
        --printc("我不是帮主，且不是学徒")
        if self:SomeoneHasApply() then
            --printc("有人自荐成功")
            if self:IRecommendMyself() then
                --printc("自荐人是我自己")
                self:SetSelfApplyBtnBlue()
                self.m_SelfRecommendLeaderBtn:AddUIEvent("click", callback(self, "OnShowSelfApplyWindow", false, true, false))
            else
                --printc("自荐人不是我自己，是其他人")
                self:SetSelfApplyBtnBlue()
                self.m_SelfRecommendLeaderBtn:AddUIEvent("click", callback(self, "OnShowSelfApplyWindow", true, false, false))
            end
        else
            --printc("没人自荐成功")
            if self.m_SatisfySelfRecommendCondition == 1 then
                --printc("满足自荐条件")
                self:SetSelfApplyBtnBlue()
                self.m_SelfRecommendLeaderBtn:AddUIEvent("click", callback(self, "OnShowConfirmPayView"))
            else
                --printc("不满足自荐条件")
                self:SetSelfApplyBtnGrey()
                self.m_SelfRecommendLeaderBtn:AddUIEvent("click", callback(self, "OnShowFloatMsgRecommendAfterXHours"))
            end
        end
    end
end

-- 有人自荐（可能是自己）
function COrgInfoPart.SomeoneHasApply(self)
    return self.m_SelfRecommendId ~= nil and self.m_SelfRecommendId ~= 0
end

function COrgInfoPart.IRecommendMyself(self)
    return self.m_SelfRecommendId ~= nil
        and self.m_SelfRecommendId ~= 0
        and self.m_SelfRecommendId == g_AttrCtrl.pid
end

function COrgInfoPart.SetSelfApplyBtnBlue(self)
    self.m_SelfRecommendLeaderBtn:SetGrey(false)
end

function COrgInfoPart.SetSelfApplyBtnGrey(self)
    self.m_SelfRecommendLeaderBtn:SetGrey(true)
end

function COrgInfoPart.RefreshSelfRecommendRedPoint(self)
    local oView = COrgInfoView:GetView()
    local bShowRedPoint = self:SomeoneHasApply() and not self:IRecommendMyself()
    self.m_RedPoint:SetActive(bShowRedPoint)
    if oView then
        oView.m_InfoRedPoint:SetActive(bShowRedPoint)
    end
end

function COrgInfoPart.OnShowSelfApplyWindow(self, showRejectBtn, isMyself, IamXuetu)
    --printc("显示自荐小窗口: showRejectBtn = " .. tostring(showRejectBtn) .. ", isMyself = " .. tostring(isMyself) .. ", IamXuetu = " .. tostring(IamXuetu))
    self.m_SelfRecommendInfoContainer:SetActive(true)
    self.m_RejectBtn:SetActive(showRejectBtn)
    self.m_RejectBtn:AddUIEvent("click", callback(self, "OnRejectSelfRecommend", IamXuetu))
    -- self.m_SelfRecommendWaitLabel:SetActive(isMyself)
    self.m_SelfRecommendWaitLabel:SetActive(false)
    
    if isMyself then
        self.m_SelfApplyTitleLabel:SetText(data.orgdata.TEXT[1076].content)
    else
        self.m_SelfApplyTitleLabel:SetText(data.orgdata.TEXT[1075].content)
    end
end

function COrgInfoPart.OnShowConfirmPayView(self)
    local silverCost = data.orgdata.OTHERS[1].self_apply_sliver

    local windowConfirmInfo = {
        msg = string.gsub(data.orgdata.TEXT[1038].content, "#silver", silverCost) .. "\n" .. data.orgdata.TEXT[1039].content,
        pivot = enum.UIWidget.Pivot.Center,
        okCallback = function()
            -- printc("帮派信息界面：点击确定扣费自荐为帮主")
            if g_AttrCtrl.silver < silverCost then
                g_NotifyCtrl:FloatMsg(data.orgdata.TEXT[1040].content)
                -- 打开银币兑换
                -- CCurrencyView:ShowView(function (oView)
                --     oView:SetCurrencyView(define.Currency.Type.Silver)
                -- end)
                g_ShopCtrl:ShowAddMoney(define.Currency.Type.Silver)
            else
                netorg.C2GSApplyOrgLeader()
            end
        end
    }
    g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo, function (oView)
        self.m_WinTipViwe = oView
    end)
end

function COrgInfoPart.OnShowFloatMsgYouAreLeader(self)
    g_NotifyCtrl:FloatMsg(data.orgdata.TEXT[1042].content)
end

function COrgInfoPart.OnShowFloatMsgOnlyFormalMemberCanDo(self)
    g_NotifyCtrl:FloatMsg(data.orgdata.TEXT[1074].content)
end

function COrgInfoPart.OnShowFloatMsgRecommendAfterXHours(self)
    -- local hours = data.orgdata.OTHERS[1].leader_offline_time / 3600
    local hours = g_OrgCtrl:ConvertSecondsStrV2(data.orgdata.OTHERS[1].leader_offline_time)
    g_NotifyCtrl:FloatMsg(string.gsub(data.orgdata.TEXT[1043].content, "#offlinetime", hours))
end

function COrgInfoPart.ShowNewInfo(self)
    if self.m_OldTime == 0 or g_TimeCtrl:GetTimeS() - self.m_OldTime > 0.5 then        
       self.m_OldTime = g_TimeCtrl:GetTimeS() 
        g_OrgCtrl:C2GSNextPageLog()
    end
end

function COrgInfoPart.OnShowPrestigeTip(self)
    COrgPrestigeTipsView:ShowView()
end

function COrgInfoPart.OnSendOrgMail(self)
    if g_OrgCtrl.m_Org.left_mail_cnt == 0 then
        local sText = data.orgdata.TEXT[1174].content 
        local iMailTimes = data.orgdata.OTHERS[1].mail_times
        sText = string.gsub(sText, "#amount", iMailTimes)
        g_NotifyCtrl:FloatMsg(sText)
        return
    end
    if g_OrgCtrl.m_LeftMailCD > 0 then
        local sText = data.orgdata.TEXT[4006].content 
        local sLeftTime = g_TimeCtrl:GetLeftTimeString(g_OrgCtrl.m_LeftMailCD)
        sText = string.gsub(sText, "#time", sLeftTime)
        g_NotifyCtrl:FloatMsg(sText)
        return
    end
    CEditOrgMailView:ShowView() 
end

function COrgInfoPart.OnEditName(self)

end

return COrgInfoPart