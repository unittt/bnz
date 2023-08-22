local CWelfareLotteryPart = class("CWelfareLotteryPart", CPageBase)

function CWelfareLotteryPart.ctor(self, cb)
    CPageBase.ctor(self,cb)

    self.m_TimeL = self:NewUI(1, CLabel)
    self.m_MoneyCnt = self:NewUI(3, CLabel)
    -- for i=4, 11 do
    --     self["m_RewardItem"..i] = self:NewUI(i, CBox)
    -- end
    self.m_TurnWidget = self:NewUI(12, CWidget)
    self.m_LotteryBtn = self:NewUI(13, CTexture)
    self.m_SelObj = self:NewUI(14, CWidget)
    self.m_MoneyGreyCnt = self:NewUI(15, CLabel)
    self.m_MoneyIcon = self:NewUI(16, CSprite)
    self.m_LotteryNameIcon = self:NewUI(17, CSprite)
    self.m_Arrow = self:NewUI(18, CSprite)
    self.m_TipBtn = self:NewUI(19, CButton)

    self.m_IsRotating = false
end

function CWelfareLotteryPart.OnInitPage(self)
    -- local csConfig = DataTools.GetLotteryData("CAISHEN_CONFIG", 1)
    self.m_TimeL:SetText("")
    if g_LotteryCtrl.m_EndTime and g_LotteryCtrl.m_EndTime > 0 then
        local endTime = self:HandlerTimeStr(g_LotteryCtrl.m_EndTime)
        self.m_TimeL:SetText(endTime)
        self:SetGoldCoinText()
    end
    self.m_SelObj:SetActive(false)
    -- self.m_MoneyCnt:SetText(g_AttrCtrl:GetGoldCoin())
    g_LotteryCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnLotteryCtrlEvent"))
    -- g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAttrCtrlEvent"))
    self.m_LotteryBtn:AddUIEvent("click", callback(self, "OnClickLotteryBtn"))
    self.m_TipBtn:AddUIEvent("click", callback(self, "OnClickTipBtn"))
end

function CWelfareLotteryPart.HandlerTimeStr(self, sTime)
    -- local _, month, day, hour, min = sTime:match("^(%d+)%-(%d+)%-(%d+) (%d+)%:(%d+)%:(%d+)")
    return os.date("%m月%d日 %H:%M", tonumber(sTime))--string.format("%s月%s日 %s:%s", month, day, hour, min)
end

function CWelfareLotteryPart.OnClickLotteryBtn(self)
    if self.m_IsRotating then
        return
    end
    
    local rewardKey = (g_LotteryCtrl.m_CaishenCostIdx or 0) + 1
    local costConfig = DataTools.GetLotteryData("CAISHEN_COST", rewardKey)
    if costConfig then
        -- 使用非绑定元宝
        local iGoldCoin = g_AttrCtrl:GetTrueGoldCoin()
        if iGoldCoin >= costConfig.goldcoin then
            nethuodong.C2GSCaishenStartChoose(rewardKey)
        else
            g_NotifyCtrl:FloatMsg("元宝不足")
            CNpcShopMainView:ShowView(function(oView)
                oView:ShowSubPageByIndex(oView:GetPageIndex("Recharge"))
            end)
        end
    else
        g_NotifyCtrl:FloatMsg("已完成全部抽奖")
        -- nethuodong.C2GSCaishenStartChoose(rewardKey)
    end
end

function CWelfareLotteryPart.StartPlay(self, data)
    if not self.m_IsRotating then
        local rand = data.idx
        local degree = self:GetDegreeByIndex(rand)
        self.m_SelObj:SetActive(false)
        local tween = DOTween.DORotate(self.m_TurnWidget.m_Transform, Vector3.New(0, 0, degree + (-360 *2)), 2, 1)
        self.m_IsRotating = true
        local function onEnd()
            self:EndToPlayLottery(data.sessionidx)
            self.m_IsRotating = false
        end
        DOTween.OnComplete(tween, onEnd)
    end
end

function CWelfareLotteryPart.GetDegreeByIndex(self, index)
    local degree = ((2 * index) - 1) * 22.5 * -1
    return degree
end

function CWelfareLotteryPart.EndToPlayLottery(self, sessionId)
    self.m_SelObj:SetActive(true)
    netother.C2GSCallback(sessionId)
end

function CWelfareLotteryPart.SetGoldCoinText(self)
    local nextIdx = g_LotteryCtrl.m_CaishenCostIdx + 1
    local costConfig = DataTools.GetLotteryData("CAISHEN_COST", nextIdx)
    if costConfig then
        self.m_MoneyCnt:SetText(costConfig.goldcoin)
    else
        local curConfig = DataTools.GetLotteryData("CAISHEN_COST", g_LotteryCtrl.m_CaishenCostIdx)
        self.m_LotteryBtn:SetColor(Color.New(0,0,0,1))
        self.m_MoneyCnt:SetActive(false)
        self.m_MoneyGreyCnt:SetText(curConfig.goldcoin)
        self.m_MoneyGreyCnt:SetActive(true)
        self.m_LotteryNameIcon:SetColor(Color.New(0,0,0,1))
        self.m_MoneyIcon:SetColor(Color.New(0,0,0,1))
        self.m_Arrow:SetColor(Color.New(0,0,0,1))
    end
end

function CWelfareLotteryPart.OnClickTipBtn(self)
    local instructionConfig = data.instructiondata.DESC[10027]
    if instructionConfig then
        local zContent = {
            title = instructionConfig.title,
            desc = instructionConfig.desc,
        }
        g_WindowTipCtrl:SetWindowInstructionInfo(zContent)
    end
end

function CWelfareLotteryPart.OnLotteryCtrlEvent(self, oCtrl)
    if oCtrl.m_EventID == define.WelFare.Event.StartLottery then
        self:StartPlay(oCtrl.m_EventData)
    elseif oCtrl.m_EventID == define.WelFare.Event.UpdateCaishenPnl then
        self:SetGoldCoinText()
    end
end

function CWelfareLotteryPart.OnAttrCtrlEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Attr.Event.Change then
        if oCtrl.m_EventData.dAttr.goldcoin or oCtrl.m_EventData.dAttr.rplgoldcoin then
            self.m_MoneyCnt:SetText(g_AttrCtrl:GetGoldCoin())
        end
    end
end

return CWelfareLotteryPart