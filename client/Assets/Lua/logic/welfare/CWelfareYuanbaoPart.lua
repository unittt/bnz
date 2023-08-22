local CWelfareYuanbaoPart = class("CWelfareYuanbaoPart", CPageBase)

function CWelfareYuanbaoPart.ctor(self, cb)
    CPageBase.ctor(self,cb)

    self.m_FirstPack = self:NewUI(1,CBox)
    self.m_SecondPack = self:NewUI(2,CBox)

    self.m_BuyBtnTextColor = nil
    self.m_BoxDict = {}
    self.m_BanId = "goldcoin_gift_2"
end

function CWelfareYuanbaoPart.OnInitPage(self)
    self:InitBoxs()
    self:BanBox()
    g_WelfareCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
end

function CWelfareYuanbaoPart.InitBox(self, id)
    local oBox
    if id == "goldcoin_gift_1" then
        oBox = self.m_FirstPack
    elseif id == "goldcoin_gift_2" then
        oBox = self.m_SecondPack
    else
        printc("undefine gift id")
        return
    end
    oBox.titleLabel = oBox:NewUI(1,CLabel)
    oBox.priceLabel = oBox:NewUI(2,CLabel)
    oBox.firstGetLabel = oBox:NewUI(3,CLabel)
    oBox.totalLabel = oBox:NewUI(4,CLabel)
    oBox.buyButton = oBox:NewUI(5,CButton)
    oBox.buttonLabel = oBox:NewUI(6,CLabel)
    if not self.m_BuyBtnTextColor then
        self.m_BuyBtnTextColor = oBox.buttonLabel:GetColor()
    end
    oBox.dayLabel = oBox:NewUI(7,CLabel)
    oBox.dayGetLabel = oBox:NewUI(8,CLabel)
    oBox.btnRimImg = oBox:NewUI(9,CSprite)
    oBox.leftDayL = oBox:NewUI(10,CLabel)
    oBox.packId = id
    oBox.buttonLabel:SetText("")
    oBox.buyButton:AddUIEvent("click", callback(self, "OnClickBuy", id))
    return oBox
end

function CWelfareYuanbaoPart.InitBoxs(self)
    for id, info in pairs(DataTools.GetChargeData("YUANBAO")) do
        local sTotalAmount = string.ConvertToArt(info.days * info.goldcoin_after + info.goldcoin_first)
        local oBox = self.m_BoxDict[id]
        if not oBox then
            oBox = self:InitBox(id)
            self.m_BoxDict[id] = oBox
        end
        local state = g_WelfareCtrl:GetChargeItemInfo(info.key)
        oBox.config = info
        oBox.state = state
        oBox.titleLabel:SetText(string.format("%s日礼包", info.days))
        oBox.priceLabel:SetText(info.cost .. "元")
        oBox.firstGetLabel:SetText(info.goldcoin_first)-- .. "元宝")
        oBox.dayGetLabel:SetText(info.goldcoin_after)-- .. "元宝")
        oBox.totalLabel:SetRichText(sTotalAmount)
        oBox.dayLabel:SetText(info.days .. "日")
        oBox.payText = info.cost .. "元购买"
        oBox.getText = "领  取"
        local iDays = g_WelfareCtrl:GetChargeItemDays(id)
        self:SetBoxState(id, state, iDays)
    end
end

function CWelfareYuanbaoPart.BanBox(self)
    local iBan = g_WelfareCtrl:GetGoldCoinBanId()
    if not iBan then return end
    local oBox = self.m_BoxDict[iBan]
    if oBox then
        oBox:SetActive(false)
    end
end

function CWelfareYuanbaoPart.OnClickBuy(self, id)
    local oBox = self.m_BoxDict[id]
    if oBox then
        if not oBox.state then return end
        if oBox.state == define.WelFare.Status.Unobtainable then
            table.print(oBox.config, "元宝大礼充值回调数据信息")
            if oBox.config.payid and string.len(oBox.config.payid) > 0 then
                g_PayCtrl:Charge(oBox.config.payid)
            end
        elseif oBox.state == define.WelFare.Status.Get then
            nethuodong.C2GSChargeRewardGoldCoinGift(id)
        end
    end
end

function CWelfareYuanbaoPart.SetBoxState(self, boxId, state, iDays)
    local oBox = self.m_BoxDict[boxId]
    if not oBox then return end
    oBox.leftDayL:SetActive(iDays > 0)
    if iDays > 0 then
        oBox.leftDayL:SetText(string.format("(剩余领取天数：%d)",iDays))
    end
    local sBtnText = state == define.WelFare.Status.Unobtainable and oBox.payText or oBox.getText
    local bBtnEnable = not (state == define.WelFare.Status.Got)
    oBox.buttonLabel:SetText(sBtnText)
    oBox.buyButton:SetActive(bBtnEnable)--SetEnabled(bBtnEnable)
    if not bBtnEnable then
        oBox.btnRimImg:SetGrey(true)
        oBox.buttonLabel:SetColor(Color.RGBAToColor("50585B"))
    elseif oBox.state and oBox.state == define.WelFare.Status.Got then
        oBox.btnRimImg:SetGrey(false)
        oBox.buttonLabel:SetColor(self.m_BuyBtnTextColor)
    end
    oBox.state = state
end

function CWelfareYuanbaoPart.OnCtrlEvent(self, oCtrl)
    if oCtrl.m_EventID == define.WelFare.Event.UpdateYuanbaoPnl then
        if oCtrl.m_EventData then
            local days = 0
            for _, dInfo in ipairs(oCtrl.m_EventData) do
                days = g_WelfareCtrl:GetChargeItemDays(dInfo.key)
                self:SetBoxState(dInfo.key, dInfo.val, days)
            end
        end
    end
end

return CWelfareYuanbaoPart