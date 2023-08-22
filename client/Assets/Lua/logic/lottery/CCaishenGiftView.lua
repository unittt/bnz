local CCaishenGiftView = class("CCaishenGiftView", CViewBase)

function CCaishenGiftView.ctor(self,cb)
    CViewBase.ctor(self, "UI/Welfare/CCaishenGiftView.prefab", cb)
    self.m_DepthType = "Dialog"
    self.m_GroupName = "main"
    self.m_ExtendClose = "Black"
end

function CCaishenGiftView.OnCreateView(self)
    self.m_CloseBtn = self:NewUI(1, CButton)
    -- self.m_TipBtn = self:NewUI(2, CButton)
    self.m_TimeL = self:NewUI(3, CLabel)
    self.m_CntL = self:NewUI(4, CLabel)
    -- self.m_Tip1L = self:NewUI(5, CLabel)
    -- self.m_Tip2L = self:NewUI(6, CLabel)
    self.m_MoneyCntL = self:NewUI(7, CLabel)
    self.m_PlateBox = self:NewUI(8, CLotteryPlateBox)
    self.m_RecordBox = self:NewUI(9, CLotteryRecordBox)
    self.m_MoneyBanCntL = self:NewUI(10, CLabel)
    self:InitContent()
end

function CCaishenGiftView.InitContent(self)
    self.m_TimeL:SetText("")
    if g_LotteryCtrl.m_EndTime and g_LotteryCtrl.m_EndTime > 0 then
        local endTime = tonumber(g_LotteryCtrl.m_EndTime)
        -- local sTime = os.date("活动结束时间：%m月%d日", endTime)
        -- local iHour = tonumber(os.date("%H", endTime)) or 0
        -- self.m_TimeL:SetText(sTime..iHour.."点")
        local leftTime = math.max(endTime - g_TimeCtrl:GetTimeS(), 0)
        self.m_TimeL:SetColor(Color.white)
        self.m_TimeL:SetText("[63432C]活动剩余时间: [-][1D8E00]"..(g_TimeCtrl:GetLeftTimeDHM(leftTime or 0)))
        self:RefreshView()
    end
    self.m_MoneyCntL:SetText(string.getSegmentaStr(g_AttrCtrl:GetTrueGoldCoin()))
    self.m_MoneyBanCntL:SetText(string.getSegmentaStr(g_AttrCtrl.rplgoldcoin))
    g_LotteryCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnLotteryCtrlEvent"))
    g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAttrCtrlEvent"))
    self.m_PlateBox:AddClickEvent(callback(self, "OnClickLottery"))
    self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
    g_LotteryCtrl:SetClickCaishen()
    g_LotteryCtrl.m_LastRecordTime = 0
    self.m_RequestTimer = Utils.AddTimer(function()
        g_LotteryCtrl:AskForCaishenRecords()
        return true
    end, 5, 0)
end

function CCaishenGiftView.RefreshView(self)
    local iCurIdx = g_LotteryCtrl.m_CaishenCostIdx
    local iNextIdx = iCurIdx + 1
    local sGroup = g_LotteryCtrl.m_GroupKey
    self.m_CntL:SetText(g_LotteryCtrl.m_CaishenCount)
    local dNextCost = DataTools.GetCaishenData(iNextIdx, sGroup)
    if dNextCost then
        self.m_PlateBox:SetAmount(dNextCost.goldcoin)
    else
        local dCost = DataTools.GetCaishenData(iCurIdx, sGroup)
        if not dCost then return end
        self.m_PlateBox:SetAmount(dCost.goldcoin)
    end
    self.m_PlateBox:SetMidPartGrey(not dNextCost)
end

function CCaishenGiftView.OnPlayEnd(self, id)
    netother.C2GSCallback(id)
end

function CCaishenGiftView.OnClickLottery(self)
    if self.m_PlateBox:IsPlaying() then
        return
    end
    local id = (g_LotteryCtrl.m_CaishenCostIdx or 0) + 1
    local sGroup = g_LotteryCtrl.m_GroupKey
    local dCost = DataTools.GetCaishenData(id, sGroup)
    if dCost then
        local iTrueCnt = g_AttrCtrl:GetTrueGoldCoin()
        if iTrueCnt >= dCost.goldcoin then
            nethuodong.C2GSCaishenStartChoose(id)
        else
            g_NotifyCtrl:FloatMsg("元宝不足")
            CNpcShopMainView:ShowView(function(oView)
                oView:ShowSubPageByIndex(oView:GetPageIndex("Recharge"))
            end)
        end
    else
        g_NotifyCtrl:FloatMsg("您已经完成全部的祈福")
    end
end

function CCaishenGiftView.AddMsgList(self, msgList)
    local recordList = {}
    for i, v in ipairs(msgList) do
        table.insert(recordList, self:GetRecordMsg(v))
    end
    self.m_RecordBox:AddRecordList(recordList)
end

function CCaishenGiftView.GetRecordMsg(self, dRecord)
    local sMsg = "[244b4e][1d8e00]#role[-]在向财神祈福时，意外获得了[af302a]#amount[-]倍的元宝奖励！[-]"
    sMsg = string.FormatString(sMsg, {role = dRecord.name, amount = (dRecord.multiple or 0)/1000})
    return {msg = sMsg}
end

function CCaishenGiftView.OnLotteryCtrlEvent(self, oCtrl)
    if oCtrl.m_EventID == define.WelFare.Event.StartLottery then
        local iStart, iEnd = oCtrl.m_EventData.idx, oCtrl.m_EventData.sessionidx
        self.m_SendId = iEnd
        self.m_PlateBox:StartPlay(iStart, iEnd, callback(self, "OnPlayEnd", iEnd))
    elseif oCtrl.m_EventID == define.WelFare.Event.UpdateCaishenPnl then
        self:RefreshView()
    elseif oCtrl.m_EventID == define.WelFare.Event.ReceiveCaishenRecords then
        self:AddMsgList(oCtrl.m_EventData)
    end
end

function CCaishenGiftView.OnAttrCtrlEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Attr.Event.Change then
        if oCtrl.m_EventData.dAttr.goldcoin or oCtrl.m_EventData.dAttr.rplgoldcoin then
            self.m_MoneyCntL:SetText(string.getSegmentaStr(g_AttrCtrl:GetTrueGoldCoin()))
            self.m_MoneyBanCntL:SetText(string.getSegmentaStr(g_AttrCtrl.rplgoldcoin))
        end
    end
end

function CCaishenGiftView.Destroy(self)
    if self.m_RequestTimer then
        Utils.DelTimer(self.m_RequestTimer)
        self.m_RequestTimer = nil
    end
    if self.m_PlateBox:IsPlaying() then
        netother.C2GSCallback(self.m_SendId)
    end
    local oView = CTimelimitView:GetView()
    if oView and oView:GetTabCount() <= 1 then
        oView:OnClose()
    end
    CViewBase.Destroy(self)
end

function CCaishenGiftView.OnClose(self)
    self:CloseView()
    local oView = CTimelimitView:GetView()
    if oView then
        return
    end
    if g_HotTopicCtrl.m_SignCallback then
        g_HotTopicCtrl:m_SignCallback()
        g_HotTopicCtrl.m_SignCallback = nil
    end
end

return CCaishenGiftView